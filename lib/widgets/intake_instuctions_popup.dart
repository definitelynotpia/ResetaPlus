import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:resetaplus/services/connection_service.dart';

class IntakeInstructionsPopup extends StatefulWidget {
  final int patientID; // Patient ID passed to the popup

  const IntakeInstructionsPopup({super.key, required this.patientID});

  @override
  State<IntakeInstructionsPopup> createState() =>
      _IntakeInstructionsPopupState();
}

class _IntakeInstructionsPopupState extends State<IntakeInstructionsPopup> {
  // Variable to hold intake instructions data
  IResultSet? _patientIntakeInstructions;

  @override
  void initState() {
    super.initState();
    // Call the asynchronous method to fetch the patient's intake instructions
    getPrescriptionIntakeInstructions(widget.patientID);
  }

  // Asynchronous method to retrieve patient intake instructions from the database
  Future<void> getPrescriptionIntakeInstructions(int patientID) async {
    try {
      // Establish database connection
      final conn = await createConnection();

      // SQL query to fetch medication and intake details for the specified patient
      var patientIntakeInstructionsData = await conn.execute('''
      SELECT 
          m.medication_name,
          m.medication_form,
          m.medication_info,
          m.medication_description,
          p.frequency,
          p.dosage,
          p.duration,
          p.intake_instructions
      FROM 
          patient_prescriptions p
      JOIN 
          medications m ON p.medication_id = m.medication_id
      WHERE 
          p.patient_id = :patient_id;
      ''', {'patient_id': patientID});

      // Update the state with the retrieved intake instructions data
      setState(() {
        _patientIntakeInstructions = patientIntakeInstructionsData;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Intake Instructions'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: () {
            List<Widget> intakeHistoryWidgets = [];

            // Check if _patientIntakeInstructions is not null and has rows
            if (_patientIntakeInstructions != null &&
                _patientIntakeInstructions!.rows.isNotEmpty) {
              // Iterate over the rows in the IResultSet
              for (var row in _patientIntakeInstructions!.rows) {
                String medicationName = row.assoc()['medication_name'] ?? 'N/A';
                String medicationForm = row.assoc()['medication_form'] ?? 'N/A';
                String medicationInfo = row.assoc()['medication_info'] ?? 'N/A';
                String medicationDescriptions =
                    row.assoc()['medication_description'] ?? 'N/A';
                String frequency = row.assoc()['frequency'] ?? 'N/A';
                String dosage = row.assoc()['dosage'] ?? 'N/A';
                String duration = row.assoc()['duration'] ?? 'N/A';
                String intakeInstructions =
                    row.assoc()['intake_instructions'] ?? 'N/A';

                intakeHistoryWidgets.add(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Medicine Name: $medicationName'),
                      Text('Form: $medicationForm'),
                      Text('Information: $medicationInfo'),
                      Text('Description: $medicationDescriptions'),
                      Text('Intake Frequency: $frequency'),
                      Text('Dosage: $dosage'),
                      Text('Duration: $duration'),
                      Text('Intake Instructions: $intakeInstructions'),
                      const SizedBox(height: 10), // Spacer between entries
                    ],
                  ),
                );
              }
            } else {
              // Add a message if no intake instructions are available
              intakeHistoryWidgets
                  .add(const Text('No intake instructions available.'));
            }

            return intakeHistoryWidgets; // Return the list of widgets
          }(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
