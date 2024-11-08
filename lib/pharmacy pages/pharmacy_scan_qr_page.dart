
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

class PharmacyScanQRPage extends StatefulWidget {
  const PharmacyScanQRPage({super.key, required String title});

  @override
  State<PharmacyScanQRPage> createState() => _PharmacyScanQRPageState();
}

// void openQRScanner(BuildContext context) async {
//   final scannedResult = await Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => const PharmacyScanQRPage()),
//   );

//   if (scannedResult != null) {
//     debugPrint('Scanned QR code data: $scannedResult');
//     // Handle scanned data (e.g., fetch file path from database)
//   }
// }

class _PharmacyScanQRPageState extends State<PharmacyScanQRPage> {

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: true,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
          }
          if (image != null) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    barcodes.first.rawValue ?? "",
                  ),
                  content: Image(
                    image: MemoryImage(image),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

