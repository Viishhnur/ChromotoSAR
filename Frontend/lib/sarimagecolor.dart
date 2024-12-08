import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/space_live.dart';

class SARImageColorizationPage extends StatefulWidget {
  const SARImageColorizationPage({super.key});

  @override
  State<SARImageColorizationPage> createState() =>
      _SARImageColorizationPageState();
}

class _SARImageColorizationPageState extends State<SARImageColorizationPage> {
  File? _selectedImage;
  String? _colorizedImage;
  bool _showGroundTruth = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _colorizedImage = null;
        _showGroundTruth = false;
      });
    }
  }

  Future<void> _predictImage() async {
    if (_selectedImage == null) {
      _showSnackBar('No grayscale image selected');
      return;
    }

    final base64Image = base64Encode(await _selectedImage!.readAsBytes());

    try {
      final response = await http.post(
        Uri.parse('http://192.168.107.201:3001/colorize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _colorizedImage = responseData['colorizedImage'];
          _showGroundTruth = true;
        });
      } else {
        _showSnackBar('Failed to colorize image');
      }
    } catch (error) {
      _showSnackBar('Error: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SAR Image Colorization')),
      body: Stack(
        children: [
          const LiveBackground(),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                if (_selectedImage != null)
                  _buildImagePreview('Urban Grayscale Image', _selectedImage!),
                const SizedBox(height: 20),
                if (_showGroundTruth)
                  _buildImagePreview('Ground Truth Image',
                      File('assets/images/urban_ground_color.png'),
                      isAsset: true),
                const SizedBox(height: 20),
                if (_colorizedImage != null)
                  _buildImageFromBase64('Colorized Image', _colorizedImage!),
                const SizedBox(height: 30),
                _buildButtonRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String title, File image, {bool isAsset = false}) {
    return Column(
      children: [
        Text(
          '$title:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))
            ],
          ),
        ),
        const SizedBox(height: 10),
        isAsset
            ? Image.asset(
                image.path,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            : Image.file(
                image,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
      ],
    );
  }

  Widget _buildImageFromBase64(String title, String base64Image) {
    return Column(
      children: [
        Text(
          '$title:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))
            ],
          ),
        ),
        const SizedBox(height: 10),
        Image.memory(
          base64Decode(base64Image),
          height: 200,
          width: 200,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOutlinedButton(
            'Upload Grayscale', Colors.redAccent, _uploadImage),
        const SizedBox(width: 20),
        _buildOutlinedButton('Colorize', Colors.blueAccent, _predictImage),
      ],
    );
  }

  Widget _buildOutlinedButton(
      String text, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
