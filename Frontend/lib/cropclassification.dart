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
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);

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

  // void loadENV() async {
  //   try {
  //     await dotenv.load(
  //         fileName:
  //             "/home/viishhnu/Backup/SEM-5/Flutter login page/Remote sensing/Frontend/.env");

  //   } catch (err) {
  //     developer.log('Error:  $err');
  //   }
  // }

  // Upload Image to the server for prediction
  Future<void> _uploadImage() async {
    if (_image == null) {
      print('No image to upload'); // Debugging line
      return;
    }

    // Convert image to Base64
    String base64Image = base64Encode(_image!.readAsBytesSync());
    developer.log(
        'Base64 image size: ${base64Image.length} characters'); // Debugging line
    // loadENV();
    // await dotenv.load(fileName: "/home/viishhnu/Backup/SEM-5/Flutter login page/Remote sensing/Backend/.env");
    // String serverIp = dotenv.env['SERVER_IP'] ?? '192.168.29.67';
    // String? port = dotenv.env['PORT'];
    // Prepare the request payload
    try {
      var response = await http.post(
        Uri.parse('http://192.168.107.201:3001/predict'),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to the Crop Classification Page!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _image == null
                    ? const Text('No image selected.')
                    : Image.file(
                        _image!,
                        height: 300,
                        width: 300,
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
