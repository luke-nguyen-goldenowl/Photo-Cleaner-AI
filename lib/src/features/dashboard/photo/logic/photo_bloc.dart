import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'photo_state.dart';

class PhotoViewBloc extends Cubit<PhotoViewState> {
  //final PhotoRepository photoRepository;
  DomainManager get domain => DomainManager();
  String? get _userId => UserPrefs.I.getUser()?.id;
  PhotoViewBloc()
      : super(PhotoViewState(
          timelinePagination: MPagination<MPhotoTimelineGroup>(),
        )) {
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    if (isClosed) return;
    if (!state.timelinePagination.canLoad) return;

    final currentPage = state.timelinePagination.page;

    emit(state.copyWith(
      timelinePagination: state.timelinePagination.toLoading(),
      status: currentPage == 0 ? PhotoViewStatus.loading : state.status,
      isFavoriteMode: false,
    ));

    final result = await domain.photo.loadPhotosByTimeline(
      page: currentPage,
      pageSize: AppConstants.pageSize,
    );

    if (isClosed) return;

    if (!result.isSuccess) {
      emit(state.copyWith(status: PhotoViewStatus.error));
      return;
    }

    final newGroups = result.data ?? [];

    final int fetchedPhotoCount =
        newGroups.fold(0, (sum, group) => sum + group.photos.length);

    final isLastPage = fetchedPhotoCount < AppConstants.pageSize;

    final totalPage = isLastPage ? (currentPage + 1) : -1;

    final countData = isLastPage
        ? (state.timelinePagination.data.length + newGroups.length)
        : -1;

    emit(state.copyWith(
      status: PhotoViewStatus.success,
      timelinePagination: state.timelinePagination.addAll(
        newGroups,
        totalPage: totalPage,
        countData: countData,
      ),
    ));
  }

  Future<void> refresh() async {
    //await loadPhotos(isLoadMore: false);
    emit(state.copyWith(timelinePagination: MPagination()));
    await loadPhotos();
  }

  Future<bool> sharePhoto(String photoId) async {
    final result = await domain.photo.sharePhoto(photoId);
    return result.isSuccess && result.data == true;
  }

  Future<bool> deletePhoto(String photoId) async {
    final key = await XAlert.show(
      title: S.text.common_delete_title_alert,
      body: S.text.common_delete_confirm_title,
      actions: [
        XAlertButton(
          title: S.text.common_delete_button_text,
          isDestructiveAction: true,
          key: 'delete',
        ),
        XAlertButton(title: S.text.common_cancelButton_title),
      ],
    );

    if (key != 'delete') {
      return false;
    }

    final result = await domain.photo.deletePhoto(photoId);
    if (isClosed) return result.isSuccess;

    if (result.isSuccess && result.data == true) {
      final updatedGroups = state.timelinePagination.data
          .map((group) {
            final updatedPhotos =
                group.photos.where((p) => p.id != photoId).toList();
            return MPhotoTimelineGroup(
              date: group.date,
              photos: updatedPhotos.cast<MPhotoItem>(),
            );
          })
          .where((group) => group.photos.isNotEmpty)
          .toList();

      final updatedFavorites = state.isFavoriteMode
          ? state.favoritePhotos.where((p) => p.id != photoId).toList()
          : state.favoritePhotos;

      if (isClosed) return true;
      emit(state.copyWith(
        // timelineGroups: updatedGroups,
        timelinePagination: state.timelinePagination.copyWith(
          data: updatedGroups,
        ),
        favoritePhotos: updatedFavorites,
      ));
      return true;
    }
    return false;
  }

  Future<void> loadFavoritePhotos() async {
    if (isClosed) return;
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      emit(state.copyWith(
        status: PhotoViewStatus.error,
      ));

      return;
    }
    emit(state.copyWith(status: PhotoViewStatus.loading, isFavoriteMode: true));

    final result = await domain.photo.loadFavoritePhotos(uid);

    if (isClosed) return;

    if (!result.isSuccess) {
      emit(state.copyWith(
        status: PhotoViewStatus.error,
        isFavoriteMode: true,
      ));
      return;
    }

    emit(state.copyWith(
      status: PhotoViewStatus.success,
      favoritePhotos: result.data ?? [],
      isFavoriteMode: true,
    ));
  }

  Future<bool> toggleFavorite(String photoId, bool isFavorite) async {
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return false;
    }
    final result = await domain.photo.toggleFavorite(photoId, isFavorite, uid);

    if (result.isSuccess) {
      _updatePhotoInGroups(
          photoId, (photo) => photo.copyWith(isFavorite: isFavorite));

      if (state.isFavoriteMode) {
        final updatedFavorites = state.favoritePhotos
            .map((photo) {
              if (photo.id == photoId) {
                return photo.copyWith(isFavorite: isFavorite);
              }
              return photo;
            })
            .where((photo) => photo.isFavorite)
            .toList();

        emit(state.copyWith(favoritePhotos: updatedFavorites));
      }
      return true;
    }
    return false;
  }

  void _updatePhotoInGroups(
      String photoId, MPhotoItem Function(MPhotoItem) updateFn) {
    final updatedGroups = state.timelinePagination.data.map((group) {
      final updatedPhotos = group.photos.map((photo) {
        if (photo.id == photoId) {
          return updateFn(photo);
        }
        return photo;
      }).toList();

      return MPhotoTimelineGroup(
        date: group.date,
        photos: updatedPhotos.cast<MPhotoItem>(),
      );
    }).toList();

    if (isClosed) return;
    emit(state.copyWith(
        timelinePagination: state.timelinePagination.copyWith(
      data: updatedGroups,
    )));
  }
}
