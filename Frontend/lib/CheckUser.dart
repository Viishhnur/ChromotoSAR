import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_page/login.dart';
import 'dart:developer' as developer;

import 'homepage.dart';
class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {

  var auth = FirebaseAuth.instance; // Firebase authentication instance
  bool isLogin = false; // For tracking the login state
   @override
  void initState() {
    super.initState();
      _checkIfLogin();
    
  }
  _checkIfLogin() async {
  // User? user = FirebaseAuth.instance.currentUser;
  auth.authStateChanges().listen((User? user) {
    if (user != null && mounted) {
      String? email = user.email; // Nullable email
      bool isNumeric = false;
      if (email != null) {
        // Check if the first 10 characters of email are numeric
        isNumeric = RegExp(r'^[0-9]+$').hasMatch(email.substring(0, 10));
      }
      developer.log('User is signed in!');
      setState(() {
        isLogin = true;
      });
      // Navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(isPhoneRegistration: isNumeric),
        ),
      );
    } else {
      developer.log('User is currently signed out!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: !isLogin
            ? const CircularProgressIndicator()
            : Container(), // Empty container since navigation occurs
      ),
    );
  }
}