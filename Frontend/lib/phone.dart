import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:login_page/otp.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PhoneLogin(), // Set PhoneLogin as the home of the app
    );
  }
}

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final _phoneController = TextEditingController(); // Controller for phone input

  @override
  void dispose() {
    _phoneController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch input and button to fill width
          children: [
            // Phone Number Input Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone, // Set keyboard type for phone number
              decoration: InputDecoration(

                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder( // Add a border around the input field
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.phone), 
              ),
            ),
            const SizedBox(height: 20), // Add spacing between input and button
            // Styled Button
            ElevatedButton(
              onPressed: () async{
               if(_phoneController.text.toString().length != 10){
                  developer.log("Phone number should be 10 digits");
                  _showErrorDialog(context, "Invalid phone number","Phone number should be 10 digits");
                  return;
               }
                developer.log("Phone number button clicked , phone number is ${_phoneController.text}");
                await FirebaseAuth.instance.verifyPhoneNumber(
                  verificationCompleted: (PhoneAuthCredential credential){

                  }, 
                  verificationFailed: (FirebaseAuthException ex){
                    developer.log("Error in phone verification ${ex.message}");
                    _showErrorDialog(context, "Error in phone verification",ex.message.toString());
                  }, 
                  codeSent: (String verificationId,int? resendToken){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=>VerificationPage(phoneNumber : _phoneController.text.toString(),verificationId: verificationId)),
                  );

                  }, codeAutoRetrievalTimeout: (String verificationId){
                    developer.log("Auto retrieval timeout");
                  },
                  phoneNumber: "+91${_phoneController.text.toString()}",
                ); 
               
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16), // Vertical padding
                shape: RoundedRectangleBorder( // Rounded corners
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.blue, // Background color of the button
              ),
              child: const Text(
                'Generate OTP', // Button text
                style: TextStyle(fontSize: 18, color: Colors.white), // Text style
              ),
            ),
          ],
        ),
      ),
    );
  }
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
}
