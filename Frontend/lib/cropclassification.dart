import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CropClassificationPage extends StatefulWidget {
  const CropClassificationPage({super.key});

  @override
  State<CropClassificationPage> createState() => _CropClassificationPageState();
}

class _CropClassificationPageState extends State<CropClassificationPage> {
  File? _image; // Variable to hold the picked image
  String? _prediction; // To hold the prediction result

  // Pick Image from the gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path); // Update _image state
          print('Image selected: ${_image!.path}'); // Debugging line
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Upload Image to the server for prediction
  Future<void> _uploadImage() async {
    if (_image == null) {
      print('No image to upload'); // Debugging line
      return;
    }

    // Convert image to Base64
    String base64Image = base64Encode(_image!.readAsBytesSync());
    developer.log('Base64 image size: ${base64Image.length} characters'); // Debugging line

    // Prepare the request payload
    try {
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
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        _prediction = 'Error uploading image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Classification'),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/crop3.jpg'), // Replace with your image path
                fit: BoxFit.cover, // Make the image cover the entire background
              ),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Center items vertically
              children: [
                ElevatedButton(
                  onPressed: _pickImage, // Trigger the image picker
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ), // Button size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded edges
                    ),
                  ),
                  child: const Text(
                    'Pick Image',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20), // Space between the buttons

                // If image is picked, display it
                if (_image != null)
                  Image.file(
                    _image!, // Display the selected image
                    height: 200, // Adjust the image size
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 20), // Space between the image and the button

                ElevatedButton(
                  onPressed: () {
                    // Check if an image is selected and proceed to upload & predict
                    if (_image != null) {
                      _uploadImage(); // Call upload and prediction method
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please pick an image first!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Upload & Predict',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20), // Space between the buttons

                // Display prediction result
                if (_prediction != null)
                  Text(
                    'Prediction: $_prediction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
