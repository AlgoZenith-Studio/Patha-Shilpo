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

/// OTP entry — TRD.md §5.1 step 2.
class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AuthController auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: Text(t.authEnterCode)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 24),
                      Text(t.authOtpTitle,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        t.authSentTo(auth.phone ?? ''),
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontFamilyFallback: AppTheme.scriptFallback,
                          fontSize: 14,
                          color: AppColors.border,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        onChanged: (_) => auth.clearError(),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontFamilyFallback: AppTheme.scriptFallback,
                          fontSize: 30,
                          letterSpacing: 12,
                          color: AppColors.ink,
                        ),
                        decoration: const InputDecoration(counterText: ''),
                      ),
                      if (auth.errorKey != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(t.authOtpInvalid,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.heritage.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(t.authDemoNotice,
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const Spacer(),
                      PrimaryBilingualButton(
                        label: t.authVerify,
                        onPressed: auth.busy ? null : _submit,
                      ),
                      const SizedBox(height: 12),
                      if (auth.busy)
                        const LinearProgressIndicator(minHeight: 2),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final AuthController auth = context.read<AuthController>();
    final NavigatorState navigator = Navigator.of(context);

    await auth.submitOtp(_controller.text);
    if (!mounted) return;

    if (auth.stage == AuthStage.ready) {
      if (auth.role == UserRole.artisan) {
        navigator.pushNamedAndRemoveUntil(Routes.artisanHome, (_) => false);
      } else {
        navigator.pushNamedAndRemoveUntil(Routes.buyerExplore, (_) => false);
      }
    } else if (auth.stage == AuthStage.needsRole) {
      navigator.pushNamedAndRemoveUntil(Routes.roleSelect, (_) => false);
    }
  }
}
