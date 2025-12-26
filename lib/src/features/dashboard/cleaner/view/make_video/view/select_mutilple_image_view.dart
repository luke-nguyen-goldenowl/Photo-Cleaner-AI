import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/logic/make_video_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/logic/make_video_state.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/state/state_pagination_widget.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:redacted/redacted.dart';

class SelectMutilpleImageView extends StatelessWidget {
  const SelectMutilpleImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                S.of(context).common_select_moments_title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              BlocBuilder<MakeVideoBloc, MakeVideoState>(
                buildWhen: (previous, current) =>
                    previous.selectedPhotos.length !=
                    current.selectedPhotos.length,
                builder: (context, state) {
                  return Text(
                    '${state.selectedPhotos.length} selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.normal,
                    ),
                  );
                },
              ),
            ],
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => AppCoordinator.pop(),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<MakeVideoBloc, MakeVideoState>(
                buildWhen: (previous, current) {
                  return previous.status != current.status ||
                      previous.photos != current.photos ||
                      previous.selectedPhotos != current.selectedPhotos;
                },
                builder: (context, state) {
                  if (state.status == MakeVideoStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == MakeVideoStatus.error) {
                    return _buildErrorState(
                        context, S.of(context).error_somethingWrongTryAgain);
                  } else if (state.photos.isEmpty) {
                    return _buildEmptyState(context);
                  } else {
                    return _buildImageGrid(context, state);
                  }
                },
              ),
            ),
            BlocBuilder<MakeVideoBloc, MakeVideoState>(
              buildWhen: (previous, current) =>
                  previous.selectedPhotos.length !=
                  current.selectedPhotos.length,
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
                    onPressed: state.selectedPhotos.isNotEmpty
                        ? () => AppCoordinator.showSelectAudioView(
                              bloc: context.read<MakeVideoBloc>(),
                            )
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
                    child: Text(
                      S.of(context).common_buttonContinue,
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
      ),
    );
  }
}

Widget _buildImageGrid(BuildContext context, MakeVideoState state) {
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
          loadMore: () => context.read<MakeVideoBloc>().loadPhotos(),
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
      final isSelected = state.selectedPhotos.any((p) => p.id == photo.id);
      final selectedIndex =
          state.selectedPhotos.indexWhere((p) => p.id == photo.id);
      return _buildPhotoTile(context, photo, isSelected, selectedIndex + 1);
    },
  );
}

Widget _buildPhotoTile(
    BuildContext context, MPhotoItem photo, bool isSelected, int orderNumber) {
  final bloc = context.read<MakeVideoBloc>();
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
          onTap: () =>
              context.read<MakeVideoBloc>().togglePhotoSelection(photo),
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
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        '$orderNumber',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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

Widget _buildErrorState(BuildContext context, String errorMessage) {
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
          errorMessage,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}
