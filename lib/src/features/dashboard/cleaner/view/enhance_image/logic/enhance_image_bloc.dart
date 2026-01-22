import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/logic/enhance_image_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:path_provider/path_provider.dart';

class EnhanceImageBloc extends Cubit<EnhanceImageState> {
  DomainManager get domain => DomainManager();
  final Map<String, Future<Uint8List?>> thumbnailFutures = {};

  EnhanceImageBloc() : super(EnhanceImageState());

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

  Future<void> processImageFromUrl(String url) async {
    if (isClosed) return;
    emit(state.copyWith(status: EnhanceImageStatus.processing));

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      emit(state.copyWith(status: EnhanceImageStatus.error));
      XToast.error(S.text.error_somethingWrongTryAgain);
      return;
    }

    final originalImageBytes = response.bodyBytes;
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
        '${tempDir.path}/temp_enhance_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(originalImageBytes);
    final result = await domain.photo.enhanceImage(tempFile);
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

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
      emit(state.copyWith(status: EnhanceImageStatus.error));
      XToast.error(result.error ?? S.text.error_somethingWrongTryAgain);
    }
  }

  Future<void> saveImage(Uint8List imageData) async {
    if (isClosed) return;

    emit(state.copyWith(status: EnhanceImageStatus.saving));

    final fileName = 'enhanced_${DateTime.now().millisecondsSinceEpoch}.png';
    final result = await domain.photo.saveImageToDevice(imageData, fileName);

    if (isClosed) return;

    if (result.isSuccess) {
      emit(state.copyWith(
        status: EnhanceImageStatus.saved,
        savedPath: result.data,
      ));

      final isSaveSuccess = await XAlert.show(
        title: S.text.success_resetPass_noti_Title,
        body: S.text.common_image_saved_successfully,
        actions: [XAlertButton(title: 'OK', key: 'ok')],
      );

      if (isSaveSuccess == 'ok') {
        AppCoordinator.pop();
        AppCoordinator.pop();
      }
    } else {
      emit(state.copyWith(status: EnhanceImageStatus.error));
      XToast.error(S.text.error_somethingWrongTryAgain);
    }
  }

  void reset() {
    emit(EnhanceImageState());
  }
}
