class MDuplicateScanProgress {
  final int current;
  final int total;

  MDuplicateScanProgress({
    required this.current,
    required this.total,
  });

  double get percentage => total > 0 ? (current / total) * 100 : 0;
}
