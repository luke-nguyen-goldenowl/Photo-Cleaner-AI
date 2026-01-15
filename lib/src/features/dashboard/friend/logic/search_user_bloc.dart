import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/dashboard/friend/logic/search_user_state.dart';
import 'package:myapp/src/features/dashboard/friend/model/search_query_formz.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import 'package:myapp/src/network/model/user/user.dart';

class SearchUserBloc extends Cubit<SearchUserState> {
  SearchUserBloc()
      : super(SearchUserState(
          usersPagination: MPagination<MUser>(pageLimit: 20),
        ));

  DomainManager get domain => DomainManager();
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 500);

  void onSearchChanged(String value) {
    _debounceTimer?.cancel();

    final formz = SearchQueryFormz.dirty(value);
    emit(state.copyWith(searchQuery: formz));

    if (value.trim().isEmpty) {
      emit(SearchUserState(
        usersPagination: MPagination<MUser>(pageLimit: 20),
      ));
      return;
    }
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch();
    });
  }

  Future<void> searchUsers() async {
    if (isClosed) return;
    if (!state.usersPagination.canLoad) return;

    final query = state.searchQuery.value.trim();
    if (query.isEmpty) return;

    final currentPage = state.usersPagination.page;
    emit(state.copyWith(
      usersPagination: state.usersPagination.toLoading(),
      status: currentPage == 0 ? SearchUserStatus.searching : state.status,
    ));

    final result = await domain.friend.searchUsers(
      query: query,
      page: currentPage,
      pageSize: state.usersPagination.pageLimit,
    );

    if (!result.isSuccess) {
      emit(state.copyWith(
        status: SearchUserStatus.error,
      ));
      return;
    }
    final newUsers = result.data ?? [];
    final isLastPage = newUsers.length < state.usersPagination.pageLimit;
    final totalPage = isLastPage ? (currentPage + 1) : -1;
    final countData =
        isLastPage ? (state.usersPagination.data.length + newUsers.length) : -1;

    if (isClosed) return;

    emit(state.copyWith(
      status: SearchUserStatus.success,
      usersPagination: state.usersPagination.addAll(
        newUsers,
        totalPage: totalPage,
        countData: countData,
      ),
    ));
  }

  Future<void> _performSearch() async {
    emit(state.copyWith(
      usersPagination: MPagination<MUser>(pageLimit: 20),
    ));
    await searchUsers();
  }

  Future<void> refresh() async {
    final query = state.searchQuery.value.trim();
    if (query.isEmpty) return;
    emit(state.copyWith(
      usersPagination: MPagination<MUser>(pageLimit: 20),
    ));
    await searchUsers();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
