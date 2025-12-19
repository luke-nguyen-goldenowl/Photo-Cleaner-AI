import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    await dotenv.load(fileName: ".env");
    final compressResult = await _compressImage(filePath);
    if (compressResult.isEmpty) {
      return null;
    }
    final compressedPath = compressResult;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(dotenv.env['RAPID_API_URL']!),
    );

    request.headers.addAll({
      'X-RapidAPI-Key': dotenv.env['RAPID_API_KEY']!,
      'X-RapidAPI-Host': dotenv.env['RAPID_API_HOST']!,
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
