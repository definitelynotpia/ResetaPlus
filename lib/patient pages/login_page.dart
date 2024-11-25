// ignore_for_file: unused_field

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:resetaplus/main.dart';
import 'package:resetaplus/services/connection_service.dart';
import '../widgets/gradient_checkbox.dart';
import '../widgets/forgot_password_dialog.dart';

import 'register_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // generate global key, uniquely identify Form widget and allow form validation
  final _formKey = GlobalKey<FormState>();

  // test login credentials
  final String _testEmail = "admin@gmail.com";
  final String _testPassword = "qwerty";

  // store input field values
  String? _email;
  String? _password;

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

  // Sets value for loggedIn in shared_preference
  void _setLoggedInStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', status);
  }

  void _setusernameSession(String? username) async {
    final prefs = await SharedPreferences.getInstance();
    if (username != null) {
      await prefs.setString('username', username);
    }
  }

  Future<void> loginUser(BuildContext context) async {
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

      // Fetch accounts and keys in one go using parameterized query
      var result = await conn.execute('''
      SELECT a.*, k.encryption_key, k.initialization_vector 
      FROM reseta_plus.patient_accounts a
      JOIN reseta_plus.patient_account_keys k ON a.patient_id = k.patient_key_id
      WHERE a.email = :email
      ''', {'email': _email});

      // Check if Widget is mounted in context
      if (context.mounted) {
        // Check if any account was found
        if (result.rows.isNotEmpty) {
          // Get the first row of patient account data
          Map patientAccountData = result.rows.first.assoc();

          // Verify the provided password against the stored password details
          if (verifyPassword(
              _password!,
              patientAccountData['password'],
              patientAccountData['salt'],
              encrypt.Key(base64.decode(patientAccountData['encryption_key'])),
              encrypt.IV(base64
                  .decode(patientAccountData['initialization_vector'])))) {
            _setusernameSession(patientAccountData['username']);
            _setLoggedInStatus(true);
            Navigator.pop(context); // Closes current window
            Navigator.push(
                context, // Opens another instance of MainApp
                MaterialPageRoute(builder: (context) => const MainApp()));
            // Show success message if login is successful
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Successfully logged in!")),
            );
            // Navigate to dashboard
          } else {
            _setLoggedInStatus(false);
            // Show failure message if password verification fails
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login failed. Please try again.")),
            );
          }
        } else {
          // Show failure message if no account is found for the email
          _setLoggedInStatus(false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed. Please try again.")),
          );
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
          const SnackBar(content: Text("Login error. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F6F5),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.1,
              horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              SizedBox(
                height: MediaQuery.of(context).size.height / 5,
                child: Image.asset('assets/logo_ResetaPlus.png'),
              ),

              // Login form centered in space
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      const SizedBox(height: 15),

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
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value,
                      ),

                      // Remember me checkbox, Forgot password link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // row widget to display multiple widgets in the same line
                        children: <Widget>[
                          // Custom widget with gradient checkbox icon
                          Flexible(
                            child: CustomCheckbox(
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
                          ),

                          // Forgot password container
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: TextButton(
                              onPressed: () => forgotPasswordDialog(context),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerRight),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // spacer
                      const SizedBox(height: 15),

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
                          onPressed: () => loginUser(context),
                          // content
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent),
                          child: const Text(
                            "SIGN IN",
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

              // Sign up prompt
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 3,
                children: <Widget>[
                  // Sign up question prompt
                  const Text(
                    "DON'T HAVE AN ACCOUNT?",
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
                            builder: (context) => const RegisterPage(
                              title: "Register",
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "SIGN UP NOW",
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
    );
  }
}
