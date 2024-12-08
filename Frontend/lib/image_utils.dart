// image_utils.dart
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// A utility class for image picking and uploading logic
class ImageUtils {
  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        return File(pickedImage.path); // Return picked image as File
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null; // Return null if no image picked or an error occurred
  }

  // Upload image to server for prediction
  static Future<String?> uploadImageForPrediction(File image) async {
    String base64Image = base64Encode(image.readAsBytesSync());
    developer.log(
        'Base64 image size: ${base64Image.length} characters'); // Debugging line

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
      if (response.statusCode == 200) {
        var resBody = json.decode(response.body);
        return resBody['crop']; // Return predicted crop result
      } else {
        print('Error: ${response.body}'); // Debugging line
        return 'Error: Could not predict the crop.'; // Return error message
      }
    } catch (e) {
      print("Error uploading image: $e");
      return 'Error: Could not upload image.'; // Return error message
    }
  }
}
