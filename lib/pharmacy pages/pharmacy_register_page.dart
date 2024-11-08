// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:resetaplus/main.dart';
import 'package:resetaplus/pharmacy%20pages/pharmacy_login_page.dart';
import '../widgets/gradient_checkbox.dart';
import 'package:email_validator/email_validator.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

final _encryptionKey = encrypt.Key.fromLength(32); // 32 bytes for AES-256
final _initializationVector = encrypt.IV.fromLength(16); // 16 bytes for AES

class PharmacyRegisterPage extends StatefulWidget {
  const PharmacyRegisterPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _PharmacyRegisterPageState();
}

class _PharmacyRegisterPageState extends State<PharmacyRegisterPage> {
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
  bool _rememberUser = false;

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
    bool emailExists =
        await existsInTable('pharmacy_accounts', 'email', _email!);

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
        } else {
          // Insert the new user into the pharmacy_accounts table
          await conn.execute(
            'INSERT INTO pharmacy_accounts (username, email, password, salt) VALUES (:username, :email, :password, :salt)',
            {
              'username': _username,
              'email': _email,
              'password': encryptedPassword,
              'salt': salt
            },
          );

          // Insert the encryption keys into the pharmacy_account_keys table
          await conn.execute(
            'INSERT INTO pharmacy_account_keys (encryption_key, initialization_vector, username) VALUES (:encryption_key, :initialization_vector, :username)',
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

            // Navigate to the login page after successful registration
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const PharmacyLoginPage(title: "Login")),
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
        body: Center(
      // add Column widget to have multiple Widgets
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // set size constraints to app logo
          SizedBox(
            height: MediaQuery.of(context).size.height / 5,
            child: Image.asset('assets/logo_ResetaPlus.png'),
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 20),
          // Sign in form
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.5,
              minWidth: MediaQuery.of(context).size.width / 2,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Username input field
                  TextFormField(
                    cursorColor: Theme.of(context).colorScheme.primary,
                    decoration: const InputDecoration(
                        border: GradientOutlineInputBorder(
                            gradient: LinearGradient(
                                colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
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
                  SizedBox(height: MediaQuery.of(context).size.height / 40),
                  // Email input field
                  TextFormField(
                    cursorColor: Theme.of(context).colorScheme.primary,
                    decoration: const InputDecoration(
                        border: GradientOutlineInputBorder(
                            gradient: LinearGradient(
                                colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
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
                  SizedBox(height: MediaQuery.of(context).size.height / 40),
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
                  SizedBox(height: MediaQuery.of(context).size.height / 40),
                  // Confirm password input field
                  TextFormField(
                    cursorColor: Theme.of(context).colorScheme.primary,
                    decoration: const InputDecoration(
                      border: GradientOutlineInputBorder(
                          gradient: LinearGradient(
                              colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                          width: 2.0),
                      label: Text("Password"),
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
                  SizedBox(height: MediaQuery.of(context).size.height / 75),
                  // Remember me checkbox, Forgot password link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // row widget to display multiple widgets in the same line
                    children: <Widget>[
                      // Custom widget with gradient checkbox icon
                      CustomCheckbox(
                        checkboxValue: _rememberUser,
                        onChange: (value) {
                          _rememberUser = value;
                        },
                        child: const Text(
                          "Remember me",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Forgot password container
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: GestureDetector(
                          // forgot password script
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              // display message
                              const SnackBar(
                                content: Text(
                                    "Check your email for a link to reset your password."),
                              ),
                            );
                          },
                          // Forgot password text
                          child: const MouseRegion(
                            // on hover, set mouse cursor to click
                            cursor: SystemMouseCursors.click,
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 35),
                  // Login button
                  Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ElevatedButton(
                      // login form script
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
          SizedBox(height: MediaQuery.of(context).size.height / 20),
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
                        builder: (context) => const PharmacyLoginPage(
                          title: "Login",
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
    ));
  }
}
