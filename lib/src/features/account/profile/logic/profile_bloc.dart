import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/user/user_repository.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/services/user_prefs.dart';

part 'profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({required this.userRepository, required BuildContext context})
      : super(const ProfileState()) {
    loadUserProfile(context);
  }

  Future<void> loadUserProfile(BuildContext context) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final cachedUser = UserPrefs.I.getUser();
      if (cachedUser == null || cachedUser.id.isEmpty) {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: S.of(context).error_somethingWrongTryAgain,
        ));
        return;
      }
      final result =
          await userRepository.getUserFromSupabase(cachedUser.email!);

      if (result.isSuccess && result.data != null) {
        final user = result.data!;

        final photoCount = 0;
        final friendCount = 0;

        emit(state.copyWith(
          status: ProfileStatus.loaded,
          user: user,
          photoCount: photoCount,
          friendCount: friendCount,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: S.of(context).error_somethingWrongTryAgain,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: S.of(context).error_somethingWrongTryAgain,
      ));
    }
  }

  Future<void> refreshProfile(BuildContext context) async {
    await loadUserProfile(context);
  }
}
