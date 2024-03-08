import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screens/home_screen.dart';
import 'authentication_screens/login_screen.dart';
import 'authentication_screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Conditional initialization based on the platform
  if (kIsWeb) {
    // Firebase initialization for web
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAEeEyB9KzoWdDKeirW-GBX_7P6Syh1KPA", // Your apiKey
        authDomain: "fluttertest-83037.firebaseapp.com", // Your authDomain
        databaseURL: "https://fluttertest-83037-default-rtdb.firebaseio.com/", // Your Realtime Database URL
        projectId: "fluttertest-83037", // Your projectId
        storageBucket: "fluttertest-83037.appspot.com", // Your storageBucket
        messagingSenderId: "702418263381", // Your messagingSenderId
        appId: "1:702418263381:web:c96b75ebb249d521e0e3dc", // Your appId
        measurementId: "G-D5RG9QG798" // Your measurementId
      ),
    );
  } else {
    // Firebase initialization for non-web platforms (Android, iOS, etc.)
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAEeEyB9KzoWdDKeirW-GBX_7P6Syh1KPA", // Your apiKey
        authDomain: "fluttertest-83037.firebaseapp.com", // Your authDomain
        databaseURL: "https://fluttertest-83037-default-rtdb.firebaseio.com/", // Your Realtime Database URL
        projectId: "fluttertest-83037", // Your projectId
        storageBucket: "fluttertest-83037.appspot.com", // Your storageBucket
        messagingSenderId: "702418263381", // Your messagingSenderId
        appId: "1:702418263381:web:c96b75ebb249d521e0e3dc", // Your appId
        measurementId: "G-D5RG9QG798" // Your measurementId
      ),
    );
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AuthWrapper(),
      routes: {
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data as Widget;
        } else {
          // Show loading screen while checking preferences
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Future<Widget> _getInitialScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool rememberMe = prefs.getBool('rememberMe') ?? false;
    
    // Check if user is logged in and "Remember Me" is true
    if (rememberMe && FirebaseAuth.instance.currentUser != null) {
      return HomeScreen();  // If user is remembered and authenticated, go to HomeScreen
    } else {
      return LoginScreen(); // Otherwise, show LoginScreen
    }
  }
}
