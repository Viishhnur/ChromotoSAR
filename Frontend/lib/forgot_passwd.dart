import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_page/uihelper.dart';
import 'dart:developer' as developer;


class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _maildId = TextEditingController();

  // Gmail validation regex
  bool isValidGmail(String email) {
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return emailRegex.hasMatch(email);
  }

  // Function to reset the password
  forgotPassword(String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      developer.log("Password reset email sent to $email");
      
      // Show a success dialog
      Uihelper.CustomDialogBox(context, "Success", "Password reset email sent to $email", true,false,false);
    } catch (e) {
      developer.log("Error sending password reset email: $e");
      
      // Handle specific Firebase Auth error codes
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          _showErrorDialog(context, "Error", "No account found for that email.");
        } else {
          _showErrorDialog(context, "Error", e.message ?? "Something went wrong");
        }
      } else {
        _showErrorDialog(context, "Error", "An unexpected error occurred.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: const Color.fromARGB(255, 176, 7, 255),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 200, 200, 255),
                Color.fromARGB(255, 255, 255, 255),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_reset,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Forgot password?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Please enter your email address to reset your password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _maildId,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Eg. abc@gmail.com",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 20),
        
                  ElevatedButton(
                    onPressed: () {
                      // Email validation check
                      if (_maildId.text.isEmpty) {
                        _showErrorDialog(context, "Error", "Please enter your email address.");
                      } else if (!isValidGmail(_maildId.text)) {
                        _showErrorDialog(context, "Error", "Please enter a valid Gmail address.");
                      } else {
                        developer.log("Reset clicked for ${_maildId.text}");
                        forgotPassword(_maildId.text, context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 176, 7, 255),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
        
                  const SizedBox(height: 20),
        
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      developer.log("Back clicked");
                    },
                    child: const Text(
                      "Go Back",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 176, 7, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to show error dialog
  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Function to show information dialog
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => VerificationPage(),
                //   ),
                // );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
