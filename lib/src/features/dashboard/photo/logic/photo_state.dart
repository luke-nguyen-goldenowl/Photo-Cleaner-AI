import 'package:equatable/equatable.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import '../model/photo_item.dart';

enum PhotoViewStatus { initial, loading, success, error }

class PhotoViewState extends Equatable {
  const PhotoViewState({
    this.status = PhotoViewStatus.initial,
    required this.timelinePagination,
    this.favoritePhotos = const [],
    this.isFavoriteMode = false,
  });

  final PhotoViewStatus status;
  final MPagination<MPhotoTimelineGroup> timelinePagination;
  final List<MPhotoItem> favoritePhotos;
  final bool isFavoriteMode;

  PhotoViewState copyWith({
    PhotoViewStatus? status,
    MPagination<MPhotoTimelineGroup>? timelinePagination,
    List<MPhotoItem>? favoritePhotos,
    bool? isFavoriteMode,
  }) {
    return PhotoViewState(
      status: status ?? this.status,
      timelinePagination: timelinePagination ?? this.timelinePagination,
      favoritePhotos: favoritePhotos ?? this.favoritePhotos,
      isFavoriteMode: isFavoriteMode ?? this.isFavoriteMode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        timelinePagination,
        favoritePhotos,
        isFavoriteMode,
      ];
}
