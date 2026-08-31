import 'package:flutter/material.dart';

import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/phone_login_screen.dart';
import '../../features/auth/screens/role_select_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/seller/add_product/add_product_flow.dart';
import '../../features/seller/home/artisan_home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../i18n/generated/app_localizations.dart';
import '../widgets/layout/buyer_shell.dart';
import 'route_names.dart';

/// Central route factory (TRD.md §11.3).
///
/// The role prefixes let a guard pick a shell. That guard is **cosmetic** —
/// the authoritative check is the Firestore Security Rules (TRD.md §5.2).
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      Routes.splash => const SplashScreen(),
      Routes.login => const PhoneLoginScreen(),
      Routes.otp => const OtpVerifyScreen(),
      Routes.roleSelect => const RoleSelectScreen(),
      Routes.artisanHome => const ArtisanHomeScreen(),
      Routes.artisanAddProduct => const AddProductFlow(),
      Routes.settings => const SettingsScreen(),
      // BuyerShell hosts its own bottom-nav and all buyer tabs internally,
      // so a single route entry covers the whole buyer module.
      Routes.buyerExplore => const BuyerShell(),
      _ => const _UnknownRoute(),
    };

    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Text(
          t.commonNotFound,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
