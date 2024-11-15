// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:gradient_borders/gradient_borders.dart';
import '../main.dart';
import './custom_ticket_card.dart';

class PrescriptionCard extends StatefulWidget {
  const PrescriptionCard({
    super.key,
    required this.drugName,
    required this.drugInfo,
    required this.description,
  });

  final double borderRadiussSize = 10;
  final String drugName;
  final String drugInfo;
  final String description;

  @override
  State<PrescriptionCard> createState() => _CurrentPrescription();
  
}

class _CurrentPrescription extends State<PrescriptionCard> {

  String? selectedPatient;
  String? selectedMedication;
  String? selectedDosage;
  String? selectedPatientId;
  String? selectedMedicationId;
  String? frequency;
  String? duration;
  String? intakeInstructions;
  String? doctorId;
  int prescriptionId = 0;
  String refills = '0';
  String status = 'active';
  String qrFilePath = 'No QR Code';
  bool dirExists = false;
  dynamic downloadDirectory;
  dynamic androidDownloadDirectory = '/storage/emulated/0/Download/ResetaPlus';

  Future<void> getPrescriptionData() async {
    try {
      final qrData = generateQRCodeData();
      final qrFilePath = await saveQRCode(qrData);
      
      final conn = await createConnection();
      await conn.execute(
        'SELECT * FROM patient_prescriptions',
        {
          'patient_id': selectedPatientId,
          'medication_id': selectedMedicationId,
          'prescription_date':
              DateTime.now().toIso8601String().split('T').first,
          'prescription_end_date': DateTime.now()
              .add(Duration(days: int.parse(duration!)))
              .toIso8601String()
              .split('T')
              .first,
          'frequency': frequency,
          'dosage': selectedDosage,
          'duration': duration,
          'refills': refills,
          'status': status,
          'intake_instructions': intakeInstructions,
          'doctor_id': doctorId,
          'qr_code_filepath': qrFilePath
        },
      );

      await conn.close();
    } catch (e) {
      debugPrint("Error: $e");
      // _showErrorSnackBar("Failed to insert prescription. Please try again.");
    }
  }

  Future<int> _getPrescriptionId() async {
    try {
      final conn = await createConnection();
      await conn.execute(
      'SELECT prescription_id'
      'FROM patient_prescriptions;',
      {'prescription_id': prescriptionId},
      );

    } catch (e) {
      debugPrint("Error fetching medications: $e");
    }

    return prescriptionId;
  }

  Future<void> updateQRCodeFilePath() async {

    //prescriptionId = _getprescriotionId();
    try {
      final conn = await createConnection();
      await conn.execute(
        'UPDATE patient_prescriptions'
        'SET (qr_code_filepath = :qrFilePath'
        'WHERE patient_id = :_getPrescriptionId();'
      );

    } catch (e) {
      debugPrint("$e");
    }
  }

// Stores the inputs in the form fields into a Map
// It then parses the data into a string
  String generateQRCodeData(){
    final qrData = {
    // 'prescription_date': DateTime.now().toIso8601String().split('T').first,
    // 'prescription_end_date': DateTime.now()
    //     .add(Duration(days: int.parse(duration!)))
    //     .toIso8601String()
    //     .split('T')
    //     .first,
    'frequency': frequency,
    'dosage': selectedDosage,
    'duration': duration,
    'refills': refills,
    'status': status,
    'intake_instructions': intakeInstructions,
  };

  return qrData.toString();
  
}

  //Scans the device to refresh the gallery
  // TO DO:
  // Determine if this needs to be moved within the save Qr Code function
  mediaScan() {
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('com.example.resetaplus/fileScanner');
        channel.invokeMethod('scanFile', {'path': androidDownloadDirectory, 'mimeType': 'image/png'});
      } catch (e) {
        debugPrint("Error triggering media scan: $e");
      }
    }
  }

  createFolder() async {
    if (Platform.isAndroid){
      downloadDirectory = androidDownloadDirectory;
      dirExists = await Directory(downloadDirectory).exists();
          
      if(!dirExists){
        await Directory(downloadDirectory).create(recursive: true);
        dirExists = true;
      } 
    }
  }

// Saves data into a QR Code into your local Documents folder
  Future<String> saveQRCode(String qrData) async {
    final qrValidationResult = QrValidator.validate(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        gapless: true,
        emptyColor: Colors.white,
      );

      // For Mobile Devices
      if (Platform.isIOS) {
        downloadDirectory = await getApplicationDocumentsDirectory();
      } else {
        downloadDirectory = androidDownloadDirectory;
      }
      
      if (downloadDirectory == null) {
        throw 'Could not get downloads directory';
      }

      final qrFilePath = "$downloadDirectory/qr_code_${DateTime.now().millisecondsSinceEpoch}.png";

      // For Desktop Directory
      // Get directory where the QR will be saved
      // In this case, its using the local Downloads folder folder
      // final downloadDirectory = await getDownloadsDirectory();
      // final qrFilePath = "${downloadDirectory?.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.jpg";

      createFolder();

      // Convert QR code to an image file
      final picData = await painter.toImageData(500);
      final bytes = picData!.buffer.asUint8List();
      final qrFile = File(qrFilePath);
      await qrFile.writeAsBytes(bytes);

      mediaScan();

      _showSnackbarMessage("QR Code Successfully downloaded!");

      return qrFilePath; // Return the file path
      
    } else {
      throw Exception("Invalid QR data");

    }
  }

  void _showSnackbarMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return TicketWidget(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Icon
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFE0BBE4), // Background color
              borderRadius: BorderRadius.circular(
                  widget.borderRadiussSize), // Rounded edges
            ),
            child: Center(
              child: Icon(
                Icons.local_pharmacy,
                size: 50,
                color: Colors.white, // Icon color
              ),
            ),
          ),
          SizedBox(height: 10),
          // Drug Name
          Text(
            widget.drugName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF602E9E),
            ),
          ),
          SizedBox(height: 5),
          // Drug Type and Dosage
          Text(
            widget.drugInfo,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 5),
          // Short Description
          Text(
            widget.description,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 10),
          // QR Code Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                saveQRCode(generateQRCodeData());
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA16AE8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadiussSize),
                ),
              ),
              child: Text(
                'Get QR Code',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
