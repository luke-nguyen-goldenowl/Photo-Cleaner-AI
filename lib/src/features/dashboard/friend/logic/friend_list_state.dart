import 'package:equatable/equatable.dart';
import 'package:myapp/src/features/dashboard/friend/model/search_query_formz.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import 'package:myapp/src/network/model/user/user.dart';

enum FriendListStatus { initial, loading, success, error }

class FriendListState extends Equatable {
  const FriendListState({
    this.status = FriendListStatus.initial,
    required this.friendsPagination,
    this.pendingRequestsCount = 0,
    this.totalFriend = 0,
    this.searchQuery = const SearchQueryFormz.pure(),
  });

  final FriendListStatus status;
  final MPagination<MUser> friendsPagination;
  final int pendingRequestsCount;
  final int totalFriend;
  final SearchQueryFormz searchQuery;

  bool get isEmpty =>
      friendsPagination.data.isEmpty && status == FriendListStatus.success;

  FriendListState copyWith({
    FriendListStatus? status,
    MPagination<MUser>? friendsPagination,
    SearchQueryFormz? searchQuery,
    int? pendingRequestsCount,
    int? totalFriend,
  }) {
    return FriendListState(
      status: status ?? this.status,
      friendsPagination: friendsPagination ?? this.friendsPagination,
      searchQuery: searchQuery ?? this.searchQuery,
      pendingRequestsCount: pendingRequestsCount ?? this.pendingRequestsCount,
      totalFriend: totalFriend ?? this.totalFriend,
    );
  }

  @override
  List<Object?> get props => [
        status,
        friendsPagination,
        pendingRequestsCount,
        totalFriend,
        searchQuery,
      ];

  @override
  String toString() {
    return 'FriendListState(status: $status, friends: ${friendsPagination.data.length}, pendingRequestsCount: $pendingRequestsCount)';
  }
}
