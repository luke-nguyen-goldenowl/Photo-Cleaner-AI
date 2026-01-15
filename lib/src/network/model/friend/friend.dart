import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend.freezed.dart';
part 'friend.g.dart';

enum FriendStatus {
  pending,
  accepted;

  String toJson() => name;

  static FriendStatus fromJson(String json) {
    return FriendStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => FriendStatus.pending,
    );
  }
}

@freezed
abstract class Friend with _$Friend {
  const factory Friend({
    required int id,
    @JsonKey(name: 'userId') required String userId,
    @JsonKey(name: 'friendId') required String friendId,
    required FriendStatus status,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  }) = _Friend;

  const Friend._();

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
}
