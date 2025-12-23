import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/logic/make_video_state.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/model/audio_item.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:photo_manager/photo_manager.dart';

class MakeVideoBloc extends Cubit<MakeVideoState> {
  DomainManager get domain => DomainManager();

  final Map<String, Future<Uint8List?>> thumbnailFutures = {};

  static const videoPickerChannel = MethodChannel('videoPickerPlatform');
  static const eventChannel = EventChannel('progress');
  StreamSubscription? _subscription;

  MakeVideoBloc() : super(MakeVideoState()) {
    _listenToProgress();
  }

  void _listenToProgress() {
    _subscription = eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is String) {
          final parts = event.split(' ');
          if (parts.length >= 2) {
            final percent = double.tryParse(parts[1]) ?? 0.0;
            final progressValue = (percent / 100).clamp(0.0, 1.0);
            emit(state.copyWith(progress: progressValue));
          }
        }
      },
      onError: (Object obj, StackTrace stackTrace) {
        debugPrint('Error receiving progress: $obj');
      },
    );
  }

  Future<void> initializeVideo(String videoPath) async {
    emit(state.copyWith(status: MakeVideoStatus.loading));

    final result = await domain.video.initializeVideoPlayer(videoPath);

    if (isClosed) return;

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        status: MakeVideoStatus.loaded,
        videoPlayerController: result.data,
      ));
    } else {
      emit(state.copyWith(
        status: MakeVideoStatus.error,
      ));
    }
  }

  Future<void> loadPhotos() async {
    emit(state.copyWith(status: MakeVideoStatus.loading));

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
        status: MakeVideoStatus.loaded,
        photos: photos,
      ));
    } else {
      emit(state.copyWith(
        status: MakeVideoStatus.error,
      ));
    }
  }

  void togglePhotoSelection(MPhotoItem photo) {
    final selectedPhotos = List<MPhotoItem>.from(state.selectedPhotos);

    final index = selectedPhotos.indexWhere((p) => p.id == photo.id);
    if (index >= 0) {
      selectedPhotos.removeAt(index);
    } else {
      selectedPhotos.add(photo);
    }

    emit(state.copyWith(selectedPhotos: selectedPhotos));
  }

  Future<void> loadAllAudioFromDevice() async {
    emit(state.copyWith(status: MakeVideoStatus.audioLoading));
    final result = await domain.video.loadAudios();
    if (isClosed) return;

    if (result.isSuccess) {
      emit(state.copyWith(
        status: MakeVideoStatus.audioLoaded,
        audioFiles: result.data ?? [],
      ));
    } else {
      emit(state.copyWith(
        status: MakeVideoStatus.error,
        errorMessage: result.error,
      ));
    }
  }

  void selectAudio(MAudioItem audio) {
    emit(state.copyWith(selectedAudio: audio));
  }

  Future<void> createVideo() async {
    if (state.selectedPhotos.isEmpty || state.selectedAudio == null) {
      return;
    }

    emit(state.copyWith(status: MakeVideoStatus.creating, progress: 0.0));

    final imagePaths = <String>[];
    for (final photo in state.selectedPhotos) {
      final asset = photo.asset;
      if (asset != null) {
        final file = await asset.file;
        if (file != null) {
          imagePaths.add(file.path);
        }
      }
    }

    if (imagePaths.isEmpty) {
      emit(state.copyWith(
        status: MakeVideoStatus.error,
      ));
      return;
    }

    final audioPath = state.selectedAudio?.path;
    if (audioPath == null || audioPath.isEmpty) {
      emit(state.copyWith(status: MakeVideoStatus.error));
      return;
    }

    final result = await domain.video.createVideo(
      imagePaths: imagePaths,
      audioPath: audioPath,
    );

    if (isClosed) return;
    final videoOutput = result.data;
    if (result.isSuccess && videoOutput != null) {
      emit(state.copyWith(
        status: MakeVideoStatus.created,
        videoPath: videoOutput,
        progress: 1.0,
      ));
      AppCoordinator.showResultVideo(videoPath: videoOutput, bloc: this);
    } else {
      emit(state.copyWith(
        status: MakeVideoStatus.error,
      ));
    }
  }

  void reset() {
    emit(MakeVideoState());
  }

  Future<void> saveVideo() async {
    final videoPath = state.videoPath;
    if (videoPath == null || videoPath.isEmpty) {
      emit(state.copyWith(status: MakeVideoStatus.error));
      return;
    }

    emit(state.copyWith(status: MakeVideoStatus.saving));

    final result = await domain.video.saveVideoToGallery(videoPath);

    if (isClosed) return;

    if (result.isSuccess) {
      emit(state.copyWith(status: MakeVideoStatus.saved));
      final isSaveSuccess = await XAlert.show(
        title: S.text.success_resetPass_noti_Title,
        body: S.text.common_save_video_success,
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
        AppCoordinator.pop();
      }
    } else {
      emit(state.copyWith(
        status: MakeVideoStatus.error,
      ));
    }
  }

  @override
  Future<void> close() {
    state.videoPlayerController?.dispose();
    _subscription?.cancel();
    return super.close();
  }
}
