/* PLACEHOLDER */

import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Color(0xffF8F6F5));
  }
}
