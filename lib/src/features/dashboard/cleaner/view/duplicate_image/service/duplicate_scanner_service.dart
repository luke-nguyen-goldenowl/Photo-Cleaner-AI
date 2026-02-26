import 'dart:isolate';
import 'dart:io';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/helper/scan_helper.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image_group.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_scan_progress.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/service/feature_extraction_service.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/model/common/result.dart';

class _ScanMessage {
  final SendPort sendPort;
  final List<String> imagePaths;
  final String modelPath;
  final double similarityThreshold;

  _ScanMessage({
    required this.sendPort,
    required this.imagePaths,
    required this.modelPath,
    this.similarityThreshold = 0.85,
  });
}

class _ScanResult {
  final List<MDuplicateImageGroup>? groups;
  final String? error;

  _ScanResult.success(this.groups) : error = null;
  _ScanResult.error(this.error) : groups = null;

  bool get isSuccess => groups != null;
  bool get isError => error != null;
}

class DuplicateScannerService {
  static const double defaultSimilarityThreshold = 0.85;

  Future<MResult<List<MDuplicateImageGroup>>> scanForDuplicates({
    required List<String> imagePaths,
    Function(MDuplicateScanProgress)? onProgress,
    double similarityThreshold = defaultSimilarityThreshold,
  }) async {
    try {
      _ScanResult? result;
      final receivePort = ReceivePort();

      if (imagePaths.isEmpty) {
        return MResult.success([]);
      }

      final extractor = FeatureExtractionService();
      final modelResult = await extractor.copyModelToFile();

      if (modelResult.isError) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      await Isolate.spawn(
        _scanIsolate,
        _ScanMessage(
          sendPort: receivePort.sendPort,
          imagePaths: imagePaths,
          modelPath: modelResult.data!,
          similarityThreshold: similarityThreshold,
        ),
      );

      await for (final message in receivePort) {
        if (message is MDuplicateScanProgress) {
          onProgress?.call(message);
        } else if (message is _ScanResult) {
          result = message;
          break;
        }
      }

      receivePort.close();

      if (result == null) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      if (result.isError) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      return MResult.success(result.groups!);
    } catch (e) {
      return MResult.error(S.text.error_somethingWrongTryAgain);
    }
  }

  static Future<void> _scanIsolate(_ScanMessage message) async {
    final extractor = FeatureExtractionService();

    try {
      final initResult = await extractor.initializeFromPath(message.modelPath);

      if (initResult.isError) {
        message.sendPort.send(_ScanResult.error(initResult.error));
        return;
      }

      final images = <MDuplicateImage>[];
      final total = message.imagePaths.length;

      for (int i = 0; i < message.imagePaths.length; i++) {
        final path = message.imagePaths[i];

        message.sendPort.send(
          MDuplicateScanProgress(
            current: i + 1,
            total: total * 2,
          ),
        );

        try {
          final featuresResult = await extractor.extractFeatures(path);

          if (featuresResult.isError) {
            continue;
          }

          final sharpness = await ScanHelper.calculateSharpness(path);
          final fileSize = await File(path).length();

          images.add(
            MDuplicateImage(
              id: 'img_$i',
              path: path,
              features: featuresResult.data!,
              size: fileSize,
              sharpness: sharpness,
            ),
          );
        } catch (e) {
          continue;
        }
      }

      if (images.length < 2) {
        message.sendPort
            .send(_ScanResult.error(S.text.common_image_not_found_title));
        return;
      }

      message.sendPort.send(
        MDuplicateScanProgress(
          current: total,
          total: total * 2,
        ),
      );

      final duplicateGroups = ScanHelper.findDuplicates(
        images,
        message.similarityThreshold,
      );

      for (final group in duplicateGroups) {
        group.images.sort((a, b) => b.sharpness.compareTo(a.sharpness));
      }

      message.sendPort.send(
        MDuplicateScanProgress(
          current: total * 2,
          total: total * 2,
        ),
      );

      message.sendPort.send(_ScanResult.success(duplicateGroups));
    } catch (e) {
      message.sendPort.send(_ScanResult.error(e.toString()));
    } finally {
      extractor.dispose();
    }
  }
}
