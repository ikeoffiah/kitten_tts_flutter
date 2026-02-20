import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Reads NumPy .npz files (ZIP of .npy arrays).
/// Used to load voice embeddings from voices.npz.
class NpzReader {
  final Map<String, NpyArray> _arrays = {};

  NpzReader.fromBytes(Uint8List data) {
    final archive = ZipDecoder().decodeBytes(data);
    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.npy')) {
        final name = file.name.replaceAll('.npy', '');
        _arrays[name] = NpyArray.fromBytes(Uint8List.fromList(file.content as List<int>));
      }
    }
  }

  factory NpzReader.fromFile(String path) {
    return NpzReader.fromBytes(File(path).readAsBytesSync());
  }

  List<String> get keys => _arrays.keys.toList();

  NpyArray? operator [](String key) => _arrays[key];
}

/// Minimal NPY format parser.
/// Supports float32 and float64 arrays (little-endian).
class NpyArray {
  final List<int> shape;
  final Float32List data;

  NpyArray._(this.shape, this.data);

  factory NpyArray.fromBytes(Uint8List bytes) {
    // NPY format: 6-byte magic (\x93NUMPY), 1-byte major, 1-byte minor,
    // 2-byte header length (LE for v1) or 4-byte (v2), then ASCII header dict.

    if (bytes[0] != 0x93 || String.fromCharCodes(bytes.sublist(1, 6)) != 'NUMPY') {
      throw FormatException('Not a valid NPY file');
    }

    final major = bytes[6];
    int headerLen;
    int headerStart;

    if (major == 1) {
      headerLen = ByteData.sublistView(bytes, 8, 10).getUint16(0, Endian.little);
      headerStart = 10;
    } else {
      headerLen = ByteData.sublistView(bytes, 8, 12).getUint32(0, Endian.little);
      headerStart = 12;
    }

    final headerStr = String.fromCharCodes(bytes.sublist(headerStart, headerStart + headerLen));
    final dataStart = headerStart + headerLen;

    final shape = _parseShape(headerStr);
    final descr = _parseDescr(headerStr);

    final dataBytes = bytes.sublist(dataStart);

    Float32List floatData;
    if (descr == '<f4' || descr == 'float32') {
      floatData = Float32List.view(dataBytes.buffer, dataBytes.offsetInBytes, dataBytes.lengthInBytes ~/ 4);
    } else if (descr == '<f8' || descr == 'float64') {
      final f64 = Float64List.view(dataBytes.buffer, dataBytes.offsetInBytes, dataBytes.lengthInBytes ~/ 8);
      floatData = Float32List(f64.length);
      for (var i = 0; i < f64.length; i++) {
        floatData[i] = f64[i].toDouble();
      }
    } else if (descr == '<f2' || descr == 'float16') {
      floatData = _decodeFloat16(dataBytes);
    } else {
      throw FormatException('Unsupported NPY dtype: $descr');
    }

    return NpyArray._(shape, floatData);
  }

  int get ndim => shape.length;
  int get length => shape.isNotEmpty ? shape[0] : 0;

  /// Gets a row from a 2D array as a Float32List view.
  Float32List row(int index) {
    if (shape.length < 2) throw StateError('Array is not 2D');
    final cols = shape[1];
    return Float32List.sublistView(data, index * cols, (index + 1) * cols);
  }

  static List<int> _parseShape(String header) {
    final match = RegExp(r"'shape':\s*\(([^)]*)\)").firstMatch(header);
    if (match == null) return [];
    final inner = match.group(1)!.trim();
    if (inner.isEmpty) return [];
    return inner.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).map(int.parse).toList();
  }

  static String _parseDescr(String header) {
    final match = RegExp(r"'descr':\s*'([^']*)'").firstMatch(header);
    return match?.group(1) ?? '<f4';
  }

  static Float32List _decodeFloat16(Uint8List bytes) {
    final count = bytes.lengthInBytes ~/ 2;
    final result = Float32List(count);
    final bd = ByteData.sublistView(bytes);
    for (var i = 0; i < count; i++) {
      result[i] = _halfToFloat(bd.getUint16(i * 2, Endian.little));
    }
    return result;
  }

  static double _halfToFloat(int half) {
    final sign = (half >> 15) & 1;
    final exp = (half >> 10) & 0x1F;
    final frac = half & 0x3FF;

    if (exp == 0) {
      if (frac == 0) return sign == 0 ? 0.0 : -0.0;
      final f = frac / 1024.0;
      final val = f * 5.960464477539063e-8; // 2^-24
      return sign == 0 ? val : -val;
    }
    if (exp == 31) {
      return frac == 0
          ? (sign == 0 ? double.infinity : double.negativeInfinity)
          : double.nan;
    }

    final f = 1.0 + frac / 1024.0;
    final val = f * _pow2(exp - 15);
    return sign == 0 ? val : -val;
  }

  static double _pow2(int n) {
    if (n >= 0) return (1 << n).toDouble();
    return 1.0 / (1 << -n).toDouble();
  }
}
