import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'patient pages/login_page.dart';
import 'pharmacy pages/pharmacy_login_page.dart';
import 'doctor pages/doctor_login_page.dart';
import 'widgets/gradient_radio_buttons.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPage();
}

class _RoleSelectionPage extends State<RoleSelectionPage> {
  String userType = "Patient";

  void _setUserType(String selectedUserType) async {
    userType = selectedUserType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffF8F6F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                // spacer
                SizedBox(height: MediaQuery.of(context).size.height / 10),

                // body
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo at the top
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 5,
                          child: Image.asset('assets/logo_ResetaPlus.png'),
                        ),

                        // spacer
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 10),

                        // Account type prompt
                        const Text(
                          "How will you be using this app?",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff602e9e),
                          ),
                        ),

                        // spacer
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 20),

                        // Patient radio button
                        CustomRadioWidget(
                          title: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Patient',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        ' – Track prescriptions and medical history, set alarms for medicine intake'),
                              ],
                            ),
                          ),
                          value: "Patient",
                          groupValue: userType,
                          onChanged: (String value) {
                            setState(() {
                              userType = value;
                            });
                          },
                        ),

                        // spacer
                        const SizedBox(height: 5),

                        // Doctor radio button
                        CustomRadioWidget(
                          title: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Doctor',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        ' – Manage patient records, authorize digital prescriptions'),
                              ],
                            ),
                          ),
                          value: "Doctor",
                          groupValue: userType,
                          onChanged: (String value) {
                            setState(() {
                              userType = value;
                            });
                          },
                        ),

                        // spacer
                        const SizedBox(height: 5),

                        // Pharmacy radio button
                        CustomRadioWidget(
                          title: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Pharmacy',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        ' – Become a trusted pharmaceutical partner of Reseta+'),
                              ],
                            ),
                          ),
                          value: "Pharmacy",
                          groupValue: userType,
                          onChanged: (String value) {
                            setState(() {
                              userType = value;
                            });
                          },
                        ),

                        // spacer
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 20),

                        // Next button
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 50,
                            width: 125,
                            transform: Matrix4.translationValues(-25, 0, 0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xffa16ae8),
                                Color(0xff94b9ff)
                              ]),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                  // Register form script
                                  onPressed: () {
                                    _setUserType(userType);

                                    if (userType == "Patient") {
                                      // Navigate to Patient's login page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage(
                                                    title: "Login")),
                                      );
                                    } else if (userType == "Doctor") {
                                      // Navigate to Doctor's login page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const DoctorLoginPage(
                                                    title: "Login")),
                                      );
                                    } else {
                                      _setUserType('Pharmacy');
                                      // Navigate to Patient's page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PharmacyLoginPage(
                                                    title: "Login")),
                                      );
                                    }
                                  },
                                  // content
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent),
                                  child: const Row(
                                    children: [
                                      Text(
                                        "Next",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
