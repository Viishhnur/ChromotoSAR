import 'dart:io';
import 'dart:convert';
import 'dart:async'; // Import for Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/uihelper.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class EmailOTPPage extends StatefulWidget {
  final String mailId;
  final String username;
  final String password;
  final File pickedImage;
  final bool isEmailOtp;
  final String generatedMobileOtp;
  EmailOTPPage(
      {super.key,
      required this.mailId,
      required this.username,
      required this.password,
      required this.pickedImage,
      required this.isEmailOtp,
      required this.generatedMobileOtp});

  @override
  _EmailOTPPageState createState() => _EmailOTPPageState();
}

class _EmailOTPPageState extends State<EmailOTPPage> {
  final TextEditingController _box1 = TextEditingController();
  final TextEditingController _box2 = TextEditingController();
  final TextEditingController _box3 = TextEditingController();
  final TextEditingController _box4 = TextEditingController();
  final TextEditingController _box5 = TextEditingController();
  final TextEditingController _box6 = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final FocusNode _focusNode6 = FocusNode();

  bool isAuthSuccess = false; // change to true when auth becomes successful
  late Timer _timer;
  late String resendedMobileOtp;
  bool isResendClicked = false; // change to true when
  int _start =
      180; // Start time in seconds (for both email and otp expire time is 3mins)

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  String _getMiddleStars(int n) {
    String res = "";
    for (int i = 0; i < n; i++) res += "*";
    return res;
  }

  String get _formattedTime {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  ValidateEmailOtp() async {
    if (await EmailOTP.verifyOTP(
        otp: _box1.text.toString() +
            _box2.text.toString() +
            _box3.text.toString() +
            _box4.text.toString() +
            _box5.text.toString() +
            _box6.text.toString())) {
      isAuthSuccess = true;
      try {
        // create a user credential in firebase authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.mailId,
          password: widget.password,
        );
      } on FirebaseAuthException {
        developer.log("Error creating");
      }
    } else {
      Uihelper.CustomDialogBox(
          context, "Error", "Invalid OTP , enter again", false, false,false);
    }
  }

  ValidatePhoneOtp() async {
    bool verificationStatus = await verifyOtp(
        isResendClicked ? resendedMobileOtp : widget.generatedMobileOtp,
        _box1.text.toString() +
            _box2.text.toString() +
            _box3.text.toString() +
            _box4.text.toString() +
            _box5.text.toString() +
            _box6.text.toString());
    if (verificationStatus == true) {
      isAuthSuccess = true;
      try {
        // create a user credential in firebase authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.mailId +
              "@gmail.com", // phone number + @gmail.com to access the data back
          password: widget.password,
        );
      } on FirebaseAuthException {
        developer.log("Error creating");
      }
    }
  }

  bool verifyOtp(String otpgenerated, String enteredOtp) {
    if (otpgenerated == enteredOtp) {
      // Success
      Uihelper.CustomDialogBox(
          context, "Success", "OTP verified successfully", true, true,true);
      return true;
    } else {
      // Failure
      Uihelper.CustomDialogBox(
          context, "Error", "Invalid OTP , enter again", false, false,false);
      return false;
    }
  }

  uploadData() async {
    try {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("Profile pics")
          .child(widget.mailId)
          .putFile(widget.pickedImage);
      TaskSnapshot taskSnapshot = await uploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.isEmailOtp
              ? widget.mailId
              : widget.mailId.substring(0, 10))
          .set({
        "Username": widget.username,
        "Image": url,
      });

      // Successful upload, update the UI
      developer.log("Image uploaded successfully");
    } catch (ex) {
      developer.log("Failed to upload image: $ex");
    }
  }

  StoreDataInDB() async {
    Uihelper.CustomDialogBox(context, "Successfully verified and registered",
        "You have registered successfully", true, true,!widget.isEmailOtp);
    try {
      developer.log("Uploading data to firebase...");

      await uploadData();
      // Navigator.push
      developer.log("Data successfully stored in firebase");
    } on FirebaseAuthException catch (ex) {
      Navigator.of(context).pop();
      // Show error dialog if there's an issue

      developer.log("Error: ${ex.code}");
      Uihelper.CustomDialogBox(
          context, "Error", ex.message ?? "Something went wrong", false, false,!widget.isEmailOtp);
    }
  }

  ResendEmailOtp() async {
    if (await EmailOTP.sendOTP(email: widget.mailId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP has been sent")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP failed to send")),
      );
    }
  }

  ResendOTPTOMobile() async {
    try {
      // Prepare the data to send
      final Map<String, String> data = {
        'mobile': "91" + widget.mailId,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(
            'http://192.168.29.20:3000'), // Use '10.0.2.2' for Android emulator
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        resendedMobileOtp =
            response.body.split('OTP:-')[1].split(' ')[0].trim();
        developer.log(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP has been sent")),
        );
      } else {
        developer.log("Failed to load data: ${response.statusCode}");
        Uihelper.CustomDialogBox(
            context, "Error", "Failed to send OTP", false, false,false);
      }
    } catch (e) {
      developer.log("Erorr: $e");
      Uihelper.CustomDialogBox(
          context, "Error", "Failed to send OTP", false, false,false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int mailIdLen = widget.mailId.length;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF1E1E2C),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Verification code",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "We have sent the code verification to",
                style: TextStyle(color: Colors.grey[500]),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    (widget.isEmailOtp ? "" : "+91 ") +
                        widget.mailId[0] +
                        widget.mailId[1] +
                        (widget.isEmailOtp
                            ? _getMiddleStars(mailIdLen - 10)
                            : "********") +
                        widget.mailId[8] +
                        widget.mailId[9] +
                        (widget.isEmailOtp ? "@gmail.com" : ""),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      widget.isEmailOtp
                          ? "Change mail id ?"
                          : "Change mobile number ?",
                      style: TextStyle(
                        color: Color(0xFF8A73FF),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOtpBox(context, _box1, _focusNode1, _focusNode2),
                  _buildOtpBox(context, _box2, _focusNode2, _focusNode3),
                  _buildOtpBox(context, _box3, _focusNode3, _focusNode4),
                  _buildOtpBox(context, _box4, _focusNode4, _focusNode5),
                  _buildOtpBox(context, _box5, _focusNode5, _focusNode6),
                  _buildOtpBox(context, _box6, _focusNode6, null),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Resend code after ",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      color: Color(0xFF8A73FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResendButton("Resend", context),
                  _buildConfirmButton(context),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, TextEditingController controller,
      FocusNode currentFocus, FocusNode? nextFocus) {
    return SizedBox(
      height: 64,
      width: 40,
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, color: Colors.white),
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFF2A2A3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF8A73FF)),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            } else {
              currentFocus.unfocus();
            }
          }
        },
      ),
    );
  }

  Widget _buildResendButton(String text, BuildContext context) {
    return TextButton(
      onPressed: () async {
        // Now resend otp
        if (widget.isEmailOtp) {
          await ResendEmailOtp();
          _showDialogBox("OTP Sent", "Otp sent successfully", context);
          // await ValidateEmailOtp();
        } else {
          await ResendOTPTOMobile();
          _showDialogBox("OTP Sent", "Otp sent successfully", context);
          // await ValidatePhoneOtp();
        }
        if (isAuthSuccess = true) {
          // Now upload the data to firebase
          // StoreDataInDB();
          try {
            developer.log("Uploading data to firebase");

            await uploadData().then((val) {
              // Navigator.push
              developer.log("Data successfully stored in firebase");
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => HomePage()),
              // );
            });
          } on FirebaseAuthException catch (ex) {
            Navigator.of(context).pop();
            // Show error dialog if there's an issue

            developer.log("Error: ${ex.code}");
            Uihelper.CustomDialogBox(context, "Error",
                ex.message ?? "Something went wrong", false, false,false);
          }
        }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (widget.isEmailOtp) {
          // now validate email otp here
          await ValidateEmailOtp();
          if (isAuthSuccess == true) {
            // Now upload the data to firebase
            await StoreDataInDB();
          }
        } else {
          // this is for phone otp authentication
          await ValidatePhoneOtp();
          if (isAuthSuccess == true) {
            // Now upload the data to firebase
            await StoreDataInDB();
          }
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Color(0xFF8A73FF),
      ),
      child: Text(
        "Verify",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

void _showDialogBox(String title, String msg, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E2C),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            msg,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(color: Color(0xFF8A73FF)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
