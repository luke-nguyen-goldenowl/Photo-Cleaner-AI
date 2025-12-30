import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/account/profile/service/image_picker_service.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/logic/enhance_image_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/logic/enhance_image_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/loading/image_scan_loading.dart';

class PickImageView extends StatefulWidget {
  final File? initialImage;
  const PickImageView({super.key, this.initialImage});

  @override
  State<PickImageView> createState() => _PickImageViewState();
}

class _PickImageViewState extends State<PickImageView> {
  File? _selectedImage;
  final ImagePickerService _picker = ImagePickerService();

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  void _handlePickImage() async {
    final result = await _picker.pickImageFromGallery();
    if (result.isSuccess && result.data != null) {
      setState(() {
        _selectedImage = File(result.data!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnhanceImageBloc, EnhanceImageState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },
      listener: (context, state) {
        if (state.status == EnhanceImageStatus.error) {
          XToast.error(S.of(context).error_somethingWrongTryAgain);
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              S.of(context).common_enhance_image_title,
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
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: _selectedImage == null
                          ? _buildUploadArea()
                          : _buildImagePreview(),
                    ),
                  ),
                  _buildBottomButton(),
                ],
              ),
              _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _handlePickImage,
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: const Color(0xFFF5F5F5),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 56,
                color: const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).common_tap_to_upload_photo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).common_supported_image_formats,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF1E2440),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 400,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  S.of(context).common_ready_to_enhance,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  S.of(context).common_ai_enhance_description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
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
      child: BlocBuilder<EnhanceImageBloc, EnhanceImageState>(
        buildWhen: (previous, current) =>
            previous.isProcessing != current.isProcessing,
        builder: (context, state) {
          return ElevatedButton(
            onPressed: _selectedImage != null && !state.isProcessing
                ? () {
                    if (_selectedImage != null) {
                      context
                          .read<EnhanceImageBloc>()
                          .processImageFromFile(_selectedImage!);
                    }
                  }
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
                        color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_fix_high, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context).common_start_enhancing,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return BlocBuilder<EnhanceImageBloc, EnhanceImageState>(
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
                  child: ImageScanLoadingIndicator(),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
