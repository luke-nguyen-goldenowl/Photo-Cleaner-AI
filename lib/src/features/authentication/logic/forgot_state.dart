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
    this.confirmPassword = '',
    this.status = FormzSubmissionStatus.initial,
    this.error = '',
    this.isDirty = false,
    this.currentStep = ForgotPasswordStep.enterEmail,
  });

  final EmailFormzInput email;
  final String otp;
  final PasswordFormzInput password;
  final String confirmPassword;
  final FormzSubmissionStatus status;
  final String error;
  final bool isDirty;
  final ForgotPasswordStep currentStep;

  bool get isValidated {
    return Formz.validate([email]);
  }

  bool get isOtpValid {
    return otp.length == 6;
  }

  bool get isPasswordValid {
    return password.isValid &&
        confirmPassword.isNotEmpty &&
        confirmPassword == password.value;
  }

  @override
  List<Object> get props => [
        email,
        otp,
        password,
        confirmPassword,
        status,
        error,
        isDirty,
        currentStep
      ];

  ForgotState copyWith({
    EmailFormzInput? email,
    String? otp,
    PasswordFormzInput? password,
    String? confirmPassword,
    FormzSubmissionStatus? status,
    String? error,
    bool? isDirty,
    ForgotPasswordStep? currentStep,
  }) {
    return ForgotState(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      error: error ?? this.error,
      isDirty: isDirty ?? this.isDirty,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
