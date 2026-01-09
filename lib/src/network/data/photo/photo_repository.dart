import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/features/dashboard/place/model/image_location.dart';
import 'package:myapp/src/network/model/common/result.dart';

abstract class PhotoRepository {
  Future<MResult<List<MPhotoItem>>> loadPhotos({
    int page = 0,
    int pageSize = 100,
  });

  Future<MResult<List<MPhotoTimelineGroup>>> loadPhotosByTimeline({
    int page = 0,
    int pageSize = 100,
  });

  /// Delete photo
  Future<MResult<bool>> deletePhoto(String photoId);

  /// Share photo
  Future<MResult<bool>> sharePhoto(String photoId);

  /// Toggle favorite status
  Future<MResult<bool>> toggleFavorite(
      String photoId, bool isFavorite, String userId);

  /// Check if photo is favorite
  Future<MResult<bool>> isFavorite(String photoId, String userId);

  /// Get all favorite photo IDs
  Future<MResult<List<String>>> getFavoriteIds(String userId);

  /// Load favorite photos (flat list, no timeline)
  Future<MResult<List<MPhotoItem>>> loadFavoritePhotos(String userId);

  /// Check permission to access photos
  Future<MResult<bool>> checkPermission();

  /// Extract GPS data from photo
  Future<MResult<MImageLocation?>> extractGpsFromPhoto(MPhotoItem photo);
}
