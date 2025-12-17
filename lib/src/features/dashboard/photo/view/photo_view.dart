import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/services/network-connection/internet_connection_cubit.dart';
import '../logic/photo_bloc.dart';
import '../logic/photo_state.dart';
import '../model/photo_item.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/router/route_name.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:redacted/redacted.dart';

class PhotoView extends StatefulWidget {
  const PhotoView({super.key});

  @override
  State<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  late final ScrollController _scrollController;
  late final PhotoViewBloc _bloc;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.9) {
      _bloc.loadMore(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhotoViewBloc()..loadPhotos(context: context),
      child: Builder(builder: (context) {
        _bloc = context.read<PhotoViewBloc>();
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        S.of(context).common_photo_tab_title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF091031),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.lock_outline),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Divider(
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  BlocBuilder<InternetConnectionCubit, InternetStatusState>(
                    builder: (context, internetState) {
                      if (internetState == InternetStatusState.disconnected) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF6C63FF).withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFF6C63FF).withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.cloud_off,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  S.of(context).common_offline_mode,
                                  style: const TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: BlocBuilder<PhotoViewBloc, PhotoViewState>(
                      builder: (context, state) {
                        if (state.status == PhotoViewStatus.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state.status == PhotoViewStatus.error) {
                          return _buildErrorState(
                              context,
                              state.errorMessage ??
                                  S.of(context).error_somethingWrongTryAgain);
                        } else if (state.isFavoriteMode &&
                            state.favoritePhotos.isEmpty) {
                          return _buildEmptyFavoriteState();
                        } else if (!state.isFavoriteMode &&
                            state.timelineGroups.isEmpty) {
                          return _buildEmptyState();
                        } else {
                          return _buildTimelineContent(context, state);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimelineContent(BuildContext context, PhotoViewState state) {
    if (state.isFavoriteMode) {
      return RefreshIndicator(
        onRefresh: () =>
            context.read<PhotoViewBloc>().loadFavoritePhotos(context),
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(4),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: state.favoritePhotos.length,
          itemBuilder: (context, index) {
            final photo = state.favoritePhotos[index];
            return _buildPhotoTile(photo);
          },
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<PhotoViewBloc>().refresh(context),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            state.timelineGroups.length + (state.isLoadingMore ? 1 : 0) + 1,
        itemBuilder: (context, index) {
          final baseCount = state.timelineGroups.length;
          final loadingExtra = state.isLoadingMore ? 1 : 0;
          final footerIndex = baseCount + loadingExtra;

          if (index < baseCount) {
            final group = state.timelineGroups[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _buildTimelineGroup(group),
            );
          }

          if (index < footerIndex) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final totalPhotos = state.timelineGroups
              .fold<int>(0, (sum, group) => sum + group.photos.length);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                '$totalPhotos ${S.of(context).common_image_count_title}',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineGroup(MPhotoTimelineGroup group) {
    final locale = Localizations.localeOf(context).languageCode;
    final formatter = DateFormat('dd MMMM yyyy ', locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                formatter.format(group.date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF091031),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: group.photos.length,
          itemBuilder: (context, index) {
            final photo = group.photos[index];
            return _buildPhotoTile(photo);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhotoTile(MPhotoItem photo) {
    return FutureBuilder<Uint8List?>(
      future: photo.asset?.thumbnailDataWithSize(
        const ThumbnailSize.square(200),
        quality: 80,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return GestureDetector(
            onTap: () {
              final state = context.read<PhotoViewBloc>().state;

              final photos = state.isFavoriteMode
                  ? state.favoritePhotos
                  : state.timelineGroups
                      .expand((group) => group.photos)
                      .toList();

              final index = photos.indexWhere((p) => p.id == photo.id);
              AppCoordinator.goNamed(
                AppRouteNames.photoDetail.name,
                extra: {
                  'photos': photos,
                  'initialIndex': index >= 0 ? index : 0,
                  'bloc': context.read<PhotoViewBloc>(),
                },
              );
            },
            child: Stack(
              children: [
                // Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: MemoryImage(snapshot.data!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Favorite icon
                if (photo.isFavorite)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
              ],
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
          ).redacted(context: context, redact: true);
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 100,
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

  Widget _buildEmptyFavoriteState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
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
            S.of(context).common_image_liked_not_found_subTitle,
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
            S.of(context).error_somethingWrongTryAgain,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PhotoViewBloc>().loadPhotos(context: context);
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

  Widget _buildFilterChips() {
    return BlocBuilder<PhotoViewBloc, PhotoViewState>(
      builder: (context, state) {
        return Row(
          children: [
            _buildFilterChip(
              label: S.of(context).common_all_chip_title,
              isSelected: !state.isFavoriteMode,
              onTap: () {
                if (state.isFavoriteMode) {
                  context.read<PhotoViewBloc>().loadPhotos(context: context);
                }
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: S.of(context).common_favourite_chip_title,
              isSelected: state.isFavoriteMode,
              onTap: () {
                context.read<PhotoViewBloc>().loadFavoritePhotos(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
