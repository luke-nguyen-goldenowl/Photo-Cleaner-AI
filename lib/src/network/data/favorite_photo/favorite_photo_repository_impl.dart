import 'dart:io';
import 'package:myapp/src/features/dashboard/photo/model/favorite_photo.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/favorite_photo/favorite_photo_repository.dart';
import 'package:myapp/src/network/data/favorite_photo/favorite_photo_service.dart';
import 'package:myapp/src/network/data/photo/photo_local_db.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/services/network-connection/internet_connection_cubit.dart';

class FavoritePhotoRepositoryImpl implements FavoritePhotoRepository {
  final FavoritePhotoService _service = FavoritePhotoService();

  @override
  Future<MResult<bool>> likePhoto(MPhotoItem photo, String userId) async {
    try {
      final file = await photo.asset?.file;
      if (file == null) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final hasInternet = await InternetConnectionCubit().hasInternet();

      if (hasInternet) {
        final syncResult = await _syncToSupabase(
          photoId: photo.id,
          userId: userId,
          imageFile: file,
        );
        return MResult.success(syncResult);
      } else {
        await PhotoLocalDatabase.I.insertFavoriteWithSync(
          photoId: photo.id,
          userId: userId,
          imagePath: file.path,
          syncStatus: SyncStatus.pending,
        );
        return MResult.success(true);
      }
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<bool> _syncToSupabase({
    required String photoId,
    required String userId,
    required File imageFile,
  }) async {
    try {
      final uploadResult = await _service.uploadFavoritePhoto(
        userId: userId,
        imageFile: imageFile,
      );

      if (!uploadResult.isSuccess || uploadResult.data == null) {
        return false;
      }

      final imageUrl = uploadResult.data!;
      final recordResult = await _service.saveFavoriteRecord(
        userId: userId,
        photoId: photoId,
        imageUrl: imageUrl,
      );

      return recordResult.isSuccess;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<MResult<bool>> unlikePhoto(String photoId, String userId) async {
    try {
      await PhotoLocalDatabase.I.deleteFavorite(photoId, userId);
      final hasInternet = await InternetConnectionCubit().hasInternet();
      if (hasInternet) {
        await _service.deleteFavoriteRecord(
          userId: userId,
          photoId: photoId,
        );
      }
      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<MFavoritePhoto>>> getFavoritePhotos(String userId) async {
    try {
      final hasInternet = await InternetConnectionCubit().hasInternet();
      final localPendingPhotos =
          await PhotoLocalDatabase.I.getPendingUploads(userId);

      if (hasInternet) {
        final remoteResult = await _service.getFavoritePhotos(userId: userId);

        if (remoteResult.isSuccess) {
          final remotePhotos = remoteResult.data ?? [];
          final remoteIds = remotePhotos.map((p) => p.photoId).toSet();
          final uniquePending = localPendingPhotos
              .where((p) => !remoteIds.contains(p.photoId))
              .toList();

          return MResult.success([...remotePhotos, ...uniquePending]);
        }

        return MResult.success(localPendingPhotos);
      } else {
        return MResult.success(localPendingPhotos);
      }
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<bool>> isFavorite(String photoId, String userId) async {
    try {
      final isLocalFavorite =
          await PhotoLocalDatabase.I.isFavorite(photoId, userId);
      if (isLocalFavorite) return MResult.success(true);

      final hasInternet = await InternetConnectionCubit().hasInternet();
      if (hasInternet) {
        final result = await _service.isFavoriteOnServer(
          userId: userId,
          photoId: photoId,
        );
        return result;
      }

      return MResult.success(false);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<void> syncPendingUploads(String userId) async {
    try {
      final pendingPhotos =
          await PhotoLocalDatabase.I.getPendingUploads(userId);

      for (final photo in pendingPhotos) {
        if (photo.localPath == null) continue;

        final file = File(photo.localPath!);
        if (!await file.exists()) {
          await PhotoLocalDatabase.I.deleteFavorite(photo.photoId, userId);
          continue;
        }
        final success = await _syncToSupabase(
          photoId: photo.photoId,
          userId: userId,
          imageFile: file,
        );

        if (success) {
          await PhotoLocalDatabase.I.deleteFavorite(photo.photoId, userId);
        }
      }
    } catch (e) {
      MResult.exception(e);
    }
  }

  @override
  Future<bool> hasPendingUploads(String userId) async {
    try {
      return await PhotoLocalDatabase.I.hasPendingUploads(userId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<MResult<List<String>>> getFavoriteIds(String userId) async {
    try {
      final hasInternet = await InternetConnectionCubit().hasInternet();
      final localIds = await PhotoLocalDatabase.I.getAllFavorites(userId);

      if (hasInternet) {
        final remoteResult = await _service.getFavoritePhotos(userId: userId);
        if (remoteResult.isSuccess) {
          final remoteIds =
              (remoteResult.data ?? []).map((p) => p.photoId).toList();
          final allIds = {...localIds, ...remoteIds}.toList();
          return MResult.success(allIds);
        }
      }

      return MResult.success(localIds);
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
