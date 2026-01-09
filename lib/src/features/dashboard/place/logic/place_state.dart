part of 'place_bloc.dart';

enum PlaceStatus {
  initial,
  loading,
  success,
  error,
}

class PlaceState extends Equatable {
  const PlaceState({
    this.status = PlaceStatus.initial,
    this.imageLocations = const [],
    this.displayMode = MapDisplayMode.markers,
    this.timeFilter = TimeFilter.all,
    this.customRange,
    this.selectedImage,
    this.mapCenter,
    this.mapZoom = 12.0,
  });

  final PlaceStatus status;
  final List<MImageLocation> imageLocations;
  final MapDisplayMode displayMode;
  final TimeFilter timeFilter;
  final DateTimeRange? customRange;
  final MImageLocation? selectedImage;
  final LatLng? mapCenter;
  final double mapZoom;

  bool get isLoading => status == PlaceStatus.loading;
  bool get isEmpty => imageLocations.isEmpty && status == PlaceStatus.success;
  bool get hasError => status == PlaceStatus.error;
  bool get hasData => imageLocations.isNotEmpty;
  bool get isInitial => status == PlaceStatus.initial;

  List<MImageLocation> get filteredLocations {
    return PlaceHelpers.getFilteredLocations(
        imageLocations, timeFilter, customRange);
  }

  Map<String, List<MImageLocation>> get groupedLocations {
    return PlaceHelpers.groupLocationsByProximity(filteredLocations);
  }

  MMapBounds? get initialBounds {
    if (filteredLocations.isEmpty) return null;
    return PlaceHelpers.getBounds(filteredLocations);
  }

  PlaceState copyWith({
    PlaceStatus? status,
    List<MImageLocation>? imageLocations,
    MapDisplayMode? displayMode,
    TimeFilter? timeFilter,
    DateTimeRange? customRange,
    MImageLocation? selectedImage,
  }) {
    return PlaceState(
      status: status ?? this.status,
      imageLocations: imageLocations ?? this.imageLocations,
      displayMode: displayMode ?? this.displayMode,
      timeFilter: timeFilter ?? this.timeFilter,
      customRange: customRange ?? this.customRange,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        imageLocations,
        displayMode,
        timeFilter,
        customRange,
        selectedImage,
      ];
}
