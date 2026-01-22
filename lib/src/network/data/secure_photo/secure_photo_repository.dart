import 'dart:io';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/features/secure_photo/model/secure_photo.dart';
import 'package:myapp/src/features/secure_photo/model/secure_vault.dart';
import 'package:myapp/src/network/model/common/result.dart';

abstract class SecurePhotoRepository {
  /// Check exists vault
  Future<MResult<bool>> hasVault(String userId);

  /// Create vault
  Future<MResult<MSecureVault>> createVault({
    required String userId,
    required String password,
  });

  /// Verify password
  Future<MResult<bool>> verifyPassword({
    required String userId,
    required String password,
  });

  /// Add secure photo
  Future<MResult<MSecurePhoto>> addSecurePhoto({
    required String userId,
    required File imageFile,
  });

  /// Get all secure photos
  Future<MResult<List<MPhotoItem>>> getSecurePhotos(String userId);

  /// Download from secure storage
  Future<MResult<File>> downloadSecurePhoto(String photoId);

  /// Add secure photo from URL (for favorite photos synced from Supabase)
  Future<MResult<MSecurePhoto>> addSecurePhotoFromUrl({
    required String userId,
    required String imageUrl,
    required String photoId,
  });

  /// Unsecure photo
  Future<MResult<File>> unsecurePhoto(String photoId);
}
