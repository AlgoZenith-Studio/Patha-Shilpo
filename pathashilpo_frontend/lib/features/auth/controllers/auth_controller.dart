import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/rbac/role.dart';
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
        // Fallback for emulator / stub testing
        _stage = AuthStage.needsRole;
        _busy = false;
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
      final doc = await _firestoreService.getUser(user.uid);
      if (doc.exists && doc.data() != null && doc.data()!['role'] != null) {
        final String r = doc.data()!['role'];
        _role = r == 'buyer' ? UserRole.buyer : UserRole.artisan;
        _stage = AuthStage.ready;
      } else {
        _stage = AuthStage.needsRole;
      }
    } catch (_) {
      _stage = AuthStage.needsRole;
    }

    _busy = false;
    notifyListeners();
  }

  /// TRD.md §5.1 step 4. Writes role to Firestore
  Future<void> chooseRole(UserRole role) async {
    if (!UserRole.selectableAtSignup.contains(role)) {
      throw ArgumentError.value(role, 'role', 'not selectable at signup');
    }

    _busy = true;
    notifyListeners();

    _role = role;
    final user = _authService.currentUser;
    if (user != null) {
      try {
        if (role == UserRole.artisan) {
          // Initialize base artisan document
          await _firestoreService.saveArtisanProfile(
            // Stub template that artisan can edit in Profile
            ArtisanModel(
              uid: user.uid,
              name: 'Artisan ${user.phoneNumber?.substring(user.phoneNumber!.length - 4) ?? ""}',
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
        } else {
          // Initialize base buyer document
          await _firestoreService.saveBuyerProfile(
            BuyerModel(
              uid: user.uid,
              name: 'Buyer ${user.phoneNumber?.substring(user.phoneNumber!.length - 4) ?? ""}',
              phone: user.phoneNumber ?? '',
              createdAt: DateTime.now(),
            ),
          );
        }
      } catch (_) {
        // Fallback for offline resilience
      }
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
    } catch (e) {
      _errorKey = e.toString();
    }

    _busy = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
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
