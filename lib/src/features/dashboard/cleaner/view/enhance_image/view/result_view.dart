import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/logic/enhance_image_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/logic/enhance_image_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';

class EnhanceResultView extends StatefulWidget {
  final Uint8List? originalImage;
  final Uint8List? enhancedImage;

  const EnhanceResultView({
    super.key,
    this.originalImage,
    this.enhancedImage,
  });

  @override
  State<EnhanceResultView> createState() => _EnhanceResultViewState();
}

class _EnhanceResultViewState extends State<EnhanceResultView> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).common_result_view_title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF1A1F36),
              child: _buildImageSection(),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return BlocBuilder<EnhanceImageBloc, EnhanceImageState>(
      buildWhen: (previous, current) {
        return previous.processedImage != current.processedImage ||
            previous.originalImage != current.originalImage;
      },
      builder: (context, state) {
        final originalImage = state.originalImage ?? widget.originalImage;
        final enhancedImage = state.processedImage ?? widget.enhancedImage;

        if (originalImage != null && enhancedImage != null) {
          return _buildComparisonView(originalImage, enhancedImage);
        }
        return Center(
          child: Text(
            S.of(context).error_somethingWrongTryAgain,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildComparisonView(Uint8List original, Uint8List enhanced) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.memory(
            enhanced,
            fit: BoxFit.contain,
          ),
        ),
        Positioned.fill(
          child: ClipRect(
            clipper: _SliderClipper(_sliderValue),
            child: Image.memory(
              original,
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (_sliderValue > 0.15)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                S.of(context).common_before,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (_sliderValue < 0.85)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                S.of(context).common_after,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          left: screenWidth * _sliderValue,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            color: Colors.white,
          ),
        ),
        Positioned(
          left: screenWidth * _sliderValue - 20,
          top: MediaQuery.of(context).size.height * 0.5 - 100,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.compare_arrows,
              color: Color(0xFF6C63FF),
              size: 24,
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _sliderValue =
                    (details.localPosition.dx / screenWidth).clamp(0.0, 1.0);
              });
            },
            onHorizontalDragStart: (details) {
              setState(() {
                _sliderValue =
                    (details.localPosition.dx / screenWidth).clamp(0.0, 1.0);
              });
            },
            onTapDown: (details) {
              setState(() {
                _sliderValue =
                    (details.localPosition.dx / screenWidth).clamp(0.0, 1.0);
              });
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BlocBuilder<EnhanceImageBloc, EnhanceImageState>(
        buildWhen: (previous, current) {
          return previous.isSaving != current.isSaving;
        },
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      state.isSaving ? null : () => _showDiscardDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF6C63FF),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    S.of(context).common_btn_discard,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: state.isSaving
                      ? null
                      : () {
                          final imageToSave =
                              widget.enhancedImage ?? state.processedImage;

                          if (imageToSave == null) {
                            XToast.error(
                                S.of(context).error_somethingWrongTryAgain);
                            return;
                          }
                          context
                              .read<EnhanceImageBloc>()
                              .saveImage(imageToSave);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_rounded),
                            SizedBox(width: 8),
                            Text(
                              S.of(context).common_button_save,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDiscardDialog(BuildContext context) {
    XAlert.show(
      title: S.of(context).common_btn_discard,
      body: S.of(context).common_discard_message,
      actions: [
        XAlertButton(title: S.of(context).common_cancelButton_title),
        XAlertButton(
          title: S.of(context).common_agreeButton_title,
          isDestructiveAction: true,
          key: 'discard',
        ),
      ],
    ).then((key) {
      if (key == 'discard') {
        AppCoordinator.pop();
        AppCoordinator.pop();
      }
    });
  }
}

// Custom clipper for the slider comparison
class _SliderClipper extends CustomClipper<Rect> {
  final double sliderPosition;

  _SliderClipper(this.sliderPosition);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * sliderPosition, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) {
    return oldClipper.sliderPosition != sliderPosition;
  }
}
