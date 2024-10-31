import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_page/uihelper.dart';
import 'dart:developer' as developer;
class AuthService {
  final _auth = FirebaseAuth.instance;
  Future<User?> createUserWithEmailAndPassword(String email,String passwd) async{
      try{

      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: passwd);
      return cred.user;
      }
      catch(e){
        developer.log("Error signing in with Google: $e");
      }
      return null;
  }

   Future<User?> signInUserWithEmailAndPassword(String email,String passwd) async{
      try{

      final cred = await _auth.signInWithEmailAndPassword(email: email, password: passwd);
      return cred.user;
      }
      catch(e){
        developer.log("Error signing in with Google: $e");
      }
      return null;
  }

  Future<void> signOut() async {
    try{
      await _auth.signOut();
    }
    catch(e){
      developer.log("Error signing in with Google: $e");
    }  
  }
  // Google Sign In
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Sign out any existing session (Google + Firebase)
      await GoogleSignIn().signOut();
      await _auth.signOut();

      // Begin the interactive sign-in process
      final  gUser = await GoogleSignIn().signIn();

      // If the user cancels the sign-in process, return null
      if (gUser == null) {
        return null;
      }

      // Ensure gUser.email is not null
      // if (gUser.email == null) {
      //   Uihelper.CustomDialogBox(
      //       context, "Error", "Google account doesn't have an email address", false);
      //   return null;
      // }

      // // Check if the user already exists in Firebase using their email
      // List<String> signInMethods = await FirebaseAuth.instance
      //     .fetchSignInMethodsForEmail(gUser.email!);

      // if (signInMethods.isEmpty) {
      //   // New user, redirect to signup page without signing them in
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => SignUpPage(),
      //     ),
      //   );
      //   return null;  // Prevent user from being signed in
      // }

      // If user exists, proceed with signing in
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential for user
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );

      // Sign in the user with the credential and return the user object
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;

    } catch (e) {
      // Handle errors gracefully
      debugPrint("Error signing in with Google: $e");
      Uihelper.CustomDialogBox(
          context, "Sign-in failed", "An error occurred during sign-in", false,false,false);
      return null; // Return null if sign-in fails
    }
  }
  

  // Google Sign Up
  Future<User?> signUpWithGoogle(BuildContext context) async {
    try {
      // Sign out any existing session (Google + Firebase)
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      // Begin the interactive sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // If the user cancels the sign-in process, return null
      if (gUser == null) {
        return null;
      }

      // // Check if the user already exists in Firebase using their email
      // List<String> signInMethods = await FirebaseAuth.instance
      //     .fetchSignInMethodsForEmail(gUser.email);

      // if (signInMethods.isEmpty) {
      //   // New user, redirect to signup page without signing them in
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => SignUpPage(),
      //     ),
      //   );
      //   return null;  // Prevent user from being signed in
      // }

      // If user exists, proceed with signing in
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential for user
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in the user with the credential and return the user object
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;

    } catch (e) {
      // Handle errors gracefully
      debugPrint("Error signing in with Google: $e");
      return null; // Return null if sign-in fails
    }
  
}

}