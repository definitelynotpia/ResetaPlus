import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:resetaplus/main.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:resetaplus/widgets/custom_ticket_card.dart';

class CredentialsPage extends StatefulWidget {
  // Define a constant for border radius size
  final double borderRadiussSize = 10;
  const CredentialsPage({super.key, required String title});

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  // List to hold patient account credentials
  List<Map<String, String>>? _patientAccountCredentials;

  @override
  void initState() {
    super.initState();
    // Fetch the patient credentials data when the widget is initialized
    getPatientCredentials();
  }

  Future<void> getPatientCredentials() async {
    try {
      // Create a connection to the database
      final conn = await createConnection();

      // Fetch accounts and keys in one go using a parameterized query
      var patientAccountData = await conn.execute('''
      SELECT a.*, k.encryption_key, k.initialization_vector 
      FROM reseta_plus.patient_accounts a
      JOIN reseta_plus.patient_account_keys k ON a.patient_id = k.patient_key_id
      ''');

      // Initialize the list to store patient account credentials
      List<Map<String, String>>? patientAccountCredentials  = [];

      // Loop through each row of the fetched data
      for (var row in patientAccountData.rows) {
        var assoc = row.assoc();
        
        // Ensure the values are non-null before using them
        String? username = assoc['username'];
        String? email = assoc['email'];
        String? password = assoc['password'];
        String? salt = assoc['salt'];
        String? encryptionKey = assoc['encryption_key'];
        String? initializationVector = assoc['initialization_vector'];

         // Check that all required values are available
        if (username != null && email != null && password != null && salt != null && encryptionKey != null && initializationVector != null) {
          // Decrypt the password and store it in the map
          patientAccountCredentials.add({
            'Username': username,
            'Email': email,
            'Password': decryptPassword(password, 
                                        salt, 
                                        encrypt.Key(base64.decode(encryptionKey)), 
                                        encrypt.IV(base64.decode(initializationVector))),
          });
        }
      }

      // Update the state with the patient account credentials
      setState(() {
        _patientAccountCredentials = patientAccountCredentials;
      });
    } catch (e) {
      // Handle errors during data fetching
      debugPrint("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching data. Please try again.")),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Allow scrolling if needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and divider for the credentials section
              const Text(
                'Patient Account Credentials',
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
              const SizedBox(height: 5),
            ],
          ),
          // Iterate through patient account credentials and create TicketWidgets
          ..._patientAccountCredentials?.map((credentials) {
            return TicketWidget(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Username Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Username: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF602E9E),
                        ),
                      ),
                      Expanded( // Allow username text to wrap
                        child: Text(
                          credentials['Username'] ?? "No Info Available",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF602E9E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Email Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF602E9E),
                        ),
                      ),
                      Expanded( // Allow email text to wrap
                        child: Text(
                          credentials['Email'] ?? "No Info Available",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF602E9E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Password Hash Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password Hash: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF602E9E),
                        ),
                      ),
                      Expanded( // Allow password hash text to wrap
                        child: Text(
                          credentials['Password'] ?? "No Info Available",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF602E9E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList() ?? [], // Fallback to an empty list if _patientAccountCredentials is null
        ],
      ),
    );
  }
}