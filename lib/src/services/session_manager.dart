import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';
import 'package:myapp/src/services/user_prefs.dart';

class SessionManager {
  static Future<MUser?> restoreSession() async {
    try {
      await UserPrefs.I.initialize();

      if (!UserPrefs.I.isLoggedIn()) {
        return null;
      }

      final provider = UserPrefs.I.getLoginProvider();

      if (provider == 'google') {
        return await _restoreGoogleSession();
      } else if (provider == 'supabase') {
        return await _restoreSupabaseSession();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<MUser?> _restoreGoogleSession() async {
    try {
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser == null) {
        return null;
      }

      final email = fbUser.email;
      if (email != null && email.isNotEmpty) {
        final response = await supabaseClient
            .from('users')
            .select()
            .eq('email', email)
            .maybeSingle();

        if (response != null) {
          final mUser = MUser(
            id: response['id'] as String,
            name: response['name'] as String?,
            email: response['email'] as String?,
            bio: response['bio'] as String?,
            avatarUrl: response['avatarUrl'] as String?,
            createdAt: response['createdAt'] != null
                ? DateTime.parse(response['createdAt'] as String)
                : null,
          );

          UserPrefs.I.setUser(mUser);
          return mUser;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<MUser?> _restoreSupabaseSession() async {
    try {
      final supabaseUser = supabaseClient.auth.currentUser;
      if (supabaseUser == null) {
        return null;
      }

      final response = await supabaseClient
          .from('users')
          .select()
          .eq('id', supabaseUser.id)
          .maybeSingle();

      if (response != null) {
        final mUser = MUser(
          id: response['id'] as String,
          name: response['name'] as String?,
          email: response['email'] as String?,
          bio: response['bio'] as String?,
          avatarUrl: response['avatarUrl'] as String?,
          createdAt: response['createdAt'] != null
              ? DateTime.parse(response['createdAt'] as String)
              : null,
        );

        UserPrefs.I.setUser(mUser);
        return mUser;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
