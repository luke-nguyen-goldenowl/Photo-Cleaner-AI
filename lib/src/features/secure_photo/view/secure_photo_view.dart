import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/features/secure_photo/logic/secure_photo_bloc.dart';
import 'package:myapp/src/features/secure_photo/logic/secure_photo_state.dart';
import 'package:myapp/src/features/secure_photo/widgets/change_password_dialog.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/services/network-connection/internet_connection_cubit.dart';
import 'package:myapp/widgets/state/state_pagination_widget.dart';
import 'package:photo_view/photo_view.dart';

class SecurePhotoView extends StatelessWidget {
  const SecurePhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SecurePhotoBloc>().checkBiometricSupport();
    return BlocProvider(
      create: (context) => SecurePhotoBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            S.of(context).common_secure_storage,
            style: const TextStyle(
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
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                final bloc = context.read<SecurePhotoBloc>();
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext bottomSheetContext) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.lock),
                            title: Text(S
                                .of(context)
                                .common_secure_photo_vault_change_password_title),
                            onTap: () async {
                              Navigator.of(bottomSheetContext).pop();
                              final confirmed = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (dialogContext) => BlocProvider.value(
                                  value: bloc,
                                  child: const ChangePasswordDialog(),
                                ),
                              );
                              if (confirmed == true) {
                                await bloc.changePassword();
                              }
                            },
                          ),
                          BlocBuilder<SecurePhotoBloc, SecurePhotoState>(
                            builder: (context, state) {
                              if (state.isBiometricSupported) {
                                return ListTile(
                                  leading: const Icon(Icons.fingerprint),
                                  title: Text(S
                                      .of(context)
                                      .common_secure_photo_vault_biometric_title),
                                  onTap: () {
                                    AppSettings.openAppSettings(
                                        type: AppSettingsType.security);
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: BlocBuilder<InternetConnectionCubit, InternetStatusState>(
                buildWhen: (previous, current) {
                  return (previous == InternetStatusState.disconnected) !=
                      (current == InternetStatusState.disconnected);
                },
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
                            color: const Color(0xFF6C63FF).withOpacity(0.08),
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
            ),
            Expanded(
              child: BlocBuilder<SecurePhotoBloc, SecurePhotoState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.securePhotosPagination !=
                        current.securePhotosPagination,
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      ),
                    );
                  }

                  if (state.hasError) {
                    XToast.error(S.of(context).error_somethingWrongTryAgain);
                  }

                  if (!state.securePhotosPagination.isLoading &&
                      state.securePhotos.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildPhotoGrid(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            S.text.common_storage_secure_empty,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.text.common_storage_secure_empty_subTitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context, SecurePhotoState state) {
    final totalItems = state.securePhotos.length +
        (state.securePhotosPagination.hasMore ? 1 : 0);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index == state.securePhotos.length) {
          return XBoxLoadMore(
            page: state.securePhotosPagination,
            loadMore: () => context.read<SecurePhotoBloc>().loadSecurePhotos(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ),
          );
        }

        final photo = state.securePhotos[index];
        return _buildPhotoTile(context, photo);
      },
    );
  }

  Widget _buildPhotoTile(BuildContext context, MPhotoItem photo) {
    return GestureDetector(
      onTap: () => _showPhotoDetail(context, photo),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: photo.storageUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(photo.storageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photo.storageUrl == null
                ? Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  )
                : null,
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.lock,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, MPhotoItem photo) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: photo.storageUrl != null
                  ? PhotoView(
                      imageProvider:
                          CachedNetworkImageProvider(photo.storageUrl!),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.black),
                      loadingBuilder: (context, event) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(Icons.error, color: Colors.white, size: 60),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.error, color: Colors.white, size: 60),
                    ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.lock_open_outlined,
                    label: S
                        .of(context)
                        .common_secure_photo_vault_remove_security_title,
                    color: Colors.green,
                    onTap: () async {
                      Navigator.of(dialogContext).pop();
                      await context
                          .read<SecurePhotoBloc>()
                          .unsecurePhoto(photo.id);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.download_outlined,
                    label: S.of(context).common_button_save,
                    color: Colors.white,
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      final url = photo.storageUrl;
                      if (url != null) {
                        context
                            .read<SecurePhotoBloc>()
                            .downloadSecurePhoto(url);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
