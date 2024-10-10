// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:resetaplus/widgets/custom_progressbar.dart';
import 'package:resetaplus/widgets/custom_currentprescription.dart';
//import 'package:resetaplus/widgets/card_medication_progress.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required String title});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Wrap content with SingleChildScrollView for scrolling
      child: Column(
        children: [
          // CARD - MEDICATION PROGRESS
          Container(
            // Outer container with gradient border
            decoration: BoxDecoration(
              border: GradientBoxBorder(
                width: 2,
                gradient: LinearGradient(colors: [
                  Color(0xffa16ae8),
                  Color(0xff94b9ff),
                ]),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE - MEDICATION PROGRESS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Sign up question prompt
                      const Text(
                        "MEDICATION PROGRESS",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF602E9E),
                        ),
                      ),
                      // Sign Up button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          // go to Sign Up form script
                          onTap: () {
                            // TODO: choose month from history
                          },
                          child: const Text(
                            "January",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF602E9E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // spacer
                  SizedBox(height: 10),

                  // Prescription progress bar
                  CustomProgressBar(
                    value: 0.6,
                    backgroundColor: Color(0xFFD9D9FF),
                    gradientColors: [Color(0xffa16ae8), Color(0xff94b9ff)],
                    height: 40,
                    borderRadius: BorderRadius.circular(15),
                    text: '2 Weeks Left',
                  ),

                  // spacer
                  SizedBox(height: 10),

                  // weekday carousel
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 75),
                    child: CarouselView(
                      itemExtent: 100,
                      shrinkExtent: 50,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      children: List<Widget>.generate(31, (int index) {
                        return ColoredBox(
                          color: Colors
                              .primaries[index % Colors.primaries.length]
                              .withOpacity(0.8),
                          child: const SizedBox.expand(),
                        );
                      }),
                    ),
                  ),

                  // spacer
                  SizedBox(height: 5),

                  // next intake alarm
                  Text(
                    'Your next medicine intake is at: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

                  // BUTTONS - INTAKE HISTORY AND INTAKE INSTRUCTIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA16AE8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'INTAKE HISTORY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA16AE8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'INTAKE INSTRUCTIONS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 25),

          // TITLE - CURRENT PRESCRIPTIONS
          Column(
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

          // ROW FOR CURRENT PRESCRIPTIONS - USING WIDGET
          Column(
            children: [
              CurrentPrescription(),
              CurrentPrescription(),
              CurrentPrescription(),
            ],
          ),
        ],
      ),
    );
  }
}
