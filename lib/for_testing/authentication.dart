class Authentication {
  // Method to validate email format
  bool isEmailValid(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegExp.hasMatch(email);
  }

  // Method to validate password length
  bool isPasswordValid(String password) {
    return password.length >= 6;
  }

  // Method to perform login authentication
  Future<bool> login(String email, String password) async {
    // Check if email and password are valid
    return isEmailValid(email) && isPasswordValid(password);
  }
}
