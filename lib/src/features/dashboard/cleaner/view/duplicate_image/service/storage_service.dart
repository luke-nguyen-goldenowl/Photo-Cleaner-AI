import 'package:flutter/services.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/storage_infor.dart';
import 'package:myapp/src/network/model/common/result.dart';

class StorageService {
  static const platform = MethodChannel('storage');

  static Future<MResult<StorageInfo>> getStorageInfo() async {
    try {
      final result =
          await platform.invokeMethod<Map<dynamic, dynamic>>('getStorageInfo');

      if (result != null) {
        final totalBytes = (result['total'] as int?) ?? 0;
        final freeBytes = (result['free'] as int?) ?? 0;

        if (totalBytes > 0) {
          final totalGB = totalBytes / (1024 * 1024 * 1024);
          final freeGB = freeBytes / (1024 * 1024 * 1024);
          final usedGB = totalGB - freeGB;

          return MResult.success(
            StorageInfo(
              totalSpace: totalGB,
              usedSpace: usedGB,
              freeSpace: freeGB,
            ),
          );
        }
      }
    } catch (e) {
      return MResult.exception(e);
    }
    return MResult.success(
        StorageInfo(totalSpace: 0, usedSpace: 0, freeSpace: 0));
  }
}
