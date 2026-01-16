import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:local_auth/local_auth.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';

class SecurePhotoService {
  Future<MResult<bool>> hashPassword({
    required String userId,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'hash-password',
        body: {
          'userId': userId,
          'password': password,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return MResult.success(true);
      }

      if (response.status == 200 || response.status == 201) {
        return MResult.success(true);
      }

      return MResult.error(S.text.error_somethingWrongTryAgain);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'change-password',
        body: {
          'userId': userId,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );

      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        return MResult.success(true);
      }

      if (response.status == 200) {
        return MResult.success(true);
      }

      return MResult.error(S.text.error_somethingWrongTryAgain);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> verifyPassword({
    required String userId,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'verify-password',
        body: {
          'userId': userId,
          'password': password,
        },
      );

      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        return MResult.success(true);
      }

      if (response.status == 200) {
        return MResult.success(true);
      }
      return MResult.error(S.text.error_somethingWrongTryAgain);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<File>> compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final targetPath = path.join(
        tempDir.path,
        '${fileName}_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        targetPath,
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      return MResult.success(File(compressedFile.path));
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<String>> uploadSecurePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final compressResult = await compressImage(imageFile);
      if (!compressResult.isSuccess || compressResult.data == null) {
        return MResult.error(compressResult.error);
      }

      final compressedFile = compressResult.data!;

      final fileExtension = path.extension(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = '$userId/$fileName';

      await supabaseClient.storage.from(AppConstants.bucketName).upload(
            filePath,
            compressedFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = supabaseClient.storage
          .from(AppConstants.bucketName)
          .getPublicUrl(filePath);

      return MResult.success(publicUrl);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> deleteSecurePhoto({
    required String fileUrl,
  }) async {
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;

      final bucketIndex = pathSegments.indexOf(AppConstants.bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await supabaseClient.storage
          .from(AppConstants.bucketName)
          .remove([filePath]);

      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> authenticateWithBiometrics() async {
    final auth = LocalAuthentication();
    try {
      final biometrics = await auth.getAvailableBiometrics();
      if (!biometrics.contains(BiometricType.strong)) {
        return MResult.error(S.text.common_fingerprint_authentication_error);
      }
      final didAuthenticate = await auth.authenticate(
        localizedReason: S.text.common_fingerprint_authentication,
        biometricOnly: true,
        sensitiveTransaction: true,
      );
      return MResult.success(didAuthenticate);
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.userCanceled) {
        return MResult.success(false);
      }
      return MResult.exception(e);
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
