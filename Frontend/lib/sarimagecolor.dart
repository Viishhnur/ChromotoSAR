import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SARImageColorizationPage extends StatefulWidget {
  const SARImageColorizationPage({super.key});

  @override
  State<SARImageColorizationPage> createState() => _SARImageColorizationPageState();
}

class _SARImageColorizationPageState extends State<SARImageColorizationPage> {
  File? _selectedImage;
  String? _colorizedImage;

  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _colorizedImage = null; // Clear previous result
      });
    }
  }

  // Send image to backend for colorization
  Future<void> _predictImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return;
    }

    final bytes = await _selectedImage!.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.255.30:3001/colorize'),  // Update the IP address to your server
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _colorizedImage = responseData['colorizedImage'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to colorize image')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAR Image Colorization'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sar2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: const Text('Upload Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _predictImage,
                  child: const Text('Predict'),
                ),
                const SizedBox(height: 20),
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                if (_colorizedImage != null)
                  Column(
                    children: [
                      const Text(
                        'Colorized Image:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Image.memory(
                        base64Decode(_colorizedImage!),
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
