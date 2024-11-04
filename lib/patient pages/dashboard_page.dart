// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:resetaplus/main.dart';

import 'package:resetaplus/widgets/custom_progressbar.dart';
import 'package:resetaplus/widgets/custom_prescription.dart';
import 'package:resetaplus/widgets/intake_history_popup.dart';
import 'package:resetaplus/widgets/intake_instuctions_popup.dart';
//import 'package:resetaplus/widgets/card_medication_progress.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required String title});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Current date for reference
  final DateTime _currentDate = DateTime.now();

  int? _patientID;

  // Variables to hold medication data
  num? _currentDay; // Current day progress
  num? _medicationDuration; // Duration of medication
  String? _nextIntakeTime; // Next intake time formatted as a string
  double? _currentProgress; // Current overall progress of medication
  List<Map<String, String>>?
      _currentPrescriptions; // Medicine information in the prescription

  @override
  void initState() {
    super.initState();
    // Call the async function to handle initialization
    _initialize(context);
  }

  // Initializes necessary data by fetching the patient ID first and then retrieving other related information
  Future<void> _initialize(BuildContext context) async {
    // Fetch the patient ID first
    await getPatientID(context);

    // Now that getPatientID has completed, call the other functions
    if (context.mounted) {
      await Future.wait([
        getNextMedicineIntake(context),
        getMedicationDayProgress(context),
        getMedicationOverallProgress(context),
        getCurrentPrescriptions(context),
      ]);
    }
  }

  // Function to get the patient ID number
  Future<void> getPatientID(BuildContext context) async {
    try {
      // Call getUserID with "patient" to retrieve the user ID for the patient
      int userID = await getUserID("patient");

      // Update the state with the retrieved patient ID
      setState(() {
        _patientID = userID;
      });
    } catch (e) {
      // Handle errors during data fetching
      debugPrint("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error fetching data. Please try again.")),
        );
      }
    }
  }

  // Function to get the information of the medication in the prescription
  Future<void> getCurrentPrescriptions(BuildContext context) async {
    try {
      final conn = await createConnection();

      // SQL query to fetch the information of the medication in the prescription
      var activePrescriptionMedicationInfo = await conn.execute('''
      SELECT 
          m.medication_name,
          m.medication_info,
          m.medication_description
      FROM 
          reseta_plus.patient_prescriptions p
      JOIN 
          reseta_plus.medications m ON p.medication_id = m.medication_id
      WHERE 
          p.patient_id = :patient_id
          AND p.status = 'active';
      ''', {'patient_id': _patientID});

      // Ensure activePrescriptionDetails is initialized as an empty list before this code
      List<Map<String, String>> activePrescriptionDetails = [];

      // Check if there are any rows returned
      if (activePrescriptionMedicationInfo.rows.isNotEmpty) {
        // Iterate through the result rows and map them to the desired structure
        for (var row in activePrescriptionMedicationInfo.rows) {
          var assoc = row.assoc();
          activePrescriptionDetails.add({
            'drugName': assoc['medication_name'] ?? '',
            'drugInfo': assoc['medication_info'] ?? '',
            'description': assoc['medication_description'] ?? '',
          });
        }
      }

      // Update the state with the prescription information
      setState(() {
        _currentPrescriptions = activePrescriptionDetails;
      });
    } catch (e) {
      // Handle errors during data fetching
      debugPrint("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error fetching data. Please try again.")),
        );
      }
    }
  }

  // Function to get the overall progress of medication
  Future<void> getMedicationOverallProgress(BuildContext context) async {
    try {
      final conn = await createConnection();

      // SQL query to fetch the duration of active prescriptions
      var activePrescriptionDuration = await conn.execute('''
      SELECT 
          duration 
      FROM 
          reseta_plus.patient_prescriptions 
      WHERE 
          patient_id = :patient_id 
          AND status = 'active';
      ''', {'patient_id': _patientID});

      // Extract the prescription duration from the result
      String? prescriptionDuration =
          activePrescriptionDuration.rows.first.assoc()['duration'];

      // Update the state with the calculated progress
      setState(() {
        _currentProgress = calculateOverallMedicationProgress(
            prescriptionDuration, _currentDay);
      });
    } catch (e) {
      // Handle errors during data fetching
      debugPrint("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error fetching data. Please try again.")),
        );
      }
    }
  }

  // Function to get today's medication progress
  Future<void> getMedicationDayProgress(BuildContext context) async {
    try {
      final conn = await createConnection();

      // SQL query to get the count of active prescription intakes for today
      var totalActivePrescriptionIntakes = await conn.execute('''
      SELECT 
          SUM(all_prescriptions_taken) AS total_all_prescriptions_taken
      FROM (
          SELECT 
              pi.intake_date,
              CASE 
                  WHEN COUNT(DISTINCT p.prescription_id) = COUNT(DISTINCT pi.prescription_id) 
                  THEN 1 
                  ELSE 0 
              END AS all_prescriptions_taken
        FROM 
            reseta_plus.patient_prescriptions p
        LEFT JOIN 
            reseta_plus.patient_prescription_intakes pi ON p.prescription_id = pi.prescription_id
        WHERE 
            p.patient_id = :patient_id
            AND p.status = 'active'
        GROUP BY 
            pi.intake_date
      ) AS subquery;
      ''', {'patient_id': _patientID});

      // Parse the total count of prescriptions taken
      num? totalCount = num.tryParse(totalActivePrescriptionIntakes.rows.first
          .assoc()['total_all_prescriptions_taken']!);

      // Update the state with the total count of prescriptions taken
      setState(() {
        _currentDay = totalCount;
      });
    } catch (e) {
      // Handle errors during data fetching
      debugPrint("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error fetching data. Please try again.")),
        );
      }
    }
  }

  // Function to get the next medicine intake time
  Future<void> getNextMedicineIntake(BuildContext context) async {
    try {
      final conn = await createConnection();

      // SQL query to get the next intake time for active prescriptions
      var patientPrescriptionIntakeData = await conn.execute('''
      SELECT 
          p.frequency,
          pi.intake_time
      FROM 
          reseta_plus.patient_prescriptions p
      JOIN 
          reseta_plus.patient_prescription_intakes pi ON p.prescription_id = pi.prescription_id
      WHERE 
          p.patient_id = :patient_id
          AND p.status = 'active';
      ''', {'patient_id': _patientID});

      DateTime? nextIntakeDateTime; // Variable to hold the next intake time

      // Check if there are any intake records
      if (patientPrescriptionIntakeData.rows.isNotEmpty) {
        for (var intakeRow in patientPrescriptionIntakeData.rows) {
          // Get intake time as a string
          String? intakeTimeStr = intakeRow.assoc()['intake_time'];

          // Parse intake time to DateTime
          DateTime intakeTime = parseTime(intakeTimeStr!);

          // Get frequency
          String? frequencyStr = intakeRow.assoc()['frequency'];

          // Calculate the next intake time
          DateTime nextTime = calculateNextIntake(intakeTime, frequencyStr!);

          // Update the next intake time if it's the earliest found
          if (nextIntakeDateTime == null ||
              nextTime.isBefore(nextIntakeDateTime)) {
            nextIntakeDateTime = nextTime;
          }
        }
      }

      await conn.close();

      // Format the next intake time
      if (nextIntakeDateTime != null) {
        String formattedTime = DateFormat('hh:mm a').format(nextIntakeDateTime);

        // Update the state with the next intake time
        setState(() {
          _nextIntakeTime = formattedTime;
        });
      }
    } catch (e) {
      // Handle errors during data fetching
      debugPrint("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error fetching data. Please try again.")),
        );
      }
    }
  }

  // Function to parse a time string into a DateTime object
  DateTime parseTime(String timeStr) {
    DateFormat format = DateFormat("HH:mm:ss");
    DateTime time = format.parse(timeStr);
    return DateTime.now()
        .copyWith(hour: time.hour, minute: time.minute, second: 0);
  }

  // Function to calculate the next intake time based on last intake and frequency
  DateTime calculateNextIntake(DateTime lastIntake, String frequencyStr) {
    // Split frequency string to get value and unit (e.g., "8 hours")
    final parts = frequencyStr.split(' ');

    // Extract the frequency value
    int frequencyValue = int.parse(parts[0]);

    // Extract the frequency unit
    String frequencyUnit = parts[1];

    Duration duration;
    // Determine duration based on frequency unit
    if (frequencyUnit.contains("hour")) {
      duration = Duration(hours: frequencyValue);
    } else if (frequencyUnit.contains("minute")) {
      duration = Duration(minutes: frequencyValue);
    } else {
      duration = Duration(hours: 1); // Default to 1 hour if not recognized
    }

    return lastIntake.add(duration);
  }

  // Function to calculate overall medication progress
  double calculateOverallMedicationProgress(String? duration, num? currentDay) {
    // Check if duration is null or currentDay is null
    if (duration == null || currentDay == null) {
      return 0.0;
    }

    // Split duration string to extract value
    final parts = duration.split(' ');

    // Parse the duration value
    num durationValue = num.parse(parts[0]);

    // Update the state with the medication duration
    setState(() {
      _medicationDuration = durationValue;
    });

    // Avoid division by zero
    if (durationValue == 0) {
      return 0.0;
    }

    return (currentDay / durationValue);
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
                    value: (_currentProgress ?? 0),
                    backgroundColor: Color(0xFFD9D9FF),
                    gradientColors: [Color(0xffa16ae8), Color(0xff94b9ff)],
                    height: 40,
                    borderRadius: BorderRadius.circular(15),
                    text:
                        '${max((_medicationDuration ?? 0) - (_currentDay ?? 0), 0)} days Left',
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
                          decoration: (index >= (_currentDay ?? 0))
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
                            child: Text("${index + 1}"),
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
                      initialPage: (_currentDay ?? 0).toInt(),
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return IntakeHistoryPopup(
                                    patientID: _patientID ?? 0);
                              },
                            );
                          },
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
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return IntakeInstructionsPopup(
                                    patientID: _patientID ?? 0);
                              },
                            );
                          },
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
            children: (_currentPrescriptions?.map((prescription) {
                  return PrescriptionCard(
                    drugName: prescription['drugName'] ??
                        "Unknown Drug", // Provide a default value if null
                    drugInfo: prescription['drugInfo'] ??
                        "No Info Available", // Provide a default value if null
                    description: prescription['description'] ??
                        "No Description Available", // Provide a default value if null
                  );
                }).toList() ??
                []), // Fallback to an empty list if _currentPrescriptions is null
          ),
        ],
      ),
    );
  }
}
