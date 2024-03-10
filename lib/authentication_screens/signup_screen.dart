import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import the connectivity_plus package
import '/main_screens/home_screen.dart'; // Update this import path according to your project structure

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isPasswordVisible = false; // Added variable to track password visibility

  void _signUp() async {
    setState(() {
      _errorMessage = ''; // Reset error message
    });

    // Check internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      setState(() {
        _errorMessage = 'No internet connection. Please connect to the internet and try again.';
      });
      return; // Exit the method if no internet connection
    }

    // Check if either the email or password fields are empty
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (!_validateEmail(_emailController.text.trim())) {
      _errorMessage = 'Please enter a valid email address.';
      setState(() {}); // Trigger UI update
      return;
    }

    if (!_validatePassword(_passwordController.text.trim())) {
      _errorMessage = 'Password must be at least 6 characters.';
      setState(() {}); // Trigger UI update
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again later.';
      setState(() {}); // Trigger UI update
    }
  }

  bool _validateEmail(String email) {
    // Simple regex to check email validity
    final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  bool _validatePassword(String password) {
    // Check for password length of at least 6 characters
    return password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DM Flix',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Signup Page',
              style: TextStyle(fontSize: 32.0, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: _signUp,
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
