// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/main_screens/home_screen.dart';
import '/authentication_screens/login_screen.dart';

// SplashScreen widget
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _rotateAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller with a duration of 3 seconds
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    // Define fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );

    // Define scale animation with elasticOut curve
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.elasticOut),
    );

    // Define rotation animation with easeInOut curve
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    // Start animation and navigate to the next screen when animation completes
    _animationController?.forward().whenComplete(_navigateToNextScreen);
  }

  @override
  void dispose() {
    // Dispose animation controller
    _animationController?.dispose();
    super.dispose();
  }

  // Function to navigate to the next screen based on user preferences
  void _navigateToNextScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool rememberMe = prefs.getBool('rememberMe') ?? false;

    // Check if rememberMe is true and user is logged in
    if (rememberMe && FirebaseAuth.instance.currentUser != null) {
      // Navigate to HomeScreen if rememberMe is true and user is logged in
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      // Navigate to LoginScreen if rememberMe is false or user is not logged in
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController!,
          builder: (context, child) {
            // Apply fade, scale, and rotate animations to the text widget
            return FadeTransition(
              opacity: _fadeAnimation!,
              child: ScaleTransition(
                scale: _scaleAnimation!,
                child: RotationTransition(
                  turns: _rotateAnimation!,
                  child: Text(
                    'DM Flix',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
