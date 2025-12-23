import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/logic/make_video_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/logic/make_video_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:video_player/video_player.dart';

class ResultVideoView extends StatefulWidget {
  final String videoPath;

  const ResultVideoView({super.key, required this.videoPath});

  @override
  State<ResultVideoView> createState() => _ResultVideoViewState();
}

class _ResultVideoViewState extends State<ResultVideoView> {
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    context.read<MakeVideoBloc>().initializeVideo(widget.videoPath);
  }

  void _setupChewieController(VideoPlayerController videoController) {
    _chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: true,
      looping: true,
      aspectRatio: videoController.value.aspectRatio,
      autoInitialize: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            S.of(context).error_somethingWrongTryAgain,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            S.of(context).common_video_ready_title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildSubtitle(),
            const SizedBox(height: 20),
            _buildVideoPlayer(),
            const SizedBox(height: 20),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        S.of(context).common_video_created_successfully,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Expanded(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BlocConsumer<MakeVideoBloc, MakeVideoState>(
            listenWhen: (previous, current) {
              return (previous.status != current.status) &&
                  (current.status == MakeVideoStatus.loaded ||
                      current.status == MakeVideoStatus.initialized ||
                      current.status == MakeVideoStatus.error);
            },
            listener: (context, state) {
              if ((state.status == MakeVideoStatus.loaded ||
                      state.status == MakeVideoStatus.initialized) &&
                  state.videoPlayerController != null) {
                _setupChewieController(state.videoPlayerController!);
                if (mounted) {
                  setState(() {});
                }
              } else if (state.status == MakeVideoStatus.error) {
                XToast.show(S.of(context).error_somethingWrongTryAgain);
              }
            },
            buildWhen: (previous, current) {
              return previous.status != current.status ||
                  previous.videoPlayerController !=
                      current.videoPlayerController;
            },
            builder: (context, state) {
              if (_chewieController != null) {
                return Chewie(controller: _chewieController!);
              }

              if (state.status == MakeVideoStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.withOpacity(0.7),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).error_somethingWrongTryAgain,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).common_loading,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BlocBuilder<MakeVideoBloc, MakeVideoState>(
        buildWhen: (previous, current) {
          return previous.status != current.status;
        },
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.status == MakeVideoStatus.saving
                      ? null
                      : () => _showDiscardDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    S.of(context).common_cancelButton_title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: state.status == MakeVideoStatus.saving
                      ? null
                      : () => context.read<MakeVideoBloc>().saveVideo(),
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
                  child: state.status == MakeVideoStatus.saving
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
      title: S.of(context).common_discard_video_title,
      body: S.of(context).common_confirm_discard_video,
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
        AppCoordinator.pop();
      }
    });
  }
}
