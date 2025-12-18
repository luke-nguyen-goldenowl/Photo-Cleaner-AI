import 'dart:math' as math;
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/src/features/dashboard/place/model/map_bound.dart';

import '../model/image_location.dart';
import '../logic/place_bloc.dart';

class PlaceHelpers {
  static List<MImageLocation> getFilteredLocations(
    List<MImageLocation> locations,
    TimeFilter filter,
    DateTimeRange? customRange,
  ) {
    final now = DateTime.now();
    switch (filter) {
      case TimeFilter.all:
        return locations;
      case TimeFilter.today:
        return locations.where((loc) {
          if (loc.dateTime == null) return false;
          return loc.dateTime!.year == now.year &&
              loc.dateTime!.month == now.month &&
              loc.dateTime!.day == now.day;
        }).toList();
      case TimeFilter.thisWeek:
        final weekAgo = now.subtract(const Duration(days: 7));
        return locations.where((loc) {
          if (loc.dateTime == null) return false;
          return loc.dateTime!.isAfter(weekAgo);
        }).toList();
      case TimeFilter.thisMonth:
        return locations.where((loc) {
          if (loc.dateTime == null) return false;
          return loc.dateTime!.year == now.year &&
              loc.dateTime!.month == now.month;
        }).toList();
      case TimeFilter.thisYear:
        return locations.where((loc) {
          if (loc.dateTime == null) return false;
          return loc.dateTime!.year == now.year;
        }).toList();
      case TimeFilter.custom:
        if (customRange == null) return locations;
        return locations.where((loc) {
          if (loc.dateTime == null) return false;
          return loc.dateTime!.isAfter(
                  customRange.start.subtract(const Duration(seconds: 1))) &&
              loc.dateTime!
                  .isBefore(customRange.end.add(const Duration(days: 1)));
        }).toList();
    }
  }

  static Map<String, List<MImageLocation>> groupLocationsByProximity(
    List<MImageLocation> locations, {
    double threshold = 0.001,
  }) {
    final Map<String, List<MImageLocation>> groups = {};

    for (var location in locations) {
      String? groupKey;

      for (var key in groups.keys) {
        final keyParts = key.split('_');
        final lat = double.parse(keyParts[0]);
        final lon = double.parse(keyParts[1]);

        final distance = math.sqrt(
          math.pow(location.latitude - lat, 2) +
              math.pow(location.longitude - lon, 2),
        );

        if (distance < threshold) {
          groupKey = key;
          break;
        }
      }

      if (groupKey == null) {
        groupKey = '${location.latitude}_${location.longitude}';
        groups[groupKey] = [];
      }

      groups[groupKey]!.add(location);
    }
    return groups;
  }

  static MMapBounds getBounds(List<MImageLocation> locations) {
    if (locations.isEmpty) {
      return MMapBounds(
        minLat: 10.8231,
        maxLat: 10.8231,
        minLon: 106.6297,
        maxLon: 106.6297,
      );
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLon = locations.first.longitude;
    double maxLon = locations.first.longitude;

    for (var location in locations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLon) minLon = location.longitude;
      if (location.longitude > maxLon) maxLon = location.longitude;
    }

    return MMapBounds(
      minLat: minLat,
      maxLat: maxLat,
      minLon: minLon,
      maxLon: maxLon,
    );
  }

  static List<MImageLocation> getSortedByTime(List<MImageLocation> locations) {
    final sorted = List<MImageLocation>.from(locations);
    sorted.sort((a, b) {
      if (a.dateTime == null || b.dateTime == null) return 0;
      return a.dateTime!.compareTo(b.dateTime!);
    });
    return sorted;
  }

  static double convertToDecimal(List<Ratio> coordinates) {
    if (coordinates.length < 3) return 0.0;
    double degrees = coordinates[0].numerator / coordinates[0].denominator;
    double minutes = coordinates[1].numerator / coordinates[1].denominator;
    double seconds = coordinates[2].numerator / coordinates[2].denominator;
    return degrees + (minutes / 60.0) + (seconds / 3600.0);
  }

  static String toDMS(double value, {bool isLat = true}) {
    final direction =
        isLat ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
    final absValue = value.abs();
    final degrees = absValue.floor();
    final minutesFull = (absValue - degrees) * 60;
    final minutes = minutesFull.floor();
    final seconds = ((minutesFull - minutes) * 60).toStringAsFixed(2);
    return '$degrees° $minutes\' $seconds" $direction';
  }

  static LatLng? getLargestGroupCenter(List<MImageLocation> locations) {
    final groups = groupLocationsByProximity(locations).values.toList();
    if (groups.isEmpty) return null;
    final largestGroup = groups.reduce((a, b) => a.length >= b.length ? a : b);
    final avgLat = largestGroup.map((l) => l.latitude).reduce((a, b) => a + b) /
        largestGroup.length;
    final avgLon =
        largestGroup.map((l) => l.longitude).reduce((a, b) => a + b) /
            largestGroup.length;
    return LatLng(avgLat, avgLon);
  }
}
