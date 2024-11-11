import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:resetaplus/main.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:gradient_borders/gradient_borders.dart';
import 'dart:math';
import 'package:resetaplus/pages/login_page.dart';

final _encryptionKey = encrypt.Key.fromLength(32); // 32 bytes for AES-256
final _initializationVector = encrypt.IV.fromLength(16); // 16 bytes for AES

class UpdatePopupForm extends StatefulWidget {
  final Map<String, String> credentials; // Accept credentials as a parameter

  const UpdatePopupForm({super.key, required this.credentials});
  @override
  UpdatePopupFormState createState() => UpdatePopupFormState();
}

class UpdatePopupFormState extends State<UpdatePopupForm> {
  final _formKey = GlobalKey<FormState>();

  // store input field values
  String? _id;
  String? _username;
  String? _email;
  String? _password;
  String? _confirmPassword;

  // Hide password?
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _id = widget.credentials['ID'];
    _username = widget.credentials['Username'];
    _email = widget.credentials['Email'];
    debugPrint("Data loaded: ${widget.credentials.toString()}");
  }

  // Toggles the password show status
  void _toggleObscuredText() {
    setState(() {
      _obscureText = !_obscureText;
    });
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

  void _showErrorSnackBar(String message) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }

  Future<void> updateUser() async {
    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      // Save the form inputs
      _formKey.currentState!.save();
    } else {
      // Exit early if the form is not valid
      return;
    }

    try {
      // Create a connection to the database
      final conn = await createConnection();

      // Generate a unique salt for hashing the password
      String salt = generateSalt();

      // Hash the user's password with the generated salt
      String hashedPassword = hashPassword(_password!, salt);

      // Encrypt the hashed password for secure storage
      String encryptedPassword = encryptPassword(hashedPassword);

      // Check if Widget is mounted in context
      if (mounted) {
        // Check if the email exists

        // Insert the new user into the patient_accounts table
        await conn.execute(
          'UPDATE patient_accounts SET username= :username, email = :email, password = :password, salt = :salt WHERE patient_id = :id  ',
          {
            'username': _username,
            'email': _email,
            'password': encryptedPassword,
            'salt': salt,
            'id': _id
          },
        );

        // Insert the encryption keys into the patient_account_keys table
        await conn.execute(
          'UPDATE patient_account_keys SET encryption_key = :encryption_key, initialization_vector = :initialization_vector, username = :username WHERE patient_key_id = :id',
          {
            'encryption_key': base64.encode(_encryptionKey.bytes),
            'initialization_vector': base64.encode(_initializationVector.bytes),
            'username': _username,
            'id': _id
          },
        );

        _showErrorSnackBar("Successfully Updated.");
        // Show a success message to the user
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Successfully updated!")),
        // );

        // Close the dialog box
        if (mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginPage(title: "Login")),
          );
        }

        // Close the database connection
        await conn.close();
      }
    } catch (e) {
      // Print error details to the console
      debugPrint("Error: $e");

      _showErrorSnackBar("Update failed. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Enter your details'),
        content: Builder(
          builder: (context) => Container(
            width:
                MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                // Allow scrolling if content overflows
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Minimize the height of the Column
                  children: [
                    // Username input field
                    TextFormField(
                      initialValue: _username,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      decoration: const InputDecoration(
                          border: GradientOutlineInputBorder(
                              gradient: LinearGradient(colors: [
                                Color(0xffa16ae8),
                                Color(0xff94b9ff)
                              ]),
                              width: 2.0),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFFa16ae8),
                          ),
                          label: Text("Username")),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty.";
                        }
                        return null;
                      },
                      onSaved: (value) => _username = value,
                    ),
                    SizedBox(height: 16), // Reduced spacing
                    // Email input field
                    TextFormField(
                      initialValue: _email,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      decoration: const InputDecoration(
                          border: GradientOutlineInputBorder(
                              gradient: LinearGradient(colors: [
                                Color(0xffa16ae8),
                                Color(0xff94b9ff)
                              ]),
                              width: 2.0),
                          prefixIcon: Icon(
                            Icons.mail,
                            color: Color(0xFFa16ae8),
                          ),
                          label: Text("Email")),
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty.";
                        } else if (!EmailValidator.validate(value)) {
                          return "Please input a valid email address.";
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value,
                    ),
                    SizedBox(height: 16), // Reduced spacing
                    // Password input field
                    TextFormField(
                      cursorColor: Theme.of(context).colorScheme.primary,
                      decoration: InputDecoration(
                        border: const GradientOutlineInputBorder(
                            gradient: LinearGradient(
                                colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                            width: 2.0),
                        label: const Text("Password"),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color(0xFFa16ae8),
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFFa16ae8),
                            ),
                            onPressed: _toggleObscuredText),
                      ),
                      obscureText: _obscureText,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty.";
                        } else {
                          _password = value;
                          return null;
                        }
                      },
                      onSaved: (value) => _password = value,
                    ),
                    SizedBox(height: 16), // Reduced spacing
                    // Confirm password input field
                    TextFormField(
                      cursorColor: Theme.of(context).colorScheme.primary,
                      decoration: const InputDecoration(
                        border: GradientOutlineInputBorder(
                            gradient: LinearGradient(
                                colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                            width: 2.0),
                        label: Text("Confirm Password"),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xFFa16ae8),
                        ),
                      ),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty.";
                        }
                        if (value != _password) {
                          return "Passwords do not match.";
                        }
                        return null;
                      },
                      onSaved: (value) => _confirmPassword = value,
                    ),
                    const Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.orange,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Warning: You will be logged out upon saving due to change of credentials",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                          top: 16), // Reduced padding for the button
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateUser();
                          }
                        },
                        child: const Text('Save'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
