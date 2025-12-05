import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:myapp/generated/i18n/app_localizations.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/src/features/authentication/model/email_fromz.dart';
import 'package:myapp/src/features/authentication/model/password_formz.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/network/model/social_type.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/network/model/social_user/social_user.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'signin_state.dart';

class SigninBloc extends Cubit<SigninState> {
  SigninBloc() : super(const SigninState());

  DomainManager get domain => DomainManager();

  Future loginWithEmail(BuildContext context) async {
    if (state.status.isInProgress) return;
    if (state.isValidated == false) return;
    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      loginType: MSocialType.email,
    ));
    XToast.showLoading();
    final email = state.email.value;
    final password = state.password.value;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
        XToast.hideLoading();
        XAlert.show(title: AppLocalizations.of(context)!.error_login);
        return;
      }
      if (user.emailConfirmedAt == null) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
        XToast.hideLoading();
        XAlert.show(title: AppLocalizations.of(context)!.error_login);
        return;
      }
      XToast.hideLoading();
      final mUser = MUser.fromSupabaseUser(user);
      UserPrefs.I.setLoginProvider('supabase');
      UserPrefs.I.setIsLoggedIn(true);
      await loginDecision(MResult.success(mUser));
      XToast.success(AppLocalizations.of(context)!.success_login);
    } catch (e) {
      XToast.hideLoading();
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      final errorResult = MResult<void>.exception(e);
      XAlert.show(
        title: AppLocalizations.of(context)!.error_login,
        body: errorResult.error ?? 'Đã xảy ra lỗi không xác định',
        actions: [
          XAlertButton(title: AppLocalizations.of(context)!.common_close),
        ],
      );
    }
  }

  Future loginWithGoogle(BuildContext context) async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      loginType: MSocialType.google,
    ));
    final result = await domain.sign.loginWithGoogle();
    return loginSocialDecision(result, MSocialType.google, context);
  }

  Future loginWithApple(BuildContext context) async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      loginType: MSocialType.apple,
    ));
    final result = await domain.sign.loginWithApple();
    return loginSocialDecision(result, MSocialType.apple, context);
  }

  Future loginWithFacebook(BuildContext context) async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      loginType: MSocialType.facebook,
    ));
    final result = await domain.sign.loginWithFacebook();
    return loginSocialDecision(result, MSocialType.facebook, context);
  }

  Future loginSocialDecision(MResult<MSocialUser> result,
      MSocialType socialType, BuildContext? context) async {
    if (result.isSuccess) {
      final data = result.data!;
      if (socialType == MSocialType.google) {
        connectBEWithGoogle(data);
      } else if (socialType == MSocialType.facebook) {
        connectBEWithFacebook(data);
      } else if (socialType == MSocialType.apple) {
        connectBEWithApple(data);
      }
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(
          title: AppLocalizations.of(context!)!.error_login,
          body: result.error);
    }
  }

  Future connectBEWithGoogle(MSocialUser user) async {
    final result = await domain.sign.connectBEWithGoogle(user);
    return loginDecision(result, socialType: user.type);
  }

  Future connectBEWithFacebook(MSocialUser user) async {
    final result = await domain.sign.connectBEWithFacebook(user);
    return loginDecision(result, socialType: user.type);
  }

  Future connectBEWithApple(MSocialUser user) async {
    final result = await domain.sign.connectBEWithApple(user);
    return loginDecision(result, socialType: user.type);
  }

  Future loginDecision(MResult<MUser> result,
      {MSocialType? socialType, BuildContext? context}) async {
    if (result.isSuccess) {
      emit(state.copyWith(status: FormzSubmissionStatus.success));

      if (socialType != null) {
        UserPrefs.I.setLoginProvider(socialType.name);
      }
      UserPrefs.I.setIsLoggedIn(true);
      GetIt.I<AccountBloc>().onLoginSuccess(result.data!);

      AppCoordinator.showHomeScreen();
      if (context != null) {
        XToast.success(AppLocalizations.of(context)!.success_login);
      }
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(
          title: AppLocalizations.of(context!)!.error_login,
          body: result.error);
    }
  }

  void onEmailChanged(String value) {
    final formz = state.email.isPure
        ? EmailFormzInput.pure(value)
        : EmailFormzInput.dirty(value);
    emit(state.copyWith(email: formz));
  }

  void onPasswordChanged(String value) {
    final formz = PasswordFormzInput.dirty(value);
    emit(state.copyWith(password: formz));
  }
}
