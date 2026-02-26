import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/duplicate_image/logic/duplicate_image_bloc.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/loading/scan_device_loading.dart';

class ScanDeviceView extends StatelessWidget {
  const ScanDeviceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DuplicateImageBloc, DuplicateImageState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.isCompleted && state.groups.isNotEmpty) {
          AppCoordinator.showDuplicateResults();
        } else if (state.isCompleted && state.groups.isEmpty) {
          XToast.show(S.of(context).common_no_duplicate_found);
          AppCoordinator.pop();
        } else if (state.hasError) {
          XToast.error(S.of(context).error_somethingWrongTryAgain);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            S.of(context).common_duplicate_image_grid_title,
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
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _buildIconStack(),
                    const SizedBox(height: 48),
                    Text(
                      S.of(context).common_duplicate_image_main_description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).common_duplicate_image_sub_description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    _buildBottomButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconStack() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0FF),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF5B5FEF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: 50,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    child: Container(
                      width: 60,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    child: Container(
                      width: 70,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 12,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Color(0xFFD1D5DB),
              size: 24,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 12,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Color(0xFFD1D5DB),
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return BlocBuilder<DuplicateImageBloc, DuplicateImageState>(
      buildWhen: (previous, current) =>
          previous.isScanning != current.isScanning,
      builder: (context, state) {
        final isDisabled = state.isScanning;

        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDisabled
                  ? [Colors.grey.shade400, Colors.grey.shade500]
                  : [const Color(0xFF5B5FEF), const Color(0xFF7C3FED)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF5B5FEF).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled
                  ? null
                  : () {
                      context.read<DuplicateImageBloc>().startScan();
                    },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    S.of(context).common_btn_action_duplicate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return BlocBuilder<DuplicateImageBloc, DuplicateImageState>(
      buildWhen: (previous, current) {
        return previous.isScanning != current.isScanning ||
            previous.progress != current.progress;
      },
      builder: (context, state) {
        if (state.isScanning) {
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
                  child: ScanDeviceLoadingIndicator(
                    progress: state.progress,
                  ),
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
