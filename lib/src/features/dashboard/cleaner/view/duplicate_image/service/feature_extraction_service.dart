import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:myapp/generated/assets/assets.gen.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/helper/scan_helper.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FeatureExtractionService {
  Interpreter? _interpreter;
  static const int inputSize = 224;
  int featureVectorSize = 100;

  static String? _cachedModelPath;

  Future<MResult<String>> copyModelToFile() async {
    if (_cachedModelPath != null && await File(_cachedModelPath!).exists()) {
      return MResult.success(_cachedModelPath!);
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final modelPath =
          '${tempDir.path}/small-100-224-feature-vector-metadata.tflite';
      final modelFile = File(modelPath);

      if (await modelFile.exists()) {
        _cachedModelPath = modelPath;
        return MResult.success(modelPath);
      }

      final modelData = await rootBundle.load(
        Assets.models.small100224FeatureVectorMetadata,
      );
      final bytes = modelData.buffer.asUint8List();
      await modelFile.writeAsBytes(bytes);

      _cachedModelPath = modelPath;
      return MResult.success(modelPath);
    } catch (e) {
      return MResult.error(S.text.error_somethingWrongTryAgain);
    }
  }

  Future<MResult<void>> initializeFromPath(String modelPath) async {
    try {
      _interpreter = Interpreter.fromFile(File(modelPath));

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      featureVectorSize = outputShape.last;
      return MResult.success(null);
    } catch (e) {
      return MResult.error(S.text.error_somethingWrongTryAgain);
    }
  }

  Future<MResult<List<double>>> extractFeatures(String imagePath) async {
    try {
      if (_interpreter == null) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final input = ScanHelper.preprocessImage(image);
      final inputTensor = input.reshape([1, inputSize, inputSize, 3]);
      final output = List.filled(
        1 * featureVectorSize,
        0.0,
      ).reshape([1, featureVectorSize]);

      _interpreter!.run(inputTensor, output);

      final features = List<double>.from(output[0]);
      return MResult.success(features);
    } catch (e) {
      return MResult.error(S.text.error_somethingWrongTryAgain);
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
