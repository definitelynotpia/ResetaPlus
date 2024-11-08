import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:gradient_borders/input_borders/gradient_outline_input_border.dart';

Future<void> forgotPasswordDialog(BuildContext context) async {
  // generate global key, uniquely identify Form widget and allow form validation
  final formKey = GlobalKey<FormState>();

  // store input field values
  String? email;

  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // dialogue title
              const Text(
                "FORGOT PASSWORD?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              // spacer
              const SizedBox(height: 20),

              // dialogue description
              const Center(
                child: Text(
                  "No worries. We’ll send a password reset link to your email.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff585858),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              // spacer
              const SizedBox(height: 30),

              // email text field
              Form(
                key: formKey,
                child: TextFormField(
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
                  onSaved: (value) => email = value,
                ),
              ),

              // spacer
              const SizedBox(height: 10),

              // Reset password button
              Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          // display message
                          const SnackBar(
                            content: Text(
                                "Check your email for a link to reset your password."),
                          ),
                        );
                      },
                      // content
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent),
                      child: const Text(
                        "RESET PASSWORD",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer
              const SizedBox(height: 20),

              // Back to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    // Register form script
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    // content
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Color(0xff8d4fdf),
                        ),
                        SizedBox(width: 3),
                        Text(
                          "Back to Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff8d4fdf),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
      });
}
