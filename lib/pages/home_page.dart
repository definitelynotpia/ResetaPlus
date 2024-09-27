import 'package:flutter/material.dart';
import '../widgets/custom_iconbutton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double iconSize = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffF8F6F5),
        // QR Code
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: "QR Code",
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              Icons.qr_code_2,
              size: iconSize + 20,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // Bottom navbar
        bottomNavigationBar: Stack(
          children: [
            // bottom appbar gradient background
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // navbar
            BottomAppBar(
              color: Colors.transparent,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Medicines page
                  SizedIconButton(
                    size: iconSize,
                    icon: Icons.medication,
                    iconColor: const Color(0xffF8F6F5),
                    onPressed: () {},
                  ),
                  // Store page
                  SizedIconButton(
                    size: iconSize,
                    icon: Icons.store,
                    iconColor: const Color(0xffF8F6F5),
                    onPressed: () {},
                  ),
                  // History page
                  SizedIconButton(
                    size: iconSize,
                    icon: Icons.history,
                    iconColor: const Color(0xffF8F6F5),
                    onPressed: () {},
                  ),
                  // Settings page
                  SizedIconButton(
                    size: iconSize,
                    icon: Icons.settings,
                    iconColor: const Color(0xffF8F6F5),
                    onPressed: () {},
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
