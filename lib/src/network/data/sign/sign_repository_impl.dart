import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/sign/sign_repository.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/network/model/social_user/social_user.dart';
import 'package:myapp/src/services/supabase/init_supabase.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignRepositoryImpl extends SignRepository {
  // https://isaacadariku.medium.com/google-sign-in-flutter-migration-guide-pre-7-0-versions-to-v7-version-cdc9efd7f182
  // https://pub.dev/packages/google_sign_in/changelog#700
  final _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;
  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
          serverClientId:
              '1000132971352-hj0bh3e8cbca8agm53tfacttc73eld7c.apps.googleusercontent.com');
      _isGoogleSignInInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Google Sign-In: $e');
    }
  }

  /// Always check Google sign in initialization before use
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<String?> getAccessTokenForScopes(List<String> scopes) async {
    await _ensureGoogleSignInInitialized();

    try {
      final authClient = _googleSignIn.authorizationClient;
      // Try to get existing authorization
      var authorization = await authClient.authorizationForScopes(scopes);
      authorization ??= await authClient.authorizeScopes(scopes);
      return authorization.accessToken;
    } catch (error) {
      debugPrint('Failed to get access token for scopes: $error');
      return null;
    }
  }

  @override
  Future<MResult<MUser>> connectBEWithApple(MSocialUser user) {
    // TODO: implement connectBEWithApple
    throw UnimplementedError();
  }

  @override
  Future<MResult<MUser>> connectBEWithFacebook(MSocialUser user) {
    // TODO: implement connectBEWithFacebook
    throw UnimplementedError();
  }

  @override
  Future<MResult<MUser>> connectBEWithGoogle(MSocialUser user) async {
    try {
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
          accessToken: user.accessToken, idToken: user.idToken);
      // Once signed in, return the UserCredential
      final UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = result.user;

      final existingUserResponse = await supabaseClient
          .from('users')
          .select()
          .eq('email', user.email ?? '')
          .maybeSingle();

      MUser finalUser;

      if (existingUserResponse == null) {
        final insertResponse = await supabaseClient
            .from('users')
            .insert({
              'email': user.email,
              'name': user.fullName,
              'avatarUrl': user.avatar,
              'createdAt': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        finalUser = MUser(
          id: insertResponse['id'] as String,
          email: user.email,
          name: user.fullName,
          avatarUrl: user.avatar,
          createdAt: DateTime.now(),
        );
      } else {
        finalUser = MUser(
          id: existingUserResponse['id'] as String,
          name: existingUserResponse['name'] as String?,
          email: existingUserResponse['email'] as String?,
          bio: existingUserResponse['bio'] as String?,
          avatarUrl: existingUserResponse['avatarUrl'] as String?,
          createdAt: existingUserResponse['createdAt'] != null
              ? DateTime.parse(existingUserResponse['createdAt'] as String)
              : null,
        );
      }

      final firebaseUser2 = MUser(
        id: firebaseUser?.uid ?? '',
        email: user.email,
        name: user.fullName,
        avatarUrl: user.avatar,
        createdAt: DateTime.now(),
      );
      await DomainManager().user.getOrAddUser(firebaseUser2);

      return MResult.success(finalUser);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<String>> forgotPassword(String email) {
    // TODO: implement forgotPassword
    throw UnimplementedError();
  }

  @override
  Future<MResult> logOut(MUser user) async {
    try {
      final loginProvider = UserPrefs.I.getLoginProvider();
      if (loginProvider == 'google') {
        await FirebaseAuth.instance.signOut();
        await _googleSignIn.signOut();
      } else {
        await supabaseClient.auth.signOut();
      }

      UserPrefs.I.clearLoginProvider();
      return MResult.success(user);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MSocialUser>> loginWithApple() {
    // TODO: implement loginWithApple
    throw UnimplementedError();
  }

  @override
  Future<MResult<MUser>> loginWithEmail(
      {required String email, required String password}) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final mUser = MUser.fromSupabaseUser(response.user!);
      return MResult.success(mUser);
    } on AuthApiException catch (e) {
      final code = e.code?.toLowerCase();

      if (code == 'email_not_confirmed') {
        return MResult.error(S.text.error_email_not_confirm);
      }
      if (code == 'invalid_credentials') {
        return MResult.error(S.text.error_email_or_password_invalid);
      }
      return MResult.exception(e);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MSocialUser>> loginWithFacebook() {
    // TODO: implement loginWithFacebook
    throw UnimplementedError();
  }

  @override
  Future<MResult<MSocialUser>> loginWithGoogle() async {
    try {
      const scopes = ['email'];
      await _ensureGoogleSignInInitialized();
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate(scopeHint: scopes);
      final accessToken = await getAccessTokenForScopes(scopes);
      if (accessToken == null) {
        return MResult.error('Failed to get access token');
      }
      // googleUser
      return MResult.success(
          MSocialUser.fromGoogleAccount(googleUser, accessToken));
    } catch (error) {
      return MResult.exception(error);
    }
  }

  @override
  Future<MResult> removeAccount(MUser user) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      user?.delete();
      return MResult.success(user);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<MUser>> signUpWithEmail(
      {required String email,
      required String password,
      required String name}) async {
    try {
      // Check if email exists
      final rows = await supabaseClient
          .rpc('email_exists', params: {'email_input': email}).select();

      final existing = rows.isEmpty ? null : rows.first;

      if (existing != null && existing['email_confirmed_at'] != null) {
        return MResult.error(S.text.error_email_have_been_used);
      } else if (existing != null && existing['email_confirmed_at'] == null) {
        return MResult.success(MUser(
          id: existing['id'],
          email: email,
          name: name,
          createdAt: DateTime.now(),
        ));
      }

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final user = response.user;
      if (user == null) {
        return MResult.error(S.text.error_signUp);
      }

      final mUser = MUser(
        id: user.id,
        name: name,
        email: email,
        bio: null,
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      await supabaseClient.from('users').insert(mUser.toSupabaseTable());
      return MResult.success(mUser);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  Future<MResult<void>> resetPassword(String newPassword) async {
    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return MResult.success(null);
    } on AuthApiException catch (e) {
      final code = e.code?.toLowerCase();

      if (code == 'same_password') {
        return MResult.error(S.text.error_same_password);
      }
      return MResult.exception(S.text.error_somethingWrongTryAgain);
    } catch (e) {
      return MResult.exception(S.text.error_somethingWrongTryAgain);
    }
  }

  @override
  Future<MResult<String>> sendOtpToEmail(String email) async {
    try {
      await supabaseClient.auth.signInWithOtp(email: email);
      return MResult.success('${S.text.success_sendOTP} $email');
    } catch (e) {
      return MResult.exception(S.text.error_somethingWrongTryAgain);
    }
  }

  @override
  Future<MResult<void>> verifyOtp(
      {required String email, required String otp}) async {
    try {
      final response = await supabaseClient.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (response.user != null) {
        return MResult.success(null);
      } else {
        return MResult.error(S.text.error_verifyOTP);
      }
    } on AuthApiException catch (e) {
      final code = e.code?.toLowerCase();

      if (code == 'otp_expired') {
        return MResult.error(S.text.error_otp_expired);
      }
      return MResult.error(S.text.error_somethingWrongTryAgain);
    } catch (e) {
      return MResult.exception(S.text.error_somethingWrongTryAgain);
    }
  }
}
