// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:resetaplus/main.dart';

import 'package:resetaplus/widgets/custom_progressbar.dart';
import 'package:resetaplus/widgets/custom_prescription.dart';
//import 'package:resetaplus/widgets/card_medication_progress.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required String title});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // current day
  final DateTime _currentDate = DateTime.now();
  final int _currentDay = 15;
  final int _patientIDTest = 1;
  String? _nextIntakeTime;

  @override
  void initState() {
    super.initState();
    // Fetch the prescription data when the widget is initialized
    getNextMedicineIntake();
  }

  Future<void> getMedicationProgress() async {
    
  }

  Future<void> getNextMedicineIntake() async {
    try {
      final conn = await createConnection();

      var patientPrescriptionIntakeData = await conn.execute('''
      SELECT 
          p.prescription_id,
          pi.prescription_intake_id,
          p.frequency,
          pi.intake_date,
          pi.intake_time,
          pi.status
      FROM 
          reseta_plus.patient_prescriptions p
      JOIN 
          reseta_plus.patient_prescription_intakes pi ON p.prescription_id = pi.prescription_id
      WHERE 
          p.patient_id = :patient_id
          AND p.status = 'active';
      ''',{'patient_id': _patientIDTest});

      DateTime? nextIntakeDateTime;

      if (patientPrescriptionIntakeData.rows.isNotEmpty) {
        for (var intakeRow in patientPrescriptionIntakeData.rows) {
          String? intakeTimeStr = intakeRow.assoc()['intake_time'];
          DateTime intakeTime = _parseTime(intakeTimeStr!);
          String? frequencyStr = intakeRow.assoc()['frequency'];
          DateTime nextTime = _calculateNextIntake(intakeTime, frequencyStr!);

          if (nextIntakeDateTime == null || nextTime.isBefore(nextIntakeDateTime)) {
            nextIntakeDateTime = nextTime;
          }
        }
      }

      await conn.close();
      // Format the next intake time
      if (nextIntakeDateTime != null) {
        String formattedTime = DateFormat('hh:mm a').format(nextIntakeDateTime);
        setState(() {
          _nextIntakeTime = formattedTime;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching data. Please try again.")),
        );
      }
    }
  }

  DateTime _parseTime(String timeStr) {
    // Parse the time string (e.g., "5:09 PM") into a DateTime object
    DateFormat format = DateFormat("HH:mm:ss");
    DateTime time = format.parse(timeStr);
    return DateTime.now().copyWith(hour: time.hour, minute: time.minute, second: 0);
  }

  DateTime _calculateNextIntake(DateTime lastIntake, String frequencyStr) {
    // Extract frequency (e.g., "8 hours")
    final parts = frequencyStr.split(' ');
    int frequencyValue = int.parse(parts[0]);
    String frequencyUnit = parts[1];

    Duration duration;
    if (frequencyUnit.contains("hour")) {
      duration = Duration(hours: frequencyValue);
    } else if (frequencyUnit.contains("minute")) {
      duration = Duration(minutes: frequencyValue);
    } else {
      duration = Duration(hours: 1); // Default to 1 hour if not recognized
    }

    return lastIntake.add(duration);
  }
  
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
                          child: Text(
                            DateFormat('MMMM').format(_currentDate),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                    _nextIntakeTime ?? 'Loading...',
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
