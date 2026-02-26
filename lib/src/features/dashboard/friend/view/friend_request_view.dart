import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/dashboard/friend/logic/friend_requests_bloc.dart';
import 'package:myapp/src/features/dashboard/friend/logic/friend_requests_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/state/state_pagination_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendRequestView extends StatelessWidget {
  const FriendRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendRequestsBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            S.of(context).common_friend_invitation,
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
        body: BlocBuilder<FriendRequestsBloc, FriendRequestsState>(
          buildWhen: (previous, current) {
            return previous.status != current.status ||
                previous.requestsPagination != current.requestsPagination ||
                previous.isLoading != current.isLoading;
          },
          builder: (context, state) {
            if (state.isLoading && state.requestsPagination.page == 0) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == FriendRequestsStatus.error) {
              return _buildErrorState(
                  S.of(context).error_somethingWrongTryAgain);
            }

            if (state.requestsPagination.data.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () => context.read<FriendRequestsBloc>().refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requestsPagination.data.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.requestsPagination.data.length) {
                    return Center(
                      child: XStatePaginationWidget(
                        page: state.requestsPagination,
                        loadMore: () => context
                            .read<FriendRequestsBloc>()
                            .loadPendingRequests(),
                        autoLoad: true,
                      ),
                    );
                  }

                  final item = state.requestsPagination.data[index];
                  return _buildRequestCard(context, item);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 120, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            S.text.common_no_friend_invitation,
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
              S.text.common_friend_invitation_message,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, FriendRequestItem item) {
    final user = item.user;
    final friendship = item.friendship;

    final locale = Localizations.localeOf(context).languageCode;

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
      child: InkWell(
        onTap: () {
          AppCoordinator.showFriendProfileScreen(userId: user.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: (user.avatarUrl != null &&
                            user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : NetworkImage('${AppConstants.avatarLink}${user.id}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF091031),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(friendship.createdAt!, locale: locale),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<FriendRequestsBloc>()
                            .acceptRequest(friendship.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        S.of(context).common_btn_accept,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showRejectDialog(context, friendship.id,
                            user.name ?? S.text.common_this_user);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        S.of(context).common_btn_reject,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(
      BuildContext context, int friendshipId, String userName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          S.of(context).common_reject_invitation_title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
            '${S.of(context).common_reject_invitation_message} $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              S.of(context).common_cancelButton_title,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FriendRequestsBloc>().rejectRequest(friendshipId);
              XToast.success(S.of(context).common_reject_success);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(S.of(context).common_btn_reject),
          ),
        ],
      ),
    );
  }
}
