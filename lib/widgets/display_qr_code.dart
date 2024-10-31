import 'dart:io';
import '../main.dart'; // Import to work with files

import 'package:flutter/material.dart';
import 'package:mysql_client/src/mysql_client/connection.dart';

class QrCodeDisplay extends StatefulWidget {
  final int prescriptionId;

  const QrCodeDisplay({
    super.key, 
    required this.prescriptionId
  });

  @override
  _QrCodeDisplayState createState() => _QrCodeDisplayState();

}



class _QrCodeDisplayState extends State<QrCodeDisplay> {
  String? qrFilePath; // To hold the QR code file path
  File? qrCodeFile;
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchQrCode(); // Fetch QR code file path when the widget is initialized
  }

  Future<void> fetchQrCode() async {
    try {
      String? filePath = await fetchQrCodeFilePath(widget.prescriptionId); // Fetch the file path
      File? qrCodeFile = await locateQrCode(filePath);

      // if (mounted) {
      //   setState(() {
      //     qrFilePath = path; // Update the state with the fetched path
      //     isLoading = false; // Set loading to false
      //   });
      // }
    } catch (e) {
      debugPrint("Error fetching QR code: $e");
      if (mounted) {
        setState(() {
          isLoading = false; // Set loading to false even on error
        });
      }
    }
  }

    // Function to fetch QR code file path from the database
  Future<String?> fetchQrCodeFilePath(int prescriptionId) async {
    final conn = await createConnection();

  try {
      debugPrint("Fetching QR code file path for prescription ID: $prescriptionId");

      var result = await conn.query('''
        SELECT qr_code_filepath 
        FROM patient_prescriptions 
        WHERE prescription_id = ?''',
        // 'prescriptionId': 2},
        [1],
      );

      debugPrint("Query result: $result");
      if (result.isNotEmpty) {
        debugPrint('QR Code File Path: ${result.first['qr_code_filepath']}');
        return result.first['qr_code_filepath'] as String?;
      } else {
        debugPrint('No record found with prescription_id = 2');
        return null; // Return null if no file path is found
      }
      
    } finally {
      await conn.close();
    }
  }

  Future<File?> locateQrCode(String? filePath) async {
    if (filePath == null) return null;

    // Create a File object with the file path
    final file = File(filePath);

    // Check if the file exists
    if (await file.exists()) {
      debugPrint('File found at the provided path: $filePath');
      return file;
    
    } else {
      debugPrint('File not found at the provided path: $filePath');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Display")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Show loading indicator
            : qrCodeFile != null
                ? Image.file(
                    qrCodeFile!, // Display QR code image
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  )
                : const Text("QR code not found."), // Message if file is null
      ),
    );
  }
}

extension on MySQLConnection {
  query(String s, List<int> list) {}
}

// extension on MySQLConnection {
//   query(String s, Map<String, int> map) {}
// }


