// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class CurrentPrescription extends StatelessWidget {
  const CurrentPrescription({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // First Card
        Expanded(
          child: buildPrescriptionCard('Drug Name 1', 'Type: Tablet, Dosage: 500mg', 'A short description of Drug 1.'),
        ),
        SizedBox(width: 10), // Space between cards
        // Second Card
        Expanded(
          child: buildPrescriptionCard('Drug Name 2', 'Type: Injection, Dosage: 250ml', 'A short description of Drug 2.'),
        ),
      ],
    );
  }

  Widget buildPrescriptionCard(String drugName, String drugInfo, String description) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: GradientBoxBorder(
          width: 2,
          gradient: LinearGradient(colors: [
            Color(0xffa16ae8),
            Color(0xff94b9ff),
          ]),
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Icon
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFFE0BBE4), // Background color
                borderRadius: BorderRadius.circular(12), // Rounded edges
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
                    borderRadius: BorderRadius.circular(8),
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
