import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/features/dashboard/friend/logic/friend_list_bloc.dart';
import 'package:myapp/src/features/dashboard/friend/logic/friend_list_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/services/network-connection/internet_connection_cubit.dart';
import 'package:myapp/widgets/forms/input.dart';
import 'package:myapp/widgets/state/state_pagination_widget.dart';

class FriendView extends StatelessWidget {
  const FriendView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendListBloc(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      S.of(context).common_friends_title,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, size: 28),
                      color: Colors.grey[700],
                      onPressed: () {
                        AppCoordinator.showSearchUserScreen();
                      },
                    ),
                    BlocBuilder<FriendListBloc, FriendListState>(
                      buildWhen: (previous, current) {
                        return previous.pendingRequestsCount !=
                            current.pendingRequestsCount;
                      },
                      builder: (context, state) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.group, size: 28),
                              color: Colors.grey[700],
                              onPressed: () async {
                                final result = await AppCoordinator
                                    .showFriendRequestsScreen<bool>();
                                if (result == true && context.mounted) {
                                  context.read<FriendListBloc>().refresh();
                                }
                              },
                            ),
                            if (state.pendingRequestsCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '${state.pendingRequestsCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 20,
                  thickness: 1,
                  color: Colors.grey[300],
                ),
                BlocBuilder<InternetConnectionCubit, InternetStatusState>(
                  buildWhen: (previous, current) {
                    return (previous == InternetStatusState.disconnected) !=
                        (current == InternetStatusState.disconnected);
                  },
                  builder: (context, internetState) {
                    if (internetState == InternetStatusState.disconnected) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.cloud_off,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                S.of(context).common_offline_mode,
                                style: const TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<FriendListBloc, FriendListState>(
                    buildWhen: (previous, current) {
                      return previous.status != current.status ||
                          previous.friendsPagination !=
                              current.friendsPagination ||
                          previous.searchQuery != current.searchQuery;
                    },
                    builder: (context, state) {
                      if (state.status == FriendListStatus.loading &&
                          state.friendsPagination.page == 0) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.status == FriendListStatus.error) {
                        return _buildErrorState(context,
                            S.of(context).error_somethingWrongTryAgain);
                      }

                      if (state.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      final query = removeDiacritics(
                        state.searchQuery.value.trim().toLowerCase(),
                      );

                      final filteredFriends = query.isEmpty
                          ? state.friendsPagination.data
                          : state.friendsPagination.data.where((user) {
                              final name = removeDiacritics(
                                  (user.name ?? '').toLowerCase());
                              final email = removeDiacritics(
                                  (user.email ?? '').toLowerCase());

                              return name.contains(query) ||
                                  email.contains(query);
                            }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  '${state.totalFriend} ${S.of(context).common_friend_count}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed:
                                      context.read<FriendListBloc>().refresh,
                                  icon: const Icon(Icons.refresh))
                            ],
                          ),
                          XInput(
                            value: state.searchQuery.value,
                            hintText: S.of(context).common_friends_search_hint,
                            prefixIcon: Icons.search,
                            onChanged: (value) {
                              context
                                  .read<FriendListBloc>()
                                  .onSearchChange(value);
                            },
                          ),
                          Expanded(
                            child: filteredFriends.isEmpty
                                ? Center(
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.search_off,
                                                size: 120,
                                                color: Colors.grey[300]),
                                            const SizedBox(height: 16),
                                            Text(
                                              S
                                                  .of(context)
                                                  .common_friends_search_no_result,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              S
                                                  .of(context)
                                                  .common_friends_try_search_again,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[500]),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      await context
                                          .read<FriendListBloc>()
                                          .refresh();
                                    },
                                    child: ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: filteredFriends.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == filteredFriends.length) {
                                          return Center(
                                            child: XStatePaginationWidget(
                                              page: state.friendsPagination,
                                              loadMore: () => context
                                                  .read<FriendListBloc>()
                                                  .loadFriends(),
                                              autoLoad: true,
                                            ),
                                          );
                                        }

                                        final friend = filteredFriends[index];
                                        return _buildFriendCard(
                                            context, friend);
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_rounded,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).common_friends_empty,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).common_friends_connect,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<FriendListBloc>().refresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(S.of(context).common_tap_to_refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, MUser user) {
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
        onTap: () async {
          final result = await AppCoordinator.showFriendProfileScreen<bool>(
            userId: user.id,
          );
          if (result == true && context.mounted) {
            context.read<FriendListBloc>().refresh();
          }
        },
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage:
              (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                  ? NetworkImage(user.avatarUrl!)
                  : NetworkImage('${AppConstants.avatarLink}${user.id}'),
        ),
        title: Text(
          user.name ?? 'Unknown',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF091031),
          ),
        ),
        subtitle: Text(
          user.email ?? '',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) async {
            switch (value) {
              case 'profile':
                final result =
                    await AppCoordinator.showFriendProfileScreen<bool>(
                  userId: user.id,
                );
                if (result == true && context.mounted) {
                  context.read<FriendListBloc>().refresh();
                }
                break;
              case 'share':
                context.read<FriendListBloc>().shareFriend(user);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline,
                      color: Color(0xFF6C63FF), size: 20),
                  SizedBox(width: 12),
                  Text(S.of(context).common_tab_profile),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_rounded, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Text(S.of(context).common_share_button_text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
