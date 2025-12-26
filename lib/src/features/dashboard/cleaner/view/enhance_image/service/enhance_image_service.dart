import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:myapp/src/config/env/env.dart';

class EnhanceImageService {
  Future<Uint8List?> upscaleImage(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ENV.rapidApiUrlEnhanceImage),
      );

      request.headers.addAll({
        'X-RapidAPI-Key': ENV.rapidApiKey,
        'X-RapidAPI-Host': ENV.rapidApiHostEnhanceImage,
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', filePath),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBytes = await response.stream.toBytes();
        final jsonString = utf8.decode(responseBytes);
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;

        if (jsonData['code'] == 0 && jsonData['result_base64'] != null) {
          final base64String = jsonData['result_base64'] as String;
          final imageBytes = base64.decode(base64String);
          return imageBytes;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
