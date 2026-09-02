import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/rbac/role.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../controllers/auth_controller.dart';

import '../../../core/widgets/brand/app_logo.dart';

/// Splash — decides the destination (TRD.md §11.3).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    final AuthController auth = context.read<AuthController>();
    await auth.initSession();
    if (!mounted) return;

    final String next = switch ((auth.stage, auth.role)) {
      (AuthStage.ready, UserRole.artisan) => Routes.artisanHome,
      (AuthStage.ready, UserRole.buyer) => Routes.buyerExplore,
      (AuthStage.needsRole, _) => Routes.roleSelect,
      _ => Routes.login,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(next, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AppLogo(
              size: 100,
              showBackground: true,
            ),
            const SizedBox(height: 24),
            Text(t.appName, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(t.appTagline, style: AppTheme.story),
            const SizedBox(height: 48),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.action,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
