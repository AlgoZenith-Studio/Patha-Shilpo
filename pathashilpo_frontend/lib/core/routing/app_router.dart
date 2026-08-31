import 'package:flutter/material.dart';

import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/phone_login_screen.dart';
import '../../features/auth/screens/role_select_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/seller/add_product/add_product_flow.dart';
import '../../features/seller/home/artisan_home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../i18n/generated/app_localizations.dart';
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
      // The buyer shell is owned by a separate contributor (PRD.md §5.6).
      Routes.buyerExplore => const _NotInThisWorkstream(),
      _ => const _UnknownRoute(),
    };

    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }
}

class _NotInThisWorkstream extends StatelessWidget {
  const _NotInThisWorkstream();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.buyerShellTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.construction_rounded, size: 48),
              const SizedBox(height: 16),
              Text(
                t.buyerNotInWorkstream,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                t.buyerNotInWorkstreamBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
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
