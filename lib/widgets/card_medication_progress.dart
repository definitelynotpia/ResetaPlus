// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'custom_progressbar.dart'; // Make sure to import your CustomProgressBar widget

class CardMedicationProgress extends StatelessWidget {
  final Color backgroundColor;
  final List<Color> borderColors;
  final String imageUrl; // Image URL
  final double progress; // Progress value (0.0 to 1.0)

  const CardMedicationProgress({
    Key? key,
    required this.backgroundColor,
    required this.borderColors,
    required this.imageUrl,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        // Outer container with gradient border
        decoration: BoxDecoration(
          border: GradientBoxBorder(
            width: 2,
            gradient: LinearGradient(colors: borderColors),
          ),
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Container(
          padding: EdgeInsets.all(20), // Inner container padding
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 100, // Adjust height as needed
                  width: double.infinity, // Full width
                ),
              ),
              SizedBox(height: 10), // Space between image and progress bar
              
              // Progress Bar
              CustomProgressBar(
                value: progress, // Pass the progress value (0.0 to 1.0)
                backgroundColor: Colors.grey[300]!, // Background color of the progress bar
                gradientColors: borderColors, // Use border colors for the progress bar
                height: 20.0,
                borderRadius: BorderRadius.circular(10), 
                text: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
