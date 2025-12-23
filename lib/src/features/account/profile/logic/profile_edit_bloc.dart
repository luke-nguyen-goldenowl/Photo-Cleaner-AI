import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/features/account/profile/model/bio_formz.dart';
import 'package:myapp/src/features/account/profile/service/image_picker_service.dart';
import 'package:myapp/src/features/authentication/model/name_formz.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/services/user_prefs.dart';

part 'profile_edit_state.dart';

class ProfileEditBloc extends Cubit<ProfileEditState> {
  //final UserRepository userRepository;
  DomainManager get domain => DomainManager();
  final ImagePickerService imagePickerService;

  ProfileEditBloc(
    MUser user, {
    ImagePickerService? imagePickerService,
  })  : imagePickerService = imagePickerService ?? ImagePickerService(),
        super(ProfileEditState(
          user: user,
          name: NameFormzInput.pure(user.name ?? ''),
          bio: BioFormzInput.pure(user.bio ?? ''),
          avatarUrl: user.avatarUrl,
        ));

  void onNameChanged(String value) {
    emit(state.copyWith(name: NameFormzInput.dirty(value)));
  }

  void onBioChanged(String value) {
    emit(state.copyWith(bio: BioFormzInput.dirty(value)));
  }

  void onAvatarChanged(String value) {
    emit(state.copyWith(avatarUrl: value));
  }

  Future<void> pickImageFromGallery() async {
    final result = await imagePickerService.pickImageFromGallery();
    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        status: ProfileEditStatus.initial,
        localAvatarPath: result.data,
      ));

      emit(state.copyWith(
        status: ProfileEditStatus.initial,
        localAvatarPath: result.data,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
      ));
    }
  }

  Future<void> pickImageFromCamera() async {
    final result = await imagePickerService.pickImageFromCamera();
    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        status: ProfileEditStatus.initial,
        localAvatarPath: result.data,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
      ));
    }
  }

  Future<void> saveProfile() async {
    if (!state.isValidated) {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
      ));

      return;
    }

    if (!state.hasChanges) {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
      ));

      return;
    }

    emit(state.copyWith(status: ProfileEditStatus.loading));

    String? avatarUrl = state.avatarUrl;

    if (state.localAvatarPath != null) {
      if (isClosed) return;
      emit(state.copyWith(status: ProfileEditStatus.uploading));

      final uploadResult = await domain.user.uploadAvatar(
        File(state.localAvatarPath!),
        state.user!.id,
      );
      if (uploadResult.isSuccess && uploadResult.data != null) {
        avatarUrl = uploadResult.data;
      } else {
        emit(state.copyWith(
          status: ProfileEditStatus.error,
        ));

        return;
      }
    }

    final updatedUser = state.user!.copyWith(
      name: state.name.value,
      bio: state.bio.value,
      avatarUrl: avatarUrl,
    );

    final result = await domain.user.updateUser(updatedUser);
    if (result.isSuccess && result.data != null) {
      UserPrefs.I.setUser(result.data!);
      emit(state.copyWith(
        status: ProfileEditStatus.success,
        user: result.data!,
        avatarUrl: avatarUrl,
        localAvatarPath: null,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
      ));
    }
  }
}
