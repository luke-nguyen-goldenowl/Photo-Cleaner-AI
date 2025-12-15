import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/src/features/authentication/model/email_fromz.dart';
import 'package:myapp/src/features/authentication/model/password_formz.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/network/model/social_type.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/network/model/social_user/social_user.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/services/user_prefs.dart';

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

    final result = await domain.sign.loginWithEmail(
      email: email,
      password: password,
      context: context,
    );
    XToast.hideLoading();

    if (result.isSuccess) {
      await loginDecision(
        result,
        socialType: MSocialType.email,
        context: context,
      );
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(
        title: S.of(context).error_login,
        body: result.error ?? S.of(context).error_somethingWrongTryAgain,
        actions: [
          XAlertButton(title: S.of(context).common_close),
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
      MSocialType socialType, BuildContext context) async {
    if (result.isSuccess) {
      final data = result.data!;
      if (socialType == MSocialType.google) {
        connectBEWithGoogle(data, context);
      } else if (socialType == MSocialType.facebook) {
        connectBEWithFacebook(data, context);
      } else if (socialType == MSocialType.apple) {
        connectBEWithApple(data, context);
      }
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(title: S.of(context).error_login, body: result.error);
    }
  }

  Future connectBEWithGoogle(MSocialUser user, BuildContext context) async {
    final result = await domain.sign.connectBEWithGoogle(user);
    return loginDecision(result, socialType: user.type, context: context);
  }

  Future connectBEWithFacebook(MSocialUser user, BuildContext context) async {
    final result = await domain.sign.connectBEWithFacebook(user);
    return loginDecision(result, socialType: user.type, context: context);
  }

  Future connectBEWithApple(MSocialUser user, BuildContext context) async {
    final result = await domain.sign.connectBEWithApple(user);
    return loginDecision(result, socialType: user.type, context: context);
  }

  Future loginDecision(MResult<MUser> result,
      {MSocialType? socialType, required BuildContext context}) async {
    if (result.isSuccess) {
      final provider = _providerNameFor(socialType);
      await UserPrefs.I.setLoginProvider(provider);
      await UserPrefs.I.setIsLoggedIn(true);
      await UserPrefs.I.setUser(result.data);

      emit(state.copyWith(status: FormzSubmissionStatus.success));
      GetIt.I<AccountBloc>().onLoginSuccess(result.data!);
      AppCoordinator.showHomeScreen();
      XToast.success(S.of(context).success_login);
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(title: S.of(context).error_login, body: result.error);
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

  String _providerNameFor(MSocialType? type) {
    switch (type) {
      case MSocialType.google:
        return 'google';
      case MSocialType.facebook:
        return 'facebook';
      case MSocialType.apple:
        return 'apple';
      case MSocialType.email:
      default:
        return 'supabase';
    }
  }
}
