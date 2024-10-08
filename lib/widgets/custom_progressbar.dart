// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double value;
  final Color backgroundColor;
  final List<Color> gradientColors;
  final double height;
  final BorderRadius borderRadius;
  final String text; // New parameter for text

  const CustomProgressBar({
    Key? key,
    required this.value,
    this.backgroundColor = Colors.white,
    required this.gradientColors, // Required gradient color list
    this.height = 8.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    required this.text, // Required text
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius, // Rounded corners
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value, // Progress value
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // Text Indicator
              Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
