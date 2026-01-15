import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/network/model/friend/friend.dart';
import 'package:myapp/src/network/model/user/user.dart';

abstract class FriendRepository {
  /// Send friend request
  Future<MResult<Friend>> sendFriendRequest({
    required String userId,
    required String friendId,
  });

  /// Accept friend request
  Future<MResult<Friend>> acceptFriendRequest(int friendshipId);

  /// Reject friend request
  Future<MResult<void>> rejectFriendRequest(int friendshipId);

  /// Remove friend
  Future<MResult<void>> removeFriend({
    required String userId,
    required String friendId,
  });

  /// Get friendship status between two users
  Future<MResult<Friend?>> getFriendshipStatus({
    required String userId,
    required String friendId,
  });

  /// Get all accepted friendships for a user
  Future<MResult<List<Friend>>> getFriends(String userId);

  /// Get pending friend requests
  Future<MResult<List<Friend>>> getPendingRequests(String userId);

  /// Get friend count
  Future<MResult<int>> getFriendCount(String userId);

  /// Search users by name or email
  Future<MResult<List<MUser>>> searchUsers({
    required String query,
    int page = 0,
    int pageSize = 20,
  });

  /// Get user profile by ID
  Future<MResult<MUser>> getUserProfile(String userId);

  /// Get friend count for a specific user
  Future<MResult<int>> getUserCountFriend(String userId);

  /// Share to friend
  Future<MResult<void>> shareToFriend(MUser user);
}
