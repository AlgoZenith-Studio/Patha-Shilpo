import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import 'models/add_product_state.dart';
import 'step1_photo/photo_capture_screen.dart';
import 'step2_voice/voice_record_screen.dart';
import 'step3_costs/cost_entry_screen.dart';
import 'step4_review/pricing_review_screen.dart';

/// The four-step add-product flow (PRD.md FEAT-02, TRD.md §11.4).
///
/// One [AddProductState] is owned here and shared by every step, so the draft
/// survives back-navigation. All four steps complete with **no network** — that
/// is the product thesis and the moment the demo turns on.
class AddProductFlow extends StatefulWidget {
  const AddProductFlow({super.key});

  @override
  State<AddProductFlow> createState() => _AddProductFlowState();
}

class _AddProductFlowState extends State<AddProductFlow> {
  final PageController _pages = PageController();
  final AddProductState _draft = AddProductState();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    _draft.dispose();
    super.dispose();
  }

  List<String> _stepLabels(AppLocalizations t) => <String>[
        t.addStepPhoto,
        t.addStepSpeak,
        t.addStepCosts,
        t.addStepReview,
      ];

  void _goTo(int index) {
    setState(() => _index = index);
    _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<bool> _confirmExit() async {
    final AppLocalizations t = AppLocalizations.of(context);
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(t.addLeaveTitle),
        content: Text(t.addLeaveBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.commonStay),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.commonLeave),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final List<String> steps = _stepLabels(t);

    return ChangeNotifierProvider<AddProductState>.value(
      value: _draft,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, _) async {
          if (didPop) return;
          if (_index > 0) {
            _goTo(_index - 1);
            return;
          }
          if (await _confirmExit() && mounted) {
            if (context.mounted) Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(steps[_index]),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _StepRail(index: _index, steps: steps),
            ),
          ),
          body: SafeArea(
            child: PageView(
              controller: _pages,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                PhotoCaptureScreen(onNext: () => _goTo(1)),
                VoiceRecordScreen(onNext: () => _goTo(2)),
                CostEntryScreen(onNext: () => _goTo(3)),
                PricingReviewScreen(onPublish: _publish),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _publish() {
    // The draft is complete and sellable from here (state OFFLINE_PROCESSED).
    // Queueing it for sync lands when data/local and sync/ are wired.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).addSavedOffline)),
    );
    Navigator.of(context).pop();
  }
}

class _StepRail extends StatelessWidget {
  const _StepRail({required this.index, required this.steps});

  final int index;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: List<Widget>.generate(steps.length, (int i) {
          final bool done = i < index;
          final bool active = i == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == steps.length - 1 ? 0 : 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || active
                          ? AppColors.action
                          : AppColors.border.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    steps[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontFamilyFallback: AppTheme.scriptFallback,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active ? AppColors.ink : AppColors.border,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
