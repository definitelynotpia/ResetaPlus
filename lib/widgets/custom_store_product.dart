// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

// rennamed from custom_currentprescription.dart
class StoreProduct extends StatelessWidget {
  const StoreProduct({Key? key}) : super(key: key);

  final double borderRadiussSize = 10;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // First Card
        Expanded(
          child: buildPrescriptionCard('Drug Name 1',
              'Type: Tablet, Dosage: 500mg', 'A short description of Drug 1.'),
        ),
        SizedBox(width: 10), // Space between cards
        // Second Card
        Expanded(
          child: buildPrescriptionCard(
              'Drug Name 2',
              'Type: Injection, Dosage: 250ml',
              'A short description of Drug 2.'),
        ),
      ],
    );
  }

  Widget buildPrescriptionCard(
      String drugName, String drugInfo, String description) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: GradientBoxBorder(
          width: 1,
          gradient: LinearGradient(colors: [
            Color.fromRGBO(195, 150, 255, 1),
            Color(0xFF86B0FF),
          ]),
        ),
        borderRadius: BorderRadius.circular(borderRadiussSize),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Icon
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFFE0BBE4), // Background color
                borderRadius:
                    BorderRadius.circular(borderRadiussSize), // Rounded edges
              ),
              child: Center(
                child: Icon(
                  Icons.local_pharmacy,
                  size: 50,
                  color: Colors.white, // Icon color
                ),
              ),
            ),
            SizedBox(height: 10),
            // Drug Name
            Text(
              drugName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF602E9E),
              ),
            ),
            SizedBox(height: 5),
            // Drug Type and Dosage
            Text(
              drugInfo,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 5),
            // Short Description
            Text(
              description,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            // QR Code Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Add functionality to get QR code
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA16AE8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadiussSize),
                  ),
                ),
                child: Text(
                  'Get QR Code',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
