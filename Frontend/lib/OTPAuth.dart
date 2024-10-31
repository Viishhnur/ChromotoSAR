import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomePage(),
//     );
//   }
// }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _response = "No data yet";
  final String mobileNumber = "918341827894"; // Example mobile number

  Future<void> fetchData() async {
    try {
      // Prepare the data to send
      final Map<String, String> data = {'mobile': mobileNumber};

      // Make the POST request
      final response = await http.post(
        Uri.parse('http://192.168.29.20:3000'), // Use '10.0.2.2' for Android emulator
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        setState(() {
          _response = response.body; // Handle the response
        });
      } else {
        setState(() {
          _response = "Failed to load data: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter HTTP Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: fetchData,
              child: Text('Fetch Data'),
            ),
            SizedBox(height: 20),
            Text(
              _response,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
