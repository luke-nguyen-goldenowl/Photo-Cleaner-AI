import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/src/config/env/env.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class RemoveBgService {
  Future<String> _compressImage(String originalFilePath) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(originalFilePath);
    final targetPath = path.join(tempDir.path,
        '${fileName}_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalFilePath,
      targetPath,
      quality: 80,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );

    if (compressedFile != null) {
      return compressedFile.path;
    }
    return originalFilePath;
  }

  Future<Uint8List?> removeBackground(String filePath) async {
    final compressResult = await _compressImage(filePath);
    if (compressResult.isEmpty) {
      return null;
    }
    final compressedPath = compressResult;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ENV.rapidApiUrl),
    );

    request.headers.addAll({
      'X-RapidAPI-Key': ENV.rapidApiKey,
      'X-RapidAPI-Host': ENV.rapidApiHost,
    });

    request.files.add(
      await http.MultipartFile.fromPath('image', compressedPath),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      final imageBytes = await response.stream.toBytes();
      await File(compressedPath).delete();
      return imageBytes;
    } else {
      await File(compressedPath).delete();
      return null;
    }
  }
}
