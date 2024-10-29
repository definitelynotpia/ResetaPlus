// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resetaplus/main.dart';

import 'package:resetaplus/widgets/custom_prescription.dart';
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
    // Fetch the prescription data when the widget is initialized
    getNextMedicineIntake();
    getMedicationDayProgress();
    getMedicationOverallProgress();
    getCurrentPrescriptions();
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
  Future<void> getMedicationOverallProgress() async {
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
      ''', {'patient_id': _patientIDTest});

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
  Future<void> getMedicationDayProgress() async {
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
      ''', {'patient_id': _patientIDTest});

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
  Future<void> getNextMedicineIntake() async {
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
      ''', {'patient_id': _patientIDTest});

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
          // TITLE - CURRENT PRESCRIPTIONS
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Patients with Prescriptions',
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
