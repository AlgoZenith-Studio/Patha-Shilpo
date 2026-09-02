import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/rbac/role.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/brand/app_logo.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/buttons/primary_bilingual_button.dart';
import '../controllers/auth_controller.dart';

/// First-login role selection — TRD.md §5.1 step 3, mvp §1.5.
///
/// Shown once. The choice is written to `users/{uid}` and is **immutable
/// afterwards**. Labels render in the language selected in Settings.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AuthController auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
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
                      const SizedBox(height: 8),
                      // Language first: everything below this renders in
                      // whichever of the three is selected, and Settings is
                      // still two screens away at this point.
                      const LanguageSwitcher(),
                      const Spacer(),
                      const Center(
                        child: AppLogo(size: 72, showBackground: true),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.roleQuestion,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 40),

                      PrimaryBilingualButton(
                        label: t.roleIMakeThings,
                        icon: Icons.handyman_rounded,
                        onPressed: auth.busy
                            ? null
                            : () => _choose(context, UserRole.artisan),
                      ),
                      const SizedBox(height: 16),
                      PrimaryBilingualButton(
                        label: t.roleIWantToBuy,
                        icon: Icons.shopping_bag_rounded,
                        onPressed: auth.busy
                            ? null
                            : () => _choose(context, UserRole.buyer),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        t.roleChooseOnce,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontFamilyFallback: AppTheme.scriptFallback,
                          fontSize: 13,
                          color: AppColors.border,
                        ),
                      ),
                      const Spacer(),
                      if (auth.busy)
                        const LinearProgressIndicator(minHeight: 2),
                      const SizedBox(height: 24),
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

  Future<void> _choose(BuildContext context, UserRole role) async {
    final NavigatorState navigator = Navigator.of(context);
    if (role == UserRole.artisan) {
      navigator.pushNamed(Routes.artisanRegistration);
    } else {
      await context.read<AuthController>().chooseRole(role);
      if (!context.mounted) return;
      navigator.pushNamedAndRemoveUntil(
        Routes.buyerExplore,
        (_) => false,
      );
    }
  }
}
