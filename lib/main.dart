import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screens/home_screen.dart';
import 'authentication_screens/login_screen.dart';
import 'authentication_screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DM Flix',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: AuthWrapper(),
      routes: {
        '/signup': (context) => SignupScreen(),
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

    if (rememberMe && FirebaseAuth.instance.currentUser != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}
