/* PLACEHOLDER */

import 'package:flutter/material.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Color(0xffF8F6F5));
  }
}
