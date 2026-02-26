class StorageInfo {
  final double totalSpace;
  final double usedSpace;
  final double freeSpace;

  StorageInfo({
    required this.totalSpace,
    required this.usedSpace,
    required this.freeSpace,
  });

  double get usagePercentage =>
      totalSpace > 0 ? (usedSpace / totalSpace * 100) : 0;

  String get totalFormatted => _formatGB(totalSpace);
  String get usedFormatted => _formatGB(usedSpace);
  String get freeFormatted => _formatGB(freeSpace);

  String _formatGB(double gb) {
    if (gb == 0) return '0 B';
    if (gb < 0.01) return '${(gb * 1024).toStringAsFixed(2)} MB';
    if (gb < 1) return '${(gb * 1024).toStringAsFixed(0)} MB';
    return '${gb.toStringAsFixed(2)} GB';
  }

  @override
  String toString() {
    return 'StorageInfo(total: $totalFormatted, used: $usedFormatted, free: $freeFormatted, usage: ${usagePercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageInfo &&
          runtimeType == other.runtimeType &&
          totalSpace == other.totalSpace &&
          usedSpace == other.usedSpace &&
          freeSpace == other.freeSpace;

  @override
  int get hashCode =>
      totalSpace.hashCode ^ usedSpace.hashCode ^ freeSpace.hashCode;
}
