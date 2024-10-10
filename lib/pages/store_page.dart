import 'package:flutter/material.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      // add Column widget to have multiple Widgets
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // row = filter button, search bar, search button
          // container = otc
          // scrollview = cards
          // container = prescription
          // scrollview = cards
          // data from
        ],
      ),
    );
  }
}
