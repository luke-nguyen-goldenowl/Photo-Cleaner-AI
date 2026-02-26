import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/model/audio_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/video/video_repository.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class VideoRepositoryImpl extends VideoRepository {
  static const videoPickerChannel = MethodChannel('videoPickerPlatform');
  @override
  Future<MResult<bool>> saveVideoToGallery(String videoPath) async {
    try {
      Permission permissionType = Permission.photos;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permissionType = Permission.photos;
        } else {
          permissionType = Permission.storage;
        }
      }

      final currentStatus = await permissionType.status;
      if (!currentStatus.isGranted) {
        final requested = await permissionType.request();
        if (!requested.isGranted) {
          return MResult.error(S.text.error_permission);
        }
      }

      const platform = MethodChannel('videoPickerPlatform');
      await platform.invokeMethod('saveVideo', {'path': videoPath});

      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<MAudioItem>>> loadAudios({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        return MResult.error(S.text.error_permission);
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(
              type: OrderOptionType.updateDate,
              asc: false,
            ),
          ],
        ),
      );
      final List<MAudioItem> audioFiles = [];

      for (final assetPath in paths) {
        final start = page * pageSize;
        final end = start + pageSize;

        final assets = await assetPath.getAssetListRange(
          start: start,
          end: end,
        );

        for (final asset in assets) {
          final file = await asset.file;
          if (file != null) {
            final extension = p.extension(file.path).toLowerCase();
            if (['.mp3', '.wav', '.m4a', '.aac'].contains(extension)) {
              audioFiles.add(MAudioItem(
                path: file.path,
                name: p.basename(file.path),
                duration: asset.duration,
              ));
            }
          }
        }
      }

      return MResult.success(audioFiles);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<String>> createVideo(
      {required List<String> imagePaths, required String audioPath}) async {
    try {
      final result = await videoPickerChannel.invokeMethod('pickImage', {
        "path": imagePaths,
        "audio": audioPath,
      });
      return MResult.success(result);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<VideoPlayerController>> initializeVideoPlayer(
      String videoPath) async {
    try {
      VideoPlayerController controller;

      if (videoPath.startsWith('content://') ||
          videoPath.startsWith('file://')) {
        controller = VideoPlayerController.contentUri(Uri.parse(videoPath));
      } else {
        controller = VideoPlayerController.file(File(videoPath));
      }

      await controller.initialize();

      return MResult.success(controller);
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
