# flutter_kitten_tts

High-quality offline text-to-speech for Flutter using the [KittenML](https://huggingface.co/KittenML) v0.8 ONNX model.

## Features

- **Fully offline** – model runs on-device, no internet after initial download
- **8 voices** – Bella, Jasper, Luna, Bruno, Rosie, Hugo, Kiki, Leo
- **Adjustable speed** – 0.5x to 2.0x
- **Automatic chunking** – long texts are split at sentence boundaries
- **24 kHz output** – PCM Float32 audio ready for playback

## Architecture

```
Text → TextPreprocessor → espeak-ng (FFI) → TextCleaner → ONNX Runtime → PCM audio
         (numbers,          (IPA            (token         (inference)
          currency,          phonemes)       mapping)
          time, etc.)
```

## Setup

### 1. Add dependency

**From pub.dev** (recommended):

```yaml
dependencies:
  flutter_kitten_tts: ^0.0.4
```

**From Git** (latest):

```yaml
dependencies:
  flutter_kitten_tts:
    git:
      url: https://github.com/ikeoffiah/kitten_tts_flutter.git
      ref: main
```

**Local path** (development):

```yaml
dependencies:
  flutter_kitten_tts:
    path: ../kitten_tts_flutter
```

### 2. espeak-ng source (Android)

Android builds espeak-ng from source. The package (both the [GitHub repo](https://github.com/ikeoffiah/kitten_tts_flutter) and the pub.dev publish) **includes** `third_party/espeak-ng`, so you do **not** need to run any script—add the dependency and build. **iOS/macOS** use bundled sources in the plugin and also require no extra steps.

> **If you see Android build errors** such as "espeak-ng source not found" or missing espeak-ng files, run the setup script once from the plugin directory (e.g. from your pub cache after `flutter pub get`):  
> `bash "$(flutter pub cache path)/hosted/pub.dev/flutter_kitten_tts-0.0.4/scripts/setup_espeak.sh"`  
> (Replace `0.0.4` with your installed version, or for a git dependency use `.../git/kitten_tts_flutter-*/scripts/setup_espeak.sh`.) This downloads espeak-ng 1.52.0 into `third_party/espeak-ng/`.

### 3. Platform configuration

**iOS/macOS**: espeak-ng is compiled from source via CocoaPods automatically.

**Android**: espeak-ng is compiled via CMake (configured in `build.gradle`).

## Usage

```dart
import 'package:flutter_kitten_tts/flutter_kitten_tts.dart';

final tts = KittenTTS();

// Initialize (downloads ~35 MB model on first run)
await tts.initialize(
  onProgress: (progress, status) {
    print('$status (${(progress * 100).toStringAsFixed(0)}%)');
  },
);

// Generate speech
final audio = await tts.generate(
  'Hello world! This is KittenTTS.',
  voice: 'Jasper',  // Bella, Jasper, Luna, Bruno, Rosie, Hugo, Kiki, Leo
  speed: 1.0,       // 0.5 to 2.0
);

// audio is Float32List at 24000 Hz – play it with audioplayers, just_audio, etc.
print('Generated ${audio.length} samples (${audio.length / 24000}s)');
```

### Streaming (chunked generation)

For long texts, generate chunks individually for streaming playback:

```dart
final chunks = tts.splitText(longText);
for (final chunk in chunks) {
  final audio = await tts.generateChunk(chunk, voice: 'Luna');
  // Play each chunk as it's ready
}
```

### Available voices

| Voice  | Gender | Key              |
|--------|--------|------------------|
| Bella  | Female | expr-voice-2-f   |
| Jasper | Male   | expr-voice-2-m   |
| Luna   | Female | expr-voice-3-f   |
| Bruno  | Male   | expr-voice-3-m   |
| Rosie  | Female | expr-voice-4-f   |
| Hugo   | Male   | expr-voice-4-m   |
| Kiki   | Female | expr-voice-5-f   |
| Leo    | Male   | expr-voice-5-m   |

## Model files

On first initialization, the package downloads from HuggingFace:

| File                         | Size   | Description           |
|------------------------------|--------|-----------------------|
| kitten_tts_nano_v0_8.onnx   | ~24 MB | ONNX model (int8)     |
| voices.npz                   | ~3 MB  | Voice embeddings      |
| espeak-ng-data.tar.bz2      | ~7 MB  | Phonemization data    |

Files are cached in the app's support directory and persist across app launches.

## Requirements

- Flutter >= 3.3.0
- Dart >= 3.10.8
- iOS 13.0+ / macOS 10.14+ / Android API 24+

## Contributing

If you clone this repo (directory may be named `kitten_tts_flutter`) and see analysis errors like "Target of URI doesn't exist: package:flutter_kitten_tts/...", run after `flutter pub get`:

```bash
bash scripts/fix_package_config.sh
```

Then run `dart analyze` or `flutter test` as usual.

## License

MIT
