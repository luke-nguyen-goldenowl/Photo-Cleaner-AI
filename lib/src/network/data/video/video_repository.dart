import 'package:myapp/src/features/dashboard/cleaner/view/make_video/model/audio_item.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:video_player/video_player.dart';

abstract class VideoRepository {
  Future<MResult<List<MAudioItem>>> loadAudios({
    int page = 0,
    int pageSize = 100,
  });

  Future<MResult<bool>> saveVideoToGallery(String videoPath);

  Future<MResult<String>> createVideo({
    required List<String> imagePaths,
    required String audioPath,
  });

  Future<MResult<VideoPlayerController>> initializeVideoPlayer(
      String videoPath);
}
