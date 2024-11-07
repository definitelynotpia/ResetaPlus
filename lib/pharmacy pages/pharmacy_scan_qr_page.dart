
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PharmacyScanQRPage extends StatefulWidget {
  const PharmacyScanQRPage({super.key, required String title});

  @override
  State<PharmacyScanQRPage> createState() => _PharmacyScanQRPageState();
}

class _PharmacyScanQRPageState extends State<PharmacyScanQRPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: SizedBox(
        height: 400,
        child: MobileScanner(onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint(barcode.rawValue ?? "No Data found in QR");
          }
        }),
      ),
    );
  }
}
