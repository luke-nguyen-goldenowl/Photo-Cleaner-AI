import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/dashboard/friend/logic/user_profile_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/services/user_prefs.dart';

class UserProfileBloc extends Cubit<UserProfileState> {
  UserProfileBloc(this._userId) : super(const UserProfileState()) {
    _loadUserProfile();
  }

  final String _userId;
  DomainManager get domain => DomainManager();

  Future<void> _loadUserProfile() async {
    emit(state.copyWith(status: UserProfileStatus.loading));

    final currentUser = UserPrefs.I.getUser();
    if (currentUser == null) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
      ));
      return;
    }

    final userResult = await domain.friend.getUserProfile(_userId);
    if (!userResult.isSuccess) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
      ));
      return;
    }
    final friendCount = await domain.friend.getUserCountFriend(_userId);
    final friendshipResult = await domain.friend.getFriendshipStatus(
      userId: currentUser.id,
      friendId: _userId,
    );

    emit(state.copyWith(
      status: UserProfileStatus.success,
      user: userResult.data,
      friendCount: friendCount.data ?? 0,
      friendship: friendshipResult.data,
    ));
  }

  Future<void> sendFriendRequest() async {
    final currentUser = UserPrefs.I.getUser();
    if (currentUser == null) return;

    emit(state.copyWith(friendshipAction: FriendshipAction.sending));

    final result = await domain.friend.sendFriendRequest(
      userId: currentUser.id,
      friendId: _userId,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        friendship: result.data,
        friendshipAction: FriendshipAction.none,
      ));
    } else {
      emit(state.copyWith(friendshipAction: FriendshipAction.none));
    }
  }

  Future<void> removeFriend() async {
    final currentUser = UserPrefs.I.getUser();
    if (currentUser == null) return;

    emit(state.copyWith(friendshipAction: FriendshipAction.removing));

    final result = await domain.friend.removeFriend(
      userId: currentUser.id,
      friendId: _userId,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        friendship: null,
        friendshipAction: FriendshipAction.none,
        friendCount: state.friendCount > 0 ? state.friendCount - 1 : 0,
      ));
      XToast.success(S.text.common_cancel_friend_request_success);
    } else {
      emit(state.copyWith(friendshipAction: FriendshipAction.none));
    }
  }

  Future<void> refresh() async {
    await _loadUserProfile();
  }
}
