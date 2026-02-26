import 'dart:typed_data';

import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';

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
  final MPagination<MPhotoItem> photoPagination;
  final MPhotoItem? selectedPhoto;
  final Uint8List? processedImage;
  final String? savedPath;

  RemoveBgState({
    this.status = RemoveBgStatus.initial,
    MPagination<MPhotoItem>? photoPagination,
    this.selectedPhoto,
    this.processedImage,
    this.savedPath,
  }) : photoPagination =
            photoPagination ?? MPagination<MPhotoItem>(pageLimit: 100);

  RemoveBgState copyWith({
    RemoveBgStatus? status,
    MPagination<MPhotoItem>? photoPagination,
    MPhotoItem? selectedPhoto,
    Uint8List? processedImage,
    String? savedPath,
    bool clearSelectedPhoto = false,
    bool clearProcessedImage = false,
  }) {
    return RemoveBgState(
      status: status ?? this.status,
      photoPagination: photoPagination ?? this.photoPagination,
      selectedPhoto:
          clearSelectedPhoto ? null : (selectedPhoto ?? this.selectedPhoto),
      processedImage:
          clearProcessedImage ? null : (processedImage ?? this.processedImage),
      savedPath: savedPath ?? this.savedPath,
    );
  }

  List<MPhotoItem> get photos => photoPagination.data;

  bool get isProcessing => status == RemoveBgStatus.processing;
  bool get isSaving => status == RemoveBgStatus.saving;
}
