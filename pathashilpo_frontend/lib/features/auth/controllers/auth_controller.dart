import 'package:flutter/foundation.dart';

import '../../../core/rbac/role.dart';

enum AuthStage { signedOut, awaitingOtp, needsRole, ready }

/// Auth state for the artisan shell.
///
/// **Stubbed.** Firebase is not initialised yet (`firebase_options.dart` and
/// `google-services.json` do not exist), so this holds state in memory and
/// accepts any six-digit OTP. The screens below are written against this
/// interface so swapping in `firebase_auth.verifyPhoneNumber` later touches
/// only this file.
///
/// Nothing here is a security boundary. Authorisation is enforced by the
/// Firestore Security Rules (TRD.md §5.2); the client copy of the role exists
/// purely to pick a shell.
class AuthController extends ChangeNotifier {
  AuthStage _stage = AuthStage.signedOut;
  String? _phone;
  UserRole? _role;
  String? _errorKey;
  bool _busy = false;

  AuthStage get stage => _stage;
  String? get phone => _phone;
  UserRole? get role => _role;
  String? get errorKey => _errorKey;
  bool get busy => _busy;

  /// TRD.md §5.1 step 1–2. Any 10-digit Indian number is accepted by the stub.
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

    await Future<void>.delayed(const Duration(milliseconds: 600));

    _phone = '+91$digits';
    _stage = AuthStage.awaitingOtp;
    _busy = false;
    notifyListeners();
  }

  /// TRD.md §5.1 step 2–3. The stub accepts any six digits.
  Future<void> submitOtp(String code) async {
    if (code.replaceAll(RegExp(r'\D'), '').length != 6) {
      _errorKey = 'errorInvalidOtp';
      notifyListeners();
      return;
    }

    _busy = true;
    _errorKey = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 600));

    // A returning user would already have users/{uid}.role; the stub always
    // routes to role selection so the flow stays demonstrable.
    _stage = AuthStage.needsRole;
    _busy = false;
    notifyListeners();
  }

  /// TRD.md §5.1 step 4. The role is **immutable after first write** — the
  /// Security Rules enforce that; this only mirrors it locally.
  Future<void> chooseRole(UserRole role) async {
    if (!UserRole.selectableAtSignup.contains(role)) {
      throw ArgumentError.value(role, 'role', 'not selectable at signup');
    }

    _busy = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 400));

    _role = role;
    _stage = AuthStage.ready;
    _busy = false;
    notifyListeners();
  }

  void signOut() {
    _stage = AuthStage.signedOut;
    _phone = null;
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
