class MImageLocation {
  final double latitude;
  final double longitude;
  final String imagePath;
  final String imageId;
  final DateTime? dateTime;

  MImageLocation({
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.imageId,
    this.dateTime,
  });

  @override
  String toString() {
    return 'MImageLocation{lat: $latitude, lon: $longitude, path: $imagePath}';
  }
}
