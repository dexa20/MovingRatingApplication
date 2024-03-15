import 'package:flutter/material.dart'; // Importing Flutter material library
import 'package:firebase_core/firebase_core.dart'; // Importing Firebase core library
import 'firebase_options.dart'; // Importing Firebase options
import 'package:shared_preferences/shared_preferences.dart'; // Importing shared preferences for local storage
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase authentication library
import 'main_screens/home_screen.dart'; // Importing home screen for authenticated users
import 'authentication_screens/login_screen.dart'; // Importing login screen for authentication
import 'authentication_screens/signup_screen.dart'; // Importing signup screen for user registration

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initializing Firebase with default options
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DM Flix', // App title
      theme: ThemeData(
        primarySwatch: Colors.green, // Setting primary color theme
        scaffoldBackgroundColor: Colors.grey[900], // Setting scaffold background color
      ),
      home: AuthWrapper(), // Setting initial route to authentication wrapper
      routes: {
        '/signup': (context) => SignupScreen(), // Setting route for signup screen
      },
      debugShowCheckedModeBanner: false, // Hiding debug banner
    );
  }
}

class AuthWrapper extends StatefulWidget { // Authentication wrapper widget
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _getInitialScreen(); // Getting initial screen after delay
    });
  }

  Future<void> _getInitialScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds for better user experience

    final SharedPreferences prefs = await SharedPreferences.getInstance(); // Get instance of shared preferences
    final bool rememberMe = prefs.getBool('rememberMe') ?? false; // Check if remember me is enabled

    if (rememberMe && FirebaseAuth.instance.currentUser != null) { // If remember me is enabled and user is authenticated
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen())); // Navigate to home screen
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen())); // Navigate to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('DM Flix', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)), // Display app name
      ),
    );
  }
}
