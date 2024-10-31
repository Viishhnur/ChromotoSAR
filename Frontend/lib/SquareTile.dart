import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  SquareTile({required this.onTap, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Simplified the onTap callback
      child: Container(
        width: 50, // You can adjust the size as needed
        height: 50, // Keeping the width and height equal for a square shape
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imageUrl), // Changed to AssetImage for local assets
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}
