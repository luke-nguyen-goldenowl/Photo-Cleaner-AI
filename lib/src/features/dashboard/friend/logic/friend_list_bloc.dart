import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/dashboard/friend/logic/friend_list_state.dart';
import 'package:myapp/src/features/dashboard/friend/model/search_query_formz.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendListBloc extends Cubit<FriendListState> {
  FriendListBloc()
      : super(FriendListState(
          friendsPagination: MPagination<MUser>(pageLimit: 20),
        )) {
    _initializeAndLoad();
  }

  DomainManager get domain => DomainManager();
  RealtimeChannel? _realtimeChannel;

  String? _currentUserId;
  Timer? _debounceTimer;

  Future<void> _initializeAndLoad() async {
    await _syncCurrentUser();
    loadFriends();
    loadPendingRequestsCount();
    _subscribeToRealtime();
  }

  Future<void> _syncCurrentUser() async {
    final result = await domain.user.syncCurrentUser();
    if (result.isSuccess && result.data != null) {
      final user = result.data;
      if (user != null) {
        _currentUserId = user.id;
      }
    }
  }

  Future<void> loadFriends() async {
    if (isClosed) return;
    final userId = _currentUserId;

    if (userId == null) {
      emit(state.copyWith(
        status: FriendListStatus.loading,
      ));
      return;
    }

    if (!state.friendsPagination.canLoad) {
      return;
    }

    final currentPage = state.friendsPagination.page;
    final isFirstPage = currentPage == 0;

    emit(state.copyWith(
      friendsPagination: state.friendsPagination.toLoading(),
      status: isFirstPage ? FriendListStatus.loading : state.status,
    ));

    final friendshipsResult = await domain.friend.getFriends(userId);

    if (!friendshipsResult.isSuccess) {
      emit(state.copyWith(
        status: FriendListStatus.error,
      ));
      return;
    }

    final friendships = friendshipsResult.data ?? [];
    final friendIds = friendships.map((f) {
      return f.userId == _currentUserId ? f.friendId : f.userId;
    }).toList();

    if (friendIds.isEmpty && isFirstPage) {
      emit(state.copyWith(
        status: FriendListStatus.success,
        friendsPagination: state.friendsPagination.addAll(
          [],
          totalPage: 1,
          countData: 0,
        ),
      ));
      return;
    }

    final pageSize = state.friendsPagination.pageLimit;
    final start = currentPage * pageSize;
    final end = start + pageSize;
    final paginatedIds = friendIds.skip(start).take(pageSize).toList();

    final List<MUser> users = [];
    for (final friendId in paginatedIds) {
      final userResult = await domain.friend.getUserProfile(friendId);
      if (userResult.isSuccess && userResult.data != null) {
        final user = userResult.data;
        if (user != null) {
          users.add(user);
        }
      }
    }

    final isLastPage = end >= friendIds.length;
    final totalPage = isLastPage ? (currentPage + 1) : -1;
    final countData = isLastPage ? friendIds.length : -1;

    if (isClosed) return;

    emit(state.copyWith(
      status: FriendListStatus.success,
      friendsPagination: state.friendsPagination.addAll(
        users,
        totalPage: totalPage,
        countData: countData,
      ),
      totalFriend: friendIds.length,
    ));
  }

  Future<void> loadPendingRequestsCount() async {
    final userId = _currentUserId;
    if (userId == null) return;

    final result = await domain.friend.getPendingRequests(userId);
    if (isClosed) return;
    if (result.isSuccess) {
      emit(state.copyWith(pendingRequestsCount: result.data?.length ?? 0));
    }
  }

  Future<void> shareFriend(MUser user) async {
    await domain.friend.shareToFriend(user);
  }

  Future<void> refresh() async {
    await _syncCurrentUser();
    emit(state.copyWith(
      friendsPagination: MPagination<MUser>(pageLimit: 20),
    ));
    await loadFriends();
    await loadPendingRequestsCount();
  }

  void onSearchChange(String keyword) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      emit(state.copyWith(
        searchQuery: SearchQueryFormz.dirty(keyword),
      ));
    });
  }

  void _subscribeToRealtime() {
    if (_currentUserId == null) return;

    _realtimeChannel = supabaseClient
        .channel('friend_list')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friends',
          callback: (payload) {
            final newData = payload.newRecord;
            final oldData = payload.oldRecord;

            // Check if the change involves the current user
            final isRelevant = (newData['userId'] == _currentUserId ||
                newData['friendId'] == _currentUserId ||
                oldData['userId'] == _currentUserId ||
                oldData['friendId'] == _currentUserId);

            if (isRelevant) {
              refresh(); // Use refresh to reset pagination and reload
            }
          },
        )
        .subscribe();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _realtimeChannel?.unsubscribe();
    return super.close();
  }
}
