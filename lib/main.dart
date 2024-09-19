import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'widgets/custom_checkbox.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Reseta+",
      theme: ThemeData(
        fontFamily: "Montserrat",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LandingPage(title: "Home"),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F6F5),
      // add Column widget to have multiple Widgets
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // expands child of Row/Column/Flex to fill available space
          Expanded(
            // Login Form start
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50, bottom: 50),
                      // display RESETA+ Logo
                      child: Image.asset('assets/logo_ResetaPlus.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      // make corners of TextFormField rounded
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        // Email input field
                        child: TextFormField(
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
                              label: Text("Email")),
                          // email validation script
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field cannot be empty.";
                            } else if (value == _testEmail) {
                              return null;
                            }
                            return "Email is incorrect";
                          },
                          onSaved: (value) => _email = value,
                        ),
                      ),
                    ),
                    // Password input field
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 14),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextFormField(
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
                            } else if (value == _testPassword) {
                              return null;
                            }
                            return "Password is incorrect.";
                          },
                          onSaved: (value) => _password = value,
                        ),
                      ),
                    ),
                    // row widget to display multiple widgets in the same line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Custom checkbox widget with gradient icon
                        CustomCheckbox(
                          rememberUser: _rememberUser,
                          onChange: (value) {
                            _rememberUser = value;
                          },
                        ),
                        // Forgot password container
                        Padding(
                          // add padding above to align text with checkbox icon
                          padding: const EdgeInsets.only(top: 18),
                          // align text to right
                          child: GestureDetector(
                              // forgot password script
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Check your email for a link to reset your password.")),
                                );
                              },
                              // Forgot password text
                              child: const MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                    // Login button
                    Padding(
                      padding: const EdgeInsets.only(top: 26),
                      child: Container(
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ElevatedButton(
                          // login form script
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Successfully logged in!")));
                            }
                          },
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
                    ),
                    // Sign up section
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Wrap(
                        alignment: WrapAlignment.center,
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
                          Padding(
                            // separate Text widgets with left padding
                            padding: const EdgeInsets.only(left: 2),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                // go to Sign Up form script
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Redirecting to Sign Up form...")),
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
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
