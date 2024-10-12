// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:resetaplus/widgets/custom_progressbar.dart';
import 'package:resetaplus/widgets/custom_store_product.dart';
import 'package:resetaplus/widgets/custom_prescription.dart';
//import 'package:resetaplus/widgets/card_medication_progress.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required String title});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // current day
  final int _currentDay = 15;

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
                            // TODO: opens a Calendar widget that allows user to view
                            // their previous and upcoming medication schedule
                            // this will change the Weekday Carousel
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

                  // date pointer
                  Container(
                    transform: Matrix4.translationValues(0, 10, 0),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 30,
                    ),
                  ),

                  // weekday carousel
                  CarouselSlider(
                    // displays the days in a month
                    items: List<Widget>.generate(31, (int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Container(
                          // card is filled if day has passed
                          // (indicating medications have been taken successfully)
                          decoration: (index >= _currentDay)
                              // if date is not yet finished
                              ? BoxDecoration(
                                  border: GradientBoxBorder(
                                    width: 1,
                                    gradient: LinearGradient(colors: [
                                      Color.fromRGBO(195, 150, 255, 1),
                                      Color(0xFF86B0FF),
                                    ]),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                )
                              // if date has passed
                              : BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromRGBO(195, 150, 255, 1),
                                      Color(0xFF86B0FF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                          child: Center(
                            child: Text("$index"),
                          ),
                        ),
                      );
                    }),
                    options: CarouselOptions(
                      height: 60,
                      aspectRatio: 1 / 1,
                      // TODO: set minimum width (so it's not too small)
                      viewportFraction: 0.2,
                      // TODO: initialPage must be set to current date (ex. 5 if December 5)
                      initialPage: 15,
                      enableInfiniteScroll: false,
                      reverse: false,
                      autoPlay: false,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.25,
                      // onPageChanged: callbackFunction,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),

                  // spacer
                  SizedBox(height: 15),

                  // next intake alarm
                  Text(
                    'Your next medicine intake is at: ',
                    style: TextStyle(
                      fontSize: 14,
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
              PrescriptionCard(
                  drugName: "drugName",
                  drugInfo: "drugInfo",
                  description: "description"),
              PrescriptionCard(
                  drugName: "drugName",
                  drugInfo: "drugInfo",
                  description: "description"),
              PrescriptionCard(
                  drugName: "drugName",
                  drugInfo: "drugInfo",
                  description: "description"),
              PrescriptionCard(
                  drugName: "drugName",
                  drugInfo: "drugInfo",
                  description: "description"),
            ],
          ),
        ],
      ),
    );
  }
}
