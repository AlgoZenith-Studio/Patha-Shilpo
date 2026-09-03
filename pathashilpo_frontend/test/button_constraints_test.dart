import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/core/theme/app_theme.dart';
import 'package:pathashilpa/core/theme/colors.dart';

/// The app theme sets `minimumSize: Size.fromHeight(AppShape.minTapTarget)` on
/// ElevatedButton and OutlinedButton, and `Size.fromHeight(56)` is
/// `Size(double.infinity, 56)`.
///
/// In a Column that is what we want. In a **Row** it throws
/// `BoxConstraints forces an infinite width` during layout and takes the whole
/// screen down with a red error — which is what made the buyer's "New RFQ"
/// control look broken: the RFQ screen never laid out at all.
///
/// These tests pin both halves of that: the trap is real, and [AppButtons]
/// defuses it.
void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: Row(children: <Widget>[child])),
      );

  testWidgets('the theme default really does force infinite width in a Row',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(
      ElevatedButton(onPressed: () {}, child: const Text('x')),
    ));

    // One bad constraint cascades: on the device this produced six chained
    // assertions and a full-screen red error, not a single tidy exception.
    // So assert that it throws at all rather than on one error's type.
    expect(
      tester.takeException(),
      isNotNull,
      reason: 'If this ever stops throwing, the theme no longer forces an '
          'infinite width and AppButtons.inRow may be unnecessary.',
    );
  });

  testWidgets('OutlinedButton has the SAME trap — this is the one that was missed',
      (WidgetTester tester) async {
    // outlinedButtonTheme carries the identical Size.fromHeight(minTapTarget).
    // The first version of this file only covered ElevatedButton, so the
    // artisan registration "Back" button — an OutlinedButton in a Row, wrapped
    // in a SizedBox that bounds HEIGHT only — went unnoticed and blanked out
    // the whole bottom bar from step 2 onward.
    await tester.pumpWidget(host(
      const SizedBox(
        height: 54,
        child: OutlinedButton(onPressed: null, child: Text('Back')),
      ),
    ));
    expect(tester.takeException(), isNotNull);
  });

  testWidgets('SizedBox(height:) does NOT bound width in a Row',
      (WidgetTester tester) async {
    // The specific misconception behind the registration bug.
    await tester.pumpWidget(host(
      const SizedBox(
        height: 54,
        child: ElevatedButton(onPressed: null, child: Text('x')),
      ),
    ));
    expect(tester.takeException(), isNotNull,
        reason: 'Bounding height alone leaves width unbounded; only '
            'SizedBox(width:), Expanded/Flexible or minimumSize fix it.');
  });

  testWidgets('an explicit minimumSize defuses it without AppButtons',
      (WidgetTester tester) async {
    // How both real fixes were written, inline in existing styleFrom calls.
    await tester.pumpWidget(host(
      SizedBox(
        height: 54,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54)),
          onPressed: () {},
          child: const Text('Back'),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('AppButtons.inRow lays out cleanly inside a Row',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(
      ElevatedButton(
        style: AppButtons.inRow,
        onPressed: () {},
        child: const Text('New RFQ'),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('New RFQ'), findsOneWidget);
    // Sized to content, not stretched across the viewport.
    expect(tester.getSize(find.byType(ElevatedButton)).width,
        lessThan(tester.view.physicalSize.width));
  });

  testWidgets('AppButtons.inRowOutlined lays out cleanly inside a Row',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(
      OutlinedButton(
        style: AppButtons.inRowOutlined,
        onPressed: () {},
        child: const Text('Listen'),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('Listen'), findsOneWidget);
  });

  testWidgets('AppButtons keeps the accessibility tap-target height',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(
      ElevatedButton(
        style: AppButtons.inRow,
        onPressed: () {},
        child: const Text('x'),
      ),
    ));

    // Content-sizing must not cost the 56dp floor low-literacy users rely on.
    expect(tester.getSize(find.byType(ElevatedButton)).height,
        greaterThanOrEqualTo(AppShape.minTapTarget));
  });
}
