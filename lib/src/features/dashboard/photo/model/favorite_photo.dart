import 'package:equatable/equatable.dart';

enum SyncStatus { pending, synced, failed }

class MFavoritePhoto extends Equatable {
  const MFavoritePhoto({
    this.id,
    required this.photoId,
    required this.userId,
    this.imageUrl,
    this.localPath,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
  });

  final int? id;
  final String photoId;
  final String userId;
  final String? imageUrl;
  final String? localPath;
  final SyncStatus syncStatus;
  final DateTime createdAt;

  MFavoritePhoto copyWith({
    int? id,
    String? photoId,
    String? userId,
    String? imageUrl,
    String? localPath,
    SyncStatus? syncStatus,
    DateTime? createdAt,
  }) {
    return MFavoritePhoto(
      id: id ?? this.id,
      photoId: photoId ?? this.photoId,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      localPath: localPath ?? this.localPath,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MFavoritePhoto.fromLocalDb(Map<String, dynamic> map) {
    return MFavoritePhoto(
      id: map['id'] as int?,
      photoId: map['photo_id'] as String,
      userId: map['user_id'] as String,
      imageUrl: map['image_url'] as String?,
      localPath: map['image_path'] as String?,
      syncStatus: _parseSyncStatus(map['sync_status'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  factory MFavoritePhoto.fromSupabase(Map<String, dynamic> map) {
    int? id;
    if (map['id'] != null) {
      id = int.tryParse(map['id'].toString());
    }
    final userId = map['user_id']?.toString() ?? '';
    final photoId = map['photo_id']?.toString() ?? '';
    final imageUrl = map['image_url']?.toString();
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(map['created_at'].toString());
    } catch (_) {
      createdAt = DateTime.now();
    }

    return MFavoritePhoto(
      id: id,
      photoId: photoId,
      userId: userId,
      imageUrl: imageUrl,
      localPath: null,
      syncStatus: SyncStatus.synced,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toLocalDb() {
    return {
      'photo_id': photoId,
      'user_id': userId,
      'image_url': imageUrl,
      'image_path': localPath,
      'sync_status': syncStatus.name,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  static SyncStatus _parseSyncStatus(String? status) {
    switch (status) {
      case 'synced':
        return SyncStatus.synced;
      case 'failed':
        return SyncStatus.failed;
      case 'pending':
      default:
        return SyncStatus.pending;
    }
  }

  @override
  List<Object?> get props => [
        id,
        photoId,
        userId,
        imageUrl,
        localPath,
        syncStatus,
        createdAt,
      ];
}
