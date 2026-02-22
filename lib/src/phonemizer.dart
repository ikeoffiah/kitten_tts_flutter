import 'espeak_ffi.dart';

/// Converts English text to IPA phonemes using espeak-ng via Dart FFI.
class Phonemizer {
  final EspeakFfi _espeak = EspeakFfi();

  bool get isInitialized => _espeak.isReady;

  /// Initialize espeak-ng. [dataPath] is the directory containing
  /// the `espeak-ng-data` folder (not the folder itself).
  void initialize(String dataPath) {
    _espeak.load();
    _espeak.init(dataPath);
  }

  /// Convert text to IPA phonemes.
  String phonemize(String text) {
    if (!_espeak.isReady) {
      throw StateError('Phonemizer not initialized. Call initialize() first.');
    }
    return _espeak.phonemize(text);
  }

  void dispose() {
    _espeak.dispose();
  }
}
