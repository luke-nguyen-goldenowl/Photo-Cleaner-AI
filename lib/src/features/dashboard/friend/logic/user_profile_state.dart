import 'package:equatable/equatable.dart';
import 'package:myapp/src/network/model/friend/friend.dart';
import 'package:myapp/src/network/model/user/user.dart';

enum UserProfileStatus {
  initial,
  loading,
  success,
  error,
}

enum FriendshipAction {
  none,
  sending,
  accepting,
  removing,
}

class UserProfileState extends Equatable {
  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.user,
    this.friendship,
    this.friendCount = 0,
    this.friendshipAction = FriendshipAction.none,
  });

  final UserProfileStatus status;
  final MUser? user;
  final Friend? friendship;
  final int friendCount;
  final FriendshipAction friendshipAction;

  bool get isLoading => status == UserProfileStatus.loading;
  bool get isFriendshipLoading => friendshipAction != FriendshipAction.none;

  bool get isFriend =>
      friendship != null && friendship!.status == FriendStatus.accepted;

  bool get hasPendingRequest =>
      friendship != null && friendship!.status == FriendStatus.pending;

  UserProfileState copyWith({
    UserProfileStatus? status,
    MUser? user,
    Friend? friendship,
    int? friendCount,
    FriendshipAction? friendshipAction,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      friendship: friendship,
      friendCount: friendCount ?? this.friendCount,
      friendshipAction: friendshipAction ?? this.friendshipAction,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        friendship,
        friendCount,
        friendshipAction,
      ];
}
