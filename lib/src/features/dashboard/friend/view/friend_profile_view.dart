import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/src/features/dashboard/friend/logic/user_profile_bloc.dart';
import 'package:myapp/src/features/dashboard/friend/logic/user_profile_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/router/coordinator.dart';

class FriendProfileView extends StatefulWidget {
  const FriendProfileView({super.key, required this.userId});
  final String userId;

  @override
  State<FriendProfileView> createState() => _FriendProfileViewState();
}

class _FriendProfileViewState extends State<FriendProfileView> {
  bool _hasChanges = false;

  void _onFriendshipChanged() {
    _hasChanges = true;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = GetIt.I<AccountBloc>().state.user.id;
    if (widget.userId == currentUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppCoordinator.pop();
        AppCoordinator.showProfile();
      });
    }
    return BlocProvider(
      create: (context) => UserProfileBloc(widget.userId),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          AppCoordinator.pop(_hasChanges);
        },
        child: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.status == UserProfileStatus.error) {
              return _buildErrorState(context);
            }

            final user = state.user;
            if (user == null) return const SizedBox.shrink();

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.black),
                  onPressed: () => AppCoordinator.pop(_hasChanges),
                ),
                title: Text(
                  S.of(context).common_tab_profile,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: RefreshIndicator(
                onRefresh: () => context.read<UserProfileBloc>().refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      _buildProfileHeader(user, state),
                      const SizedBox(height: 30),
                      _buildFriendshipButton(context, state),
                      const SizedBox(height: 30),
                      _buildStatsRow(state),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(MUser user, UserProfileState state) {
    final avatarUrl = user.avatarUrl ?? '${AppConstants.avatarLink}${user.id}';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.grey[200],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name ?? '',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF091031),
          ),
        ),
        const SizedBox(height: 4),
        state.isFriend
            ? Text(
                user.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              )
            : SizedBox.shrink(),
        const SizedBox(height: 16),
        Text(
          user.bio ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildFriendshipButton(BuildContext context, UserProfileState state) {
    if (state.isFriendshipLoading) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[100],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (state.isFriend) {
      return _buildFriendButton(context, state);
    } else if (state.hasPendingRequest) {
      return _buildPendingRequestButton(context, state);
    } else {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            _onFriendshipChanged();
            context.read<UserProfileBloc>().sendFriendRequest();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                S.of(context).common_add_friend,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildPendingRequestButton(
      BuildContext context, UserProfileState state) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'cancel') {
          _onFriendshipChanged();
          context.read<UserProfileBloc>().removeFriend();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'cancel',
          child: Row(
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(S.of(context).common_cancel_friend_request),
            ],
          ),
        ),
      ],
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6C63FF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 8),
            Text(
              S.of(context).common_pending_friend_request,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendButton(BuildContext context, UserProfileState state) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'remove') {
          _showRemoveFriendDialog(context);
        }
      },
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.person_remove, color: Colors.red[400]),
              const SizedBox(width: 12),
              Text(
                S.of(context).common_friends_unfriend,
                style: TextStyle(color: Colors.red[400]),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6C63FF), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              S.of(context).common_friends_connected,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showRemoveFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          S.of(context).common_friends_unfriend,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          S.of(context).common_unfriend_message,
        ),
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
              _onFriendshipChanged();
              context.read<UserProfileBloc>().removeFriend();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(S.of(context).common_agreeButton_title),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserProfileState state) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            count: state.friendCount.toString(),
            label: S.text.common_friend_text_profile,
            icon: Icons.people_outline,
            iconColor: const Color(0xFFFF4D80),
            iconBg: const Color(0xFFFFEEF3),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String count,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF091031),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => AppCoordinator.pop(_hasChanges),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              S.of(context).error_somethingWrongTryAgain,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
