import 'package:equatable/equatable.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import 'package:myapp/src/network/model/friend/friend.dart';
import 'package:myapp/src/network/model/user/user.dart';

enum FriendRequestsStatus { initial, loading, success, error }

class FriendRequestsState extends Equatable {
  const FriendRequestsState({
    this.status = FriendRequestsStatus.initial,
    required this.requestsPagination,
    this.isLoading = false,
  });

  final FriendRequestsStatus status;
  final MPagination<FriendRequestItem> requestsPagination;
  final bool isLoading;

  FriendRequestsState copyWith({
    FriendRequestsStatus? status,
    final MPagination<FriendRequestItem>? requestsPagination,
    bool? isLoading,
  }) {
    return FriendRequestsState(
      status: status ?? this.status,
      requestsPagination: requestsPagination ?? this.requestsPagination,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        requestsPagination,
        isLoading,
      ];

  @override
  String toString() {
    return 'FriendRequestsState(status: $status, requests: ${requestsPagination.data.length}, isLoading: $isLoading)';
  }
}

class FriendRequestItem extends Equatable {
  const FriendRequestItem({
    required this.friendship,
    required this.user,
  });

  final Friend friendship;
  final MUser user;

  FriendRequestItem copyWith({
    Friend? friendship,
    MUser? user,
  }) {
    return FriendRequestItem(
      friendship: friendship ?? this.friendship,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [friendship, user];

  @override
  String toString() {
    return 'FriendRequestItem(friendship: ${friendship.id}, user: ${user.id})';
  }
}
