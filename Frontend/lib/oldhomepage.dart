import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_page/login.dart';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final bool isPhoneRegistration;
  const HomePage({super.key, required this.isPhoneRegistration});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  String profileImageUrl = '';
  bool isLoading = true; // Loading state
  File? _image;
  String? _prediction;
  String? _serverIp;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          print('Image selected: ${_image!.path}'); // Debugging line
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadImage() async {
    // final serverIp = dotenv.env['SERVER_IP'];
    if (_image == null) {
      print('No image to upload'); // Debugging line
      return;
    }

    // Convert image to Base64
    String base64Image = base64Encode(_image!.readAsBytesSync());
    developer.log('Base64 image size: ${base64Image} characters'); // Debugging line

    // Prepare the request payload
    var response = await http.post(
      Uri.parse('http://192.168.184.30:3001/predict'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image': base64Image,
      }),
    );

    // Handle the response
    print('Response status: ${response.statusCode}'); // Debugging line
    if (response.statusCode == 200) {
      var resBody = json.decode(response.body);
      setState(() {
        _prediction = resBody['crop'];
        print('Prediction received: $_prediction'); // Debugging line
      });
    } else {
      print('Error: ${response.body}'); // Debugging line
      setState(() {
        _prediction = 'Error: Could not predict the crop.';
      });
    }
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        String documentId = widget.isPhoneRegistration ? email.substring(0, 10) : email;

        // Fetch data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(documentId)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['Username'] ?? 'Unknown User'; // Fallback to 'Unknown User'
            profileImageUrl = userDoc['Image'] ?? ''; // Fallback to empty string
            isLoading = false; // Data is loaded, stop loading indicator
          });
        } else {
          developer.log('User document not found');
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : Stack(
              children: [
                // Profile, Username, and Dropdown in top right corner
                Positioned(
                  top: 50,
                  right: 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Make the Row only take the required space
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : const AssetImage('assets/images/default_avatar.png')
                                as ImageProvider, // Fallback to default avatar
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          username.isNotEmpty ? username : 'Loading...',
                          overflow: TextOverflow.ellipsis, // Handle long usernames
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (String? newValue) {
                            switch (newValue) {
                              case "profile":
                                // Handle profile navigation
                                break;
                              case "settings":
                                // Handle settings navigation
                                break;
                              case "signout":
                                logOut(); // Call logOut method
                                break;
                            }
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: "profile",
                              child: Row(
                                children: const [
                                  Icon(Icons.person),
                                  SizedBox(width: 8),
                                  Text("Profile"),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: "settings",
                              child: Row(
                                children: const [
                                  Icon(Icons.settings),
                                  SizedBox(width: 8),
                                  Text("Settings"),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: "signout",
                              child: Row(
                                children: const [
                                  Icon(Icons.logout),
                                  SizedBox(width: 8),
                                  Text("Sign Out"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Welcome Text, Image, and Buttons in Center
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome to the Homepage!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _image == null
                          ? const Text('No image selected.')
                          : Image.file(
                              _image!,
                              height: 200,
                              width: 200,
                            ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Select Image from Gallery'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _uploadImage,
                        child: const Text('Upload and Predict'),
                      ),
                      const SizedBox(height: 16),
                      _prediction == null
                          ? const Text('Prediction will appear here.')
                          : Text(
                              'Predicted crop: $_prediction',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
