import 'dart:io';
import 'dart:typed_data';

import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image_group.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_scan_progress.dart';
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

  /// Remove background from photo
  Future<MResult<Uint8List>> removeBackground(File imageFile);

  /// Enhance/upscale image
  Future<MResult<Uint8List>> enhanceImage(File imageFile);

  /// Save photo to local storage
  Future<MResult<String>> saveImageToDevice(
      Uint8List imageData, String fileName);

  /// Scan for duplicate images
  Future<MResult<List<MDuplicateImageGroup>>> scanForDuplicates({
    Function(MDuplicateScanProgress)? onProgress,
    double similarityThreshold = 0.85,
  });

  /// Get all image paths from device
  Future<MResult<List<String>>> getAllImagePaths();

  /// Delete images by paths
  Future<MResult<int>> deleteImagesByPaths(List<String> paths);

  /// Enhance image from URL
  Future<MResult<Uint8List>> enhanceImageFromUrl(String imageUrl);
}
