
import 'package:firebase_auth/firebase_auth.dart';
// This is for Firebase
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'auth_service.dart';
import 'forgot_passwd.dart';
import 'SquareTile.dart'; // For otp boxes
import 'uihelper.dart';
import 'homepage.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Remote Sensing",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPageState(); // Instance of login page
  }
}

class _LoginPageState extends State<LoginPage> {
  
  bool _obscureText = true; // For tracking the visibility of the text
  final TextEditingController _username =
      TextEditingController(); // Controller for the username field
  final TextEditingController _passwd =
      TextEditingController(); // Controller for the password field

  void login(BuildContext context, String mailId, String passwd) async {
    bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(mailId.substring(0, 10));
    if (mailId.isEmpty || passwd.isEmpty) {
      Uihelper.CustomDialogBox(
          context, "Error", "Enter required fields", false, false,false);
      return;
    }

    try {
      Uihelper.CustomLoadingIcon(
          context); // show an loading icons till u get confirmation from firebase server
      developer.log("Attempting to sign in with email: $mailId");
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: isNumeric ? mailId + "@gmail.com" : mailId,
              password: passwd);

      // User successfully logged in
      developer.log("Successfully signed in. Navigating to Home Page.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(isPhoneRegistration: isNumeric,)),
      );
    } on FirebaseAuthException catch (err) {
      Navigator.of(context).pop();
      developer.log("FirebaseAuthException: ${err.code}");
      if (err.code == 'user-not-found') {
        Uihelper.CustomDialogBox(
            context, "Error", "User doesn't exist", false, false,false);
      } else if (err.code == 'wrong-password') {
        Uihelper.CustomDialogBox(
            context, "Error", "Invalid credentials", false, false,false);
      } else {
        Uihelper.CustomDialogBox(
            context, "Error", err.message ?? "An error occurred", false, false,false);
      }
    } catch (e) {
      developer.log("Exception: $e");
      Uihelper.CustomDialogBox(
          context, "Error", "An unexpected error occurred", false, false,false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Remote Sensing',
          style: TextStyle(
            color: Colors.lime,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Makes the body extend behind the app bar
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage("assets/images/background.png"), // Background image
            fit: BoxFit.fill, // Makes the image cover the entire background
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.3), // Darker semi-transparent background
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(
                  vertical: 50), // Center the container
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // first show a circular avatar for logo
                  SizedBox(
                    height: 10,
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  // Text box for username
                  Uihelper.CustomTextField(_username, "Eg. abc@gmail.com or 91********89",
                      "Email or phone number", Icons.person, false, false, false, () {}),

                  SizedBox(height: 20),

                  // Text box for password
                  Uihelper.CustomTextField(_passwd, "password", "Password",
                      Icons.lock_outline, _obscureText, true, false, () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  }),

                  SizedBox(height: 15),
                  InkWell(
                    // To make a widget tappable
                    onTap: () {
                      developer.log("Forgot Password tapped");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()),
                      );
                    },
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )),
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      developer.log(
                          "Login button pressed with Username: ${_username.text}");
                      login(context, _username.text, _passwd.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black
                          .withOpacity(0.8), // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      minimumSize:
                          Size(double.infinity, 50), // Full-width button
                      elevation: 5, // Added elevation
                    ),
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Google + Apple sign-in options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(
                        onTap: () async {
                          developer.log("Google Sign-in tapped");
                          await AuthService()
                              .signInWithGoogle(context)
                              .then((res) {
                            if (res != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(isPhoneRegistration: false,)),
                              );
                            }
                          });
                        },
                        imageUrl: "assets/images/google.png",
                      ),
                      SizedBox(width: 20),
                      SquareTile(
                          onTap: () {
                            developer.log("Apple Sign-in tapped");
                          },
                          imageUrl: "assets/images/apple.png"),
                    ],
                  ),
                  SizedBox(height: 40),
                  Uihelper.FooterBox(context, "Don't have an account?",
                      " Register", true), // Footer box for registration
                  SizedBox(height: 20),

                  // Terms and conditions
                  Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Social media icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlutterSocialButton(
                        onTap: () {},
                        mini: true,
                        buttonType: ButtonType.facebook,
                      ),
                      SizedBox(width: 20),
                      FlutterSocialButton(
                        onTap: () {},
                        mini: true,
                        buttonType: ButtonType.twitter,
                      ),
                      SizedBox(width: 20),
                      FlutterSocialButton(
                        onTap: () {},
                        mini: true,
                        buttonType: ButtonType.linkedin,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
