import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/remove_bg/logic/remove_bg.state.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/remove_bg/logic/remove_bg_bloc.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/loading/erase_loading.dart';
import 'package:myapp/widgets/state/state_pagination_widget.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:redacted/redacted.dart';

class SelectImageView extends StatelessWidget {
  const SelectImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).common_remove_bg_title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => AppCoordinator.pop(),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    S.of(context).common_select_image_title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<RemoveBgBloc, RemoveBgState>(
                    buildWhen: (previous, current) {
                      return previous.photoPagination !=
                              current.photoPagination ||
                          previous.selectedPhoto != current.selectedPhoto;
                    },
                    builder: (context, state) {
                      if (state.photoPagination.isFirstLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.photoPagination.isFirstError) {
                        return _buildErrorState(context,
                            S.of(context).error_somethingWrongTryAgain);
                      } else if (state.photos.isEmpty &&
                          state.photoPagination.page > 0) {
                        return _buildEmptyState(context);
                      } else {
                        return _buildImageGrid(context, state);
                      }
                    },
                  ),
                ),
                BlocBuilder<RemoveBgBloc, RemoveBgState>(
                  buildWhen: (previous, current) {
                    return previous.selectedPhoto != current.selectedPhoto ||
                        previous.isProcessing != current.isProcessing;
                  },
                  builder: (context, state) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: state.selectedPhoto != null &&
                                !state.isProcessing
                            ? () => context.read<RemoveBgBloc>().processImage()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: state.isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                S.of(context).common_button_handle_remove_bg,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

Widget _buildImageGrid(BuildContext context, RemoveBgState state) {
  final totalItems = state.photoPagination.data.length +
      (state.photoPagination.hasMore ? 1 : 0);

  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
    ),
    itemCount: totalItems,
    itemBuilder: (context, index) {
      if (index == state.photoPagination.data.length) {
        return XBoxLoadMore(
          page: state.photoPagination,
          loadMore: () => context.read<RemoveBgBloc>().loadPhotos(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      final photo = state.photoPagination.data[index];
      final isSelected = state.selectedPhoto?.id == photo.id;
      return _buildPhotoTile(context, photo, isSelected);
    },
  );
}

Widget _buildPhotoTile(
    BuildContext context, MPhotoItem photo, bool isSelected) {
  final bloc = context.read<RemoveBgBloc>();
  final future = bloc.thumbnailFutures[photo.id] ??
      photo.asset?.thumbnailDataWithSize(
        const ThumbnailSize.square(200),
        quality: 80,
      );

  if (bloc.thumbnailFutures[photo.id] == null && future != null) {
    bloc.thumbnailFutures[photo.id] = future;
  }
  return FutureBuilder<Uint8List?>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.data != null) {
        return GestureDetector(
          onTap: () => context.read<RemoveBgBloc>().selectPhoto(photo),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFF6C63FF),
                      width: 3,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(isSelected ? 5 : 8),
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
        ).redacted(context: context, redact: true);
      }
    },
  );
}

Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.photo_library_outlined,
          size: 80,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).common_image_not_found_title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context).common_image_not_found_subTitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorState(BuildContext context, String? errorMessage) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.red[300],
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).error_somethingWrongTryAgain,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.read<RemoveBgBloc>().refreshPhotos();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(S.of(context).common_try_again),
        ),
      ],
    ),
  );
}

Widget _buildLoadingOverlay() {
  return BlocBuilder<RemoveBgBloc, RemoveBgState>(
    buildWhen: (previous, current) {
      return previous.isProcessing != current.isProcessing;
    },
    builder: (context, state) {
      if (state.isProcessing) {
        return Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.7),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: EraseLoadingIndicator(),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    },
  );
}
