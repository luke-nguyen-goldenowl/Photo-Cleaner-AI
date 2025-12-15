part of 'forgot_bloc.dart';

enum ForgotPasswordStep {
  enterEmail,
  enterOtp,
  resetPassword,
}

class ForgotState extends Equatable {
  const ForgotState({
    this.email = const EmailFormzInput.pure(''),
    this.otp = '',
    this.password = const PasswordFormzInput.pure(''),
    this.confirmPassword = const ConfirmPasswordFormzInput.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.currentStep = ForgotPasswordStep.enterEmail,
    this.resendCountdown = 0,
  });

  final EmailFormzInput email;
  final String otp;
  final PasswordFormzInput password;
  final ConfirmPasswordFormzInput confirmPassword;
  final FormzSubmissionStatus status;
  final ForgotPasswordStep currentStep;
  final int resendCountdown;

  bool get isValidated {
    return Formz.validate([email]);
  }

  bool get isOtpValid {
    return otp.length == 6;
  }

  bool get isPasswordValid {
    return password.isValid &&
        confirmPassword.isValid &&
        confirmPassword.value == password.value;
  }

  bool get canResendOtp {
    return resendCountdown == 0;
  }

  @override
  List<Object> get props => [
        email,
        otp,
        password,
        confirmPassword,
        status,
        currentStep,
        resendCountdown
      ];

  ForgotState copyWith({
    EmailFormzInput? email,
    String? otp,
    PasswordFormzInput? password,
    ConfirmPasswordFormzInput? confirmPassword,
    FormzSubmissionStatus? status,
    String? error,
    bool? isDirty,
    ForgotPasswordStep? currentStep,
    int? resendCountdown,
  }) {
    return ForgotState(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      resendCountdown: resendCountdown ?? this.resendCountdown,
    );
  }
}
