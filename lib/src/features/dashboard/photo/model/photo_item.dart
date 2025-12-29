import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

class MPhotoItem extends Equatable {
  const MPhotoItem({
    required this.asset,
    this.isFavorite = false,
  });

  final AssetEntity? asset;
  final bool isFavorite;

  String get id => asset?.id ?? '';
  String get title => asset?.title ?? 'No Title';
  String get filePath => asset?.relativePath ?? 'Unknown';
  DateTime? get createDate => asset?.createDateTime;
  String get lat => asset?.latitude.toString() ?? 'Unknown';
  String get lon => asset?.longitude.toString() ?? 'Unknown';
  bool get isVideo => asset?.type == AssetType.video;
  int get width => asset?.width ?? 0;
  int get height => asset?.height ?? 0;

  MPhotoItem copyWith({
    AssetEntity? asset,
    bool? isFavorite,
  }) {
    return MPhotoItem(
      asset: asset ?? this.asset,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, isFavorite];
}

class MPhotoTimelineGroup extends Equatable {
  MPhotoTimelineGroup({
    required DateTime date,
    required this.photos,
  }) : date = DateTime(date.year, date.month, date.day);

  final DateTime date;
  final List<MPhotoItem> photos;

  MPhotoTimelineGroup copyWith({
    DateTime? date,
    List<MPhotoItem>? photos,
  }) {
    return MPhotoTimelineGroup(
      date:
          date != null ? DateTime(date.year, date.month, date.day) : this.date,
      photos: photos ?? this.photos,
    );
  }

  @override
  List<Object?> get props => [date, photos];
}
