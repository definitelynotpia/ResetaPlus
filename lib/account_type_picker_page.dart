import 'package:flutter/material.dart';

import 'patient pages/login_page.dart';
import 'doctor pages/doctor_login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPage();
}

class _RoleSelectionPage extends State<RoleSelectionPage> {
  void _setUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo at the top
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
              child: Image.asset('assets/logo_ResetaPlus.png'),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 10),

            // Doctor button
            Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffa16ae8), Color(0xff94b9ff)],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ElevatedButton(
                onPressed: () {
                  _setUserType('Doctor');
                  // Navigate to Doctor's page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const DoctorLoginPage(title: "Login")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  "Doctor",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 20),

            // Patient button
            Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffa16ae8), Color(0xff94b9ff)],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ElevatedButton(
                onPressed: () {
                  _setUserType('Patient');
                  // Navigate to Patient's page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPage(title: "Login")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  "Patient",
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
    );
  }
}

// Placeholder for Doctor's page
class DoctorPage extends StatelessWidget {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Page")),
      body: const Center(child: Text("Welcome to the Doctor Page")),
    );
  }
}
