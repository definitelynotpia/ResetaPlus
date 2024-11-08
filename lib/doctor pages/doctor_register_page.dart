// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:resetaplus/main.dart';
import 'package:resetaplus/doctor%20pages/doctor_login_page.dart';
import '../widgets/gradient_checkbox.dart';
import '../register_consent_forms.dart';
import 'package:email_validator/email_validator.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

final _encryptionKey = encrypt.Key.fromLength(32); // 32 bytes for AES-256
final _initializationVector = encrypt.IV.fromLength(16); // 16 bytes for AES

class DoctorRegisterPage extends StatefulWidget {
  const DoctorRegisterPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends State<DoctorRegisterPage> {
  // generate global key, uniquely identify Form widget and allow form validation
  final _formKey = GlobalKey<FormState>();

  // store input field values
  String? _username;
  String? _licenseNumber;
  String? _email;
  String? _password;
  String? _confirmPassword;

  // Hide password?
  bool _obscureText = true;
  // Remember user?
  final bool _termsAndConditionsConsent = false;
  bool _privacyPolicyConsent = false;

  // Toggles the password show status
  void _toggleObscuredText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<bool> existsInTable(
      String tableName, String columnName, String value) async {
    try {
      // Create a connection to the database
      final conn = await createConnection();

      // Prepare the SQL query
      var results = await conn.execute(
        'SELECT COUNT(*) AS count FROM $tableName WHERE $columnName = :value',
        {'value': value},
      );

      // Fetch the count from the result
      Map count = results.rows.first.assoc();

      // Close the database connection
      await conn.close();

      // Return true if count is greater than 0, otherwise false
      return int.parse(count['count']) > 0;
    } catch (e) {
      debugPrint("Error: $e");
      return false; // Return false in case of error
    }
  }

  Future<void> registerUser(BuildContext context) async {
    // Check if the form is valid
    if (!_formKey.currentState!.validate()) {
      // Exit early if the form is not valid
      return;
    }

    // Save the form inputs
    _formKey.currentState!.save();

    // Check for email and license existence
    bool emailExists = await existsInTable('doctor_accounts', 'email', _email!);
    bool licenseExists = await existsInTable(
        'doctor_accounts', 'license_number', _licenseNumber!);
    bool verifiedLicenseExists = await existsInTable(
        'verified_license', 'license_number', _licenseNumber!);

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
      if (context.mounted) {
        // Check if the email exists
        if (emailExists) {
          // Check if Widget is mounted in context
          if (context.mounted) {
            // Handle the case where the email is already in use
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Email already in use. Please use another.")),
            );
          }
        } else if (licenseExists) {
          // Check if Widget is mounted in context
          if (context.mounted) {
            // Handle the case where the license is already in use
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("License already registered to another user.")),
            );
          }
        } else if (!verifiedLicenseExists) {
          // Check if Widget is mounted in context
          if (context.mounted) {
            // Handle the case where the license is already in use
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid License.")),
            );
          }
        } else {
          // Insert the new user into the doctor_accounts table
          await conn.execute(
            'INSERT INTO doctor_accounts (username, license_number, email, password, salt) VALUES (:username, :license_number, :email, :password, :salt)',
            {
              'username': _username,
              'license_number': _licenseNumber?.toUpperCase(),
              'email': _email,
              'password': encryptedPassword,
              'salt': salt
            },
          );

          // Insert the encryption keys into the doctor_account_keys table
          await conn.execute(
            'INSERT INTO doctor_account_keys (encryption_key, initialization_vector, username) VALUES (:encryption_key, :initialization_vector, :username)',
            {
              'encryption_key': base64.encode(_encryptionKey.bytes),
              'initialization_vector':
                  base64.encode(_initializationVector.bytes),
              'username': _username
            },
          );

          // Check if Widget is mounted in context
          if (context.mounted) {
            // Show a success message to the user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Successfully registered!")),
            );

            // Navigate to the Register page after successful registration
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const DoctorLoginPage(title: "Register")),
            );
          }
        }
      }

      // Close the database connection
      await conn.close();
    } catch (e) {
      // Print error details to the console
      debugPrint("Error: $e");

      // Check if Widget is mounted in context
      if (context.mounted) {
        // Show error message if an exception occurs during the process
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Registration failed. Please try again.")),
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
    return Scaffold(
      backgroundColor: const Color(0xffF8F6F5),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          // add Column widget to have multiple Widgets
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.04,
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // set size constraints to app logo
                SizedBox(
                  height: MediaQuery.of(context).size.height / 6.5,
                  child: Image.asset('assets/logo_ResetaPlus_doctors.png'),
                ),

                // Sign in form
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Username input field
                        TextFormField(
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
                          // Username validation script
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field cannot be empty.";
                            }
                            return null;
                          },
                          onSaved: (value) => _username = value,
                        ),

                        // spacer
                        const SizedBox(height: 10),

                        // License Number input field
                        TextFormField(
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
                              label: Text("License Number")),
                          // License Number validation script
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field cannot be empty.";
                            }
                            return null;
                          },
                          onSaved: (value) => _licenseNumber = value,
                        ),

                        // spacer
                        const SizedBox(height: 10),

                        // Email input field
                        TextFormField(
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
                          // Email validation script
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

                        // spacer
                        const SizedBox(height: 10),

                        // Password input field
                        TextFormField(
                          cursorColor: Theme.of(context).colorScheme.primary,
                          decoration: InputDecoration(
                            border: const GradientOutlineInputBorder(
                                gradient: LinearGradient(colors: [
                                  Color(0xffa16ae8),
                                  Color(0xff94b9ff)
                                ]),
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
                          // password validation script
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

                        // spacer
                        const SizedBox(height: 10),

                        // Confirm password input field
                        TextFormField(
                          cursorColor: Theme.of(context).colorScheme.primary,
                          decoration: const InputDecoration(
                            border: GradientOutlineInputBorder(
                                gradient: LinearGradient(colors: [
                                  Color(0xffa16ae8),
                                  Color(0xff94b9ff)
                                ]),
                                width: 2.0),
                            label: Text("Confirm password"),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color(0xFFa16ae8),
                            ),
                          ),
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          // Confirm password validation script
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field cannot be empty.";
                            }
                            if (value != _password) {
                              // Check if it matches the password
                              return "Passwords do not match.";
                            }
                            return null;
                          },
                          onSaved: (value) => _confirmPassword = value,
                        ),

                        // spacer
                        const SizedBox(height: 10),

                        // Terms and conditions
                        CustomCheckbox(
                          checkboxValue: _privacyPolicyConsent,
                          onChange: (value) {
                            _privacyPolicyConsent = value;
                          },
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            children: [
                              // statement
                              const Text(
                                "I agree to ",
                                style: TextStyle(fontSize: 16),
                              ),

                              // t&c page button
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  // go to Sign Up form script
                                  onTap: () {
                                    // Navigate to T&C consent form page
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterConsentForms(page: 1)));
                                  },
                                  child: const Text(
                                    "Reseta+ Terms & Conditions",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                ".",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        // Privacy policy
                        CustomCheckbox(
                          checkboxValue: _privacyPolicyConsent,
                          onChange: (value) {
                            _privacyPolicyConsent = value;
                          },
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            children: [
                              // statement
                              const Text(
                                "I agree to ",
                                style: TextStyle(fontSize: 16),
                              ),

                              // privacy policy page button
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  // go to Sign Up form script
                                  onTap: () {
                                    // Navigate to Privacy Policy consent form page
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterConsentForms(page: 2)));
                                  },
                                  child: const Text(
                                    "Reseta+ Privacy Policy",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                ".",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        // spacer
                        const SizedBox(height: 20),

                        // Register button
                        Container(
                          height: 50,
                          width: 200,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ElevatedButton(
                            // Register form script
                            onPressed: () => registerUser(context),
                            // content
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent),
                            child: const Text(
                              "SIGN UP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Login prompt
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 3,
                  children: <Widget>[
                    // Sign up question prompt
                    const Text(
                      "ALREADY HAVE AN ACCOUNT?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    // Sign Up button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        // go to Sign Up form script
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorLoginPage(
                                title: "Register",
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "SIGN IN",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
      ),
    );
  }
}
