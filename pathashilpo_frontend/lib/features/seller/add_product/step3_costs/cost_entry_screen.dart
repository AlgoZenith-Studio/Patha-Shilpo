import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/pricing_constants.dart';
import '../../../../core/i18n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/primary_bilingual_button.dart';
import '../models/add_product_state.dart';

/// Step 3 — material cost and hours of work (PRD.md FEAT-02).
///
/// Two numbers, nothing else. These are the only inputs the pricing formula
/// needs, and both are things the artisan already knows without looking
/// anything up.
class CostEntryScreen extends StatefulWidget {
  const CostEntryScreen({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<CostEntryScreen> createState() => _CostEntryScreenState();
}

class _CostEntryScreenState extends State<CostEntryScreen> {
  final TextEditingController _cost = TextEditingController();
  final TextEditingController _hours = TextEditingController();

  @override
  void initState() {
    super.initState();
    final AddProductState draft = context.read<AddProductState>();
    if (draft.materialCost != null) _cost.text = '${draft.materialCost}';
    if (draft.hoursOfWork != null) _hours.text = '${draft.hoursOfWork}';
  }

  @override
  void dispose() {
    _cost.dispose();
    _hours.dispose();
    super.dispose();
  }

  int? get _costValue => int.tryParse(_cost.text.trim());
  int? get _hoursValue => int.tryParse(_hours.text.trim());
  bool get _valid =>
      _costValue != null &&
      _hoursValue != null &&
      _costValue! >= 0 &&
      _hoursValue! > 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(t.costsTitle,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),

          _BigNumberField(
            controller: _cost,
            label: t.costsMaterial,
            prefix: '₹',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          _BigNumberField(
            controller: _hours,
            label: t.costsHours,
            suffix: t.costsHoursSuffix,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 24),
          if (_valid) _LivePreview(cost: _costValue!, hours: _hoursValue!),

          const SizedBox(height: 24),
          PrimaryBilingualButton(
            label: t.costsSeePrice,
            onPressed: _valid ? _commit : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _commit() {
    context.read<AddProductState>().setCosts(
          materialCost: _costValue!,
          hoursOfWork: _hoursValue!,
        );
    widget.onNext();
  }
}

class _BigNumberField extends StatelessWidget {
  const _BigNumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.prefix,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
            fontFamily: AppTheme.headingFont,
            fontFamilyFallback: AppTheme.scriptFallback,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          decoration: InputDecoration(
            prefixText: prefix,
            suffixText: suffix,
            hintText: '0',
          ),
        ),
      ],
    );
  }
}

/// Shows the wage component the moment both numbers exist, so the artisan
/// sees *why* the price moves rather than waiting for a black box.
class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.cost, required this.hours});

  final int cost;
  final int hours;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final int labour = hours * PricingConstants.fairWagePerHour;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(color: AppColors.border, width: AppShape.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _row(context, t.costsMaterials, '₹$cost'),
          _row(
            context,
            t.costsYourLabour(hours, PricingConstants.fairWagePerHour),
            '₹$labour',
          ),
          const Divider(height: 18),
          Text(t.costsFairWageNote,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
}
