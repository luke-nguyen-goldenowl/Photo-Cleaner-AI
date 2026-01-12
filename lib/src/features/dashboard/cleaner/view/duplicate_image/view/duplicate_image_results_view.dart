import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/logic/duplicate_image_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/model/duplicate_image_group.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/widget/circular_storage_indicator.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import '../helper/scan_helper.dart';

class DuplicateImageResultsView extends StatelessWidget {
  const DuplicateImageResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DuplicateImageBloc, DuplicateImageState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.isDeleteSuccess) {
          XToast.success(S.of(context).common_delete_success);
          AppCoordinator.pop();
        } else if (state.hasError) {
          XToast.error(S.of(context).error_somethingWrongTryAgain);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            S.of(context).common_title_result_scan,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
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
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildDeleteActionBar(),
              const SizedBox(height: 16),
              _buildGroupsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return BlocBuilder<DuplicateImageBloc, DuplicateImageState>(
      buildWhen: (previous, current) =>
          previous.groups.length != current.groups.length ||
          previous.storageInfo != current.storageInfo,
      builder: (context, state) {
        final storageInfo = state.storageInfo;
        return Column(
          children: [
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (storageInfo != null)
                      CircularStorageIndicator(
                        percentage: storageInfo.usagePercentage,
                        size: 80,
                        strokeWidth: 6,
                        color: ScanHelper.getStorageColor(
                            storageInfo.usagePercentage),
                        backgroundColor: const Color(0xFFE5E7EB),
                        centerText: S.of(context).common_storage_tag,
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${state.groups.length} ${S.of(context).common_group_found_text}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (storageInfo != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.storage,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${storageInfo.usedFormatted} / ${storageInfo.totalFormatted}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.cloud_queue,
                                  size: 16,
                                  color: Colors.green[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${storageInfo.freeFormatted} ${S.of(context).common_storage_free}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            Text(
                              S.of(context).common_loading,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteActionBar() {
    return BlocBuilder<DuplicateImageBloc, DuplicateImageState>(
      buildWhen: (previous, current) =>
          previous.totalSelectedSize != current.totalSelectedSize,
      builder: (context, state) {
        if (state.totalSelectedSize == 0) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${S.of(context).common_you_can_free_up} ${ScanHelper.formatSize(state.totalSelectedSize)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _showDeleteConfirmation(
                        context, state.totalSelectedSize),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667EEA),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      S.of(context).common_delete_button_text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupsList() {
    return BlocBuilder<DuplicateImageBloc, DuplicateImageState>(
      buildWhen: (previous, current) => previous.groups != current.groups,
      builder: (context, state) {
        if (state.groups.isEmpty) {
          return _buildEmptyState(context);
        }

        return Expanded(
          child: ListView.builder(
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return _buildDuplicateGroupCard(context, group, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildDuplicateGroupCard(
      BuildContext context, MDuplicateImageGroup group, int groupIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${S.of(context).common_group_title} ${groupIndex + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${S.of(context).common_similarity}: ${(group.similarity * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${group.images.length} ${S.of(context).common_image_count_title}',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: group.images.length,
                itemBuilder: (context, imageIndex) {
                  final image = group.images[imageIndex];
                  return _buildImageThumbnail(
                      context, image, imageIndex, groupIndex);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, MDuplicateImage image,
      int imageIndex, int groupIndex) {
    return GestureDetector(
      onTap: () {
        _showImagePreview(context, image);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 40),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<DuplicateImageBloc>()
                            .toggleImageSelection(groupIndex, imageIndex);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: image.isSelected
                              ? const Color(0xFF667EEA)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: image.isSelected
                                ? const Color(0xFF667EEA)
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: image.isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    ),
                  ),
                  if (imageIndex == 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0XFFfacc15), Color(0XFFfacc15)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star,
                                size: 12, color: Colors.white.withOpacity(0.9)),
                            Text(
                              S.of(context).common_best_image_tag,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ScanHelper.formatSize(image.size),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).common_no_duplicate_found,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, MDuplicateImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(
                File(image.path),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int totalSize) {
    XAlert.show(
      title: S.of(context).common_delete_title_alert,
      body: S.of(context).common_delete_selected_image_message,
      actions: [
        XAlertButton(title: S.of(context).common_cancelButton_title),
        XAlertButton(
          title: S.of(context).common_agreeButton_title,
          isDestructiveAction: true,
          key: 'confirm',
        ),
      ],
    ).then((key) {
      if (key == 'confirm') {
        context.read<DuplicateImageBloc>().deleteSelectedImages();
      }
    });
  }
}
