// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:math';
import '../widgets/display_qr_code.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';
import 'package:resetaplus/services/connection_service.dart';

import 'package:resetaplus/widgets/custom_progressbar.dart';
import 'package:resetaplus/widgets/intake_history_popup.dart';
import 'package:resetaplus/widgets/intake_instuctions_popup.dart';
import 'package:resetaplus/widgets/prescription_popup.dart';
//import 'package:resetaplus/widgets/card_medication_progress.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key, required this.title});

  final String title;

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  // Current date for reference
  final DateTime _currentDate = DateTime.now();

  int? _doctorID;

  // A list to store medication progress data for active patients
  List<Map<String, dynamic>>? _activePatientMedicationProgressData;

  @override
  void initState() {
    super.initState();
    // Fetch the prescription data when the widget is initialized
    _initialize(context);
  }

  // Initializes necessary data by fetching the doctor ID first and then retrieving other related information
  Future<void> _initialize(BuildContext context) async {
    // Fetch the doctor ID first
    await getDoctorID(context);

    // Now that getDoctorID has completed, call the other functions
    if (context.mounted) {
      await Future.wait([getActivePatientMedicationProgress(context)]);
    }
  }

  // Function to get the doctor ID number
  Future<void> getDoctorID(BuildContext context) async {
    try {
      // Call getUserID with "doctor" to retrieve the user ID for the doctor
      int userID = await getUserID("doctor");

      // Update the state with the retrieved doctor ID
      setState(() {
        _doctorID = userID;
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

  Future<void> getActivePatientMedicationProgress(BuildContext context) async {
    try {
      // Establish a connection to the database
      final conn = await createConnection();

      // Query to fetch distinct active patients along with their usernames
      var activePatients = await conn.execute('''
      SELECT DISTINCT pp.patient_id, pa.username
      FROM patient_prescriptions pp
      JOIN patient_accounts pa ON pp.patient_id = pa.patient_id
      WHERE pp.status = 'active' 
        AND pp.doctor_id = :doctor_id;
      ''', {'doctor_id': _doctorID});

      // Initialize a list to hold medication progress data
      List<Map<String, dynamic>>? activePatientMedicationProgressData = [];

      // Iterate over each row returned from the query
      for (var row in activePatients.rows) {
        var assoc = row.assoc();
        // Retrieve the patient_id as a string
        String? patientIdString = assoc['patient_id'];

        // Convert the string to an int with a default value
        int patientIdInt = patientIdString != null
            ? int.tryParse(patientIdString) ??
                0 // Default to 0 if parsing fails
            : 0; // Default to 0 if patientIdString is null

        // Get the duration of the patient's prescription
        num medicationDuration = context.mounted
            ? await getPrescriptionDuration(patientIdInt, context)
            : -1;

        // Get the current day of medication progress for the patient
        num? currentDay = context.mounted
            ? await getMedicationDayProgress(patientIdInt, context)
            : -1;

        // Get the next intake time for the patient's medication
        String nextIntakeTime = context.mounted
            ? await getNextMedicineIntake(patientIdInt, context)
            : "";

        // Calculate overall medication progress based on duration and current day
        double currentProgress =
            calculateOverallMedicationProgress(medicationDuration, currentDay);

        // Add the patient's progress data to the list
        activePatientMedicationProgressData.add({
          'patientID': assoc['patient_id'],
          'username': assoc['username'],
          'currentProgress': currentProgress,
          'medicationDuration': medicationDuration,
          'currentDay': currentDay,
          'nextIntakeTime': nextIntakeTime,
        });
      }

      // Update the state with the active patients' medication progress data
      setState(() {
        _activePatientMedicationProgressData =
            activePatientMedicationProgressData;
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
  Future<num> getPrescriptionDuration(
      int patientID, BuildContext context) async {
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
      ''', {'patient_id': patientID});

      // Check if there are any active prescriptions
      if (activePrescriptionDuration.rows.isNotEmpty) {
        // Split duration string to extract value
        final parts = activePrescriptionDuration.rows.first
            .assoc()['duration']!
            .split(' ');

        // Parse the duration value
        num durationValue = num.parse(parts[0]);

        // Extract the prescription duration from the result
        return durationValue;
      } else {
        // Return 0.0 if there are no active prescriptions
        return 0.0;
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
      return 0.0; // Return 0.0 to indicate no progress
    }
  }

  // Function to get today's medication progress
  Future<num?> getMedicationDayProgress(
      int patientID, BuildContext context) async {
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
      ''', {'patient_id': patientID});

      // Parse the total count of prescriptions taken
      num? totalCount = num.tryParse(totalActivePrescriptionIntakes.rows.first
          .assoc()['total_all_prescriptions_taken']!);

      // Update the state with the total count of prescriptions taken
      return totalCount;
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
    return null;
  }

  // Function to get the next medicine intake time
  Future<String> getNextMedicineIntake(
      int patientID, BuildContext context) async {
    try {
      final conn = await createConnection();

      // SQL query to get the next intake time for active prescriptions
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
      ''', {'patient_id': patientID});

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
        return formattedTime;
      } else {
        // Return a default message if no intake time is found
        return 'No upcoming intake scheduled';
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

      return 'Error occurred'; // Return a string indicating an error
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
  double calculateOverallMedicationProgress(num? duration, num? currentDay) {
    // Check if duration is null or currentDay is null
    if (duration == null || currentDay == null) {
      return 0.0;
    }

    // Avoid division by zero
    if (duration == 0) {
      return 0.0;
    }

    return (currentDay / duration);
  }

  void displayQRCode(BuildContext context, int prescriptionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrCodeDisplay(
            prescriptionId: prescriptionId), // Pass the prescription ID
      ),
    );
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

          // CARD - MEDICATION PROGRESS
          Container(
            padding: EdgeInsets.all(8), // Padding for the outer container
            decoration: BoxDecoration(
              color: Colors
                  .transparent, // Ensure the outer container is transparent
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (_activePatientMedicationProgressData
                      ?.map((patientData) {
                    int patientID = int.parse(patientData['patientID']);
                    double currentProgress =
                        patientData['currentProgress'] ?? 0;
                    num medicationDuration =
                        patientData['medicationDuration'] ?? '0';
                    num currentDay = patientData['currentDay'] ?? 0;
                    String nextIntakeTime =
                        patientData['nextIntakeTime'] ?? 'N/A';
                    String username = patientData['username'] ?? 'N/A';

                    return Container(
                      // Container with gradient border for each patient data
                      decoration: BoxDecoration(
                        border: GradientBoxBorder(
                          width: 2,
                          gradient: LinearGradient(colors: [
                            Color(0xffa16ae8),
                            Color(0xff94b9ff),
                          ]),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors
                            .white, // White background for the inner container
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF602E9E),
                            ),
                          ),
                          // TITLE - MEDICATION PROGRESS
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                "MEDICATION PROGRESS",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF602E9E),
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: opens a Calendar widget
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
                            value: (currentProgress),
                            backgroundColor: Color(0xFFD9D9FF),
                            gradientColors: [
                              Color(0xffa16ae8),
                              Color(0xff94b9ff)
                            ],
                            height: 40,
                            borderRadius: BorderRadius.circular(15),
                            text:
                                '${max(medicationDuration - currentDay, 0)} days Left',
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
                            items: List<Widget>.generate(31, (int index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                child: Container(
                                  decoration: (index >= currentDay)
                                      ? BoxDecoration(
                                          border: GradientBoxBorder(
                                            width: 1,
                                            gradient: LinearGradient(colors: [
                                              Color.fromRGBO(195, 150, 255, 1),
                                              Color(0xFF86B0FF),
                                            ]),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        )
                                      : BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color.fromRGBO(195, 150, 255, 1),
                                              Color(0xFF86B0FF),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                              viewportFraction: 0.2,
                              initialPage: currentDay.toInt(),
                              enableInfiniteScroll: false,
                              reverse: false,
                              autoPlay: false,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.25,
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
                            nextIntakeTime,
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
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return IntakeHistoryPopup(
                                            patientID: patientID);
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
                                            patientID: patientID);
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
                    );
                  }).toList() ??
                  []),
            ),
          ),

          SizedBox(height: 20), // Add some spacing before the button

          ElevatedButton(
              onPressed: () {
                // Change the number based on the prescription
                // that you want the QR code from
                displayQRCode(context, 1);
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

          SizedBox(height: 20), // Add some spacing after the button
        ],
      ),
    );
  }
}
