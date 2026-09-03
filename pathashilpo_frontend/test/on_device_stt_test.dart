import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/ai/voice/controllers/on_device_stt_controller.dart';
import 'package:pathashilpa/core/i18n/generated/app_localizations.dart';
import 'package:pathashilpa/core/i18n/locale_provider.dart';
import 'package:pathashilpa/ai/voice/models/stt_state.dart';
import 'package:pathashilpa/ai/voice/views/guided_fallback_form.dart';
import 'package:pathashilpa/ai/voice/views/voice_recorder_widget.dart';

void main() {
  group('On-Device STT Models & Controller Tests', () {
    test('SttResult holds transcription, confidence, and language code', () {
      const res = SttResult(
        text: 'चंदेरी सिल्क साड़ी',
        isFinal: true,
        confidence: 0.98,
        languageCode: 'hi_IN',
      );

      expect(res.text, equals('चंदेरी सिल्क साड़ी'));
      expect(res.isFinal, isTrue);
      expect(res.confidence, equals(0.98));
      expect(res.languageCode, equals('hi_IN'));
      expect(res.toString(), contains('चंदेरी सिल्क साड़ी'));
    });

    test('OnDeviceSttController singleton instance exists and has valid initial state', () {
      final ctrl1 = OnDeviceSttController();
      final ctrl2 = OnDeviceSttController();

      expect(identical(ctrl1, ctrl2), isTrue);
      expect(ctrl1.isListening, isFalse);
      expect(ctrl1.soundLevel, equals(0.0));
      expect(ctrl1.lastSpokenText, isEmpty);
      expect(ctrl1.isOffline, isFalse);
      expect(ctrl1.isFallbackActive, isFalse);
    });

    test('resolveLocaleId correctly matches all three languages (English, Hindi, Bengali)', () {
      final ctrl = OnDeviceSttController();

      // English
      final localeEn = ctrl.resolveLocaleId('en');
      expect(localeEn, contains('en'));

      // Hindi
      final localeHi = ctrl.resolveLocaleId('hi');
      expect(localeHi.isNotEmpty, isTrue);

      // Bengali
      final localeBn = ctrl.resolveLocaleId('bn');
      expect(localeBn.isNotEmpty, isTrue);
    });
  });

  group('On-Device STT Widgets Tests', () {
    testWidgets('VoiceRecorderWidget builds and renders microphone button', (tester) async {
      // The recorder renders localised copy now, so it needs the delegates.
      // Pumping it bare made AppLocalizations.of(context) return null.
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: kSupportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: VoiceRecorderWidget(
              onTranscriptChanged: (_) {},
            ),
          ),
        ),
      );
      // pump(), not pumpAndSettle(): the mic runs a repeating pulse
      // animation, so the tree never reaches a settled state.
      await tester.pump();

      expect(find.byType(VoiceRecorderWidget), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
      // Asserted through the localisation table, not a literal, so the test
      // does not have to be edited every time the copy is reworded.
      final AppLocalizations t = AppLocalizations.of(
          tester.element(find.byType(VoiceRecorderWidget)));
      expect(find.text(t.voiceTapMic), findsOneWidget);
    });

    testWidgets('GuidedFallbackForm renders text field with given hint and label', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GuidedFallbackForm(
              controller: controller,
              label: 'हस्तशिल्प विवरण',
              hint: 'विस्तार से लिखें...',
            ),
          ),
        ),
      );

      expect(find.text('हस्तशिल्प विवरण'), findsOneWidget);
      expect(find.text('विस्तार से लिखें...'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'शुद्ध रेशम और सोने की ज़री का काम');
      expect(controller.text, equals('शुद्ध रेशम और सोने की ज़री का काम'));
    });
  });
}
