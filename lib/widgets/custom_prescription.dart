// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
// import 'package:gradient_borders/gradient_borders.dart';
import './custom_ticket_card.dart';

class PrescriptionCard extends StatefulWidget {
  const PrescriptionCard({
    super.key,
    required this.drugName,
    required this.drugInfo,
    required this.description,
  });

  final double borderRadiussSize = 10;
  final String drugName;
  final String drugInfo;
  final String description;

  @override
  State<PrescriptionCard> createState() => _CurrentPrescription();
}

class _CurrentPrescription extends State<PrescriptionCard> {
  @override
  Widget build(BuildContext context) {
    return TicketWidget(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Icon
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFE0BBE4), // Background color
              borderRadius: BorderRadius.circular(
                  widget.borderRadiussSize), // Rounded edges
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
            widget.drugName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF602E9E),
            ),
          ),
          SizedBox(height: 5),
          // Drug Type and Dosage
          Text(
            widget.drugInfo,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 5),
          // Short Description
          Text(
            widget.description,
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
                  borderRadius: BorderRadius.circular(widget.borderRadiussSize),
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
    );
  }
}
