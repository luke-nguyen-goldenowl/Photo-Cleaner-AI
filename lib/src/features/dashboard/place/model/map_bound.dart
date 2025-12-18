class MMapBounds {
  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;

  MMapBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
  });

  double get centerLat => (minLat + maxLat) / 2;
  double get centerLon => (minLon + maxLon) / 2;
}
