import 'package:myapp/src/features/dashboard/cleaner/view/make_video/model/audio_item.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
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
  final MPagination<MPhotoItem> photoPagination;
  final List<MPhotoItem> selectedPhotos;
  final MPagination<MAudioItem> audioPagination;
  final MAudioItem? selectedAudio;
  final String? videoPath;
  final String? errorMessage;
  final double progress;

  MakeVideoState({
    this.status = MakeVideoStatus.initial,
    this.videoPlayerController,
    MPagination<MPhotoItem>? photoPagination,
    this.selectedPhotos = const [],
    MPagination<MAudioItem>? audioPagination,
    this.selectedAudio,
    this.videoPath,
    this.errorMessage,
    this.progress = 0.0,
  })  : photoPagination =
            photoPagination ?? MPagination<MPhotoItem>(pageLimit: 100),
        audioPagination =
            audioPagination ?? MPagination<MAudioItem>(pageLimit: 10);
  MakeVideoState copyWith({
    MakeVideoStatus? status,
    VideoPlayerController? videoPlayerController,
    MPagination<MPhotoItem>? photoPagination,
    List<MPhotoItem>? selectedPhotos,
    MPagination<MAudioItem>? audioPagination,
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
      photoPagination: photoPagination ?? this.photoPagination,
      selectedPhotos: selectedPhotos ?? this.selectedPhotos,
      audioPagination: audioPagination ?? this.audioPagination,
      selectedAudio:
          clearSelectedAudio ? null : (selectedAudio ?? this.selectedAudio),
      videoPath: clearVideoPath ? null : (videoPath ?? this.videoPath),
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  List<MPhotoItem> get photos => photoPagination.data;
  List<MAudioItem> get audios => audioPagination.data;
  bool get isCreating => status == MakeVideoStatus.creating;
  bool get hasSelectedPhotos => selectedPhotos.isNotEmpty;
  bool get hasSelectedAudio => selectedAudio != null;
}
