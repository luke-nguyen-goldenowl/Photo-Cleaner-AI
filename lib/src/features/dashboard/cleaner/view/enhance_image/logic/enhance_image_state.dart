import 'dart:typed_data';

import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';

enum EnhanceImageStatus {
  initial,
  loading,
  loaded,
  processing,
  processed,
  saving,
  saved,
  error
}

class EnhanceImageState {
  final EnhanceImageStatus status;
  final List<MPhotoItem> photos;
  final MPhotoItem? selectedPhoto;
  final Uint8List? originalImage;
  final Uint8List? processedImage;
  final String? savedPath;

  EnhanceImageState({
    this.status = EnhanceImageStatus.initial,
    this.photos = const [],
    this.selectedPhoto,
    this.originalImage,
    this.processedImage,
    this.savedPath,
  });

  EnhanceImageState copyWith({
    EnhanceImageStatus? status,
    List<MPhotoItem>? photos,
    MPhotoItem? selectedPhoto,
    Uint8List? originalImage,
    Uint8List? processedImage,
    String? savedPath,
    bool clearSelectedPhoto = false,
    bool clearOriginalImage = false,
    bool clearProcessedImage = false,
  }) {
    return EnhanceImageState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      selectedPhoto:
          clearSelectedPhoto ? null : (selectedPhoto ?? this.selectedPhoto),
      originalImage:
          clearOriginalImage ? null : (originalImage ?? this.originalImage),
      processedImage:
          clearProcessedImage ? null : (processedImage ?? this.processedImage),
      savedPath: savedPath ?? this.savedPath,
    );
  }

  bool get isProcessing => status == EnhanceImageStatus.processing;
  bool get isSaving => status == EnhanceImageStatus.saving;
}
