import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/rbac/role.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/buttons/primary_bilingual_button.dart';
import '../controllers/auth_controller.dart';

/// Premium Heritage Login Screen supporting Phone OTP and Google Sign-In.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AuthController auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: <Widget>[
          // Background Heritage Craft Artwork
          Positioned.fill(
            child: Image.asset(
              'assets/data/login_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.canvas),
            ),
          ),

          // Gradient overlay for readability and heritage mood
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColors.canvas.withValues(alpha: 0.40),
                    AppColors.canvas.withValues(alpha: 0.75),
                    AppColors.canvas.withValues(alpha: 0.96),
                  ],
                  stops: const <double>[0.0, 0.45, 0.85],
                ),
              ),
            ),
          ),

          // Main Interactive Content
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 20),

                          // App Branding / Heritage Header
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border, width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(Icons.palette_outlined, color: AppColors.action, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'PATHA-SHILPO',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Heading
                          Text(
                            t.authPhoneTitle,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your mobile number to receive a secure OTP code.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                          ),

                          const SizedBox(height: 28),

                          // Glassmorphic Phone Input Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.ink.withValues(alpha: 0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          height: 56,
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.canvas,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppColors.border,
                                              width: AppShape.hairline,
                                            ),
                                          ),
                                          child: Text(
                                            '🇮🇳 +91',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextField(
                                            controller: _phoneController,
                                            keyboardType: TextInputType.phone,
                                            autofocus: false,
                                            maxLength: 10,
                                            onChanged: (_) => auth.clearError(),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            style: const TextStyle(
                                              fontFamily: AppTheme.bodyFont,
                                              fontFamilyFallback: AppTheme.scriptFallback,
                                              fontSize: 20,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.ink,
                                            ),
                                            decoration: InputDecoration(
                                              counterText: '',
                                              hintText: t.authPhoneHint,
                                              filled: true,
                                              fillColor: AppColors.canvas,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (auth.errorKey != null) ...<Widget>[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.red.shade200),
                                        ),
                                        child: Text(
                                          auth.errorKey!,
                                          style: TextStyle(
                                            color: Colors.red.shade800,
                                            fontSize: 13,
                                            fontFamily: AppTheme.bodyFont,
                                          ),
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 20),

                                    PrimaryBilingualButton(
                                      label: t.authSendCode,
                                      onPressed: auth.busy ? null : _submitPhone,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider with "OR"
                          Row(
                            children: <Widget>[
                              const Expanded(child: Divider(color: AppColors.border)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: TextStyle(
                                    fontFamily: 'Pally',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: AppColors.border)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google Sign In Button
                          OutlinedButton(
                            onPressed: auth.busy ? null : _submitGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              side: const BorderSide(color: AppColors.border, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                // Google Logo icon
                                Image.network(
                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                  width: 22,
                                  height: 22,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.g_mobiledata_rounded,
                                    color: AppColors.ink,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          if (auth.busy)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: CircularProgressIndicator(color: AppColors.action),
                              ),
                            ),

                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'Preserving India\'s Master Crafts · Fair-Wage Verified',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPhone() async {
    final AuthController auth = context.read<AuthController>();
    final NavigatorState navigator = Navigator.of(context);

    await auth.submitPhone(_phoneController.text);
    if (!mounted) return;

    if (auth.stage == AuthStage.awaitingOtp) {
      navigator.pushNamed(Routes.otp);
    }
  }

  Future<void> _submitGoogle() async {
    final AuthController auth = context.read<AuthController>();
    final NavigatorState navigator = Navigator.of(context);

    await auth.signInWithGoogle();
    if (!mounted) return;

    if (auth.stage == AuthStage.ready) {
      if (auth.role == UserRole.artisan) {
        navigator.pushNamedAndRemoveUntil(Routes.artisanHome, (_) => false);
      } else {
        navigator.pushNamedAndRemoveUntil(Routes.buyerExplore, (_) => false);
      }
    } else if (auth.stage == AuthStage.needsRole) {
      navigator.pushNamed(Routes.roleSelect);
    }
  }
}
