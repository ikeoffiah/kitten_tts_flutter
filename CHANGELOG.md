# Changelog

All notable changes to this project will be documented in this file.

## 0.1.1

* **Package renamed** from `kitten_tts_flutter` to `flutter_kitten_tts` to avoid pub.dev name conflict. Update your dependency and imports to `flutter_kitten_tts`.

## 0.1.0

* Initial release of KittenTTS Flutter plugin.
* KittenTTS v0.8 ONNX model support with espeak-ng phonemization.
* Offline text-to-speech: model, voices, and espeak-ng data downloaded and cached on first run.
* Eight built-in voices: Bella, Jasper, Luna, Bruno, Rosie, Hugo, Kiki, Leo.
* Configurable speed; sentence-aware chunking with automatic token-length guard (max 500 tokens).
* **iOS / macOS:** Native espeak-ng built via CocoaPods; Swift bridge to retain C symbols for Dart FFI.
* **Android:** Native espeak-ng built via CMake from `third_party/espeak-ng` (run `scripts/setup_espeak.sh` first).
  * Support for both legacy (`speak_lib.c`) and current (`speech.c`) espeak-ng source layouts.
  * `config.h` provided for Android (PACKAGE_VERSION, PATH_ESPEAK_DATA, USE_* defines).
  * sPlayer.c excluded when USE_SPEECHPLAYER=0 to avoid missing speechPlayer.h.
* Public API: `KittenTTS`, `initialize()`, `generate()`, `generateChunk()`, `splitText()`, `kittenVoices`, `ModelManager`.
