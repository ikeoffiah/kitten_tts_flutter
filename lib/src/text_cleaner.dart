/// Maps phoneme characters (IPA symbols) to integer token IDs for the ONNX model.
///
/// The vocabulary matches the KittenTTS Python TextCleaner exactly.
class TextCleaner {
  late final Map<String, int> _charToIndex;

  TextCleaner() {
    const pad = '\$';
    const punctuation = ';:,.!?¡¿—…"«»"" ';
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    const lettersIpa =
        "ɑɐɒæɓʙβɔɕçɗɖðʤəɘɚɛɜɝɞɟʄɡɠɢʛɦɧħɥʜɨɪʝɭɬɫɮʟɱɯɰŋɳɲɴøɵɸθœɶʘɹɺɾɻʀʁɽʂʃʈʧʉʊʋⱱʌɣɤʍχʎʏʑʐʒʔʡʕʢǀǁǂǃˈˌːˑʼʴʰʱʲʷˠˤ˞↓↑→↗↘'̩'ᵻ";

    final symbols = <String>[
      pad,
      ...punctuation.split(''),
      ...letters.split(''),
      ...lettersIpa.characters,
    ];

    _charToIndex = {};
    for (var i = 0; i < symbols.length; i++) {
      _charToIndex[symbols[i]] = i;
    }
  }

  /// Converts a phoneme string to a list of integer token IDs.
  /// Unknown characters are silently skipped.
  List<int> encode(String phonemes) {
    final tokens = <int>[];
    for (final char in phonemes.characters) {
      final idx = _charToIndex[char];
      if (idx != null) tokens.add(idx);
    }
    return tokens;
  }

  /// Encodes phonemes and wraps with start/end padding tokens (0).
  List<int> encodeWithBoundary(String phonemes) {
    return [0, ...encode(phonemes), 0];
  }
}

/// Extension to iterate over grapheme clusters (important for multi-byte IPA chars).
extension _StringCharacters on String {
  List<String> get characters {
    final result = <String>[];
    final runes = this.runes.toList();
    for (final rune in runes) {
      result.add(String.fromCharCode(rune));
    }
    return result;
  }
}
