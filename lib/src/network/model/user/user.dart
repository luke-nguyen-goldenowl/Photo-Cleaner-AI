import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class MUser with _$MUser {
  const factory MUser({
    required String id,
    String? name,
    String? email,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
  }) = _MUser;

  const MUser._();

  factory MUser.empty() {
    return const MUser(id: '');
  }

  factory MUser.fromJson(Map<String, Object?> json) => _$MUserFromJson(json);
  factory MUser.fromSupabaseUser(User user) {
    return MUser(
      id: user.id,
      email: user.email,
      name: user.userMetadata?['name'] as String?,
      avatarUrl: user.userMetadata?['avatarUrl'] as String?,
      bio: user.userMetadata?['bio'] as String?,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  Map<String, dynamic> toSupabaseTable() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl ?? '',
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }
}
