import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/photo/photo_local_db.dart';
import 'package:myapp/src/network/data/photo/photo_repository.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

class PhotoRepositoryImpl extends PhotoRepository {
  //final PhotoDatabaseHelper _dbHelper = PhotoDatabaseHelper.instance;
  String? get _userId => UserPrefs.I.getUser()?.id;

  @override
  Future<MResult<bool>> checkPermission() async {
    try {
      Permission permissionType = Permission.photos;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permissionType = Permission.photos;
        } else {
          permissionType = Permission.storage;
        }
      }

      final currentStatus = await permissionType.status;
      if (!currentStatus.isGranted) {
        final requested = await permissionType.request();

        if (!requested.isGranted) {
          return MResult.error(
            S.text.error_permission,
          );
        }
      }

      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<MPhotoItem>>> loadPhotos({
    int page = 0,
    int pageSize = 100,
  }) async {
    try {
      final permissionResult = await checkPermission();
      if (!permissionResult.isSuccess) {
        return MResult.error(permissionResult.error);
      }

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(
              type: OrderOptionType.updateDate,
              asc: false,
            ),
          ],
        ),
      );

      if (albums.isEmpty) {
        return MResult.success([]);
      }
      final AssetPathEntity recentAlbum = albums.first;
      final start = page * pageSize;
      final end = start + pageSize;
      final List<AssetEntity> assets = await recentAlbum.getAssetListRange(
        start: start,
        end: end,
      );

      final favoriteIdsResult = await getFavoriteIds(_userId!);
      final favoriteIds = favoriteIdsResult.isSuccess
          ? (favoriteIdsResult.data ?? [])
          : <String>[];

      final photos = assets.map((asset) {
        return MPhotoItem(
          asset: asset,
          isFavorite: favoriteIds.contains(asset.id),
        );
      }).toList();
      return MResult.success(photos);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<MPhotoTimelineGroup>>> loadPhotosByTimeline({
    int page = 0,
    int pageSize = 100,
  }) async {
    try {
      final photosResult = await loadPhotos(page: page, pageSize: pageSize);
      if (!photosResult.isSuccess) {
        return MResult.error(photosResult.error);
      }

      final photos = photosResult.data ?? [];
      if (photos.isEmpty) {
        return MResult.success([]);
      }

      final Map<DateTime, List<MPhotoItem>> grouped = {};

      for (final photo in photos) {
        final date = photo.createDate;
        if (date == null) continue;
        final dayKey = DateTime(date.year, date.month, date.day);

        grouped.putIfAbsent(dayKey, () => []);
        grouped[dayKey]!.add(photo);
      }

      final groups = grouped.entries.map((entry) {
        return MPhotoTimelineGroup(
          date: entry.key,
          photos: entry.value,
        );
      }).toList();

      groups.sort((a, b) => b.date.compareTo(a.date));

      return MResult.success(groups);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<bool>> deletePhoto(String photoId) async {
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(
              type: OrderOptionType.updateDate,
              asc: false,
            ),
          ],
        ),
      );
      final assets = await albums.first.getAssetListRange(start: 0, end: 1000);
      final asset = assets.firstWhere((a) => a.id == photoId);
      await PhotoManager.editor.deleteWithIds([asset.id]);

      return MResult.success(true);
    } catch (e) {
      return MResult.exception(S.text.error_somethingWrongTryAgain);
    }
  }

  @override
  Future<MResult<bool>> sharePhoto(String photoId) async {
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(
              type: OrderOptionType.updateDate,
              asc: false,
            ),
          ],
        ),
      );
      final assets = await albums.first.getAssetListRange(start: 0, end: 1000);
      final asset = assets.firstWhere((a) => a.id == photoId);

      final file = await asset.file;
      if (file != null) {
        await Share.shareXFiles([
          XFile(file.path),
        ], text: S.text.common_text_share);
        return MResult.success(true);
      }
      return MResult.error(S.text.error_somethingWrongTryAgain);
    } catch (e) {
      return MResult.exception(S.text.error_somethingWrongTryAgain);
    }
  }

  @override
  Future<MResult<bool>> toggleFavorite(
      String photoId, bool isFavorite, String userId) async {
    try {
      if (isFavorite) {
        await PhotoDatabaseHelper.I.insertFavorite(photoId, userId);
      } else {
        await PhotoDatabaseHelper.I.deleteFavorite(photoId, userId);
      }
      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<bool>> isFavorite(String photoId, String userId) async {
    try {
      final isFav = await PhotoDatabaseHelper.I.isFavorite(photoId, userId);
      return MResult.success(isFav);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<String>>> getFavoriteIds(String userId) async {
    try {
      final ids = await PhotoDatabaseHelper.I.getAllFavorites(userId);
      return MResult.success(ids);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<MPhotoItem>>> loadFavoritePhotos(String userId) async {
    try {
      final favoriteIdsResult = await getFavoriteIds(userId);
      if (!favoriteIdsResult.isSuccess) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }
      final favoriteIds = favoriteIdsResult.data ?? [];

      if (favoriteIds.isEmpty) {
        return MResult.success([]);
      }

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(
              type: OrderOptionType.updateDate,
              asc: false,
            ),
          ],
        ),
      );

      if (albums.isEmpty) {
        return MResult.success([]);
      }

      final assets = await albums.first.getAssetListPaged(page: 0, size: 1000);
      final favoriteAssets =
          assets.where((asset) => favoriteIds.contains(asset.id)).toList();

      final photos = favoriteAssets
          .map((asset) => MPhotoItem(
                asset: asset,
                isFavorite: true,
              ))
          .toList();

      return MResult.success(photos);
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
