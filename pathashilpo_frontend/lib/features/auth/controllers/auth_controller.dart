import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/rbac/role.dart';
import '../../../data/local/session_box.dart';
import '../../../data/models/artisan_model.dart';
import '../../../data/models/buyer_model.dart';
import '../../../data/remote/auth_service.dart';
import '../../../data/remote/firestore_service.dart';

enum AuthStage { signedOut, awaitingOtp, needsRole, ready }

/// Auth state for the artisan & buyer shells.
///
/// Connects to Firebase Phone Auth and Firestore user profiles (TRD.md §5.1).
class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStage _stage = AuthStage.signedOut;
  String? _phone;
  String? _verificationId;
  UserRole? _role;
  String? _errorKey;
  bool _busy = false;

  AuthStage get stage => _stage;
  String? get phone => _phone;
  UserRole? get role => _role;
  String? get errorKey => _errorKey;
  bool get busy => _busy;
  User? get currentUser => _authService.currentUser;

  /// Initialises session on app launch from active Firebase Auth session & Firestore profile
  Future<void> initSession() async {
    final user = _authService.currentUser;
    if (user == null) {
      _stage = AuthStage.signedOut;
      _phone = null;
      _role = null;
      _errorKey = null;
      notifyListeners();
      return;
    }
    _phone = user.phoneNumber;
    await _onAuthSuccess();
  }

  /// TRD.md §5.1 step 1–2. Starts live Firebase Phone Verification.
  Future<void> submitPhone(String raw) async {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      _errorKey = 'errorInvalidPhone';
      notifyListeners();
      return;
    }

    _busy = true;
    _errorKey = null;
    notifyListeners();

    _phone = '+91$digits';

    try {
      await _authService.verifyPhone(
        phoneNumber: _phone!,
        onCodeSent: (String verId, int? resendToken) {
          _verificationId = verId;
          _stage = AuthStage.awaitingOtp;
          _busy = false;
          notifyListeners();
        },
        onVerificationFailed: (FirebaseAuthException error) {
          _busy = false;
          _errorKey = error.message ?? 'errorVerificationFailed';
          notifyListeners();
        },
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval / instant verification on Android
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            await _onAuthSuccess();
          } catch (e) {
            _busy = false;
            _errorKey = e.toString();
            notifyListeners();
          }
        },
        onCodeAutoRetrievalTimeout: (String verId) {
          _verificationId = verId;
        },
      );
    } catch (e) {
      _busy = false;
      _errorKey = e.toString();
      notifyListeners();
    }
  }

  /// TRD.md §5.1 step 2–3. Verifies the OTP with Firebase Auth.
  Future<void> submitOtp(String code) async {
    final String cleanCode = code.replaceAll(RegExp(r'\D'), '');
    if (cleanCode.length != 6) {
      _errorKey = 'errorInvalidOtp';
      notifyListeners();
      return;
    }

    _busy = true;
    _errorKey = null;
    notifyListeners();

    try {
      if (_verificationId != null) {
        await _authService.signInWithOtp(
          verificationId: _verificationId!,
          smsCode: cleanCode,
        );
        await _onAuthSuccess();
      } else {
        // No verificationId means the phone step never completed, so there is
        // nothing to verify against. Previously this fell through to
        // needsRole, which let an unauthenticated user into the app. Fail
        // closed instead.
        _busy = false;
        _errorKey = 'errorVerificationExpired';
        notifyListeners();
      }
    } catch (e) {
      _busy = false;
      _errorKey = e.toString();
      notifyListeners();
    }
  }

  /// Sign in with Google Account
  Future<void> signInWithGoogle() async {
    _busy = true;
    _errorKey = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null && credential.user != null) {
        await _onAuthSuccess();
      } else {
        _busy = false;
        notifyListeners();
      }
    } catch (e) {
      _busy = false;
      _errorKey = e.toString();
      notifyListeners();
    }
  }

  /// Checks Firestore profile to see if user has an existing role or needs first-time role selection
  Future<void> _onAuthSuccess() async {
    final user = _authService.currentUser;
    if (user == null) {
      _stage = AuthStage.signedOut;
      _busy = false;
      notifyListeners();
      return;
    }

    try {
      // 1. Check local session cache first for fast offline response
      final cachedRole = const SessionBox().role;
      if (cachedRole != null) {
        _role = cachedRole == 'buyer' ? UserRole.buyer : UserRole.artisan;
        _stage = AuthStage.ready;
      }

      // 2. Fetch authoritative user document from Firestore
      final doc = await _firestoreService.getUser(user.uid);
      if (doc.exists && doc.data() != null && doc.data()!['role'] != null) {
        final String r = doc.data()!['role'];
        final resolvedRole = r == 'buyer' ? UserRole.buyer : UserRole.artisan;

        if (resolvedRole == UserRole.artisan) {
          final artisanProfile = await _firestoreService.getArtisan(user.uid);
          if (artisanProfile != null) {
            // Completed artisan registration
            _role = UserRole.artisan;
            _stage = AuthStage.ready;
            await const SessionBox().setRole('artisan');
          } else {
            // Role selected but artisan registration steps incomplete
            _role = UserRole.artisan;
            _stage = AuthStage.needsRole;
          }
        } else {
          // Buyer profile
          _role = UserRole.buyer;
          _stage = AuthStage.ready;
          await const SessionBox().setRole('buyer');
          await ensureBuyerProfile();
        }
      } else {
        // New user (new Gmail or new phone) without registration
        _stage = AuthStage.needsRole;
      }
    } catch (_) {
      if (_role != null) {
        _stage = AuthStage.ready;
      } else {
        _stage = AuthStage.needsRole;
      }
    }

    _busy = false;
    notifyListeners();
  }

  /// Creates `buyers/{uid}` if the signed-in buyer has no profile document.
  ///
  /// [chooseRole] writes `users/{uid}` and `buyers/{uid}` as two separate
  /// calls and swallows failures for offline resilience, so a buyer could end
  /// up with a role but no profile. Every buyer screen reads the profile, and
  /// a missing one made the app tell an already-signed-in buyer to "sign in as
  /// a buyer". This repairs that on the next successful launch.
  ///
  /// Safe to call repeatedly: it reads first and only writes when absent, so
  /// it never overwrites a profile the buyer has since filled in.
  Future<void> ensureBuyerProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;
    try {
      if (await _firestoreService.getBuyer(user.uid) != null) return;
      await _firestoreService.saveBuyerProfile(
        BuyerModel(
          uid: user.uid,
          name: user.displayName?.trim().isNotEmpty == true
              ? user.displayName!
              : 'Buyer ${user.phoneNumber != null && user.phoneNumber!.length >= 4 ? user.phoneNumber!.substring(user.phoneNumber!.length - 4) : ""}'
                  .trim(),
          phone: user.phoneNumber ?? '',
          email: user.email,
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // Still offline. The next launch tries again; nothing is lost.
    }
  }

  /// TRD.md §5.1 step 4. Writes role to Firestore
  Future<void> chooseRole(UserRole role) async {
    if (!UserRole.selectableAtSignup.contains(role)) {
      throw ArgumentError.value(role, 'role', 'not selectable at signup');
    }

    final user = _authService.currentUser;
    if (user == null) {
      _errorKey = 'errorNotSignedIn';
      _stage = AuthStage.signedOut;
      notifyListeners();
      return;
    }

    _busy = true;
    notifyListeners();

    _role = role;
    try {
      if (role == UserRole.artisan) {
        // Initialize base artisan document
        await _firestoreService.saveArtisanProfile(
          ArtisanModel(
            uid: user.uid,
            name:
                'Artisan ${user.phoneNumber?.substring(user.phoneNumber!.length - 4) ?? ""}',
            nameHi: 'कारीगर',
            village: 'Chanderi',
            district: 'Ashoknagar',
            state: 'Madhya Pradesh',
            craft: 'Handloom',
            cluster: 'Chanderi Cluster',
            story: 'Traditional artisan preserving heritage handiwork.',
            storyHi: 'पारंपरिक विरासत हस्तशिल्प को संरक्षित करने वाले कारीगर।',
            yearsOfPractice: 5,
            createdAt: DateTime.now(),
          ),
        );
        await const SessionBox().setRole('artisan');
      } else {
        // Initialize base buyer document
        await _firestoreService.saveBuyerProfile(
          BuyerModel(
            uid: user.uid,
            name:
                'Buyer ${user.phoneNumber?.substring(user.phoneNumber!.length - 4) ?? ""}',
            phone: user.phoneNumber ?? '',
            createdAt: DateTime.now(),
          ),
        );
        await const SessionBox().setRole('buyer');
      }
    } catch (_) {
      // Offline resilience: the role is cached locally and the profile write
      // is retried by [ensureBuyerProfile] on the next launch. Without that
      // retry a buyer ended up with users/{uid}.role == 'buyer' but no
      // buyers/{uid} document, and every buyer screen then told a signed-in
      // buyer to "sign in as a buyer".
    }

    _stage = AuthStage.ready;
    _busy = false;
    notifyListeners();
  }

  /// Registers and saves a complete Artisan Profile in Firestore
  Future<void> registerArtisanProfile(ArtisanModel artisan) async {
    _busy = true;
    notifyListeners();

    try {
      await _firestoreService.saveArtisanProfile(artisan);
      _role = UserRole.artisan;
      _stage = AuthStage.ready;
      await const SessionBox().setRole('artisan');
    } catch (e) {
      _errorKey = e.toString();
    }

    _busy = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await const SessionBox().clearRole();
    _stage = AuthStage.signedOut;
    _phone = null;
    _verificationId = null;
    _role = null;
    _errorKey = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorKey == null) return;
    _errorKey = null;
    notifyListeners();
  }
}
