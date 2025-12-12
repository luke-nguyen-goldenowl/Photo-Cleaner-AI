// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MUser _$MUserFromJson(Map<String, dynamic> json) => _MUser(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MUserToJson(_MUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'bio': instance.bio,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt?.toIso8601String(),
    };
