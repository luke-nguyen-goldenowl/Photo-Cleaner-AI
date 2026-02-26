import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/features/dashboard/friend/logic/search_user_bloc.dart';
import 'package:myapp/src/features/dashboard/friend/logic/search_user_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/forms/input.dart';
import 'package:myapp/widgets/state/state_pagination_widget.dart';

class SearchUserView extends StatelessWidget {
  const SearchUserView({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchUserBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            S.of(context).common_search,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => AppCoordinator.pop(),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<SearchUserBloc, SearchUserState>(
                buildWhen: (previous, current) {
                  return previous.searchQuery != current.searchQuery;
                },
                builder: (context, state) {
                  return XInput(
                    value: state.searchQuery.value,
                    hintText: S.of(context).common_friends_search_hint,
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      context.read<SearchUserBloc>().onSearchChanged(value);
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchUserBloc, SearchUserState>(
                buildWhen: (previous, current) {
                  return previous.status != current.status ||
                      previous.usersPagination != current.usersPagination;
                },
                builder: (context, state) {
                  if (state.status == SearchUserStatus.initial) {
                    return _buildEmptyState(context);
                  } else if (state.status == SearchUserStatus.searching &&
                      state.usersPagination.page == 0) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == SearchUserStatus.error) {
                    return _buildErrorState(context);
                  } else if (state.isEmpty) {
                    return _buildNoResultsState(context);
                  } else {
                    return _buildSearchResults(context, state);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).common_friends_search_description,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                S.of(context).common_friends_search_sub_description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchUserState state) {
    return RefreshIndicator(
      onRefresh: () => context.read<SearchUserBloc>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.usersPagination.data.length + 1,
        itemBuilder: (context, index) {
          if (index == state.usersPagination.data.length) {
            return Center(
              child: XStatePaginationWidget(
                page: state.usersPagination,
                loadMore: () => context.read<SearchUserBloc>().searchUsers(),
                autoLoad: true,
              ),
            );
          }

          final user = state.usersPagination.data[index];
          return _buildUserCard(
            context: context,
            name: user.name ?? '',
            email: user.email ?? '',
            avatar: user.avatarUrl ?? '${AppConstants.avatarLink}${user.id}',
            onTap: () {
              AppCoordinator.showFriendProfileScreen(userId: user.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            S.of(context).error_somethingWrongTryAgain,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 120, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              S.of(context).common_friends_search_no_result,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                S.of(context).common_friends_try_search_again,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard({
    required BuildContext context,
    required String name,
    required String email,
    required String avatar,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(avatar),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF091031),
          ),
        ),
      ),
    );
  }
}
