import 'package:myapp/src/features/dashboard/photo/model/favorite_photo.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/network/model/common/result.dart';

abstract class FavoritePhotoRepository {
  Future<MResult<bool>> likePhoto(MPhotoItem photo, String userId);

  Future<MResult<bool>> unlikePhoto(String photoId, String userId);

  Future<MResult<List<MFavoritePhoto>>> getFavoritePhotos(String userId);

  Future<MResult<bool>> isFavorite(String photoId, String userId);

  Future<void> syncPendingUploads(String userId);

  Future<bool> hasPendingUploads(String userId);

  Future<MResult<List<String>>> getFavoriteIds(String userId);
}
