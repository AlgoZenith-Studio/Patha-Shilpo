import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/generated/app_localizations.dart';
import '../../core/rbac/role.dart';
import '../../core/theme/colors.dart';
import '../auth/controllers/auth_controller.dart';

/// Plain-language explanation of what the app does — and, just as importantly,
/// what it does not do.
///
/// Two audiences see different sections: an artisan needs to know how their
/// price is built and that their identity number is never stored; a buyer needs
/// to know there is no checkout and why. Showing both sets to everyone would
/// bury the part that matters to each.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AuthController auth = context.watch<AuthController>();
    final bool isBuyer = auth.role == UserRole.buyer;

    return Scaffold(
      appBar: AppBar(title: Text(t.infoTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: <Widget>[
          _Section(
            icon: Icons.info_outline_rounded,
            title: t.infoWhatThisIs,
            body: t.infoWhatThisIsBody,
          ),

          if (isBuyer) ...<Widget>[
            _Section(
              icon: Icons.explore_outlined,
              title: t.infoBuyerWhat,
              body: t.infoBuyerWhatBody,
            ),
            _Section(
              icon: Icons.balance_rounded,
              title: t.infoFairTrade,
              body: t.infoFairTradeBody,
            ),
            _Section(
              icon: Icons.payments_outlined,
              title: t.infoBuyerNoCheckout,
              body: t.infoBuyerNoCheckoutBody,
              emphasised: true,
            ),
          ] else ...<Widget>[
            _Section(
              icon: Icons.calculate_outlined,
              title: t.infoHowPricing,
              body: t.infoHowPricingBody,
            ),
            _Section(
              icon: Icons.cloud_off_rounded,
              title: t.infoOffline,
              body: t.infoOfflineBody,
            ),
            _Section(
              icon: Icons.lock_outline_rounded,
              title: t.infoPrivacy,
              body: t.infoPrivacyBody,
            ),
            _Section(
              icon: Icons.pending_outlined,
              title: t.infoNotYet,
              body: t.infoNotYetBody,
              emphasised: true,
            ),
          ],

          const SizedBox(height: 24),
          Center(
            child: Text(
              '${t.appName} · ${t.settingsVersion('1.0.0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
    this.emphasised = false,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Used for the "what this does not do" sections, which matter most and are
  /// the easiest for someone to miss.
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: emphasised
            ? AppColors.heritage.withValues(alpha: 0.30)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(color: AppColors.border, width: AppShape.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 20, color: AppColors.action),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
