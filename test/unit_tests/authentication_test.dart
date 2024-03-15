import 'package:flutter_test/flutter_test.dart'; // Importing Flutter test library
import 'package:DM_Flix/for_testing/authentication.dart'; // Importing authentication class for testing

void main() {
  group('Authentication', () {
    final Authentication auth = Authentication(); // Creating instance of Authentication class

    group('Email Validation', () {
      // Test for validating valid email
      test('Valid email returns true', () {
        expect(auth.isEmailValid('test@example.com'), isTrue);
      });

      // Test for validating invalid email
      test('Invalid email returns false', () {
        expect(auth.isEmailValid('test'), isFalse);
      });
    });

    group('Password Validation', () {
      // Test for validating valid password
      test('Valid password returns true', () {
        expect(auth.isPasswordValid('123456'), isTrue);
      });

      // Test for validating invalid password (too short)
      test('Invalid password (too short) returns false', () {
        expect(auth.isPasswordValid('12345'), isFalse);
      });
    });

    group('Login', () {
      // Test for successful login with valid credentials
      test('Successful login with valid credentials', () async {
        expect(await auth.login('test@example.com', '123456'), isTrue);
      });

      // Test for failed login with invalid email
      test('Failed login with invalid email', () async {
        expect(await auth.login('test', '123456'), isFalse);
      });

      // Test for failed login with invalid password
      test('Failed login with invalid password', () async {
        expect(await auth.login('test@example.com', '12345'), isFalse);
      });
    });
  });
}
