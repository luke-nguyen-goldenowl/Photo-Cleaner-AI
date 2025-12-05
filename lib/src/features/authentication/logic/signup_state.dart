part of 'signup_bloc.dart';

class SignupState extends Equatable {
  const SignupState({
    this.email = const EmailFormzInput.pure(),
    this.password = const PasswordFormzInput.pure(''),
    this.name = const NameFormzInput.pure(''),
    this.status = FormzSubmissionStatus.initial,
    this.confirmPassword = const ConfirmPasswordFormzInput.pure(),
  });

  final EmailFormzInput email;
  final PasswordFormzInput password;
  final NameFormzInput name;
  final FormzSubmissionStatus status;
  final ConfirmPasswordFormzInput confirmPassword;
  bool get isValidated {
    return Formz.validate([email, password, name, confirmPassword]);
  }

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
    ConfirmPasswordFormzInput? confirmPassword,
  }) {
    return SignupState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      name: name ?? this.name,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}
