import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kitten_tts/src/text_preprocessor.dart';

void main() {
  late TextPreprocessor pp;

  setUp(() {
    pp = TextPreprocessor();
  });

  group('numberToWords', () {
    test('basic numbers', () {
      expect(TextPreprocessor.numberToWords(0), 'zero');
      expect(TextPreprocessor.numberToWords(1), 'one');
      expect(TextPreprocessor.numberToWords(13), 'thirteen');
      expect(TextPreprocessor.numberToWords(42), 'forty-two');
      expect(TextPreprocessor.numberToWords(100), 'one hundred');
      expect(TextPreprocessor.numberToWords(1000), 'one thousand');
    });

    test('large numbers', () {
      expect(TextPreprocessor.numberToWords(1000000), 'one million');
      expect(TextPreprocessor.numberToWords(2500), 'two thousand five hundred');
    });
  });

  group('process', () {
    test('expands currency', () {
      final result = pp.process(r'The price is $5.');
      expect(result, contains('five'));
      expect(result, contains('dollar'));
    });

    test('expands percentages', () {
      final result = pp.process('About 50% done');
      expect(result, contains('fifty'));
      expect(result, contains('percent'));
    });

    test('expands time', () {
      final result = pp.process('Meet at 3:30 pm');
      expect(result, contains('three'));
      expect(result, contains('thirty'));
      expect(result, contains('pm'));
    });

    test('expands ordinals', () {
      final result = pp.process('The 1st and 2nd place');
      expect(result, contains('first'));
      expect(result, contains('second'));
    });

    test('removes URLs', () {
      final result = pp.process('Visit https://example.com for details');
      expect(result, isNot(contains('https')));
      expect(result, contains('visit'));
    });

    test('normalizes whitespace', () {
      final result = pp.process('  hello   world  ');
      expect(result, 'hello world');
    });
  });
}
