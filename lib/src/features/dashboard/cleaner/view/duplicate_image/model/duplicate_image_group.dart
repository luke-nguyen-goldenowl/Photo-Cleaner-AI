import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image.dart';

class MDuplicateImageGroup {
  final List<MDuplicateImage> images;
  final double similarity;

  MDuplicateImageGroup({
    required this.images,
    required this.similarity,
  });
}
