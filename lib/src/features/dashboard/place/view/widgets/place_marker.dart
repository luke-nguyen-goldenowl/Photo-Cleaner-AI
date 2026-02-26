import 'dart:io';
import 'package:flutter/material.dart';
import '../../model/image_location.dart';

class XPlaceMarker extends StatelessWidget {
  final List<MImageLocation> locations;
  final bool isSelected;
  final VoidCallback onTap;

  const XPlaceMarker({
    super.key,
    required this.locations,
    required this.isSelected,
    required this.onTap,
  });
  Widget _buildThumbnail(MImageLocation location) {
    final file = File(location.thumbnailPath);
    return Image.file(
      file,
      fit: BoxFit.cover,
      cacheWidth: 64,
      cacheHeight: 64,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.photo_library,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = locations.length > 1;
    final location = locations.first;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: isSelected ? 80 : 65,
            height: isSelected ? 80 : 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.red : Colors.white,
                width: isSelected ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: _buildThumbnail(location),
            ),
          ),
          if (isGroup)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  locations.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
