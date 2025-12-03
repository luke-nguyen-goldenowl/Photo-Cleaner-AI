part of 'signup_bloc.dart';

class SignupState extends Equatable {
  const SignupState({
    this.email = const EmailFormzInput.pure(),
    this.password = const PasswordFormzInput.pure(''),
    this.name = const NameFormzInput.pure(''),
    this.status = FormzSubmissionStatus.initial,
    this.message = '',
    this.isDirty = false,
    this.confirmPassword = '',
  });

  final EmailFormzInput email;
  final PasswordFormzInput password;
  final NameFormzInput name;
  final FormzSubmissionStatus status;
  final String message;
  final bool isDirty;
  final String confirmPassword;
  bool get isValidated {
    return Formz.validate([email, password, name]) && isConfirmPasswordValid;
  }

  bool get isConfirmPasswordValid =>
      confirmPassword == password.value && confirmPassword.isNotEmpty;

  @override
  List<Object> get props => [
        email,
        password,
        status,
        name,
        confirmPassword,
      ];

  SignupState copyWith({
    EmailFormzInput? email,
    PasswordFormzInput? password,
    FormzSubmissionStatus? status,
    NameFormzInput? name,
    String? message,
    bool? isDirty,
    String? confirmPassword,
  }) {
    return SignupState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      name: name ?? this.name,
      message: message ?? this.message,
      isDirty: isDirty ?? this.isDirty,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}
