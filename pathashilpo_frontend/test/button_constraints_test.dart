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
