import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import '../logic/photo_bloc.dart';
import '../model/photo_item.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:redacted/redacted.dart';

class PhotoDetailView extends StatefulWidget {
  final List<MPhotoItem> photos;
  final int initialIndex;

  const PhotoDetailView(
      {super.key, required this.photos, this.initialIndex = 0});

  @override
  State<PhotoDetailView> createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
  late PageController _pageController;
  late int _currentIndex;
  late List<MPhotoItem> _photos;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.photos);
    final validatedIndex = widget.initialIndex.clamp(0, _photos.length - 1);
    _currentIndex = validatedIndex;
    _pageController = PageController(initialPage: validatedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  MPhotoItem get _currentPhoto => _photos[_currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              return FutureBuilder<Uint8List?>(
                future: photo.asset?.originBytes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data != null) {
                    return PhotoView(
                      imageProvider: MemoryImage(snapshot.data!),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 30,
                      initialScale: PhotoViewComputedScale.contained,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                    ).redacted(context: context, redact: true);
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                },
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentIndex + 1}/${widget.photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showMoreOptions(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: _buildActionButtons(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
            icon: _currentPhoto.isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
            label: S.of(context).common_like_button_text,
            color: _currentPhoto.isFavorite ? Colors.red : Colors.white,
            onTap: () async {
              final newFavoriteStatus = !_currentPhoto.isFavorite;
              final success =
                  await context.read<PhotoViewBloc>().toggleFavorite(
                        _currentPhoto.id,
                        newFavoriteStatus,
                      );
              if (success) {
                setState(() {
                  _photos[_currentIndex] = _currentPhoto.copyWith(
                    isFavorite: newFavoriteStatus,
                  );
                });
                XToast.success(newFavoriteStatus
                    ? S.of(context).common_add_to_favorite
                    : S.of(context).common_remove_favorite);
              }
            }),

        // Secure
        _buildActionButton(
          icon: Icons.lock,
          label: S.of(context).common_secure_button_text,
          color: Colors.white,
          onTap: () async {},
        ),

        // Enhance
        _buildActionButton(
          icon: Icons.auto_fix_high,
          label: S.of(context).common_enhance_button_text,
          color: Colors.white,
          onTap: () async {
            final asset = _currentPhoto.asset;
            if (asset != null) {
              final file = await asset.file;
              if (file != null && await file.exists()) {
                AppCoordinator.showPickImageEnhance(initialImage: file);
              }
            } else {
              XToast.error(S.of(context).error_somethingWrongTryAgain);
            }
          },
        ),

        // Share
        _buildActionButton(
          icon: Icons.share,
          label: S.of(context).common_share_button_text,
          color: Colors.white,
          onTap: () async {
            await context.read<PhotoViewBloc>().sharePhoto(_currentPhoto.id);
          },
        ),

        // Delete
        _buildActionButton(
          icon: Icons.delete_outline,
          label: S.of(context).common_delete_button_text,
          color: Colors.red,
          onTap: () async {
            final success = await context
                .read<PhotoViewBloc>()
                .deletePhoto(_currentPhoto.id);
            if (success && mounted) {
              Navigator.pop(context);
              XToast.success(S.of(context).common_delete_success);
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.2),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildMoreOption(
              icon: Icons.info_outline,
              title: S.of(context).common_detail_option_text,
              onTap: () {
                Navigator.pop(context);
                _showPhotoInfo(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF091031)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showPhotoInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).common_infor_image_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                S.of(context).common_name_image_text, _currentPhoto.title),
            _buildInfoRow(
                S.of(context).common_height_text, '${_currentPhoto.height}'),
            _buildInfoRow(
                S.of(context).common_width_text, '${_currentPhoto.width}'),
            _buildInfoRow(
                S.of(context).common_path_image_text, _currentPhoto.filePath),
            _buildInfoRow(S.of(context).common_created_text,
                _currentPhoto.createDate?.toString() ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).common_close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
