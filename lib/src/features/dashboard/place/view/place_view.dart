import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/widgets/loading/location_loading.dart';
import '../logic/place_bloc.dart';
import '../model/image_location.dart';
import '../helper/place_helpers.dart';
import 'widgets/place_marker.dart';
import 'widgets/time_filter_dialog.dart';
import 'widgets/image_detail_sheet.dart';
import 'widgets/group_images_sheet.dart';

class PlacesView extends StatelessWidget {
  const PlacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<PlaceBloc, PlaceState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.imageLocations != current.imageLocations;
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const LocationLoadingIndicator();
          }
          if (state.hasError) {
            return _buildErrorState(
                context, S.of(context).error_somethingWrongTryAgain);
          }

          if (state.isEmpty) {
            return _buildEmptyState(context);
          }

          return const MapView();
        },
      ),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitLargeBounds());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      context.read<PlaceBloc>().loadPhotosWithGPS();
      _loaded = true;
    }
  }

  void _fitInitialBounds() {
    final bounds = context.read<PlaceBloc>().state.initialBounds;
    if (bounds != null) {
      _mapController.move(
        LatLng(bounds.centerLat, bounds.centerLon),
        12.0,
      );
    }
  }

  void _fitLargeBounds() {
    final locations = context.read<PlaceBloc>().state.filteredLocations;
    final center = PlaceHelpers.getLargestGroupCenter(locations);
    if (center != null) {
      _mapController.move(center, 12.0);
    }
  }

  void _zoomToLocation(MImageLocation location) {
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      16.0,
    );
  }

  void _showImageDetail(MImageLocation location) {
    XImageDetailSheet.show(
      context,
      location,
      () => _zoomToLocation(location),
    );
  }

  void _showGroupImages(List<MImageLocation> locations) {
    XGroupImagesSheet.show(
      context,
      locations,
      _showImageDetail,
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PlaceBloc>(),
        child: const XTimeFilterDialog(),
      ),
    ).then((_) {
      _fitInitialBounds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).common_tab_place_title,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.refresh_outlined),
          onPressed: () {
            context.read<PlaceBloc>().refresh();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<MapDisplayMode>(
            icon: const Icon(Icons.grid_view_rounded),
            onSelected: (mode) {
              context.read<PlaceBloc>().setDisplayMode(mode);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: MapDisplayMode.markers,
                child: Row(
                  children: [
                    Icon(Icons.place, size: 20, color: Colors.black),
                    SizedBox(width: 12),
                    Text(S.of(context).common_view_mode_maker),
                  ],
                ),
              ),
              PopupMenuItem(
                value: MapDisplayMode.route,
                child: Row(
                  children: [
                    Icon(Icons.route, size: 20, color: Colors.black),
                    SizedBox(width: 12),
                    Text(S.of(context).common_view_mode_route),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildInfoBanner(context),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return BlocBuilder<PlaceBloc, PlaceState>(
      buildWhen: (previous, current) {
        return previous.displayMode != current.displayMode ||
            previous.groupedLocations != current.groupedLocations ||
            previous.selectedImage != current.selectedImage ||
            previous.imageLocations != current.imageLocations ||
            previous.timeFilter != current.timeFilter ||
            previous.customRange != current.customRange;
      },
      builder: (context, state) {
        final filteredLocations = state.filteredLocations;
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: filteredLocations.isNotEmpty
                ? LatLng(
                    filteredLocations.first.latitude,
                    filteredLocations.first.longitude,
                  )
                : const LatLng(0, 0),
            initialZoom: 12.0,
            minZoom: 3.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: AppConstants.urlTemplate,
              subdomains: AppConstants.subdomains,
              userAgentPackageName: AppConstants.userAgentPackageName,
              tileSize: 256,
              tileDimension: 256,
              minZoom: 3,
              maxZoom: 20,
              minNativeZoom: 0,
              maxNativeZoom: 19,
              keepBuffer: 3,
              panBuffer: 1,
              tileDisplay: const TileDisplay.fadeIn(),
            ),
            if (state.displayMode == MapDisplayMode.route)
              _buildRouteLayer(filteredLocations),
            _buildMarkerLayer(state),
          ],
        );
      },
    );
  }

  Widget _buildRouteLayer(List<MImageLocation> locations) {
    if (locations.length < 2) return const SizedBox.shrink();

    final sortedLocations = PlaceHelpers.getSortedByTime(locations);
    final points = sortedLocations
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    return PolylineLayer(
      polylines: [
        Polyline(
          points: points,
          strokeWidth: 3,
          color: Colors.blue,
          borderStrokeWidth: 1,
          borderColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildMarkerLayer(
    PlaceState state,
  ) {
    return MarkerLayer(
      markers: state.groupedLocations.entries.map((entry) {
        final locations = entry.value;
        final avgLat =
            locations.map((l) => l.latitude).reduce((a, b) => a + b) /
                locations.length;
        final avgLon =
            locations.map((l) => l.longitude).reduce((a, b) => a + b) /
                locations.length;

        final isSelected = locations.any(
          (loc) => state.selectedImage?.imageId == loc.imageId,
        );

        return Marker(
          point: LatLng(avgLat, avgLon),
          width: isSelected ? 90 : 75,
          height: isSelected ? 90 : 75,
          child: XPlaceMarker(
            locations: locations,
            isSelected: isSelected,
            onTap: () {
              if (locations.length > 1) {
                _showGroupImages(locations);
              } else {
                _showImageDetail(locations.first);
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return BlocBuilder<PlaceBloc, PlaceState>(
      buildWhen: (previous, current) {
        return previous.status != current.status ||
            previous.displayMode != current.displayMode;
      },
      builder: (context, state) {
        return Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.displayMode == MapDisplayMode.markers
                        ? S.of(context).common_touch_for_detail
                        : S.of(context).common_timeline_place,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildErrorState(BuildContext context, String errorMessage) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.red[300],
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).error_somethingWrongTryAgain,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_off, size: 100, color: Colors.grey[300]),
        SizedBox(height: 16),
        Text(
          S.of(context).common_not_found_gps_image,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context).common_please_take_gps_image,
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {
            context.read<PlaceBloc>().refresh();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(S.of(context).common_try_again),
        ),
      ],
    ),
  );
}
