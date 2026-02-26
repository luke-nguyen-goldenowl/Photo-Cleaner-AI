import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/services/user_prefs.dart';

part 'profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  //final UserRepository userRepository;
  DomainManager get domain => DomainManager();

  ProfileBloc({required BuildContext context}) : super(const ProfileState()) {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final cachedUser = UserPrefs.I.getUser();
    final email = cachedUser?.email;
    if (cachedUser == null ||
        cachedUser.id.isEmpty ||
        email == null ||
        email.isEmpty) {
      emit(state.copyWith(
        status: ProfileStatus.error,
      ));
      return;
    }
    final result = await domain.user.getUserFromSupabase(email);

    if (result.isSuccess && result.data != null) {
      final user = result.data!;

      final friendsRes = await domain.friend.getFriendCount(user.id);
      final friendCount = friendsRes.data ?? 0;

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
        friendCount: friendCount,
      ));
    } else {
      emit(state.copyWith(
        status: ProfileStatus.error,
      ));
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }
}
