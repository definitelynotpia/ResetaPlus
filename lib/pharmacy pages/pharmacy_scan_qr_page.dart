
import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class PharmacyScanQRPage extends StatefulWidget {
  const PharmacyScanQRPage({super.key, required String title});

  @override
  State<PharmacyScanQRPage> createState() => _PharmacyScanQRPageState();
}

class _PharmacyScanQRPageState extends State<PharmacyScanQRPage> {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
    void reassemble() {
      super.reassemble();
      if (controller != null) {
        controller!.pauseCamera();
        controller!.resumeCamera();
      }
    }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (scannedData != null)
                  ? Text('Scanned data: $scannedData')
                  : const Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code; // Save the scanned data
      });
      // Stop the scanner if you want to handle only a single scan
      controller.pauseCamera();

      // Use the scanned data here (e.g., navigate to another screen or display information)
      if (scannedData != null) {
        Navigator.pop(context, scannedData); // Return scanned data to previous screen
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

