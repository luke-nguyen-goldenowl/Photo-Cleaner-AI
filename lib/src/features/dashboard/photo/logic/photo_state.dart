import 'package:equatable/equatable.dart';
import '../model/photo_item.dart';

enum PhotoViewStatus { initial, loading, success, error }

class PhotoViewState extends Equatable {
  const PhotoViewState({
    this.status = PhotoViewStatus.initial,
    this.timelineGroups = const [],
    this.favoritePhotos = const [],
    this.isFavoriteMode = false,
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final PhotoViewStatus status;
  final List<MPhotoTimelineGroup> timelineGroups;
  final List<MPhotoItem> favoritePhotos;
  final bool isFavoriteMode;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get isLoading =>
      status == PhotoViewStatus.loading && timelineGroups.isEmpty;
  bool get isEmpty =>
      timelineGroups.isEmpty && status == PhotoViewStatus.success;
  int get totalPhotos =>
      timelineGroups.fold(0, (sum, group) => sum + group.photos.length);
  PhotoViewState copyWith({
    PhotoViewStatus? status,
    List<MPhotoTimelineGroup>? timelineGroups,
    List<MPhotoItem>? favoritePhotos,
    bool? isFavoriteMode,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return PhotoViewState(
      status: status ?? this.status,
      timelineGroups: timelineGroups ?? this.timelineGroups,
      favoritePhotos: favoritePhotos ?? this.favoritePhotos,
      isFavoriteMode: isFavoriteMode ?? this.isFavoriteMode,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        timelineGroups,
        favoritePhotos,
        isFavoriteMode,
        currentPage,
        hasMore,
        isLoadingMore,
        errorMessage,
      ];

  @override
  String toString() {
    return 'PhotoViewState(status: $status, groups: ${timelineGroups.length}, totalPhotos: $totalPhotos, currentPage: $currentPage, hasMore: $hasMore)';
  }
}
