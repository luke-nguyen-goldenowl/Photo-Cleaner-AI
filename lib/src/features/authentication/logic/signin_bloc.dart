import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/src/features/authentication/model/email_fromz.dart';
import 'package:myapp/src/features/authentication/model/model_input.dart';
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

  Future loginWithEmail() async {
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
        XAlert.show(title: 'Đăng nhập thất bại', body: 'Lỗi không xác định');
        return;
      }
      if (user.emailConfirmedAt == null) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
        XToast.hideLoading();
        XAlert.show(
          title: 'Chưa xác thực email',
          body: 'Vui lòng xác thực email trước khi đăng nhập.',
        );
        return;
      }
      XToast.hideLoading();
      final mUser = MUser.fromSupabaseUser(user);
      UserPrefs.I.setLoginProvider('supabase');
      UserPrefs.I.setIsLoggedIn(true);
      await loginDecision(MResult.success(mUser));
      XToast.success('Đăng nhập thành công');
    } catch (e) {
      XToast.hideLoading();
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      final errorResult = MResult<void>.exception(e);
      XAlert.show(
        title: 'Đăng nhập thất bại',
        body: errorResult.error ?? 'Đã xảy ra lỗi không xác định',
      );
    }
  }

  Future loginWithGoogle() async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      loginType: MSocialType.google,
    ));
    final result = await domain.sign.loginWithGoogle();
    return loginSocialDecision(result, MSocialType.google);
  }

  Future loginWithApple() async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      loginType: MSocialType.apple,
    ));
    final result = await domain.sign.loginWithApple();
    return loginSocialDecision(result, MSocialType.apple);
  }

  Future loginWithFacebook() async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      loginType: MSocialType.facebook,
    ));
    final result = await domain.sign.loginWithFacebook();
    return loginSocialDecision(result, MSocialType.facebook);
  }

  Future loginSocialDecision(
      MResult<MSocialUser> result, MSocialType socialType) async {
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
      XAlert.show(title: "Error", body: result.error);
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

  Future loginDecision(MResult<MUser> result, {MSocialType? socialType}) async {
    if (result.isSuccess) {
      emit(state.copyWith(status: FormzSubmissionStatus.success));

      if (socialType != null) {
        UserPrefs.I.setLoginProvider(socialType.name);
      }
      UserPrefs.I.setIsLoggedIn(true);
      GetIt.I<AccountBloc>().onLoginSuccess(result.data!);

      AppCoordinator.showHomeScreen();
      XToast.success('Đăng nhập thành công');
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(title: 'Login Error', body: result.error);
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
