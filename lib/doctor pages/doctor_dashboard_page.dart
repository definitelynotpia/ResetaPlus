// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:math';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';
import 'package:resetaplus/main.dart';

import 'package:resetaplus/widgets/custom_prescription.dart';
import 'package:resetaplus/widgets/prescription_popup.dart';
//import 'package:resetaplus/widgets/card_medication_progress.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key, required String title});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  // Current date for reference
  final DateTime _currentDate = DateTime.now();
  // Sample patient ID for testing
  final int _patientIDTest = 1;

  final int _doctorIDTest = 1;

  List<Map<String, String>>? _currentPrescriptions; // Medicine information in the prescription
  List<Map<String, dynamic>>? _activePatientMedicationProgressData;

  @override
  void initState() {
    super.initState();
    // Fetch the prescription data when the widget is initialized
    getActivePatientMedicationProgress();
    getCurrentPrescriptions();
  }

  Future<void> getActivePatientMedicationProgress()async {
    try{
      final conn = await createConnection();

      var activePatients = await conn.execute(''' 
      SELECT DISTINCT pp.patient_id, pa.username
      FROM patient_prescriptions pp
      JOIN patient_accounts pa ON pp.patient_id = pa.patient_id
      WHERE pp.status = 'active' 
        AND pp.doctor_id = :doctor_id;
      ''', {'doctor_id': _doctorIDTest});

      List<Map<String, dynamic>>? activePatientMedicationProgressData = [];

      for (var row in activePatients.rows) {
        var assoc = row.assoc();
        // Retrieve the patient_id as a string
        String? patientIdString = assoc['patient_id'];

        // Convert the string to an int with a default value
        int patientIdInt = patientIdString != null 
            ? int.tryParse(patientIdString) ?? 0 // Default to 0 if parsing fails
            : 0; // Default to 0 if patientIdString is null
        
        num medicationDuration = await getPrescriptionDuration(patientIdInt);
        num? currentDay = await getMedicationDayProgress(patientIdInt);
        double currentProgress= calculateOverallMedicationProgress(medicationDuration, currentDay);
        String nextIntakeTime = await getNextMedicineIntake(patientIdInt);

        activePatientMedicationProgressData.add({
          'username': assoc['username'],
          'currentProgress': currentProgress,
          'medicationDuration': medicationDuration,
          'currentDay': currentDay,
          'nextIntakeTime': nextIntakeTime,
        });
      }

      // Update the state with the next intake time
      setState(() {
        _activePatientMedicationProgressData = activePatientMedicationProgressData;
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
  Future<void> getCurrentPrescriptions() async {
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
      ''', {'patient_id': _patientIDTest});

      // Initialize the list to hold prescription data
      List<Map<String, String>> activePrescriptionDetails = [];

      // Iterate through the result rows and map them to the desired structure
      for (var row in activePrescriptionMedicationInfo.rows) {
        var assoc = row.assoc();
        activePrescriptionDetails.add({
          'drugName': assoc['medication_name'] ?? '',
          'drugInfo': assoc['medication_info'] ?? '',
          'description': assoc['medication_description'] ?? '',
        });
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
  Future<num> getPrescriptionDuration(int patientID) async {
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
        final parts = activePrescriptionDuration.rows.first.assoc()['duration']!.split(' ');

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
  Future<num?> getMedicationDayProgress(int patientID) async {
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
  Future<String> getNextMedicineIntake(int patientID) async {
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

          debugPrint(DateFormat('yyyy-MM-dd – kk:mm').format(nextTime));

          // Update the next intake time if it's the earliest found
          if (nextIntakeDateTime == null || nextTime.isBefore(nextIntakeDateTime)) {
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
      // Optionally, you can throw an exception or return a default value
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
          ElevatedButton(
              onPressed: () {
                // Action to perform when the button is pressed
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PrescriptionPopupForm();
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffa16ae8), // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
              child: const Text(
                "Add Prescription", // Button text
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }

  void _showPrescriptionDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? drugName;
    String? drugInfo;
    String? description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Prescription'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Drug Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the drug name';
                      }
                      return null;
                    },
                    onSaved: (value) => drugName = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Drug Info'),
                    onSaved: (value) => drugInfo = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    onSaved: (value) => description = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  
                  // Handle the prescription creation logic here
                  // e.g., call an API or update the state

                  // Close the dialog after saving
                  Navigator.of(context).pop();
                }
              },
              child: Text('Create Prescription'),
            ),
          ],
        );
      },
    );
  }
}
