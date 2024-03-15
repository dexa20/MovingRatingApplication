import 'package:flutter_test/flutter_test.dart';
import 'package:DM_Flix/for_testing/authentication.dart';

void main() {
  group('Authentication', () {
    final Authentication auth = Authentication();

    group('Email Validation', () {
      test('Valid email returns true', () {
        expect(auth.isEmailValid('test@example.com'), isTrue);
      });

      test('Invalid email returns false', () {
        expect(auth.isEmailValid('test'), isFalse);
      });
    });

    group('Password Validation', () {
      test('Valid password returns true', () {
        expect(auth.isPasswordValid('123456'), isTrue);
      });

      test('Invalid password (too short) returns false', () {
        expect(auth.isPasswordValid('12345'), isFalse);
      });
    });

    group('Login', () {
      test('Successful login with valid credentials', () async {
        expect(await auth.login('test@example.com', '123456'), isTrue);
      });

      test('Failed login with invalid email', () async {
        expect(await auth.login('test', '123456'), isFalse);
      });

      test('Failed login with invalid password', () async {
        expect(await auth.login('test@example.com', '12345'), isFalse);
      });
    });
  });
}
