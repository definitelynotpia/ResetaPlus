import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resetaplus/main.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:resetaplus/widgets/custom_ticket_card.dart';
import 'package:resetaplus/widgets/update_popup.dart';
import 'package:resetaplus/pages/login_page.dart';

final _encryptionKey = encrypt.Key.fromLength(32); // 32 bytes for AES-256
final _initializationVector = encrypt.IV.fromLength(16); // 16 bytes for AES

class CredentialsPage extends StatefulWidget {
  // Define a constant for border radius size
  final double borderRadiussSize = 10;
  const CredentialsPage({super.key, required String title});

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  // store input field values
  // String? _username;
  // String? _email;
  // String? _password;

  // List to hold patient account credentials
  List<Map<String, String>>? _patientAccountCredentials;
  String _usernameSession = "John Doe";
  @override
  void initState() {
    super.initState();
    // Fetch the patient credentials data when the widget is initialized
    getPatientCredentials();
    _getusernameSession();
  }

  void _getusernameSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameSession = prefs.getString('username') ?? "admin";
    });
  }

  Future<void> _deleteCredential(String? id, String? username) async {
    if (id == null) return;

    try {
      // Create a connection to the database
      final conn = await createConnection();

      // Run the delete query
      await conn.execute(
        'DELETE FROM patient_accounts WHERE patient_id = :id',
        {'id': id},
      );

      await conn.execute(
        'DELETE FROM patient_account_keys WHERE patient_key_id = :id',
        {'id': id},
      );

      // Close the connection
      await conn.close();

      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Credential deleted successfully!")),
        );
      }
      if (mounted) {
        if (_usernameSession == username) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginPage(title: "Login")),
          );
        } else {
          // Refresh the credentials list
          await getPatientCredentials();
        }
      }
    } catch (e) {
      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete credential.")),
        );
      }
    }
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
      List<Map<String, String>>? patientAccountCredentials = [];

      // Loop through each row of the fetched data
      for (var row in patientAccountData.rows) {
        var assoc = row.assoc();

        // Ensure the values are non-null before using them
        String? id = assoc['patient_id'];
        String? username = assoc['username'];
        String? email = assoc['email'];
        String? password = assoc['password'];
        String? salt = assoc['salt'];
        String? encryptionKey = assoc['encryption_key'];
        String? initializationVector = assoc['initialization_vector'];

        // Check that all required values are available
        if (id != null &&
            username != null &&
            email != null &&
            password != null &&
            salt != null &&
            encryptionKey != null &&
            initializationVector != null) {
          // Decrypt the password and store it in the map
          patientAccountCredentials.add({
            'ID': id,
            'Username': username,
            'Email': email,
            'Password': decryptPassword(
                password,
                salt,
                encrypt.Key(base64.decode(encryptionKey)),
                encrypt.IV(base64.decode(initializationVector))),
          });
        }
      }

      // Update the state with the patient account credentials
      setState(() {
        _patientAccountCredentials = patientAccountCredentials;
        debugPrint("Data loaded: ${_patientAccountCredentials.toString()}");
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

  String encryptPassword(String password) {
    // Create an encrypter instance using the AES algorithm and the specified key
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));

    // Encrypt the provided password using the encrypter and the specified initialization vector (IV)
    final encryptedPassword =
        encrypter.encrypt(password, iv: _initializationVector);

    // Return the encrypted password as a base64-encoded string for storage
    return encryptedPassword.base64;
  }

  String generateSalt([int length = 16]) {
    // Create a secure random number generator
    final random = Random.secure();

    // Define the characters that can be used in the salt
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    // Generate a random salt by selecting characters from the set
    return List.generate(
            length, (index) => characters[random.nextInt(characters.length)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Allow scrolling if needed
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
                  child: Stack(
                    children: [
                      Column(
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
                              Expanded(
                                child: Text(
                                  credentials['Username'] ??
                                      "No Info Available",
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
                              Expanded(
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
                              Expanded(
                                child: Text(
                                  credentials['Password'] ??
                                      "No Info Available",
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
                      // Positioned Edit Icon
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF602E9E),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return UpdatePopupForm(
                                    credentials: credentials);
                              },
                            );
                          },
                        ),
                      ),
                      // Delete Icon
                      Positioned(
                        top: 0,
                        right: 40, // Adjust spacing if needed
                        child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: const Text(
                                        "Are you sure you want to delete this credential?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Delete"),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close dialog
                                          _deleteCredential(
                                              credentials['ID'],
                                              credentials[
                                                  'Username']); // Call delete function
                                        },
                                      ),
                                    ],
                                  ); // Pass the ID to the delete function
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                );
              }).toList() ??
              [], // Fallback to an empty list if _patientAccountCredentials is null
        ],
      ),
    );
  }
}
