import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/remove_bg/logic/remove_bg.state.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:photo_manager/photo_manager.dart';

class RemoveBgBloc extends Cubit<RemoveBgState> {
  //final PhotoRepository photoRepository;
  DomainManager get domain => DomainManager();
  final Map<String, Future<Uint8List?>> thumbnailFutures = {};

  RemoveBgBloc() : super(RemoveBgState());

  Future<void> loadPhotos(BuildContext context) async {
    emit(state.copyWith(status: RemoveBgStatus.loading));

    final result = await domain.photo.loadPhotos(
      page: 0,
      pageSize: 1000,
      context: context,
    );

    if (isClosed) return;

    if (result.isSuccess) {
      final photos = result.data ?? [];
      thumbnailFutures.clear();
      for (final photo in photos) {
        if (photo.asset != null) {
          thumbnailFutures[photo.id] = photo.asset!.thumbnailDataWithSize(
            const ThumbnailSize.square(200),
            quality: 80,
          );
        }
      }

      emit(state.copyWith(
        status: RemoveBgStatus.loaded,
        photos: photos,
      ));
    } else {
      if (context.mounted) {
        emit(state.copyWith(
          status: RemoveBgStatus.error,
          errorMessage: result.error,
        ));
      }
    }
  }

  void selectPhoto(MPhotoItem photo) {
    emit(state.copyWith(selectedPhoto: photo));
  }

  Future<void> processImage(BuildContext context) async {
    if (state.selectedPhoto == null) {
      return;
    }

    if (isClosed) return;
    emit(state.copyWith(status: RemoveBgStatus.processing));

    final asset = state.selectedPhoto!.asset;
    if (asset == null) {
      if (context.mounted) {
        emit(state.copyWith(
          status: RemoveBgStatus.error,
          errorMessage: state.errorMessage,
        ));
      }
      return;
    }

    final file = await asset.file;
    if (isClosed) return;

    if (file == null) {
      if (context.mounted) {
        emit(state.copyWith(
          status: RemoveBgStatus.error,
          errorMessage: state.errorMessage,
        ));
      }
      return;
    }
    final result = await domain.photo.removeBackground(file, context);

    if (isClosed) return;

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        status: RemoveBgStatus.processed,
        processedImage: result.data,
      ));
      AppCoordinator.showResultRemoveBg(imageData: result.data!);
    } else {
      if (context.mounted) {
        emit(state.copyWith(
          status: RemoveBgStatus.error,
          errorMessage: result.error,
        ));
      }
    }
  }

  Future<void> saveImage(BuildContext context) async {
    if (state.processedImage == null) {
      return;
    }

    if (isClosed) return;
    emit(state.copyWith(status: RemoveBgStatus.saving));

    final fileName = 'removed_bg_${DateTime.now().millisecondsSinceEpoch}.png';
    final result = await domain.photo
        .saveImageToDevice(state.processedImage!, fileName, context);

    if (isClosed) return;

    if (result.isSuccess) {
      emit(state.copyWith(
        status: RemoveBgStatus.saved,
        savedPath: result.data,
      ));
      final isSaveSuccess = await XAlert.show(
        title: S.of(context).success_resetPass_noti_Title,
        body: S.of(context).common_image_saved_successfully,
        actions: [
          XAlertButton(
            title: 'OK',
            key: 'ok',
          ),
        ],
      );
      if (isSaveSuccess == 'ok' && context.mounted) {
        AppCoordinator.pop();
        AppCoordinator.pop();
      }
    } else {
      if (context.mounted) {
        emit(state.copyWith(
          status: RemoveBgStatus.error,
          errorMessage: result.error,
        ));
      }
    }
  }

  void reset() {
    emit(RemoveBgState());
  }

  void setProcessedImage(Uint8List imageData) {
    emit(state.copyWith(
      processedImage: imageData,
      status: RemoveBgStatus.processed,
    ));
  }
}
