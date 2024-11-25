import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:resetaplus/services/connection_service.dart';

class IntakeHistoryPopup extends StatefulWidget {
  final int patientID; // Patient ID passed to the popup

  const IntakeHistoryPopup({super.key, required this.patientID});

  @override
  State<IntakeHistoryPopup> createState() => _IntakeHistoryPopupState();
}

class _IntakeHistoryPopupState extends State<IntakeHistoryPopup> {
  // Variable to hold intake history data
  IResultSet? _patientIntakeHistory;

  @override
  void initState() {
    super.initState();
    // Call the async function to fetch the patient's intake history
    getPatientIntakeHistory(widget.patientID);
  }

  // Asynchronous method to retrieve patient intake history from the database
  Future<void> getPatientIntakeHistory(int patientID) async {
    try {
      // Establish database connection
      final conn = await createConnection();

      // SQL query to fetch the intake information for the specified patient
      var patientIntakeHistoryData = await conn.execute('''
      SELECT intake_date, intake_time, status
      FROM patient_prescription_intakes
      WHERE patient_id = :patient_id;
      ''', {'patient_id': patientID});

      // Update the state with the retrieved intake history data
      setState(() {
        _patientIntakeHistory = patientIntakeHistoryData;
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
      title: const Text('Intake History'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: () {
            List<Widget> intakeHistoryWidgets = [];

            // Check if _patientIntakeHistory is null or has no rows
            if (_patientIntakeHistory != null &&
                _patientIntakeHistory!.rows.isNotEmpty) {
              // Iterate over the rows in the IResultSet
              for (var row in _patientIntakeHistory!.rows) {
                String intakeDate = row.assoc()['intake_date'] ?? 'N/A';
                String intakeTime = row.assoc()['intake_time'] ?? 'N/A';
                String status = row.assoc()['status'] ?? 'N/A';

                // Determine the color based on the status
                Color statusColor;
                switch (status) {
                  case 'late':
                    statusColor = Colors.orange;
                    break;
                  case 'on_time':
                    statusColor = Colors.green;
                    break;
                  case 'missed':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor =
                        Colors.black; // Default color for unknown status
                }

                intakeHistoryWidgets.add(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Intake Date: $intakeDate'),
                      Text('Intake Time: $intakeTime'),
                      const Text('Status:'),
                      Text(
                        status,
                        style: TextStyle(color: statusColor), // Apply the color
                      ),
                      const SizedBox(height: 10), // Spacer between entries
                    ],
                  ),
                );
              }
            } else {
              // Add a message if there's no intake history available
              intakeHistoryWidgets
                  .add(const Text('No intake history available.'));
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
