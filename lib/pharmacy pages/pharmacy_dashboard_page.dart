// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:math';
import '../widgets/display_qr_code.dart';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';
import 'package:resetaplus/main.dart';

import 'package:resetaplus/widgets/custom_prescription.dart';
import 'package:resetaplus/widgets/prescription_popup.dart';
//import 'package:resetaplus/widgets/card_medication_progress.dart';

class PharmacyDashboardPage extends StatefulWidget {
  const PharmacyDashboardPage({super.key, required String title});

  @override
  State<PharmacyDashboardPage> createState() => _PharmacyDashboardPageState();
}

class _PharmacyDashboardPageState extends State<PharmacyDashboardPage> {
  // Current date for reference
  final DateTime _currentDate = DateTime.now();
  // Sample patient ID for testing

  final int _pharmacyIDTest = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Wrap content with SingleChildScrollView for scrolling
      child: Column(
        children: [
          // TITLE - CURRENT PRESCRIPTIONS
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Patients',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF602E9E),
                ),
              ),
              Divider(
                thickness: 3,
                color: Colors.grey[300]!,
              ),
              SizedBox(height: 5),
            ],
          ),

          // ROW FOR CURRENT PRESCRIPTIONS - USING WIDGET
          // Column(
          //   children: (_currentPrescriptions?.map((prescription) {
          //         return PrescriptionCard(
          //           drugName: prescription['drugName'] ??
          //               "Unknown Drug", // Provide a default value if null
          //           drugInfo: prescription['drugInfo'] ??
          //               "No Info Available", // Provide a default value if null
          //           description: prescription['description'] ??
          //               "No Description Available", // Provide a default value if null
          //         );
          //       }).toList() ??
          //       []), // Fallback to an empty list if _currentPrescriptions is null
          // ),
          ElevatedButton(
              onPressed: () {
                // Change the number based on the prescription 
                // that you want the QR code from
                // displayQRCode(context, 1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffa16ae8), // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
              child: const Text(
                "Show QR Code", // Button text
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }
}
