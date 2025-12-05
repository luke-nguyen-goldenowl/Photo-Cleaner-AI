import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/authentication/model/email_fromz.dart';
import 'package:myapp/src/features/authentication/model/model_input.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/generated/i18n/app_localizations.dart';

part 'forgot_state.dart';

class ForgotBloc extends Cubit<ForgotState> {
  ForgotBloc() : super(const ForgotState());
  DomainManager get domain => DomainManager();

  Future sendOtpToEmail(BuildContext context) async {
    if (state.email.isValid == false || state.status.isInProgress) {
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    XToast.showLoading();

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: state.email.value,
      );

      XToast.hideLoading();
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        currentStep: ForgotPasswordStep.enterOtp,
      ));
      XToast.success(
          '${AppLocalizations.of(context)!.success_sendOTP} ${state.email.value}');
    } catch (e) {
      XToast.hideLoading();
      emit(state.copyWith(status: FormzSubmissionStatus.failure));

      final errorResult = MResult<void>.exception(e);
      XAlert.show(
        title: AppLocalizations.of(context)!.error_sendOTP,
        body: errorResult.error ??
            AppLocalizations.of(context)!.error_somethingWrongTryAgain,
        actions: [XAlertButton(title: S.text.common_close)],
      );
    }
  }

  Future verifyOtp(BuildContext context) async {
    if (state.otp.length != 6 || state.status.isInProgress) {
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    XToast.showLoading();

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: state.email.value,
        token: state.otp,
        type: OtpType.email,
      );

      XToast.hideLoading();

      if (response.user != null) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          currentStep: ForgotPasswordStep.resetPassword,
        ));
        XToast.success(AppLocalizations.of(context)!.success_verifyOTP);
      } else {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
        XAlert.show(
          title: AppLocalizations.of(context)!.error_verifyOTP,
          body: AppLocalizations.of(context)!.error_OTP_invalid,
          actions: [XAlertButton(title: S.text.common_close)],
        );
      }
    } catch (e) {
      XToast.hideLoading();
      emit(state.copyWith(status: FormzSubmissionStatus.failure));

      final errorResult = MResult<void>.exception(e);
      XAlert.show(
        title: AppLocalizations.of(context)!.error_verifyOTP,
        body: errorResult.error ??
            AppLocalizations.of(context)!.error_OTP_invalid,
        actions: [XAlertButton(title: S.text.common_close)],
      );
    }
  }

  Future resetPassword(BuildContext context) async {
    if (!state.isPasswordValid || state.status.isInProgress) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    XToast.showLoading();

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: state.password.value),
      );

      XToast.hideLoading();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      await XAlert.show(
        title: AppLocalizations.of(context)!.success_resetPass_noti_Title,
        body: AppLocalizations.of(context)!.success_resetPass_noti_subTitle,
        actions: [XAlertButton(title: S.text.common_close)],
      );
      AppCoordinator.showSignInScreen();
    } catch (e) {
      XToast.hideLoading();
      emit(state.copyWith(status: FormzSubmissionStatus.failure));

      final errorResult = MResult<void>.exception(e);
      XAlert.show(
        title: AppLocalizations.of(context)!.error_resetPass,
        body: errorResult.error ??
            AppLocalizations.of(context)!.error_somethingWrongTryAgain,
        actions: [XAlertButton(title: S.text.common_close)],
      );
    }
  }

  Future resendOtp(BuildContext context) async {
    await sendOtpToEmail(context);
  }

  void goBack() {
    if (state.currentStep == ForgotPasswordStep.enterOtp) {
      emit(state.copyWith(
        currentStep: ForgotPasswordStep.enterEmail,
        otp: '',
      ));
    } else if (state.currentStep == ForgotPasswordStep.resetPassword) {
      emit(state.copyWith(
        currentStep: ForgotPasswordStep.enterOtp,
        password: const PasswordFormzInput.pure(''),
        confirmPassword: '',
      ));
    }
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

  void onOtpChanged(String value) {
    emit(state.copyWith(otp: value, isDirty: true));
  }

  void onPasswordChanged(String value) {
    final formz = PasswordFormzInput.dirty(value);
    emit(state.copyWith(password: formz, isDirty: true));
  }

  void onConfirmPasswordChanged(String value) {
    emit(state.copyWith(confirmPassword: value, isDirty: true));
  }
}
