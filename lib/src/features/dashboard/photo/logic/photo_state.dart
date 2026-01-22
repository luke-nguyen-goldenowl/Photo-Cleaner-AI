import 'package:equatable/equatable.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import '../model/photo_item.dart';

enum PhotoViewStatus { initial, loading, success, error }

class PhotoViewState extends Equatable {
  const PhotoViewState({
    this.status = PhotoViewStatus.initial,
    required this.timelinePagination,
    required this.favoritePagination,
    this.isFavoriteMode = false,
    this.lastToggledFavoritePhotoId,
  });

  final PhotoViewStatus status;
  final MPagination<MPhotoTimelineGroup> timelinePagination;
  final MPagination<MPhotoItem> favoritePagination;
  final bool isFavoriteMode;
  final String? lastToggledFavoritePhotoId;

  List<MPhotoItem> get favoritePhotos => favoritePagination.data;

  PhotoViewState copyWith({
    PhotoViewStatus? status,
    MPagination<MPhotoTimelineGroup>? timelinePagination,
    MPagination<MPhotoItem>? favoritePagination,
    bool? isFavoriteMode,
    String? lastToggledFavoritePhotoId,
    bool clearLastToggledFavoritePhotoId = false,
  }) {
    return PhotoViewState(
      status: status ?? this.status,
      timelinePagination: timelinePagination ?? this.timelinePagination,
      favoritePagination: favoritePagination ?? this.favoritePagination,
      isFavoriteMode: isFavoriteMode ?? this.isFavoriteMode,
      lastToggledFavoritePhotoId: clearLastToggledFavoritePhotoId
          ? null
          : (lastToggledFavoritePhotoId ?? this.lastToggledFavoritePhotoId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        timelinePagination,
        favoritePagination,
        isFavoriteMode,
        lastToggledFavoritePhotoId,
      ];
}
