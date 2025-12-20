import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/dialogs/alert_wrapper.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/dialogs/widget/alert_dialog.dart';
import 'package:myapp/src/features/authentication/model/confirm_password_formz.dart';
import 'package:myapp/src/features/authentication/model/email_fromz.dart';
import 'package:myapp/src/features/authentication/model/password_formz.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/router/coordinator.dart';

part 'forgot_state.dart';

class ForgotBloc extends Cubit<ForgotState> {
  ForgotBloc() : super(const ForgotState());
  DomainManager get domain => DomainManager();
  Timer? _resendTimer;

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    emit(state.copyWith(resendCountdown: 60));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentCountdown = state.resendCountdown;
      if (currentCountdown > 0) {
        emit(state.copyWith(resendCountdown: currentCountdown - 1));
      } else {
        timer.cancel();
      }
    });
  }

  void _stopResendTimer() {
    _resendTimer?.cancel();
    emit(state.copyWith(resendCountdown: 0));
  }

  Future sendOtpToEmail() async {
    if (state.email.isValid == false || state.status.isInProgress) {
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    XToast.showLoading();

    final result = await domain.sign.sendOtpToEmail(state.email.value);
    XToast.hideLoading();

    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        currentStep: ForgotPasswordStep.enterOtp,
      ));
      _startResendTimer();
      XToast.success('${S.text.success_sendOTP} ${state.email.value}');
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(
        title: S.text.error_sendOTP,
        body: result.error ?? S.text.error_somethingWrongTryAgain,
        actions: [XAlertButton(title: S.text.common_close)],
      );
    }
  }

  Future verifyOtp() async {
    if (state.otp.length != 6 || state.status.isInProgress) {
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    XToast.showLoading();

    final result =
        await domain.sign.verifyOtp(email: state.email.value, otp: state.otp);

    XToast.hideLoading();

    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        currentStep: ForgotPasswordStep.resetPassword,
      ));
      XToast.success(S.text.success_verifyOTP);
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(
        title: S.text.error_verifyOTP,
        body: result.error ?? S.text.error_OTP_invalid,
        actions: [XAlertButton(title: S.text.common_close)],
      );
    }
  }

  Future resetPassword() async {
    if (!state.isPasswordValid || state.status.isInProgress) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    XToast.showLoading();

    final result = await domain.sign.resetPassword(state.password.value);

    XToast.hideLoading();

    if (result.isSuccess) {
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      await XAlert.show(
        title: S.text.success_resetPass_noti_Title,
        body: S.text.success_resetPass_noti_subTitle,
        actions: [XAlertButton(title: S.text.common_close)],
      );
      AppCoordinator.showSignInScreen();
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      XAlert.show(
        title: S.text.error_resetPass,
        body: result.error ?? S.text.error_somethingWrongTryAgain,
        actions: [XAlertButton(title: S.text.common_close)],
      );
    }
  }

  Future resendOtp() async {
    if (!state.canResendOtp) return;
    await sendOtpToEmail();
  }

  void goBack() {
    if (state.currentStep == ForgotPasswordStep.enterOtp) {
      _stopResendTimer();
      emit(state.copyWith(
        currentStep: ForgotPasswordStep.enterEmail,
        otp: '',
      ));
    } else if (state.currentStep == ForgotPasswordStep.resetPassword) {
      emit(state.copyWith(
        currentStep: ForgotPasswordStep.enterOtp,
        password: const PasswordFormzInput.pure(''),
        confirmPassword: const ConfirmPasswordFormzInput.pure(),
      ));
    }
  }

  void onEmailChanged(String value) {
    final formz = EmailFormzInput.dirty(value);
    emit(state.copyWith(
      email: formz,
    ));
  }

  void onOtpChanged(String value) {
    emit(state.copyWith(otp: value, isDirty: true));
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
