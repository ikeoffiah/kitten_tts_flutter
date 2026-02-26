import 'package:flutter_test/flutter_test.dart';
import 'package:kitten_tts_flutter/kitten_tts_flutter.dart';

void main() {
  test('KittenTTS can be instantiated', () {
    final tts = KittenTTS();
    expect(tts.isInitialized, false);
    expect(tts.sampleRate, 24000);
    expect(tts.availableVoices, isNotEmpty);
    expect(tts.availableVoices.length, 8);
  });

  test('kittenVoices contains expected voices', () {
    expect(kittenVoices, contains('Jasper'));
    expect(kittenVoices, contains('Bella'));
    expect(kittenVoices, contains('Luna'));
    expect(kittenVoices, contains('Bruno'));
    expect(kittenVoices, contains('Rosie'));
    expect(kittenVoices, contains('Hugo'));
    expect(kittenVoices, contains('Kiki'));
    expect(kittenVoices, contains('Leo'));
  });

  test('generate throws when not initialized', () {
    final tts = KittenTTS();
    expect(() => tts.generate('hello'), throwsA(isA<StateError>()));
  });
}
