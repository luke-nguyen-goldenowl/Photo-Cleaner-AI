import 'dart:typed_data';

import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';

enum RemoveBgStatus {
  initial,
  loading,
  loaded,
  processing,
  processed,
  saving,
  saved,
  error
}

class RemoveBgState {
  final RemoveBgStatus status;
  final List<MPhotoItem> photos;
  final MPhotoItem? selectedPhoto;
  final Uint8List? processedImage;
  final String? savedPath;
  final String? errorMessage;

  RemoveBgState({
    this.status = RemoveBgStatus.initial,
    this.photos = const [],
    this.selectedPhoto,
    this.processedImage,
    this.savedPath,
    this.errorMessage,
  });

  RemoveBgState copyWith({
    RemoveBgStatus? status,
    List<MPhotoItem>? photos,
    MPhotoItem? selectedPhoto,
    Uint8List? processedImage,
    String? savedPath,
    String? errorMessage,
    bool clearSelectedPhoto = false,
    bool clearProcessedImage = false,
  }) {
    return RemoveBgState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      selectedPhoto:
          clearSelectedPhoto ? null : (selectedPhoto ?? this.selectedPhoto),
      processedImage:
          clearProcessedImage ? null : (processedImage ?? this.processedImage),
      savedPath: savedPath ?? this.savedPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isProcessing => status == RemoveBgStatus.processing;
  bool get isSaving => status == RemoveBgStatus.saving;
}
