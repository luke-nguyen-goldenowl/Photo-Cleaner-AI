import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/src/features/authentication/model/confirm_password_formz.dart';
import 'package:myapp/src/features/authentication/model/email_fromz.dart';
import 'package:myapp/src/features/authentication/model/password_formz.dart';
import 'package:myapp/src/features/authentication/model/name_formz.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/services/user_prefs.dart';

part 'signup_state.dart';

class SignupBloc extends Cubit<SignupState> {
  SignupBloc() : super(const SignupState());

  DomainManager get domain => DomainManager();
  Future signupWithEmail(BuildContext context) async {
    if (state.status.isInProgress) return;
    if (!state.isValidated) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    XToast.showLoading();

    final email = state.email.value;
    final password = state.password.value;
    final name = state.name.value;

    final result = await domain.sign.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );

    XToast.hideLoading();

    if (result.isSuccess) {
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      signupDecision(context, result.data!);
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(
        title: S.of(context).error_signUp,
        body: result.error ?? S.of(context).error_somethingWrongTryAgain,
        actions: [XAlertButton(title: S.of(context).common_close)],
      );
    }
  }

  Future signupDecision(BuildContext context, MUser incomingUser) async {
    UserPrefs.I.setLoginProvider('supabase');
    UserPrefs.I.setIsLoggedIn(true);
    GetIt.I<AccountBloc>().onLoginSuccess(incomingUser);
    AppCoordinator.pop();
    XToast.success(S.of(context).success_signUp);
  }

  void onEmailChanged(String value) {
    final formz = EmailFormzInput.dirty(value);
    emit(state.copyWith(
      email: formz,
    ));
  }

  void onNameChanged(String value) {
    final formz = NameFormzInput.dirty(value);
    emit(state.copyWith(name: formz));
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(
      password: PasswordFormzInput.dirty(value),
    ));
  }

  void onConfirmPasswordChanged(String value) {
    emit(state.copyWith(
      confirmPassword: ConfirmPasswordFormzInput.dirty(
        password: state.password.value,
        value: value,
      ),
    ));
  }
}
