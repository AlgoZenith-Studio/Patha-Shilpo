import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/ai/voice/controllers/on_device_stt_controller.dart';
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceRecorderWidget(
              onTranscriptChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(VoiceRecorderWidget), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
      expect(find.text('Tap mic to dictate story'), findsOneWidget);
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
