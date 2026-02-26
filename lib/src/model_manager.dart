import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Downloads and manages KittenTTS model files from HuggingFace.
class ModelManager {
  static const _hfBase =
      'https://huggingface.co/KittenML/kitten-tts-nano-0.8-int8/resolve/main';
  static const _modelDirName = 'kitten-tts-nano-0.8-int8';
  static const _readyMarker = '.ready';

  String? _modelDir;

  String get modelDir => _modelDir ?? '';
  String get modelPath => p.join(modelDir, 'kitten_tts_nano_v0_8.onnx');
  String get voicesPath => p.join(modelDir, 'voices.npz');
  String get espeakDataPath => p.join(modelDir, 'espeak-ng-data');

  Future<bool> isReady() async {
    final dir = await _getModelDir();
    return File(p.join(dir.path, _readyMarker)).existsSync();
  }

  Future<void> download({
    void Function(double progress, String status)? onProgress,
  }) async {
    final dir = await _getModelDir();
    _modelDir = dir.path;

    final marker = File(p.join(dir.path, _readyMarker));
    if (marker.existsSync()) {
      debugPrint('[ModelManager] Already downloaded at ${dir.path}');
      onProgress?.call(1.0, 'Ready');
      return;
    }

    // Download model ONNX file (~24 MB)
    await _downloadIfMissing(
      fileName: 'kitten_tts_nano_v0_8.onnx',
      url: '$_hfBase/kitten_tts_nano_v0_8.onnx',
      dir: dir.path,
      progressBase: 0.0,
      progressRange: 0.5,
      onProgress: onProgress,
    );

    // Download voices NPZ file (~3.3 MB)
    await _downloadIfMissing(
      fileName: 'voices.npz',
      url: '$_hfBase/voices.npz',
      dir: dir.path,
      progressBase: 0.5,
      progressRange: 0.15,
      onProgress: onProgress,
    );

    // Download and extract espeak-ng data (~7 MB)
    await _ensureEspeakData(dir.path, onProgress);

    await marker.create();
    onProgress?.call(1.0, 'Ready');
    debugPrint('[ModelManager] All files ready at ${dir.path}');
  }

  Future<void> _downloadIfMissing({
    required String fileName,
    required String url,
    required String dir,
    required double progressBase,
    required double progressRange,
    void Function(double, String)? onProgress,
  }) async {
    final filePath = p.join(dir, fileName);
    if (File(filePath).existsSync()) {
      debugPrint('[ModelManager] $fileName already exists');
      return;
    }

    onProgress?.call(progressBase, 'Downloading $fileName...');
    debugPrint('[ModelManager] Downloading $url');

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url))
        ..followRedirects = true
        ..maxRedirects = 5;
      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception(
          'Download $fileName failed: HTTP ${response.statusCode}',
        );
      }

      final total = response.contentLength ?? 0;
      final file = File(filePath);
      final sink = file.openWrite();
      var received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          final fileProgress = received / total;
          final overall = progressBase + fileProgress * progressRange;
          onProgress?.call(
            overall,
            'Downloading $fileName... ${(fileProgress * 100).toStringAsFixed(0)}%',
          );
        }
      }
      await sink.close();
    } finally {
      client.close();
    }
  }

  Future<void> _ensureEspeakData(
    String baseDir,
    void Function(double, String)? onProgress,
  ) async {
    final espeakDir = Directory(p.join(baseDir, 'espeak-ng-data'));
    if (espeakDir.existsSync() && espeakDir.listSync().isNotEmpty) {
      debugPrint('[ModelManager] espeak-ng-data already exists');
      return;
    }

    onProgress?.call(0.7, 'Downloading espeak-ng data...');
    const espeakUrl =
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/espeak-ng-data.tar.bz2';

    final client = http.Client();
    Uint8List archiveBytes;
    try {
      final request = http.Request('GET', Uri.parse(espeakUrl))
        ..followRedirects = true
        ..maxRedirects = 5;
      final response = await client.send(request);
      final chunks = <int>[];
      final total = response.contentLength ?? 0;
      var received = 0;
      await for (final chunk in response.stream) {
        chunks.addAll(chunk);
        received += chunk.length;
        if (total > 0) {
          onProgress?.call(
            0.7 + (received / total) * 0.15,
            'Downloading espeak-ng data... ${(received / total * 100).toStringAsFixed(0)}%',
          );
        }
      }
      archiveBytes = Uint8List.fromList(chunks);
    } finally {
      client.close();
    }

    onProgress?.call(0.9, 'Extracting espeak-ng data...');
    await compute(_extractArchive, _ExtractParams(archiveBytes, baseDir));
    debugPrint('[ModelManager] espeak-ng-data extracted');
  }

  Future<Directory> _getModelDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(appDir.path, 'kitten_tts', _modelDirName));
    if (!dir.existsSync()) await dir.create(recursive: true);
    _modelDir = dir.path;
    return dir;
  }
}

class _ExtractParams {
  final Uint8List data;
  final String targetDir;
  const _ExtractParams(this.data, this.targetDir);
}

Future<void> _extractArchive(_ExtractParams params) async {
  final decompressed = BZip2Decoder().decodeBytes(params.data);
  final archive = TarDecoder().decodeBytes(decompressed);

  for (final file in archive) {
    if (file.name.isEmpty) continue;
    final filePath = p.join(params.targetDir, file.name);
    if (file.isFile) {
      final outFile = File(filePath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    } else {
      await Directory(filePath).create(recursive: true);
    }
  }
}
