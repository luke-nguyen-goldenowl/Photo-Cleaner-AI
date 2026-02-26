// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Friend _$FriendFromJson(Map<String, dynamic> json) => _Friend(
      id: (json['id'] as num).toInt(),
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      status: $enumDecode(_$FriendStatusEnumMap, json['status']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FriendToJson(_Friend instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'friendId': instance.friendId,
      'status': instance.status.toJson(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$FriendStatusEnumMap = {
  FriendStatus.pending: 'pending',
  FriendStatus.accepted: 'accepted',
};
