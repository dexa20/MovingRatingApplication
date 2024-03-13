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
        // Make sure to add routes for other screens as needed
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _getInitialScreen();
    });
  }

  Future<void> _getInitialScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe && FirebaseAuth.instance.currentUser != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen content goes here
    return Scaffold(
      body: Center(
        child: Text('DM Flix', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
      ),
    );
  }
}
