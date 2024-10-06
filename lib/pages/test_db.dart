// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:resetaplus/widgets/custom_progressbar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required String title});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // TOP PART WITH GRADIENT
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffa16ae8), 
                    Color(0xff94b9ff),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // APP BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // NAME
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Jane Doe',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          ],
                        ),
                        // PROFILE PICTURE ICON
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white, // Change to white for better contrast
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xffa16ae8), // Change icon color for contrast
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 25), // space before the card

                  // CARD - MEDICATION PROGRESS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      // Outer container with gradient border
                      decoration: BoxDecoration(
                        border: GradientBoxBorder(
                          width: 2,
                          gradient: LinearGradient(colors: [
                            Color(0xffa16ae8), 
                            Color(0xff94b9ff),
                          ]),
                        ),
                        borderRadius: BorderRadius.circular(12), // Rounded corner
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20), // Inner container padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        
                        child: Row(
                          children: [
                            // TITLE - MEDICATION PROGRESS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text( 
                                    'Medication Progress',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF602E9E),
                                    ),
                                  ),

                                  SizedBox(height: 10), // space between title and progress bar
                                  
                                  CustomProgressBar(
                                    value: 0.6, // 60% percent
                                    backgroundColor: Color(0xFFD9D9FF),
                                    gradientColors: [
                                      Color(0xffa16ae8), 
                                      Color(0xff94b9ff)],
                                    height: 20.0,
                                    borderRadius: BorderRadius.circular(10),
                                    text: '2 Weeks Left', // replace with dynamic text if needed
                                  ),
                                
                                  SizedBox(height: 10), // space between progress bar and week
                                  
                                  Text(
                                    'Your next medicine intake is at: ',
                                    style: TextStyle(
                                      fontSize: 14
                                    ),
                                  ),

                                  Text(
                                    '13:00',
                                    style: TextStyle(
                                      fontSize: 54,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFA16AE8),
                                    ),
                                  ),

                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA16AE8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'INTAKE HISTORY',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ), // END OF MEDICATION PROGRESS
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25), // space after card

            // TITLE - CURRENT PRESCRIPTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Prescriptions',
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
            ),

            // CARD - CURRENT PRESCRIPTIONS

          ], // children
        ),
      ),
    );
  } // widget 
} // class 
