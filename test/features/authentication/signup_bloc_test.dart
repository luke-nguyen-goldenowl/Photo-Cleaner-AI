import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/features/authentication/logic/signup_bloc.dart';
import 'package:myapp/src/features/authentication/model/confirm_password_formz.dart';
import 'package:myapp/src/features/authentication/model/email_fromz.dart';
import 'package:myapp/src/features/authentication/model/form_error.dart';
import 'package:myapp/src/features/authentication/model/name_formz.dart';
import 'package:myapp/src/features/authentication/model/password_formz.dart';

void main() {
  group('SignupBloc', () {
    late SignupBloc signupBloc;

    setUp(() {
      signupBloc = SignupBloc();
    });

    tearDown(() {
      signupBloc.close();
    });

    test('initial state is correct', () {
      expect(signupBloc.state, const SignupState());
      expect(signupBloc.state.email, const EmailFormzInput.pure());
      expect(signupBloc.state.password, const PasswordFormzInput.pure(''));
      expect(signupBloc.state.name, const NameFormzInput.pure(''));
      expect(signupBloc.state.confirmPassword,
          const ConfirmPasswordFormzInput.pure());
      expect(signupBloc.state.status, FormzSubmissionStatus.initial);
      expect(signupBloc.state.isValidated, isFalse);
    });

    group('onEmailChanged', () {
      test('emits state with updated email when valid email is entered', () {
        signupBloc.onEmailChanged('test@example.com');

        expect(signupBloc.state.email.value, 'test@example.com');
        expect(signupBloc.state.email.isValid, isTrue);
      });

      test('emits state with invalid email when invalid email is entered', () {
        signupBloc.onEmailChanged('invalid-email');

        expect(signupBloc.state.email.value, 'invalid-email');
        expect(signupBloc.state.email.isValid, isFalse);
        expect(signupBloc.state.email.error, FormError.invalid);
      });

      test('emits state with empty error when empty email is entered', () {
        signupBloc.onEmailChanged('');

        expect(signupBloc.state.email.value, '');
        expect(signupBloc.state.email.error, FormError.empty);
      });
    });

    group('onPasswordChanged', () {
      test('emits state with valid password when password >= 6 characters', () {
        signupBloc.onPasswordChanged('password123');

        expect(signupBloc.state.password.value, 'password123');
        expect(signupBloc.state.password.isValid, isTrue);
      });

      test('emits state with invalid password when password < 6 characters',
          () {
        signupBloc.onPasswordChanged('12345');

        expect(signupBloc.state.password.value, '12345');
        expect(signupBloc.state.password.isValid, isFalse);
        expect(signupBloc.state.password.error, FormError.invalid);
      });

      test('emits state with empty error when empty password is entered', () {
        signupBloc.onPasswordChanged('');

        expect(signupBloc.state.password.error, FormError.empty);
      });
    });

    group('onNameChanged', () {
      test('emits state with valid name when name is not empty', () {
        signupBloc.onNameChanged('John Doe');

        expect(signupBloc.state.name.value, 'John Doe');
        expect(signupBloc.state.name.isValid, isTrue);
      });

      test('emits state with empty error when empty name is entered', () {
        signupBloc.onNameChanged('');

        expect(signupBloc.state.name.error, FormError.empty);
      });
    });

    group('onConfirmPasswordChanged', () {
      test('emits state with valid confirmPassword when passwords match', () {
        signupBloc.onPasswordChanged('password123');
        signupBloc.onConfirmPasswordChanged('password123');

        expect(signupBloc.state.confirmPassword.value, 'password123');
        expect(signupBloc.state.confirmPassword.isValid, isTrue);
      });

      test(
          'emits state with invalid confirmPassword when passwords do not match',
          () {
        signupBloc.onPasswordChanged('password123');
        signupBloc.onConfirmPasswordChanged('differentPassword');

        expect(signupBloc.state.confirmPassword.value, 'differentPassword');
        expect(signupBloc.state.confirmPassword.isValid, isFalse);
        expect(signupBloc.state.confirmPassword.error, FormError.invalid);
      });

      test('emits state with empty error when empty confirmPassword is entered',
          () {
        signupBloc.onPasswordChanged('password123');
        signupBloc.onConfirmPasswordChanged('');

        expect(signupBloc.state.confirmPassword.error, FormError.empty);
      });
    });

    group('Form Validation', () {
      test('isValidated returns false when all fields are pure (initial)', () {
        expect(signupBloc.state.isValidated, isFalse);
      });

      test('isValidated returns false when only email is valid', () {
        signupBloc.onEmailChanged('test@example.com');
        expect(signupBloc.state.isValidated, isFalse);
      });

      test('isValidated returns false when email and password are valid', () {
        signupBloc.onEmailChanged('test@example.com');
        signupBloc.onPasswordChanged('password123');
        expect(signupBloc.state.isValidated, isFalse);
      });

      test(
          'isValidated returns false when email, password and name are valid but confirmPassword is not',
          () {
        signupBloc.onEmailChanged('test@example.com');
        signupBloc.onPasswordChanged('password123');
        signupBloc.onNameChanged('John Doe');
        signupBloc.onConfirmPasswordChanged('different');
        expect(signupBloc.state.isValidated, isFalse);
      });

      test('isValidated returns true when all fields are valid', () {
        signupBloc.onEmailChanged('test@example.com');
        signupBloc.onPasswordChanged('password123');
        signupBloc.onNameChanged('John Doe');
        signupBloc.onConfirmPasswordChanged('password123');
        expect(signupBloc.state.isValidated, isTrue);
      });
    });

    group('SignupState copyWith', () {
      test('copyWith returns same object when no parameters are passed', () {
        const state = SignupState();
        final copied = state.copyWith();
        expect(copied.email, state.email);
        expect(copied.password, state.password);
        expect(copied.name, state.name);
        expect(copied.confirmPassword, state.confirmPassword);
        expect(copied.status, state.status);
      });

      test('copyWith updates only the specified fields', () {
        const state = SignupState();
        final copied = state.copyWith(
          email: const EmailFormzInput.dirty('test@example.com'),
          status: FormzSubmissionStatus.inProgress,
        );
        expect(copied.email.value, 'test@example.com');
        expect(copied.status, FormzSubmissionStatus.inProgress);
        expect(copied.password, state.password);
        expect(copied.name, state.name);
      });
    });

    group('SignupState equality', () {
      test('two SignupStates with same values are equal', () {
        const state1 = SignupState();
        const state2 = SignupState();
        expect(state1, equals(state2));
      });

      test('two SignupStates with different values are not equal', () {
        const state1 = SignupState();
        final state2 = state1.copyWith(
          email: const EmailFormzInput.dirty('test@example.com'),
        );
        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('PasswordFormzInput', () {
    group('Valid Passwords', () {
      test('should accept password with 6 characters', () {
        final password = PasswordFormzInput.dirty('123456');
        expect(password.isValid, isTrue);
        expect(password.error, isNull);
      });

      test('should accept password with more than 6 characters', () {
        final password = PasswordFormzInput.dirty('password123!@#');
        expect(password.isValid, isTrue);
        expect(password.error, isNull);
      });

      test('should accept password with special characters', () {
        final password = PasswordFormzInput.dirty('P@ssw0rd!');
        expect(password.isValid, isTrue);
      });

      test('should accept password with spaces', () {
        final password = PasswordFormzInput.dirty('pass word');
        expect(password.isValid, isTrue);
      });
    });

    group('Invalid Passwords', () {
      test('should reject empty password with FormError.empty', () {
        final password = PasswordFormzInput.dirty('');
        expect(password.isValid, isFalse);
        expect(password.error, FormError.empty);
      });

      test('should reject password with 1 character', () {
        final password = PasswordFormzInput.dirty('a');
        expect(password.isValid, isFalse);
        expect(password.error, FormError.invalid);
      });

      test('should reject password with 5 characters', () {
        final password = PasswordFormzInput.dirty('12345');
        expect(password.isValid, isFalse);
        expect(password.error, FormError.invalid);
      });
    });

    group('Pure vs Dirty state', () {
      test('pure state should have default value', () {
        const password = PasswordFormzInput.pure();
        expect(password.isPure, isTrue);
        expect(password.value, '');
      });

      test('pure state with value', () {
        const password = PasswordFormzInput.pure('initialValue');
        expect(password.isPure, isTrue);
        expect(password.value, 'initialValue');
      });
    });
  });

  group('ConfirmPasswordFormzInput', () {
    group('Valid Confirm Passwords', () {
      test('should accept when passwords match', () {
        const confirmPassword = ConfirmPasswordFormzInput.dirty(
          password: 'password123',
          value: 'password123',
        );
        expect(confirmPassword.isValid, isTrue);
        expect(confirmPassword.error, isNull);
      });

      test('should return empty error when both passwords are empty', () {
        const confirmPassword = ConfirmPasswordFormzInput.dirty(
          password: '',
          value: '',
        );
        expect(confirmPassword.error, FormError.empty);
      });
    });

    group('Invalid Confirm Passwords', () {
      test('should reject empty confirmPassword with FormError.empty', () {
        const confirmPassword = ConfirmPasswordFormzInput.dirty(
          password: 'password123',
          value: '',
        );
        expect(confirmPassword.isValid, isFalse);
        expect(confirmPassword.error, FormError.empty);
      });

      test('should reject when passwords do not match', () {
        const confirmPassword = ConfirmPasswordFormzInput.dirty(
          password: 'password123',
          value: 'differentPassword',
        );
        expect(confirmPassword.isValid, isFalse);
        expect(confirmPassword.error, FormError.invalid);
      });

      test('should reject when passwords differ by case', () {
        const confirmPassword = ConfirmPasswordFormzInput.dirty(
          password: 'Password123',
          value: 'password123',
        );
        expect(confirmPassword.isValid, isFalse);
        expect(confirmPassword.error, FormError.invalid);
      });

      test('should reject when passwords differ by whitespace', () {
        const confirmPassword = ConfirmPasswordFormzInput.dirty(
          password: 'password123',
          value: 'password123 ',
        );
        expect(confirmPassword.isValid, isFalse);
        expect(confirmPassword.error, FormError.invalid);
      });
    });

    group('Pure vs Dirty state', () {
      test('pure state should have default values', () {
        const confirmPassword = ConfirmPasswordFormzInput.pure();
        expect(confirmPassword.isPure, isTrue);
        expect(confirmPassword.value, '');
        expect(confirmPassword.password, '');
      });

      test('pure state with values', () {
        const confirmPassword = ConfirmPasswordFormzInput.pure(
          password: 'password123',
          value: 'password123',
        );
        expect(confirmPassword.isPure, isTrue);
      });
    });
  });

  group('NameFormzInput', () {
    group('Valid Names', () {
      test('should accept name with single character', () {
        final name = NameFormzInput.dirty('A');
        expect(name.isValid, isTrue);
        expect(name.error, isNull);
      });

      test('should accept name with spaces', () {
        final name = NameFormzInput.dirty('John Doe');
        expect(name.isValid, isTrue);
      });

      test('should accept name with special characters', () {
        final name = NameFormzInput.dirty("O'Connor");
        expect(name.isValid, isTrue);
      });

      test('should accept name with Vietnamese characters', () {
        final name = NameFormzInput.dirty('Nguyễn Văn A');
        expect(name.isValid, isTrue);
      });

      test('should accept name with numbers', () {
        final name = NameFormzInput.dirty('User123');
        expect(name.isValid, isTrue);
      });
    });

    group('Invalid Names', () {
      test('should reject empty name with FormError.empty', () {
        final name = NameFormzInput.dirty('');
        expect(name.isValid, isFalse);
        expect(name.error, FormError.empty);
      });
    });

    group('Pure vs Dirty state', () {
      test('pure state should have default value', () {
        const name = NameFormzInput.pure();
        expect(name.isPure, isTrue);
        expect(name.value, '');
      });

      test('pure state with value', () {
        const name = NameFormzInput.pure('John');
        expect(name.isPure, isTrue);
        expect(name.value, 'John');
      });
    });
  });

  group('Integration: Full Signup Flow Validation', () {
    late SignupBloc bloc;

    setUp(() {
      bloc = SignupBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('complete valid signup form', () {
      bloc.onEmailChanged('user@example.com');
      bloc.onPasswordChanged('SecurePass123');
      bloc.onNameChanged('John Doe');
      bloc.onConfirmPasswordChanged('SecurePass123');

      expect(bloc.state.email.isValid, isTrue);
      expect(bloc.state.password.isValid, isTrue);
      expect(bloc.state.name.isValid, isTrue);
      expect(bloc.state.confirmPassword.isValid, isTrue);
      expect(bloc.state.isValidated, isTrue);
    });

    test('form becomes invalid when password is changed after confirmPassword',
        () {
      bloc.onEmailChanged('user@example.com');
      bloc.onPasswordChanged('SecurePass123');
      bloc.onNameChanged('John Doe');
      bloc.onConfirmPasswordChanged('SecurePass123');

      expect(bloc.state.isValidated, isTrue);

      bloc.onPasswordChanged('NewPassword456');

      expect(bloc.state.password.value, 'NewPassword456');
    });

    test('form validation with edge cases', () {
      bloc.onEmailChanged('user@mail.company.com');
      expect(bloc.state.email.isValid, isTrue);

      bloc.onPasswordChanged('123456');
      expect(bloc.state.password.isValid, isTrue);

      bloc.onNameChanged('A');
      expect(bloc.state.name.isValid, isTrue);

      bloc.onConfirmPasswordChanged('123456');
      expect(bloc.state.confirmPassword.isValid, isTrue);

      expect(bloc.state.isValidated, isTrue);
    });

    test('all fields empty should not be validated', () {
      bloc.onEmailChanged('');
      bloc.onPasswordChanged('');
      bloc.onNameChanged('');
      bloc.onConfirmPasswordChanged('');

      expect(bloc.state.email.error, FormError.empty);
      expect(bloc.state.password.error, FormError.empty);
      expect(bloc.state.name.error, FormError.empty);
      expect(bloc.state.confirmPassword.error, FormError.empty);
      expect(bloc.state.isValidated, isFalse);
    });
  });
}
