import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image_group.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/storage_infor.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/service/storage_service.dart';
import 'package:myapp/src/network/domain_manager.dart';
part 'duplicate_image_state.dart';

class DuplicateImageBloc extends Cubit<DuplicateImageState> {
  DomainManager get domain => DomainManager();

  DuplicateImageBloc() : super(const DuplicateImageState()) {
    loadStorageInfo();
  }

  Future<void> startScan() async {
    emit(state.copyWith(status: DuplicateImageStatus.scanning, progress: 0.0));
    loadStorageInfo();

    final result = await domain.photo.scanForDuplicates(
      onProgress: (progress) {
        emit(state.copyWith(
          progress: progress.percentage / 100,
        ));
      },
      similarityThreshold: 0.85,
    );

    if (result.isSuccess) {
      final groups = result.data ?? [];
      emit(state.copyWith(
        status: DuplicateImageStatus.completed,
        groups: groups,
        progress: 1.0,
      ));
      loadStorageInfo();
    } else {
      emit(state.copyWith(
        status: DuplicateImageStatus.error,
      ));
    }
  }

  void toggleImageSelection(int groupIndex, int imageIndex) {
    final groups = List<MDuplicateImageGroup>.from(state.groups);
    final group = groups[groupIndex];
    final images = List<MDuplicateImage>.from(group.images);
    final image = images[imageIndex];

    images[imageIndex] = image.copyWith(isSelected: !image.isSelected);
    groups[groupIndex] = MDuplicateImageGroup(
      images: images,
      similarity: group.similarity,
    );

    emit(state.copyWith(groups: groups));
  }

  Future<void> deleteSelectedImages() async {
    emit(state.copyWith(status: DuplicateImageStatus.deleting));

    final selectedPaths = <String>[];
    for (final group in state.groups) {
      for (final image in group.images) {
        if (image.isSelected) {
          selectedPaths.add(image.path);
        }
      }
    }

    final result = await domain.photo.deleteImagesByPaths(selectedPaths);

    if (result.isSuccess) {
      final deletedCount = result.data ?? 0;

      final groups = List<MDuplicateImageGroup>.from(state.groups);
      for (var i = 0; i < groups.length; i++) {
        final images =
            groups[i].images.where((img) => !img.isSelected).toList();

        if (images.isNotEmpty) {
          groups[i] = MDuplicateImageGroup(
            images: images,
            similarity: groups[i].similarity,
          );
        }
      }
      groups.removeWhere((group) => group.images.isEmpty);

      emit(state.copyWith(
        status: DuplicateImageStatus.deleteSuccess,
        groups: groups,
        deletedCount: deletedCount,
      ));
      loadStorageInfo();
    } else {
      emit(state.copyWith(
        status: DuplicateImageStatus.error,
      ));
    }
  }

  Future<void> loadStorageInfo() async {
    final storageInfoResult = await StorageService.getStorageInfo();
    emit(state.copyWith(storageInfo: storageInfoResult.data));
  }

  void reset() {
    emit(const DuplicateImageState());
  }
}
