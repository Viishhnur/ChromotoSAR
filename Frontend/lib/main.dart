import 'package:email_otp/email_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'CheckUser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  EmailOTP.config(
    appName: 'ChromatoSAR',
    otpType: OTPType.numeric,
    expiry: 180000, // OTP expires in 3 minutes (180 x 1000 seconds)
    emailTheme: EmailTheme.v4,
    appEmail: 'remoteSensing@gmail.com',
    otpLength: 6,
  );
  // await dotenv.load(fileName: "Backend/.env"); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Remote Sensing",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CheckUser(),
    );
  }
}
