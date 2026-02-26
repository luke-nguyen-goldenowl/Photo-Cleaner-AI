import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/user/user_reference.dart';
import 'package:myapp/src/network/data/user/user_repository.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositoryImpl extends UserRepository {
  final usersRef = UserReference();
  @override
  Future<MResult<MUser>> getUser(String id) async {
    try {
      final result = FirebaseAuth.instance.currentUser;
      if (result != null) {
        final user = MUser(
            id: result.uid, email: result.email, name: result.displayName);
        return MResult.success(user);
      }
      return MResult.error('Error');
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MUser>> getOrAddUser(MUser user) {
    return usersRef.getOrAddUser(user);
  }

  @override
  Future<MResult<List<MUser>>> getUsers() {
    return usersRef.getUsers();
  }

  @override
  Future<MResult<MUser>> getUserFromSupabase(String email) async {
    try {
      final response = await supabaseClient
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response != null) {
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
      }
      return MResult.error(S.text.error_somethingWrongTryAgain);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MUser>> updateUser(MUser user) async {
    try {
      final updateData = {
        'name': user.name,
        'bio': user.bio,
        'avatarUrl': user.avatarUrl,
      };
      await supabaseClient.from('users').update(updateData).eq('id', user.id);

      return MResult.success(user);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<String>> uploadAvatar(File imageFile, String userId) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = '$userId/$fileName';

      await supabaseClient.storage.from('avatar').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      final publicUrl =
          supabaseClient.storage.from('avatar').getPublicUrl(filePath);
      return MResult.success(publicUrl);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MUser>> syncCurrentUser() async {
    try {
      final cachedUser = UserPrefs.I.getUser();
      if (cachedUser == null || cachedUser.email == null) {
        return MResult.error('No cached user or email');
      }

      final response = await supabaseClient
          .from('users')
          .select()
          .eq('email', cachedUser.email!)
          .maybeSingle();

      if (response != null) {
        final supabaseUser = MUser(
          id: response['id'] as String,
          name: response['name'] as String?,
          email: response['email'] as String?,
          bio: response['bio'] as String?,
          avatarUrl: response['avatarUrl'] as String?,
          createdAt: response['createdAt'] != null
              ? DateTime.parse(response['createdAt'] as String)
              : null,
        );
        UserPrefs.I.setUser(supabaseUser);
        return MResult.success(supabaseUser);
      }
      return MResult.error('User not found in Supabase');
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
