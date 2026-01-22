import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/src/features/authentication/model/email_fromz.dart';
import 'package:myapp/src/features/authentication/model/form_error.dart';

void main() {
  group('EmailFormzInput - Email Validation', () {
    group('Valid Emails', () {
      const validEmails = [
        'test@example.com',
        'user@domain.org',
        'john.doe@company.co',
        'alice-bob@test.io',
        'user123@mail.vn',
        'first.last@subdomain.domain.com',
        'user-name@my-company.org',
        'a@b.co',
        'user@domain.info',
        'name@company.travel',
        'test_user@example.com',
        'user-1@domain-test.com',
        'john_doe.test@company.co.uk',
        'simple@example.museum',
        'user@localhost.local',
      ];

      for (final email in validEmails) {
        test('should accept valid email: $email', () {
          final emailInput = EmailFormzInput.dirty(email);
          expect(emailInput.isValid, isTrue);
          expect(emailInput.error, isNull);
        });
      }
    });

    group('Invalid Emails - Format Errors', () {
      const invalidEmails = [
        'plainaddress',
        '@missingusername.com',
        'username@.com',
        'username@domain',
        'username@domain.',
        'username@domain.c',
        '.username@domain.com',
        'username.@domain.com',
        'user..name@domain.com',
        'username@domain..com',
        'user name@domain.com',
        'username@domain .com',
        'username @domain.com',
        'username@ domain.com',
        'user<name>@domain.com',
        'user(name)@domain.com',
        'user[name]@domain.com',
        'user;name@domain.com',
        'user:name@domain.com',
        'user,name@domain.com',
        'user!name@domain.com',
        'user#name@domain.com',
        'user\$name@domain.com',
        'user%name@domain.com',
        'user&name@domain.com',
        'user*name@domain.com',
        'user+name@domain.com',
        'user=name@domain.com',
        'user/name@domain.com',
        "user'name@domain.com",
        'user"name@domain.com',
        'user`name@domain.com',
        'user|name@domain.com',
        'user\\name@domain.com',
        'user^name@domain.com',
        'user~name@domain.com',
        '@domain.com',
        'username@',
        '@',
        'username@@domain.com',
        'user@name@domain.com',
      ];

      for (final email in invalidEmails) {
        test('should reject invalid email: $email', () {
          final emailInput = EmailFormzInput.dirty(email);
          expect(emailInput.isValid, isFalse);
          expect(emailInput.error, equals(FormError.invalid));
        });
      }
    });

    group('Empty Email', () {
      test('should return FormError.empty when email is empty string', () {
        final emailInput = EmailFormzInput.dirty('');
        expect(emailInput.isValid, isFalse);
        expect(emailInput.error, equals(FormError.empty));
      });

      test('should return FormError.empty when email is null-coalesced empty',
          () {
        final emailInput = EmailFormzInput.dirty('');
        expect(emailInput.isValid, isFalse);
        expect(emailInput.error, equals(FormError.empty));
      });
    });

    group('Pure vs Dirty state', () {
      test('pure state should not have error initially', () {
        const emailInput = EmailFormzInput.pure();
        expect(emailInput.isPure, isTrue);
        expect(emailInput.value, equals(''));
      });

      test('pure state with valid email', () {
        const emailInput = EmailFormzInput.pure('test@example.com');
        expect(emailInput.isPure, isTrue);
        expect(emailInput.value, equals('test@example.com'));
      });

      test('dirty state with valid email should be valid', () {
        final emailInput = EmailFormzInput.dirty('test@example.com');
        expect(emailInput.isPure, isFalse);
        expect(emailInput.isValid, isTrue);
        expect(emailInput.error, isNull);
      });

      test('dirty state with invalid email should have error', () {
        final emailInput = EmailFormzInput.dirty('invalid-email');
        expect(emailInput.isPure, isFalse);
        expect(emailInput.isValid, isFalse);
        expect(emailInput.error, equals(FormError.invalid));
      });
    });

    group('Edge Cases', () {
      test('should handle emails with numbers in local part', () {
        final emailInput = EmailFormzInput.dirty('user123@example.com');
        expect(emailInput.isValid, isTrue);
      });

      test('should handle emails with numbers in domain', () {
        final emailInput = EmailFormzInput.dirty('user@domain123.com');
        expect(emailInput.isValid, isTrue);
      });

      test('should handle emails with hyphens', () {
        final emailInput = EmailFormzInput.dirty('user-name@my-domain.com');
        expect(emailInput.isValid, isTrue);
      });

      test('should handle emails with underscores in local part', () {
        final emailInput = EmailFormzInput.dirty('user_name@domain.com');
        expect(emailInput.isValid, isTrue);
      });

      test('should handle emails with multiple subdomains', () {
        final emailInput =
            EmailFormzInput.dirty('user@mail.subdomain.example.com');
        expect(emailInput.isValid, isTrue);
      });

      test('should handle emails with long TLD', () {
        final emailInput = EmailFormzInput.dirty('user@example.photography');
        expect(emailInput.isValid, isTrue);
      });

      test('should handle minimal valid email', () {
        final emailInput = EmailFormzInput.dirty('a@b.co');
        expect(emailInput.isValid, isTrue);
      });

      test(
          'should accept email with leading hyphen in domain (regex limitation)',
          () {
        final emailInput = EmailFormzInput.dirty('user@-domain.com');

        expect(emailInput.isValid, isTrue);
      });

      test(
          'should accept email with trailing hyphen in domain (regex limitation)',
          () {
        final emailInput = EmailFormzInput.dirty('user@domain-.com');

        expect(emailInput.isValid, isTrue);
      });

      test('should handle email with hyphen in TLD', () {
        final emailInput = EmailFormzInput.dirty('user@domain.co-m');
        expect(emailInput.isValid, isTrue);
      });
    });

    group('Unicode and International Characters', () {
      test('should reject email with Vietnamese characters', () {
        final emailInput = EmailFormzInput.dirty('người@example.com');
        expect(emailInput.isValid, isFalse);
      });

      test('should reject email with Chinese characters', () {
        final emailInput = EmailFormzInput.dirty('用户@example.com');
        expect(emailInput.isValid, isFalse);
      });

      test('should reject email with emoji', () {
        final emailInput = EmailFormzInput.dirty('user😀@example.com');
        expect(emailInput.isValid, isFalse);
      });

      test('should reject email with accented characters', () {
        final emailInput = EmailFormzInput.dirty('usér@example.com');
        expect(emailInput.isValid, isFalse);
      });
    });

    group('Whitespace Handling', () {
      test('should reject email with leading whitespace', () {
        final emailInput = EmailFormzInput.dirty(' user@example.com');
        expect(emailInput.isValid, isFalse);
      });

      test('should reject email with trailing whitespace', () {
        final emailInput = EmailFormzInput.dirty('user@example.com ');
        expect(emailInput.isValid, isFalse);
      });

      test('should reject email with only whitespace', () {
        final emailInput = EmailFormzInput.dirty('   ');
        expect(emailInput.isValid, isFalse);
      });

      test('should reject email with tab character', () {
        final emailInput = EmailFormzInput.dirty('user\t@example.com');
        expect(emailInput.isValid, isFalse);
      });

      test('should reject email with newline character', () {
        final emailInput = EmailFormzInput.dirty('user\n@example.com');
        expect(emailInput.isValid, isFalse);
      });
    });
  });
}
