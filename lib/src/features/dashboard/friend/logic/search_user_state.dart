import 'package:equatable/equatable.dart';
import 'package:myapp/src/features/dashboard/friend/model/search_query_formz.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import 'package:myapp/src/network/model/user/user.dart';

enum SearchUserStatus {
  initial,
  searching,
  success,
  error,
}

class SearchUserState extends Equatable {
  const SearchUserState({
    this.status = SearchUserStatus.initial,
    this.searchQuery = const SearchQueryFormz.pure(),
    required this.usersPagination,
  });
  final SearchUserStatus status;
  final SearchQueryFormz searchQuery;
  final MPagination<MUser> usersPagination;

  bool get isEmpty =>
      usersPagination.data.isEmpty && status == SearchUserStatus.success;

  SearchUserState copyWith({
    SearchUserStatus? status,
    SearchQueryFormz? searchQuery,
    MPagination<MUser>? usersPagination,
  }) {
    return SearchUserState(
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      usersPagination: usersPagination ?? this.usersPagination,
    );
  }

  @override
  List<Object?> get props => [
        status,
        searchQuery,
        usersPagination,
      ];
}
