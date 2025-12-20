import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/src/features/account/profile/logic/profile_edit_bloc.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/forms/input.dart';

class ProfileEditView extends StatelessWidget {
  const ProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = GoRouterState.of(context).extra as MUser;
    return BlocProvider(
        create: (context) => ProfileEditBloc(user),
        child: BlocConsumer<ProfileEditBloc, ProfileEditState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == ProfileEditStatus.success) {
              XToast.success(S.of(context).success_update_profile);

              if (state.user != null) {
                context.read<AccountBloc>().onEditProfileSuccess(
                      name: state.user!.name ?? '',
                    );
              }
              AppCoordinator.pop();
            } else if (state.status == ProfileEditStatus.error) {
              XToast.error(S.of(context).error_somethingWrongTryAgain);
            }
          },
          buildWhen: (previous, current) =>
              previous != current &&
              current.status != ProfileEditStatus.success,
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF091031)),
                  onPressed: () => AppCoordinator.pop(),
                ),
                title: Text(
                  S.of(context).common_edit_profile_text,
                  style: TextStyle(
                    color: Color(0xFF091031),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  if (state.hasChanges &&
                      !state.isLoading &&
                      !state.isUploading &&
                      state.isValidated)
                    TextButton(
                      onPressed: () {
                        context.read<ProfileEditBloc>().saveProfile(context);
                      },
                      child: Text(
                        S.of(context).common_save_button_profile_text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                ],
              ),
              body: state.isLoading || state.isUploading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            state.isUploading
                                ? S.of(context).common_uploading_image_text
                                : S.of(context).common_handling_text,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildAvatarSection(context, state),
                          const SizedBox(height: 40),
                          XInput(
                            value: state.name.value,
                            hintText:
                                S.of(context).common_name_label_input_text,
                            prefixIcon: Icons.person_outline,
                            onChanged: (value) {
                              context
                                  .read<ProfileEditBloc>()
                                  .onNameChanged(value);
                            },
                            errorText: state.name.errorOf(context),
                          ),
                          const SizedBox(height: 20),
                          XInput(
                            value: state.bio.value,
                            hintText: S.of(context).common_bio_label_input_text,
                            prefixIcon: Icons.info_outline,
                            onChanged: (value) {
                              context
                                  .read<ProfileEditBloc>()
                                  .onBioChanged(value);
                            },
                            errorText: state.bio.errorOf(context),
                            keyboardType: TextInputType.multiline,
                            maxLength: 200,
                          ),
                          const SizedBox(height: 40),
                          Text(
                            S.of(context).common_subTitle_edit_profile,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ));
  }

  Widget _buildAvatarSection(BuildContext context, ProfileEditState state) {
    ImageProvider avatarProvider;
    if (state.avatarUrl != null && state.avatarUrl!.isNotEmpty) {
      avatarProvider = NetworkImage(state.avatarUrl!);
    } else {
      avatarProvider = NetworkImage(
        '${AppConstants.avatarLink}${state.user?.id}',
      );
    }

    if (state.localAvatarPath != null) {
      avatarProvider = FileImage(File(state.localAvatarPath!));
    }

    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: avatarProvider,
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImageSourceDialog(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    final bloc = context.read<ProfileEditBloc>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF6C63FF)),
                title: Text(S.of(context).common_select_from_gallery),
                onTap: () {
                  Navigator.pop(context);
                  bloc.pickImageFromGallery(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
                title: Text(S.of(context).common_take_new_image),
                onTap: () {
                  Navigator.pop(context);
                  bloc.pickImageFromCamera(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
