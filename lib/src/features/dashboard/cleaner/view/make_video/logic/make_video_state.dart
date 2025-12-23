import 'package:myapp/src/features/dashboard/cleaner/view/make_video/model/audio_item.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:video_player/video_player.dart';

enum MakeVideoStatus {
  initial,
  loading,
  loaded,
  audioLoading,
  audioLoaded,
  creating,
  created,
  initializing,
  initialized,
  saving,
  saved,
  error
}

class MakeVideoState {
  final MakeVideoStatus status;
  final VideoPlayerController? videoPlayerController;
  final List<MPhotoItem> photos;
  final List<MPhotoItem> selectedPhotos;
  final List<MAudioItem> audioFiles;
  final MAudioItem? selectedAudio;
  final String? videoPath;
  final String? errorMessage;
  final double progress;

  MakeVideoState({
    this.status = MakeVideoStatus.initial,
    this.videoPlayerController,
    this.photos = const [],
    this.selectedPhotos = const [],
    this.audioFiles = const [],
    this.selectedAudio,
    this.videoPath,
    this.errorMessage,
    this.progress = 0.0,
  });

  MakeVideoState copyWith({
    MakeVideoStatus? status,
    VideoPlayerController? videoPlayerController,
    List<MPhotoItem>? photos,
    List<MPhotoItem>? selectedPhotos,
    List<MAudioItem>? audioFiles,
    MAudioItem? selectedAudio,
    String? videoPath,
    String? errorMessage,
    double? progress,
    bool clearSelectedAudio = false,
    bool clearVideoPath = false,
  }) {
    return MakeVideoState(
      status: status ?? this.status,
      videoPlayerController:
          videoPlayerController ?? this.videoPlayerController,
      photos: photos ?? this.photos,
      selectedPhotos: selectedPhotos ?? this.selectedPhotos,
      audioFiles: audioFiles ?? this.audioFiles,
      selectedAudio:
          clearSelectedAudio ? null : (selectedAudio ?? this.selectedAudio),
      videoPath: clearVideoPath ? null : (videoPath ?? this.videoPath),
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  bool get isCreating => status == MakeVideoStatus.creating;
  bool get hasSelectedPhotos => selectedPhotos.isNotEmpty;
  bool get hasSelectedAudio => selectedAudio != null;
}
