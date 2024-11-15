import 'package:flutter/material.dart';


class PharmacyDashboardPage extends StatefulWidget {
  const PharmacyDashboardPage({super.key, required  this.title});

  final String title;

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
              const Text(
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
              const SizedBox(height: 5),
              
            ],
          ),

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
