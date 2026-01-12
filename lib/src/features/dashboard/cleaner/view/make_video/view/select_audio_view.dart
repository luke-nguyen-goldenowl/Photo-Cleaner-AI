import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/logic/make_video_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/logic/make_video_state.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/model/audio_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/utils/date/duration.ext.dart';
import 'package:myapp/widgets/loading/loading_clock.dart';
import 'package:myapp/widgets/state/state_pagination_widget.dart';

class SelectAudioView extends StatefulWidget {
  const SelectAudioView({super.key});

  @override
  State<SelectAudioView> createState() => _SelectAudioViewState();
}

class _SelectAudioViewState extends State<SelectAudioView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).common_select_audio_title,
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
        backgroundColor: Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: Stack(
        children: [
          BlocConsumer<MakeVideoBloc, MakeVideoState>(
            listenWhen: (previous, current) {
              return previous.status != current.status;
            },
            buildWhen: (previous, current) {
              return previous.status != current.status ||
                  previous.audioPagination != current.audioPagination ||
                  previous.selectedAudio != current.selectedAudio;
            },
            listener: (context, state) {
              if (state.status == MakeVideoStatus.error) {
                XToast.show(S.of(context).error_somethingWrongTryAgain);
              }
            },
            builder: (context, state) {
              if (state.audioPagination.isFirstLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClockLoadingIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).common_loading,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state.audios.isEmpty && state.audioPagination.page > 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).common_no_audio_file_selected,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.of(context).common_tap_to_select_audio,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: state.audios.length,
                      itemBuilder: (context, index) {
                        final audio = state.audios[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BlocBuilder<MakeVideoBloc, MakeVideoState>(
                            buildWhen: (prev, curr) =>
                                prev.selectedAudio?.path !=
                                curr.selectedAudio?.path,
                            builder: (context, blocState) {
                              final isSelected =
                                  blocState.selectedAudio?.path == audio.path;
                              return AudioItem(
                                audio: audio,
                                isSelected: isSelected,
                                onTap: () => context
                                    .read<MakeVideoBloc>()
                                    .selectAudio(audio),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  XStatePaginationWidget(
                    page: state.audioPagination,
                    loadMore: () =>
                        context.read<MakeVideoBloc>().loadAudioFromDevice(),
                    autoLoad: true,
                  ),
                  _buildCreateVideoButton(context, state),
                ],
              );
            },
          ),
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return BlocBuilder<MakeVideoBloc, MakeVideoState>(
      buildWhen: (previous, current) =>
          previous.isCreating != current.isCreating ||
          previous.progress != current.progress,
      builder: (context, state) {
        if (state.isCreating) {
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
                  child: ClockLoadingIndicator(progress: state.progress),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCreateVideoButton(BuildContext context, MakeVideoState state) {
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
        onPressed: state.selectedAudio != null && !state.isCreating
            ? () {
                context.read<MakeVideoBloc>().createVideo();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: state.isCreating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                S.of(context).common_button_create_video,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class AudioItem extends StatelessWidget {
  final MAudioItem audio;
  final bool isSelected;
  final VoidCallback onTap;

  const AudioItem({
    required this.audio,
    required this.isSelected,
    required this.onTap,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSelected ? Icons.volume_up : Icons.music_note,
                  color: isSelected ? Colors.white : const Color(0xFF6C63FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audio.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Duration(seconds: audio.duration).toMMSS,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF6C63FF),
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
