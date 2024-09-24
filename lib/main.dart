import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Reseta+", // app title
      theme: ThemeData(
        fontFamily: "Montserrat", // set custom font as default
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // load Login page on startup
      home: const LoginPage(title: "Login"),
    );
  }
}
