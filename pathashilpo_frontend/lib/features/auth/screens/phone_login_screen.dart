import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/buttons/primary_bilingual_button.dart';
import '../controllers/auth_controller.dart';

/// Phone entry — TRD.md §5.1 step 1.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
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
      appBar: AppBar(title: Text(t.authSignIn)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 24),
              Text(t.authPhoneTitle,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),

              Row(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppShape.cardRadius),
                      border: Border.all(
                        color: AppColors.border,
                        width: AppShape.hairline,
                      ),
                    ),
                    child: Text('+91',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      maxLength: 10,
                      onChanged: (_) => auth.clearError(),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontFamilyFallback: AppTheme.scriptFallback,
                        fontSize: 22,
                        letterSpacing: 2,
                        color: AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: t.authPhoneHint,
                      ),
                    ),
                  ),
                ],
              ),

              if (auth.errorKey != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(t.authPhoneInvalid,
                    style: Theme.of(context).textTheme.bodySmall),
              ],

              const Spacer(),
              PrimaryBilingualButton(
                label: t.authSendCode,
                onPressed: auth.busy ? null : _submit,
              ),
              const SizedBox(height: 12),
              if (auth.busy) const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final AuthController auth = context.read<AuthController>();
    final NavigatorState navigator = Navigator.of(context);

    await auth.submitPhone(_controller.text);
    if (!mounted) return;

    if (auth.stage == AuthStage.awaitingOtp) {
      navigator.pushNamed(Routes.otp);
    }
  }
}
