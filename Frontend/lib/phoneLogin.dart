import 'dart:io'; // for File
import 'dart:convert'; // for json conversion

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/EmailOTPPage.dart';
import 'package:login_page/homepage.dart';
import 'package:login_page/signup.dart';
import 'uihelper.dart';
import 'dart:developer' as developer;
import 'SquareTile.dart';
import 'live_space.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;

class PhoneLoginPage extends StatefulWidget {
  @override
  _PhoneLoginPageState createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _auth = AuthService();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _passwd = TextEditingController();
  final TextEditingController _confirmPasswd = TextEditingController();
  bool _obscurePasswd = true;
  bool _obscureConfirmPasswd = true;

  final FocusNode _emailFocusNode = FocusNode();
  bool _isAppBarVisible = true; // track if app bar is visible
  File? pickedImage; // Track the picked image
  @override
  void initState() {
    super.initState();
    // add a event listner
    _emailFocusNode.addListener(() {
      setState(() {
        _isAppBarVisible = !_emailFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<String> sendOTPTOMobile() async {
    try {
      // Prepare the data to send
      final Map<String, String> data = {
        'mobile': "91" + _phoneNumber.text.toString()
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(
            'http://192.168.153.193:3000'), // Use '10.0.2.2' for Android emulator // 192.168.153.193 for hotspot
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        String otp = response.body.split('OTP:-')[1].split(' ')[0].trim();
        developer.log(response.body);
        return otp;
      } else {
        developer.log("Failed to load data: ${response.statusCode}");
        return "";
      }
    } catch (e) {
      developer.log("Erorr: $e");
      return "";
    }
  }

  void signUp(BuildContext context, String num, String passwd,
      String confirmPasswd) async {
    if (num == "" && passwd == "") {
      Uihelper.CustomDialogBox(
          context, "Error", "Please enter the required details", false,false,false);
    } else if (passwd == "" && confirmPasswd == "") {
      Uihelper.CustomDialogBox(
          context, "Error", "Please enter your password and confirm it", false,false,false);
    } else if (confirmPasswd == "") {
      Uihelper.CustomDialogBox(
          context, "Error", "Please confirm your password", false,false,false);
    } else if (passwd != confirmPasswd) {
      developer.log("Passwords do not match");
      Uihelper.CustomDialogBox(context, "Error",
          "Passwords do not match, please enter correctly", false,false,false);
    } else {
      developer.log("mobileNumber: $num, Password: $passwd");

      try {
        // Call sendOTPTOMobile and get the OTP
        String? otp = await sendOTPTOMobile();

        developer.log("OTP is ${otp}");
        // Navigate to OTP page, passing the OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailOTPPage(
              mailId: _phoneNumber.text.toString(),
              username:_username.text.toString(),
              password: _passwd.text.toString(),
              pickedImage: pickedImage!,
              isEmailOtp: false,
              generatedMobileOtp:otp // Pass the OTP to the next screen
            ),
          ),
        );
            } catch (ex) {
        Uihelper.CustomDialogBox(context, "Error", "Failed to Send OTP", false,false,false);
      }
    }
  }

  pickImage(ImageSource imageSource) async {
    try {
      // the imageSource can be from gallery or camera
      final photo = await ImagePicker().pickImage(source: imageSource);
      if (photo == null) return;

      // copy the path of image
      final tempImgPath = File(photo.path);
      setState(() {
        pickedImage = tempImgPath;
      });
    } catch (ex) {
      developer.log("Failed to pick image: $ex");
    }
  }

  showImagePickerBox() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pick Image from"),
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensures that the dialog is not too large
            children: [
              ListTile(
                onTap: () {
                  pickImage(ImageSource.camera);

                  Navigator.pop(context);
                },
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
              ),
              ListTile(
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                leading: Icon(Icons.image),
                title: Text("Gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allows screen to resize to avoid overflow
      appBar: _isAppBarVisible
          ? AppBar(
              title: Text("Sign Up Page"),
            )
          : null,

      body: Stack(children: [
        LiveBackground(),
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0), // Added padding for better layout
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // phone number page
                InkWell(
                  // To make a widget tappable
                  onTap: () {
                    developer.log("mail register tapped");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Register with mail ?",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      InkWell(
                        onTap: () {
                          showImagePickerBox();
                        },
                        child: pickedImage != null
                            ? CircleAvatar(
                                radius: 35,
                                backgroundImage: FileImage(pickedImage!),
                              )
                            : CircleAvatar(
                                radius: 35,
                                child: Icon(
                                  Icons.person,
                                  size: 35,
                                )),
                      ),
                    ],
                  )),
                ),
                // text box for email
                SizedBox(
                  height: 20,
                ),
                Uihelper.CustomTextField(_username, "username", "Username",
                    Icons.person, false, false, false, () {}),
                SizedBox(
                  height: 20,
                ),
                Uihelper.CustomTextField(_phoneNumber, "phone", "number",
                    Icons.phone, false, false, true, () {}),

                SizedBox(height: 20), // Spacing between the text fields
                // for password box
                Uihelper.CustomTextField(_passwd, "enter password", "Password",
                    Icons.lock, _obscurePasswd, true, false, () {
                  setState(() {
                    _obscurePasswd = !_obscurePasswd;
                  });
                }),

                SizedBox(
                    height: 20), // Spacing before the confirm password field
                // for confirm password box
                Uihelper.CustomTextField(
                    _confirmPasswd,
                    "confirm password",
                    "Confirm Password",
                    Icons.lock,
                    _obscureConfirmPasswd,
                    true,
                    false, () {
                  setState(() {
                    _obscureConfirmPasswd = !_obscureConfirmPasswd;
                  });
                }),

                SizedBox(height: 20), // Spacing before the sign-up button

                ElevatedButton(
                  onPressed: () {
                    signUp(
                        context,
                        _phoneNumber.text.toString(),
                        _passwd.text.toString(),
                        _confirmPasswd.text.toString());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue.withOpacity(0.8), // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    minimumSize: Size(double.infinity, 50), // Full-width button
                    elevation: 5, // Added elevation
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
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

                SizedBox(
                  height: 20,
                ),
                // google + apple signup options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      onTap: () async {
                        developer.log("Google Sign-up tapped");

                        // Sign out from any existing session to ensure new sign-in

                        // Attempt Google sign-up
                        User? user =
                            await AuthService().signUpWithGoogle(context);

                        // If sign-in is successful, navigate to the main page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(isPhoneRegistration: false,),
                          ),
                        );
                      },
                      imageUrl: "assets/images/google.png",
                    ),
                    SizedBox(width: 20),
                    SquareTile(
                      onTap: () {
                        developer.log("Apple Sign-in tapped");
                      },
                      imageUrl: "assets/images/apple.png",
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Uihelper.FooterBox(context, "Already a member? ", "Login",
                    false), // Footer box for registration
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
