import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:photo_manager/photo_manager.dart';
import 'photo_state.dart';

class PhotoViewBloc extends Cubit<PhotoViewState> {
  DomainManager get domain => DomainManager();
  String? get _userId => UserPrefs.I.getUser()?.id;
  List<MPhotoItem> _allFavoritePhotos = [];

  PhotoViewBloc()
      : super(PhotoViewState(
          timelinePagination: MPagination<MPhotoTimelineGroup>(),
          favoritePagination: MPagination<MPhotoItem>(pageLimit: 20),
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
        timelinePagination: state.timelinePagination.copyWith(
          data: updatedGroups,
        ),
        favoritePagination: state.favoritePagination.copyWith(
          data: updatedFavorites,
        ),
      ));
      XToast.success(S.text.common_delete_success);
      return true;
    }
    XToast.error(S.text.error_somethingWrongTryAgain);
    return false;
  }

  Future<bool> deletePhotoWithoutAlert(String photoId) async {
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
        timelinePagination: state.timelinePagination.copyWith(
          data: updatedGroups,
        ),
        favoritePagination: state.favoritePagination.copyWith(
          data: updatedFavorites,
        ),
      ));
      XToast.success(S.text.common_add_to_secure_photo_vault);
      return true;
    }
    XToast.error(S.text.error_somethingWrongTryAgain);
    return false;
  }

  Future<void> loadFavoritePhotos() async {
    final List<MPhotoItem> photoItems = [];
    Map<String, AssetEntity> assetMap = {};
    if (isClosed) return;
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      emit(state.copyWith(
        status: PhotoViewStatus.error,
      ));
      return;
    }

    if (!state.favoritePagination.canLoad) {
      return;
    }

    final currentPage = state.favoritePagination.page;
    final isFirstPage = currentPage == 0;

    emit(state.copyWith(
      favoritePagination: state.favoritePagination.toLoading(),
      status: isFirstPage ? PhotoViewStatus.loading : state.status,
      isFavoriteMode: true,
    ));

    if (isFirstPage) {
      final favoriteResult = await domain.favoritePhoto.getFavoritePhotos(uid);

      if (isClosed) return;

      if (!favoriteResult.isSuccess) {
        emit(state.copyWith(
          status: PhotoViewStatus.error,
          isFavoriteMode: true,
        ));
        return;
      }

      final favoritePhotos = favoriteResult.data ?? [];

      if (favoritePhotos.isEmpty) {
        emit(state.copyWith(
          status: PhotoViewStatus.success,
          favoritePagination: state.favoritePagination.addAll(
            [],
            totalPage: 1,
            countData: 0,
          ),
          isFavoriteMode: true,
        ));
        return;
      }

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
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

      if (albums.isNotEmpty) {
        final assets =
            await albums.first.getAssetListPaged(page: 0, size: 10000);
        assetMap = {for (var asset in assets) asset.id: asset};
      }

      for (final fav in favoritePhotos) {
        final asset = assetMap[fav.photoId];
        if (asset != null) {
          photoItems.add(MPhotoItem(
            asset: asset,
            isFavorite: true,
            storageUrl: fav.imageUrl,
          ));
        } else if (fav.imageUrl != null) {
          photoItems.add(MPhotoItem(
            asset: null,
            isFavorite: true,
            storageUrl: fav.imageUrl,
            securePhotoId: fav.photoId,
          ));
        } else if (fav.localPath != null) {
          AssetEntity? foundAsset;
          for (final entry in assetMap.entries) {
            final assetFile = await entry.value.file;
            if (assetFile?.path == fav.localPath) {
              foundAsset = entry.value;
              break;
            }
          }
          if (foundAsset != null) {
            photoItems.add(MPhotoItem(
              asset: foundAsset,
              isFavorite: true,
              storageUrl: null,
            ));
          } else {
            photoItems.add(MPhotoItem(
              asset: null,
              isFavorite: true,
              storageUrl: null,
              securePhotoId: fav.photoId,
              localFilePath: fav.localPath,
            ));
          }
        }
      }

      _allFavoritePhotos = photoItems;
    }

    if (isClosed) return;

    if (_allFavoritePhotos.isEmpty && isFirstPage) {
      emit(state.copyWith(
        status: PhotoViewStatus.success,
        favoritePagination: state.favoritePagination.addAll(
          [],
          totalPage: 1,
          countData: 0,
        ),
        isFavoriteMode: true,
      ));
      return;
    }

    final pageSize = state.favoritePagination.pageLimit;
    final start = currentPage * pageSize;
    final paginatedPhotos =
        _allFavoritePhotos.skip(start).take(pageSize).toList();

    final isLastPage = (start + pageSize) >= _allFavoritePhotos.length;
    final totalPage = isLastPage ? (currentPage + 1) : -1;
    final countData = isLastPage ? _allFavoritePhotos.length : -1;

    emit(state.copyWith(
      status: PhotoViewStatus.success,
      favoritePagination: state.favoritePagination.addAll(
        paginatedPhotos,
        totalPage: totalPage,
        countData: countData,
      ),
      isFavoriteMode: true,
    ));
  }

  Future<void> refreshFavoritePhotos() async {
    _allFavoritePhotos = [];
    emit(state.copyWith(
      favoritePagination: MPagination<MPhotoItem>(pageLimit: 20),
    ));
    await loadFavoritePhotos();
  }

  void setFavoriteMode(bool isFavoriteMode) {
    emit(state.copyWith(isFavoriteMode: isFavoriteMode));
  }

  Future<bool> toggleFavorite(String photoId, bool isFavorite) async {
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return false;
    }

    _updatePhotoInGroups(
        photoId, (photo) => photo.copyWith(isFavorite: isFavorite));

    if (state.isFavoriteMode) {
      if (isFavorite) {
        final photo = _findPhotoById(photoId);
        if (photo != null) {
          final updatedFavorites = [
            ...state.favoritePhotos,
            photo.copyWith(isFavorite: true),
          ];
          emit(state.copyWith(
            favoritePagination: state.favoritePagination.copyWith(
              data: updatedFavorites,
            ),
            lastToggledFavoritePhotoId: photoId,
          ));
        }
      } else {
        final updatedFavorites =
            state.favoritePhotos.where((photo) => photo.id != photoId).toList();
        _allFavoritePhotos =
            _allFavoritePhotos.where((photo) => photo.id != photoId).toList();
        emit(state.copyWith(
          favoritePagination: state.favoritePagination.copyWith(
            data: updatedFavorites,
          ),
          lastToggledFavoritePhotoId: photoId,
        ));
      }
    } else {
      emit(state.copyWith(lastToggledFavoritePhotoId: photoId));
    }

    bool success = false;

    if (isFavorite) {
      final photo = _findPhotoById(photoId);
      if (photo == null) {
        _updatePhotoInGroups(photoId, (p) => p.copyWith(isFavorite: false));
        emit(state.copyWith(lastToggledFavoritePhotoId: photoId));
        return false;
      }
      final result = await domain.favoritePhoto.likePhoto(photo, uid);
      success = result.isSuccess && result.data == true;
    } else {
      final result = await domain.favoritePhoto.unlikePhoto(photoId, uid);
      success = result.isSuccess && result.data == true;
    }
    if (!success) {
      _updatePhotoInGroups(
          photoId, (photo) => photo.copyWith(isFavorite: !isFavorite));

      if (state.isFavoriteMode) {
        await refreshFavoritePhotos();
      } else {
        emit(state.copyWith(lastToggledFavoritePhotoId: photoId));
      }
      return false;
    }

    return true;
  }

  MPhotoItem? _findPhotoById(String photoId) {
    for (final group in state.timelinePagination.data) {
      for (final photo in group.photos) {
        if (photo.id == photoId) {
          return photo;
        }
      }
    }
    for (final photo in state.favoritePhotos) {
      if (photo.id == photoId) {
        return photo;
      }
    }
    return null;
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
