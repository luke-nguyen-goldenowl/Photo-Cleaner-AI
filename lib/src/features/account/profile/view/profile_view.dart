import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/config/constants/constants.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/src/features/account/profile/logic/profile_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/router/route_name.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        context: context,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (previous, current) =>
              previous.isLoading != current.isLoading ||
              previous.user != current.user ||
              previous.photoCount != current.photoCount ||
              previous.friendCount != current.friendCount,
          builder: (context, profileState) {
            if (profileState.isLoading && profileState.user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProfileBloc>().loadUserProfile(context);
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildProfileHeader(profileState),
                          const SizedBox(height: 30),
                          _buildStatsRow(profileState, context),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              S.of(context).common_helper_text_profile,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildMenuItem(
                            icon: Icons.favorite,
                            iconColor: const Color(0xFFFF4D80),
                            iconBgColor: const Color(0xFFFFEEF3),
                            title: S.of(context).common_favourite_text_profile,
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.share,
                            iconColor: const Color(0xFF37E663),
                            iconBgColor: const Color(0xFFE8F9E7),
                            title:
                                S.of(context).common_share_folder_text_profile,
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.lock_outline,
                            iconColor: const Color(0xFF9C27B0),
                            iconBgColor: const Color(0xFFF3E5F5),
                            title:
                                S.of(context).common_secure_folder_text_profile,
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.logout,
                            iconColor: Colors.redAccent,
                            iconBgColor: const Color(0xFFFFEBEE),
                            title: S.of(context).common_log_out_text,
                            onTap: () {
                              context.read<AccountBloc>().onLogOut(context);
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildMemberSince(profileState, context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                      onPressed: () {
                        final user = context.read<ProfileBloc>().state.user;
                        if (user != null) {
                          AppCoordinator.goNamed(AppRouteNames.profileEdit.name,
                              extra: user);
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileState state) {
    final user = state.user;
    final uid = user?.id;
    final avatarUrl = user?.avatarUrl ?? '${AppConstants.avatarLink}$uid';
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';
    final bio = user?.bio ?? 'Hi there! I am using Pixel Perfect.';

    return Column(
      children: [
        Stack(
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
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: Colors.grey[200],
                  onBackgroundImageError: (_, __) {},
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 10,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF091031),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          bio,
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

  Widget _buildStatsRow(ProfileState state, BuildContext context) {
    final photoCount = state.photoCount;
    final friendCount = state.friendCount;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            count: photoCount.toString(),
            label: S.of(context).common_image_text_profile,
            icon: Icons.image_outlined,
            iconColor: const Color(0xFF4834D4),
            iconBg: const Color(0xFFF0EFFF),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            count: friendCount.toString(),
            label: S.of(context).common_friend_text_profile,
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

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF091031),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildMemberSince(ProfileState state, BuildContext context) {
    Localizations.localeOf(context).languageCode;
    final createdAt = state.user?.createdAt;
    String memberText = '';

    if (createdAt != null) {
      final locale = Localizations.localeOf(context).languageCode;
      final formatter = DateFormat('MMMM yyyy', locale);
      memberText =
          "${S.of(context).common_member_since_text} ${formatter.format(createdAt)}";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Text(
          memberText,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
