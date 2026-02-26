class MDuplicateImage {
  final String id;
  final String path;
  final List<double>? features;
  final int size;
  final double sharpness;
  bool isSelected;

  MDuplicateImage({
    required this.id,
    required this.path,
    this.features,
    this.size = 0,
    this.sharpness = 0.0,
    this.isSelected = false,
  });

  MDuplicateImage copyWith({
    List<double>? features,
    int? size,
    double? sharpness,
    bool? isSelected,
  }) {
    return MDuplicateImage(
      id: id,
      path: path,
      features: features ?? this.features,
      size: size ?? this.size,
      sharpness: sharpness ?? this.sharpness,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
