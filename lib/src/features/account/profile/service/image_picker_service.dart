import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:path/path.dart' as path;

class ImagePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<MResult<String>> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return MResult.error('no_image_selected');
      }

      final compressedPath = await _compressImage(pickedFile.path);

      if (compressedPath != null) {
        return MResult.success(compressedPath);
      } else {
        return MResult.error('compress_failed');
      }
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<String>> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return MResult.error('no_image_captured');
      }

      final compressedPath = await _compressImage(pickedFile.path);

      if (compressedPath != null) {
        return MResult.success(compressedPath);
      } else {
        return MResult.error('compress_failed');
      }
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<String?> _compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = path.basenameWithoutExtension(imagePath);
      final fileExtension = path.extension(imagePath);
      final targetPath =
          '${file.parent.path}/${fileName}_compressed$fileExtension.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: 80,
        minWidth: 512,
        minHeight: 512,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        return result.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
