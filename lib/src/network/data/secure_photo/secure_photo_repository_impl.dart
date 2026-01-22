import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/features/secure_photo/model/secure_photo.dart';
import 'package:myapp/src/features/secure_photo/model/secure_vault.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/secure_photo/secure_photo_service.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';
import 'secure_photo_repository.dart';

class SecurePhotoRepositoryImpl extends SecurePhotoRepository {
  final SecurePhotoService _service = SecurePhotoService();

  @override
  Future<MResult<bool>> hasVault(String userId) async {
    try {
      final result = await supabaseClient
          .from('secure_vaults')
          .select('id')
          .eq('userId', userId)
          .maybeSingle();

      return MResult.success(result != null);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MSecureVault>> createVault({
    required String userId,
    required String password,
  }) async {
    try {
      final hashResult = await _service.hashPassword(
        userId: userId,
        password: password,
      );

      if (!hashResult.isSuccess) {
        return MResult.error(hashResult.error);
      }

      final response = await supabaseClient
          .from('secure_vaults')
          .select()
          .eq('userId', userId)
          .maybeSingle();

      if (response != null) {
        final vault = MSecureVault.fromJson(response);
        return MResult.success(vault);
      }

      return MResult.error(S.text.error_somethingWrongTryAgain);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<bool>> verifyPassword({
    required String userId,
    required String password,
  }) async {
    try {
      final result = await _service.verifyPassword(
        userId: userId,
        password: password,
      );
      return result;
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MSecurePhoto>> addSecurePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final uploadResult = await _service.uploadSecurePhoto(
        userId: userId,
        imageFile: imageFile,
      );

      if (!uploadResult.isSuccess || uploadResult.data == null) {
        return MResult.error(uploadResult.error);
      }
      final fileUrl = uploadResult.data!;

      final vaultResponse = await supabaseClient
          .from('secure_vaults')
          .select('id')
          .eq('userId', userId)
          .single();

      final vaultId = vaultResponse['id'] as int;

      final photoResponse = await supabaseClient
          .from('secure_photos')
          .insert({
            'vaultId': vaultId,
            'fileUrl': fileUrl,
          })
          .select()
          .single();

      final securePhoto = MSecurePhoto.fromJson(photoResponse);
      return MResult.success(securePhoto);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MSecurePhoto>> addSecurePhotoFromUrl({
    required String userId,
    required String imageUrl,
    required String photoId,
  }) async {
    try {
      final vaultResponse = await supabaseClient
          .from('secure_vaults')
          .select('id')
          .eq('userId', userId)
          .single();

      final vaultId = vaultResponse['id'] as int;

      final photoResponse = await supabaseClient
          .from('secure_photos')
          .insert({
            'vaultId': vaultId,
            'fileUrl': imageUrl,
          })
          .select()
          .single();

      final securePhoto = MSecurePhoto.fromJson(photoResponse);

      await supabaseClient
          .from('favorite_photos')
          .delete()
          .eq('user_id', userId)
          .eq('photo_id', photoId);

      return MResult.success(securePhoto);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<MPhotoItem>>> getSecurePhotos(String userId) async {
    try {
      final vaultResponse = await supabaseClient
          .from('secure_vaults')
          .select('id')
          .eq('userId', userId)
          .maybeSingle();

      if (vaultResponse == null) {
        return MResult.success([]);
      }

      final vaultId = vaultResponse['id'] as int;

      final photosResponse = await supabaseClient
          .from('secure_photos')
          .select()
          .eq('vaultId', vaultId)
          .order('createdAt', ascending: false);

      final photos = (photosResponse as List)
          .map((json) => MSecurePhoto.fromJson(json))
          .map((securePhoto) => MPhotoItem(
                securePhotoId: securePhoto.id,
                asset: null,
                storageUrl: securePhoto.fileUrl,
                isFavorite: false,
              ))
          .toList();

      return MResult.success(photos);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<File>> unsecurePhoto(String photoId) async {
    try {
      final photoResponse = await supabaseClient
          .from('secure_photos')
          .select()
          .eq('id', photoId)
          .single();

      final fileUrl = photoResponse['fileUrl'] as String;

      File? downloadedFile;
      await FileDownloader.downloadFile(
        url: fileUrl,
        onDownloadCompleted: (String path) {
          downloadedFile = File(path);
        },
        onDownloadError: (String error) {
          XToast.error(S.text.error_somethingWrongTryAgain);
        },
      );

      if (downloadedFile == null) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      await _service.deleteSecurePhoto(fileUrl: fileUrl);

      await supabaseClient.from('secure_photos').delete().eq('id', photoId);

      return MResult.success(downloadedFile);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<File>> downloadSecurePhoto(String photoUrl) async {
    try {
      if (photoUrl.isEmpty) {
        XToast.error(S.text.error_somethingWrongTryAgain);
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }
      File? downloadedFile;
      await FileDownloader.downloadFile(
        url: photoUrl,
        onDownloadCompleted: (String path) {
          XToast.show(S.text.common_downloaded);
          downloadedFile = File(path);
        },
        onDownloadError: (String error) {
          XToast.error(S.text.error_somethingWrongTryAgain);
        },
      );
      if (downloadedFile != null) {
        return MResult.success(downloadedFile);
      } else {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
