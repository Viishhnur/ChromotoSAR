import 'package:flutter/material.dart';

class DisasterManagementPage extends StatefulWidget {
  const DisasterManagementPage({super.key});

  @override
  State<DisasterManagementPage> createState() => _DisasterManagementPageState();
}

class _DisasterManagementPageState extends State<DisasterManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Management'),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/disaster.jpg'), // Replace with your image path
                fit: BoxFit.fill, // Make the image cover the entire background
              ),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Center items vertically
              children: [
                ElevatedButton(
                  onPressed: () {
                    _uploadImage();
                  },
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
                    'Upload Image',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20), // Space between the buttons
                ElevatedButton(
                  onPressed: () {
                    _predictImage();
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
                    'Predict',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder for upload image functionality
  void _uploadImage() {
    // Add your logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload image button clicked')),
    );
  }

  // Placeholder for predict functionality
  void _predictImage() {
    // Add your logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Predict button clicked')),
    );
  }
}
