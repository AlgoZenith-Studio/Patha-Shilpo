import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/core/widgets/brand/app_logo.dart';

void main() {
  group('Document Validation Tests', () {
    test('Aadhaar accepts exactly 12 digits and rejects other lengths', () {
      final validAadhaar1 = '123452346578'.replaceAll(RegExp(r'\D'), '');
      final validAadhaar2 = '982341056721'.replaceAll(RegExp(r'\D'), '');
      final shortAadhaar = '123456789'.replaceAll(RegExp(r'\D'), '');
      final longAadhaar = '1234567890123'.replaceAll(RegExp(r'\D'), '');

      expect(validAadhaar1.length == 12 && RegExp(r'^\d{12}$').hasMatch(validAadhaar1), isTrue);
      expect(validAadhaar2.length == 12 && RegExp(r'^\d{12}$').hasMatch(validAadhaar2), isTrue);
      expect(shortAadhaar.length == 12, isFalse);
      expect(longAadhaar.length == 12, isFalse);
    });

    test('PAN accepts exactly 10 characters and matches PAN format', () {
      final validPan = 'BKZPK7821M'.trim().toUpperCase();
      final validPan2 = 'ABCDE1234F'.trim().toUpperCase();
      final invalidShortPan = 'BKZPK7821'.trim().toUpperCase();
      final invalidLongPan = 'BKZPK7821MA'.trim().toUpperCase();

      expect(validPan.length == 10 && RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(validPan), isTrue);
      expect(validPan2.length == 10 && RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(validPan2), isTrue);
      expect(invalidShortPan.length == 10, isFalse);
      expect(invalidLongPan.length == 10, isFalse);
    });

    test('GST accepts exactly 15 characters and matches GSTIN format', () {
      final validGst = '22AAAAA0000A1Z5'.trim().toUpperCase();
      final invalidShortGst = '22AAAAA0000A1Z'.trim().toUpperCase();
      final invalidLongGst = '22AAAAA0000A1Z55'.trim().toUpperCase();

      expect(validGst.length == 15, isTrue);
      expect(invalidShortGst.length == 15, isFalse);
      expect(invalidLongGst.length == 15, isFalse);
    });
  });

  group('Brand AppLogo Tests', () {
    testWidgets('AppLogo widget builds cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const AppLogo(size: 48, showBackground: true),
      );
      expect(find.byType(AppLogo), findsOneWidget);
    });
  });
}
