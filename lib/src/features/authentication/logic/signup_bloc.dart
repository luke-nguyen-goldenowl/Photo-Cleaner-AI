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
import 'package:myapp/src/features/authentication/model/model_input.dart';
import 'package:myapp/src/features/authentication/model/name_formz.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    try {
      final rows = await Supabase.instance.client
          .rpc('email_exists', params: {'email_input': email}).select();

      final existing = rows.isEmpty ? null : rows.first;

      if (existing != null && existing['email_confirmed_at'] != null) {
        XToast.hideLoading();
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
        final errorResult = MResult<void>.error('Email đã được sử dụng');
        XAlert.show(
          title: AppLocalizations.of(context)!.error_signUp,
          body: errorResult.error!,
          actions: [
            XAlertButton(title: AppLocalizations.of(context)!.common_close)
          ],
        );
        return;
      } else if (existing != null && existing['email_confirmed_at'] == null) {
        XToast.hideLoading();
        emit(state.copyWith(status: FormzSubmissionStatus.success));
        XToast.success(AppLocalizations.of(context)!.success_signUp);
      }
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final user = response.user;
      if (user == null) {
        XToast.hideLoading();
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
        XAlert.show(
          title: AppLocalizations.of(context)!.error_signUp,
          body: AppLocalizations.of(context)!.error_somethingWrongTryAgain,
          actions: [
            XAlertButton(title: AppLocalizations.of(context)!.common_close)
          ],
        );
        return;
      }

      final mUser = MUser(
        id: user.id,
        name: name,
        email: email,
        bio: null,
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      try {
        await Supabase.instance.client
            .from('users')
            .insert(mUser.toSupabaseTable());
      } catch (insertError) {
        return MResult<void>.exception(insertError);
      }
      XToast.hideLoading();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      signupDecision(context, mUser);
    } catch (e) {
      XToast.hideLoading();
      emit(state.copyWith(status: FormzSubmissionStatus.failure));

      final errorResult = MResult<void>.exception(e);
      XAlert.show(
        title: AppLocalizations.of(context)!.error_signUp,
        body: errorResult.error ??
            AppLocalizations.of(context)!.error_somethingWrongTryAgain,
        actions: [
          XAlertButton(title: AppLocalizations.of(context)!.common_close)
        ],
      );
    }
  }

  Future signupDecision(BuildContext context, MUser incomingUser) async {
    UserPrefs.I.setLoginProvider('supabase');
    UserPrefs.I.setIsLoggedIn(true);
    GetIt.I<AccountBloc>().onLoginSuccess(incomingUser);
    AppCoordinator.pop();
    XToast.success(AppLocalizations.of(context)!.success_signUp);
  }

  void onEmailChanged(String value) {
    final formz = state.email.isPure
        ? EmailFormzInput.pure(value)
        : EmailFormzInput.dirty(value);
    emit(state.copyWith(
      email: formz,
      isDirty: true,
    ));
  }

  void onNameChanged(String value) {
    final formz = NameFormzInput.dirty(value);
    emit(state.copyWith(name: formz, isDirty: true));
  }

  void onPasswordChanged(String value) {
    final formz = PasswordFormzInput.dirty(value);
    emit(state.copyWith(password: formz, isDirty: true));
  }

  void onConfirmPasswordChanged(String value) {
    emit(state.copyWith(confirmPassword: value, isDirty: true));
  }
}
