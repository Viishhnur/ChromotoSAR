import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/food.dart';
class VerificationPage extends StatefulWidget{
  // contrsuctor
  final String phoneNumber;
  final String verificationId;
  VerificationPage({super.key,required this.phoneNumber,required this.verificationId});
  @override
  _VerificationPageState createState() => _VerificationPageState();
}
class _VerificationPageState extends State<VerificationPage> {
  // String get phoneNumber => phoneNumber;
  final TextEditingController _box1 = TextEditingController();
    final TextEditingController _box2 = TextEditingController();
  final TextEditingController _box3 = TextEditingController();
  final TextEditingController _box4 = TextEditingController();
    final TextEditingController _box5 = TextEditingController();

  final TextEditingController _box6 = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF1E1E2C), // Dark background color
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
                    "+91 " + widget.phoneNumber[0] + widget.phoneNumber[1] + "********" + widget.phoneNumber[8] + widget.phoneNumber[9],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      // Handle change mail id 
                      Navigator.pop(context); // go back previous forgot passwd screen
                    },
                    child: Text(
                      "Change phone number ?",
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
                  _buildOtpBox(context,_box1),
                  _buildOtpBox(context,_box2),
                  _buildOtpBox(context,_box3),
                  _buildOtpBox(context,_box4),
                  _buildOtpBox(context, _box5),
                  _buildOtpBox(context, _box6),
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
                    "1:00",
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

  Widget _buildOtpBox(BuildContext context,TextEditingController controller) {
    return SizedBox(
      height: 64,
      width: 40,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, color: Colors.white),
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFF2A2A3A), // Darker box color
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
            borderSide: BorderSide(color: Color(0xFF8A73FF)), // Border color when focused
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton(String text, BuildContext context) {
    return TextButton(
      onPressed: () {
        // Handle resend action
        _showDialogBox("OTP Sent","Otp sent successfully",context);
        
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
      onPressed: () async{
        // _showDialogBox("Verified","Successfully verfied your mail",context);
        try{
          PhoneAuthCredential credential = await PhoneAuthProvider.credential(
            verificationId: widget.verificationId, 
            smsCode: (_box1.text+_box2.text+_box3.text+_box4.text+_box5.text+_box6.text).toString()
          );

          FirebaseAuth.instance.signInWithCredential(credential)
          .then((res){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>HomePage(title : "Welcome this is home page")),
            );
          });
          
        }
        catch(ex){
          _showDialogBox("Error","Error in verifying OTP",context);
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Color(0xFF8A73FF), // Purple background color
      ),
      child: Text(
        "Confirm",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

void _showDialogBox(String title,String msg ,BuildContext context){
  showDialog(
    context: context,
    builder: (context){
      return AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      );
    }
  );
}

