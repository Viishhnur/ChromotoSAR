import 'package:flutter/material.dart';
import 'package:login_page/homepage.dart';
import 'package:login_page/login.dart';
import 'dart:developer' as developer;
import 'package:login_page/signup.dart';

class Uihelper {
  static Widget CustomTextField(
    TextEditingController controller,
    String placeholder,
    String label,
    IconData prefixIconData,
    bool toHide,
    bool
        isSuffixIconThere, // Nullable for cases where we don't need suffix icon
    bool isPhoneNum,    
    Function() onSuffixTap, // A callback for the suffix icon tap
  ) {
    return TextField(
      controller: controller,
      obscureText: toHide,
      obscuringCharacter: "*",
      style: TextStyle(color: Colors.white), 
      keyboardType: isPhoneNum ? TextInputType.number : null,

      decoration: InputDecoration(
        hintText: placeholder,
        labelText: label,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        labelStyle: TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(
            color: Colors.purple,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        prefixIcon: Icon(prefixIconData, color: Colors.white),
        suffixIcon: isSuffixIconThere
            ? IconButton(
                icon: Icon(
                  toHide ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed:
                    onSuffixTap, // Using a callback to handle state from outside
              )
            : null, // Set suffixIcon to null if we don't want to show it
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
      ),
    );
  }

  static void CustomDialogBox(
      BuildContext context, String title, String content, bool isSuccess,bool isNavigatingToHomePage,bool isPhoneRegistration) {
    showDialog(
      context: context,
      // content: content
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.green : Colors.red,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  isSuccess ? Navigator.pop(context) : -1;
                  if(isNavigatingToHomePage){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(isPhoneRegistration: isPhoneRegistration,),
                      ),
                    );
                  }
                  else Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void CustomLoadingIcon(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            backgroundColor: Colors.transparent,
          ),
        );
      },
    );
  }

  static Widget FooterBox(BuildContext context, String message,
      String registerOrLogin, bool inLoginPage) {
    return GestureDetector(
      onTap: () {
        // Handle sign-up action here
        developer.log("Register tapped");
        // Now here use Navigator function
        if (inLoginPage) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUpPage(),
              ));
        }
        else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
        }
      },
      // This widget allows you to style text with different styles in a single Text widget.
      //It is used here to combine multiple styles within one piece of text.
      child: RichText(
        text: TextSpan(
          // This class is used to apply styles to portions of text. Each TextSpan can have its own TextStyle.
          children: [
            TextSpan(
              text: message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: registerOrLogin,
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
