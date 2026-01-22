import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/features/dashboard/photo/model/favorite_photo.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritePhotoService {
  Future<MResult<File>> compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final targetPath = path.join(
        tempDir.path,
        '${fileName}_fav_${DateTime.now().millisecondsSinceEpoch}.jpg',
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

  Future<MResult<String>> uploadFavoritePhoto({
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
      final fileName =
          'fav_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = '$userId/$fileName';

      await supabaseClient.storage
          .from(AppConstants.favoritePhotoBucket)
          .upload(
            filePath,
            compressedFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = supabaseClient.storage
          .from(AppConstants.favoritePhotoBucket)
          .getPublicUrl(filePath);

      await compressedFile.delete();

      return MResult.success(publicUrl);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> deleteFavoritePhotoFromStorage({
    required String imageUrl,
  }) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      final bucketIndex =
          pathSegments.indexOf(AppConstants.favoritePhotoBucket);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        return MResult.success(true);
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await supabaseClient.storage
          .from(AppConstants.favoritePhotoBucket)
          .remove([filePath]);

      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<int>> saveFavoriteRecord({
    required String userId,
    required String photoId,
    required String imageUrl,
  }) async {
    try {
      final response = await supabaseClient
          .from('favorite_photos')
          .insert({
            'user_id': userId,
            'photo_id': photoId,
            'image_url': imageUrl,
          })
          .select('id')
          .single();

      return MResult.success(response['id'] as int);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> deleteFavoriteRecord({
    required String userId,
    required String photoId,
  }) async {
    try {
      final record = await supabaseClient
          .from('favorite_photos')
          .select('image_url')
          .eq('user_id', userId)
          .eq('photo_id', photoId)
          .maybeSingle();

      await supabaseClient
          .from('favorite_photos')
          .delete()
          .eq('user_id', userId)
          .eq('photo_id', photoId);

      if (record != null && record['image_url'] != null) {
        await deleteFavoritePhotoFromStorage(imageUrl: record['image_url']);
      }

      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<List<MFavoritePhoto>>> getFavoritePhotos({
    required String userId,
  }) async {
    try {
      final response = await supabaseClient
          .from('favorite_photos')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final photos = (response as List)
          .map((item) => MFavoritePhoto.fromSupabase(item))
          .toList();

      return MResult.success(photos);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> isFavoriteOnServer({
    required String userId,
    required String photoId,
  }) async {
    try {
      final response = await supabaseClient
          .from('favorite_photos')
          .select('id')
          .eq('user_id', userId)
          .eq('photo_id', photoId)
          .maybeSingle();

      return MResult.success(response != null);
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
