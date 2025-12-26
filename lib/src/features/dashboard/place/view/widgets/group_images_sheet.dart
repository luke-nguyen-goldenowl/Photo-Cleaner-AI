import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import '../../model/image_location.dart';

class XGroupImagesSheet extends StatelessWidget {
  final List<MImageLocation> locations;
  final Function(MImageLocation) onImageTap;

  const XGroupImagesSheet({
    super.key,
    required this.locations,
    required this.onImageTap,
  });

  Widget _buildThumbnail(MImageLocation location) {
    return Image.file(
      File(location.thumbnailPath),
      fit: BoxFit.cover,
      cacheWidth: 200,
      cacheHeight: 200,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.photo_library, color: Colors.grey, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${locations.length} ${S.of(context).common_image_count_title} ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onImageTap(location);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildThumbnail(location),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context,
    List<MImageLocation> locations,
    Function(MImageLocation) onImageTap,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => XGroupImagesSheet(
        locations: locations,
        onImageTap: onImageTap,
      ),
    );
  }
}
