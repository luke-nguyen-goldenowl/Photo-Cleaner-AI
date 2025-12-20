import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/src/features/dashboard/place/db/gps_local_db.dart';
import 'package:myapp/src/features/dashboard/place/helper/place_helpers.dart';
import 'package:myapp/src/features/dashboard/place/model/map_bound.dart';
import 'package:myapp/src/network/domain_manager.dart';
import '../model/image_location.dart';

part 'place_state.dart';

enum MapDisplayMode { markers, heatmap, route }

enum TimeFilter { all, today, thisWeek, thisMonth, thisYear, custom }

class PlaceBloc extends Cubit<PlaceState> {
  //final PhotoRepository photoRepository;
  DomainManager get domain => DomainManager();
  bool _hasLoaded = false;

  PlaceBloc() : super(const PlaceState());

  Future<void> loadPhotosWithGPS({
    bool forceReload = false,
  }) async {
    if (isClosed) return;

    if (_hasLoaded && !forceReload) return;
    _hasLoaded = true;

    emit(state.copyWith(status: PlaceStatus.loading));

    final result = await domain.photo.loadPhotos(
      page: 0,
      pageSize: 1000,
    );

    if (!result.isSuccess) {
      if (isClosed) return;
      emit(state.copyWith(
        status: PlaceStatus.error,
      ));
      return;
    }

    final photos = result.data ?? [];
    if (photos.isEmpty) {
      if (isClosed) return;
      emit(state.copyWith(
        status: PlaceStatus.success,
        imageLocations: [],
      ));
      return;
    }

    final List<MImageLocation> photosWithGPS = [];
    final gpsCache = GpsCacheDb();

    for (final photo in photos) {
      if (isClosed) return;
      final asset = photo.asset;
      if (asset == null) continue;
      if (!forceReload) {
        final cached = await gpsCache.get(asset.id);
        if (cached != null) {
          photosWithGPS.add(cached);
          continue;
        }
      }

      final result = await domain.photo.extractGpsFromPhoto(photo);
      final gpsData = result.data;

      if (result.isSuccess && gpsData != null) {
        photosWithGPS.add(gpsData);
        await gpsCache.put(gpsData);
      }
    }

    if (isClosed) return;
    emit(state.copyWith(
      status: PlaceStatus.success,
      imageLocations: photosWithGPS,
    ));
  }

  void setDisplayMode(MapDisplayMode mode) {
    if (isClosed) return;
    emit(state.copyWith(displayMode: mode));
  }

  void setTimeFilter(TimeFilter filter, {DateTimeRange? customRange}) {
    if (isClosed) return;
    if (filter == TimeFilter.custom) {
      emit(state.copyWith(timeFilter: filter, customRange: customRange));
    } else {
      emit(state.copyWith(timeFilter: filter, customRange: null));
    }
  }

  void selectImage(MImageLocation? image) {
    if (isClosed) return;
    emit(state.copyWith(selectedImage: image));
  }

  void clearSelection() {
    if (isClosed) return;
    emit(state.copyWith(selectedImage: null));
  }

  Future<void> refresh() async {
    emit(state.copyWith(status: PlaceStatus.loading));
    await loadPhotosWithGPS(forceReload: true);
  }
}
