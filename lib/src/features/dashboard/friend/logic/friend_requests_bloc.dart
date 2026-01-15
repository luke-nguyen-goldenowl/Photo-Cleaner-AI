import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/src/features/dashboard/friend/logic/friend_requests_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendRequestsBloc extends Cubit<FriendRequestsState> {
  FriendRequestsBloc()
      : super(FriendRequestsState(
          requestsPagination: MPagination<FriendRequestItem>(pageLimit: 20),
        )) {
    loadPendingRequests();
    subscribeToRealtime();
  }

  DomainManager get domain => DomainManager();
  RealtimeChannel? _realtimeChannel;

  String? get _currentUser => GetIt.I<AccountBloc>().state.user.id;

  Future<void> loadPendingRequests() async {
    emit(state.copyWith(status: FriendRequestsStatus.loading, isLoading: true));

    final userId = _currentUser;
    if (userId == null) {
      emit(state.copyWith(
        status: FriendRequestsStatus.error,
        isLoading: false,
      ));
      return;
    }
    if (!state.requestsPagination.canLoad) {
      return;
    }

    final currentPage = state.requestsPagination.page;
    final isFirstPage = currentPage == 0;

    emit(state.copyWith(
      requestsPagination: state.requestsPagination.toLoading(),
      status: isFirstPage ? FriendRequestsStatus.loading : state.status,
      isLoading: isFirstPage,
    ));

    final result = await domain.friend.getPendingRequests(userId);

    if (!result.isSuccess) {
      emit(state.copyWith(
        status: FriendRequestsStatus.error,
        isLoading: false,
      ));
      return;
    }

    final allFriendships = result.data ?? [];
    if (allFriendships.isEmpty && isFirstPage) {
      emit(state.copyWith(
        status: FriendRequestsStatus.success,
        isLoading: false,
        requestsPagination: state.requestsPagination.addAll(
          [],
          totalPage: 1,
          countData: 0,
        ),
      ));
      return;
    }

    final pageSize = state.requestsPagination.pageLimit;
    final start = currentPage * pageSize;
    final end = start + pageSize;

    final paginatedFriendships =
        allFriendships.skip(start).take(pageSize).toList();

    final List<FriendRequestItem> items = [];
    for (final friendship in paginatedFriendships) {
      final userResult = await domain.friend.getUserProfile(friendship.userId);
      final user = userResult.data;
      if (userResult.isSuccess && user != null) {
        items.add(FriendRequestItem(
          friendship: friendship,
          user: user,
        ));
      }
    }

    final isLastPage = end >= allFriendships.length;
    final totalPage = isLastPage ? (currentPage + 1) : -1;
    final countData = isLastPage ? allFriendships.length : -1;

    if (isClosed) return;

    emit(state.copyWith(
      status: FriendRequestsStatus.success,
      isLoading: false,
      requestsPagination: state.requestsPagination.addAll(
        items,
        totalPage: totalPage,
        countData: countData,
      ),
    ));
  }

  void subscribeToRealtime() {
    final userId = _currentUser;
    if (userId == null) {
      return;
    }
    _realtimeChannel = supabaseClient
        .channel('friend_requests')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friends',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'friend_id',
            value: userId,
          ),
          callback: (payload) {
            loadPendingRequests();
          },
        )
        .subscribe();
  }

  Future<void> acceptRequest(int friendshipId) async {
    final result = await domain.friend.acceptFriendRequest(friendshipId);

    if (result.isSuccess) {
      final updatedList = state.requestsPagination.data
          .where((item) => item.friendship.id != friendshipId)
          .toList();

      emit(state.copyWith(
          requestsPagination: state.requestsPagination
              .copyWith(data: updatedList, countData: updatedList.length)));
      XToast.success(S.text.common_accept_success);
    }
  }

  Future<void> rejectRequest(int friendshipId) async {
    final result = await domain.friend.rejectFriendRequest(friendshipId);

    if (result.isSuccess) {
      final updatedList = state.requestsPagination.data
          .where((item) => item.friendship.id != friendshipId)
          .toList();

      emit(state.copyWith(
          requestsPagination: state.requestsPagination
              .copyWith(data: updatedList, countData: updatedList.length)));
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(
      requestsPagination: MPagination<FriendRequestItem>(pageLimit: 20),
    ));
    await loadPendingRequests();
  }

  @override
  Future<void> close() {
    _realtimeChannel?.unsubscribe();
    return super.close();
  }
}
