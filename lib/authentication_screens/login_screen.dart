// Import necessary packages and files
import 'package:flutter/material.dart'; // Flutter material design components
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication services
import 'package:shared_preferences/shared_preferences.dart'; // Persistent local storage
import 'package:connectivity_plus/connectivity_plus.dart'; // Internet connectivity check
import '/main_screens/home_screen.dart'; // Import home screen widget
import '/authentication_screens/signup_screen.dart'; // Import signup screen widget

// Class for the login screen widget
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for email and password text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // State variables
  bool _rememberMe = false; // State to remember user's login
  String _errorMessage = ''; // Error message display state
  bool _isPasswordVisible = false; // State to toggle password visibility

  @override
  void initState() {
    super.initState();
    // Load remember me preference when the screen initializes
    _loadRememberMePreference();
  }

  // Function to load remember me preference from shared preferences
  Future<void> _loadRememberMePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  // Function to validate email format
  bool _isEmailValid(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegExp.hasMatch(email);
  }

  // Function to validate password length
  bool _isPasswordValid(String password) {
    return password.length >= 6;
  }

  // Function to handle login process
  void _login() async {
    setState(() {
      _errorMessage = ''; // Clear any previous error message
    });

    // Check internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'No internet connection. Please connect to the internet and try again.';
      });
      return;
    }

    // Retrieve email and password from text fields
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Validate email and password
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (!_isEmailValid(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    if (!_isPasswordValid(password)) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters.';
      });
      return;
    }

    // Attempt to sign in with Firebase Auth
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Save remember me preference
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', _rememberMe);

      // Navigate to home screen on successful login
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid email address or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar with title
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
            // Title
            Text(
              'Login Page',
              style: TextStyle(
                fontSize: 32.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48.0),
            // Email text field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8.0),
            // Password text field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
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
            SizedBox(height: 20),
            // Remember me checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      _rememberMe = value!;
                    });
                  },
                  checkColor: Colors.green,
                  fillColor: MaterialStateProperty.all(Colors.white),
                ),
                Text(
                  'Remember Me',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Login button
            ElevatedButton(
              child: Text(
                'Login',
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
              onPressed: _login,
            ),
            SizedBox(height: 16.0),
            // Sign up button
            TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignupScreen())),
              child: Text(
                "Don't have an account? Sign Up",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            // Error message display
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
