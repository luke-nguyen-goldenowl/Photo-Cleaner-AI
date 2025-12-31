part of 'duplicate_image_bloc.dart';

enum DuplicateImageStatus {
  initial,
  scanning,
  completed,
  deleting,
  deleteSuccess,
  error,
}

class DuplicateImageState extends Equatable {
  const DuplicateImageState({
    this.status = DuplicateImageStatus.initial,
    this.groups = const [],
    this.progress = 0.0,
    this.deletedCount = 0,
    this.storageInfo,
  });

  final DuplicateImageStatus status;
  final List<MDuplicateImageGroup> groups;
  final double progress;
  final int deletedCount;
  final StorageInfo? storageInfo;

  bool get isScanning => status == DuplicateImageStatus.scanning;
  bool get isCompleted => status == DuplicateImageStatus.completed;
  bool get isDeleting => status == DuplicateImageStatus.deleting;
  bool get isDeleteSuccess => status == DuplicateImageStatus.deleteSuccess;
  bool get hasError => status == DuplicateImageStatus.error;

  int get totalSelectedSize {
    int total = 0;
    for (final group in groups) {
      for (final image in group.images) {
        if (image.isSelected) {
          total += image.size;
        }
      }
    }
    return total;
  }

  @override
  List<Object?> get props => [
        status,
        groups,
        progress,
        deletedCount,
        storageInfo,
      ];

  DuplicateImageState copyWith({
    DuplicateImageStatus? status,
    List<MDuplicateImageGroup>? groups,
    double? progress,
    int? deletedCount,
    StorageInfo? storageInfo,
  }) {
    return DuplicateImageState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      progress: progress ?? this.progress,
      deletedCount: deletedCount ?? this.deletedCount,
      storageInfo: storageInfo ?? this.storageInfo,
    );
  }
}
