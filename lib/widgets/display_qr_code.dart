import 'dart:io';
import 'dart:async';   
import 'package:resetaplus/main.dart';

import 'package:flutter/material.dart';
 // For loading environment variables


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
  bool isLoading = true; 


  @override
  void initState() {
    super.initState();
    // testFunction();
    fetchQrCode(); // Fetch QR code file path when the widget is initialized
    
  }
  
  Future<void> fetchQrCode() async {
    try {
      String? filePath = await fetchQrCodeFilePath(widget.prescriptionId); // Fetch the file path
      qrCodeFile = await locateQrCode(filePath);

      if (mounted) {
        setState(() {
          qrFilePath = filePath; // Update the state with the fetched path
          isLoading = false; // Set loading to false
        });
      }
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
  Future <String?> fetchQrCodeFilePath(int prescriptionId) async {
      final conn = await createConnection();
      debugPrint("Connected to DB");

      try {
        debugPrint("Fetching QR code file path for prescription ID: $prescriptionId");

        // For testing
        // const testQuery = '''
        //   SELECT qr_code_filepath 
        //   FROM patient_prescriptions 
        //   WHERE prescription_id = 2''';

        const query = '''
          SELECT qr_code_filepath 
          FROM patient_prescriptions 
          WHERE prescription_id = :prescriptionId''';

        var result = await conn.execute(query, {'prescriptionId': widget.prescriptionId,});

        debugPrint("Query result: $result");

          // Check if the result has rows
          if (result.rows.isNotEmpty) {  // Check the number of rows returned
            // Access each row
              return result.rows.first.colByName('qr_code_filepath')?.toString(); // Change type casting as necessary
          } else {
            debugPrint('No data found for prescription ID: $prescriptionId');
            return null;
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

