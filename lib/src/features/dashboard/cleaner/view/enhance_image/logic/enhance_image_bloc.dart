import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/logic/enhance_image_state.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:photo_manager/photo_manager.dart';

class EnhanceImageBloc extends Cubit<EnhanceImageState> {
  DomainManager get domain => DomainManager();
  final Map<String, Future<Uint8List?>> thumbnailFutures = {};

  EnhanceImageBloc() : super(EnhanceImageState());

  Future<void> loadPhotos() async {
    emit(state.copyWith(status: EnhanceImageStatus.loading));

    final result = await domain.photo.loadPhotos(
      page: 0,
      pageSize: 1000,
    );

    if (isClosed) return;

    if (result.isSuccess) {
      final photos = result.data ?? [];
      thumbnailFutures.clear();
      for (final photo in photos) {
        final asset = photo.asset;
        if (asset != null) {
          thumbnailFutures[photo.id] = asset.thumbnailDataWithSize(
            const ThumbnailSize.square(200),
            quality: 80,
          );
        }
      }

      emit(state.copyWith(
        status: EnhanceImageStatus.loaded,
        photos: photos,
      ));
    } else {
      emit(state.copyWith(
        status: EnhanceImageStatus.error,
      ));
    }
  }

  void selectPhoto(MPhotoItem photo) {
    emit(state.copyWith(selectedPhoto: photo));
  }

  Future<void> processImage() async {
    final selectedPhoto = state.selectedPhoto;

    if (selectedPhoto == null) {
      return;
    }

    if (isClosed) return;
    emit(state.copyWith(status: EnhanceImageStatus.processing));

    final asset = selectedPhoto.asset;
    if (asset == null) {
      emit(state.copyWith(
        status: EnhanceImageStatus.error,
      ));
      return;
    }

    final file = await asset.file;
    if (isClosed) return;

    if (file == null) {
      emit(state.copyWith(
        status: EnhanceImageStatus.error,
      ));
      return;
    }

    // Get original image
    final originalImageBytes = await asset.originBytes;

    final result = await domain.photo.enhanceImage(file);

    if (isClosed) return;
    final processedData = result.data;

    if (result.isSuccess && processedData != null) {
      emit(state.copyWith(
        status: EnhanceImageStatus.processed,
        originalImage: originalImageBytes,
        processedImage: processedData,
      ));
      AppCoordinator.showResultEnhanceImage(
        originalImage: originalImageBytes!,
        enhancedImage: processedData,
      );
    } else {
      emit(state.copyWith(
        status: EnhanceImageStatus.error,
      ));
    }
  }

  Future<void> processImageFromFile(File file) async {
    if (isClosed) return;
    emit(state.copyWith(status: EnhanceImageStatus.processing));
    final originalImageBytes = await file.readAsBytes();

    final result = await domain.photo.enhanceImage(file);

    if (isClosed) return;
    final processedData = result.data;

    if (result.isSuccess && processedData != null) {
      emit(state.copyWith(
        status: EnhanceImageStatus.processed,
        originalImage: originalImageBytes,
        processedImage: processedData,
      ));
      AppCoordinator.showResultEnhanceImage(
        originalImage: originalImageBytes,
        enhancedImage: processedData,
      );
    } else {
      emit(state.copyWith(
        status: EnhanceImageStatus.error,
      ));
    }
  }

  Future<void> saveImage() async {
    final imageToSave = state.processedImage;

    if (imageToSave == null) {
      return;
    }

    if (isClosed) return;
    emit(state.copyWith(status: EnhanceImageStatus.saving));

    final fileName = 'enhanced_${DateTime.now().millisecondsSinceEpoch}.png';
    final result = await domain.photo.saveImageToDevice(imageToSave, fileName);

    if (isClosed) return;

    if (result.isSuccess) {
      emit(state.copyWith(
        status: EnhanceImageStatus.saved,
        savedPath: result.data,
      ));
      final isSaveSuccess = await XAlert.show(
        title: S.text.success_resetPass_noti_Title,
        body: S.text.common_image_saved_successfully,
        actions: [
          XAlertButton(
            title: 'OK',
            key: 'ok',
          ),
        ],
      );
      if (isSaveSuccess == 'ok') {
        AppCoordinator.pop();
        AppCoordinator.pop();
      }
    } else {
      emit(state.copyWith(
        status: EnhanceImageStatus.error,
      ));
    }
  }

  void reset() {
    emit(EnhanceImageState());
  }

  void setProcessedImages(Uint8List originalImage, Uint8List enhancedImage) {
    emit(state.copyWith(
      originalImage: originalImage,
      processedImage: enhancedImage,
      status: EnhanceImageStatus.processed,
    ));
  }
}
