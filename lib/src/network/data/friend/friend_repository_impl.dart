import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/friend/friend_repository.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/network/model/friend/friend.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';
import 'package:myapp/src/utils/utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FriendRepositoryImpl extends FriendRepository {
  @override
  Future<MResult<Friend>> sendFriendRequest({
    required String userId,
    required String friendId,
  }) async {
    try {
      if (userId.isEmpty || friendId.isEmpty) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      if (userId == friendId) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }
      final existing = await supabaseClient
          .from('friends')
          .select()
          .or('and(userId.eq.$userId,friendId.eq.$friendId),and(userId.eq.$friendId,friendId.eq.$userId)')
          .maybeSingle();

      if (existing != null) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final response = await supabaseClient
          .from('friends')
          .insert({
            'userId': userId,
            'friendId': friendId,
            'status': 'pending',
            'createdAt': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final friend = Friend.fromJson(response);
      return MResult.success(friend);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<Friend>> acceptFriendRequest(int friendshipId) async {
    try {
      final response = await supabaseClient
          .from('friends')
          .update({
            'status': 'accepted',
            'createdAt': DateTime.now().toIso8601String()
          })
          .eq('id', friendshipId)
          .select()
          .single();

      final friend = Friend.fromJson(response);
      return MResult.success(friend);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<void>> rejectFriendRequest(int friendshipId) async {
    try {
      await supabaseClient.from('friends').delete().eq('id', friendshipId);
      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<void>> removeFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      if (userId.isEmpty || friendId.isEmpty) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }
      await supabaseClient.from('friends').delete().or(
          'and(userId.eq.$userId,friendId.eq.$friendId),and(userId.eq.$friendId,friendId.eq.$userId)');

      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<Friend?>> getFriendshipStatus({
    required String userId,
    required String friendId,
  }) async {
    try {
      if (userId.isEmpty || friendId.isEmpty) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final response = await supabaseClient
          .from('friends')
          .select()
          .or('and(userId.eq.$userId,friendId.eq.$friendId),and(userId.eq.$friendId,friendId.eq.$userId)')
          .maybeSingle();

      if (response == null) {
        return MResult.success(null);
      }

      final friend = Friend.fromJson(response);
      return MResult.success(friend);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<Friend>>> getPendingRequests(String userId) async {
    try {
      if (userId.isEmpty) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final response = await supabaseClient
          .from('friends')
          .select()
          .eq('friendId', userId)
          .eq('status', 'pending')
          .order('createdAt', ascending: false);

      final requests =
          (response as List).map((json) => Friend.fromJson(json)).toList();

      return MResult.success(requests);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<int>> getFriendCount(String userId) async {
    try {
      if (userId.isEmpty) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final resp = await supabaseClient
          .rpc('get_friend_count', params: {'p_user_id': userId});

      final count =
          (resp is num) ? resp.toInt() : int.tryParse('${resp ?? 0}') ?? 0;

      return MResult.success(count);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<MUser>>> searchUsers({
    required String query,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return MResult.success([]);
      }
      final response = await supabaseClient
          .from('users')
          .select()
          .order('name', ascending: true);

      final allUsers = (response as List).map((json) {
        return MUser(
          id: json['id'] as String,
          name: json['name'] as String?,
          email: json['email'] as String?,
          bio: json['bio'] as String?,
          avatarUrl: json['avatarUrl'] as String?,
          createdAt: json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
        );
      }).toList();

      final filteredUsers = allUsers.where((user) {
        return Utils.isMatchSearchAccent(user.name ?? '', query);
      }).toList();

      final from = page * pageSize;
      final to = from + pageSize;
      final paginatedUsers = filteredUsers.sublist(
        from,
        to > filteredUsers.length ? filteredUsers.length : to,
      );

      return MResult.success(paginatedUsers);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MUser>> getUserProfile(String userId) async {
    try {
      if (userId.isEmpty) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final response = await supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final user = MUser(
        id: response['id'] as String,
        name: response['name'] as String?,
        email: response['email'] as String?,
        bio: response['bio'] as String?,
        avatarUrl: response['avatarUrl'] as String?,
        createdAt: response['createdAt'] != null
            ? DateTime.parse(response['createdAt'] as String)
            : null,
      );

      return MResult.success(user);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<int>> getUserCountFriend(String userId) async {
    try {
      if (userId.isEmpty) {
        return MResult.error(S.text.error_somethingWrongTryAgain);
      }

      final friendsResponse = await supabaseClient
          .rpc('get_friend_count', params: {'p_user_id': userId});

      final count = friendsResponse as int? ?? 0;

      return MResult.success(count);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<List<Friend>>> getFriends(String userId) async {
    try {
      final response = await supabaseClient
          .from('friends')
          .select()
          .or('userId.eq.$userId,friendId.eq.$userId')
          .eq('status', 'accepted')
          .order('createdAt', ascending: false);

      final friends =
          (response as List).map((json) => Friend.fromJson(json)).toList();

      return MResult.success(friends);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<void>> shareToFriend(MUser user) async {
    try {
      final email = user.email ?? '';
      final subject = Uri.encodeComponent(S.text.common_text_share);
      final mailtoLink = 'mailto:$email?subject=$subject';
      if (await canLaunchUrl(Uri.parse(mailtoLink))) {
        await launchUrl(Uri.parse(mailtoLink));
      } else {
        await Share.share(S.text.common_text_share);
      }
      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
