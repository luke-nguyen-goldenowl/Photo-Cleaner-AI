import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/src/features/account/profile/model/bio_formz.dart';
import 'package:myapp/src/features/authentication/model/name_formz.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/user/user_repository.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:path/path.dart' as path;

part 'profile_edit_state.dart';

class ProfileEditBloc extends Cubit<ProfileEditState> {
  final UserRepository userRepository;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileEditBloc(MUser user, {required this.userRepository})
      : super(ProfileEditState(
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

  Future<void> pickImageFromGallery(BuildContext context) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _processImage(pickedFile.path, context);
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
        errorMessage: S.of(context).error_somethingWrongTryAgain,
      ));
    }
  }

  Future<void> pickImageFromCamera(BuildContext context) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _processImage(pickedFile.path, context);
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
        errorMessage: S.of(context).error_somethingWrongTryAgain,
      ));
    }
  }

  Future<void> _processImage(String imagePath, BuildContext context) async {
    try {
      emit(state.copyWith(status: ProfileEditStatus.loading));

      final compressedFile = await _compressImage(imagePath);

      if (compressedFile != null) {
        emit(state.copyWith(
          status: ProfileEditStatus.initial,
          localAvatarPath: compressedFile.path,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileEditStatus.error,
          errorMessage: S.of(context).error_somethingWrongTryAgain,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
        errorMessage: S.of(context).error_somethingWrongTryAgain,
      ));
    }
  }

  Future<File?> _compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = path.basenameWithoutExtension(imagePath);
      final fileExtension = path.extension(imagePath);
      final targetPath =
          '${file.parent.path}/${fileName}_compressed$fileExtension.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: 80,
        minWidth: 512,
        minHeight: 512,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        await file.length();
        await File(result.path).length();
        return File(result.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    if (!state.isValidated) {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
        errorMessage: S.of(context).error_somethingWrongTryAgain,
      ));
      return;
    }

    if (!state.hasChanges) {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
        errorMessage: S.of(context).error_somethingWrongTryAgain,
      ));
      return;
    }

    try {
      emit(state.copyWith(status: ProfileEditStatus.loading));

      String? avatarUrl = state.avatarUrl;

      if (state.localAvatarPath != null) {
        emit(state.copyWith(status: ProfileEditStatus.uploading));
        final uploadResult = await userRepository.uploadAvatar(
          File(state.localAvatarPath!),
          state.user!.id,
        );

        if (uploadResult.isSuccess && uploadResult.data != null) {
          avatarUrl = uploadResult.data;
        } else {
          emit(state.copyWith(
            status: ProfileEditStatus.error,
            errorMessage: uploadResult.error ??
                S.of(context).error_somethingWrongTryAgain,
          ));
          return;
        }
      }

      final updatedUser = state.user!.copyWith(
        name: state.name.value,
        bio: state.bio.value,
        avatarUrl: avatarUrl,
      );

      final result = await userRepository.updateUser(updatedUser);

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
          errorMessage:
              result.error ?? S.of(context).error_somethingWrongTryAgain,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileEditStatus.error,
        errorMessage: S.of(context).error_somethingWrongTryAgain,
      ));
    }
  }
}
