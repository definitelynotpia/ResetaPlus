// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
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
  String? prescriptionId;
  String refills = '0';
  String status = 'active';
  String qrFilePath = 'No QR Code';
  bool dirExists = false;
  List<Map<String, String>> prescriptionData = [];
  dynamic downloadDirectory;
  dynamic androidDownloadDirectory = '/storage/emulated/0/Download/ResetaPlus';
  
  @override
  void initState() {
    super.initState();
    _getPrescriptionId();
    getPrescriptionData();
    
  }
  // Refreshes Media folders of the device
  // This ensures the that QR code we download shows up in the gallery
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

  // Creates folder named ResetaPlus
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

  void _showSnackbarMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // Stores the inputs in the form fields into a Map
  // It then parses the data into a string
  String generateQRCodeData(List<Map<String, String>> qrData) {

  if (qrData.isEmpty) {
    debugPrint("Error: qrData is null or empty");
    return '{}'; // Return an empty JSON object or handle it appropriately
  }

  final firstEntry = qrData.first;

    final qrDataMap = {
    'medication_id': firstEntry['medication_id'],

    // This is causing issues with fetching data. It could be a parsing issue
  
    // 'prescription_date': DateTime.now().toIso8601String().split('T').first,
    // 'prescription_end_date': DateTime.now()
    //     .add(Duration(days: int.parse(duration!)))
    //     .toIso8601String()
    //     .split('T')
    //     .first,
    'frequency': firstEntry['frequency'],
    'dosage': firstEntry['dosage'],
    'duration': firstEntry['duration'],
    'refills': firstEntry['refills'],
    'status': firstEntry['status'],
    'intake_instructions': firstEntry['intake_instructions'],
  };

  return qrDataMap.toString();
  // return jsonEncode(qrDataMap);
  
}

  Future<void> getPrescriptionData() async {

    final prescriptionId = await _getPrescriptionId();

    try {
      final conn = await createConnection();
      final queryResult =  await conn.execute(
        'SELECT * ' 
        'FROM patient_prescriptions '
        'WHERE prescription_id = 1',
        // {
        //   'prescription_id': prescriptionId,
        // },
      );

      List<Map<String, String>> patientPrescription = [];
      
      for (var row in queryResult.rows) {
        var assoc = row.assoc();
        patientPrescription.add({
          // Specify which columns to get
          'medication_id': assoc['medication_id'] ?? '',
          // 'prescription_date': DateTime.now().toIso8601String().split('T').first,
          // 'prescription_end_date': DateTime.now()
          //     .add(Duration(days: int.parse(duration!)))
          //     .toIso8601String()
          //     .split('T')
          //     .first,
          'frequency': assoc['frequency'] ?? '',
          'dosage': assoc['dosage'] ?? '',
          'duration': assoc['duration'] ?? '',
          'refills': assoc['refills'] ?? '',
          'status': assoc['status'] ?? '',
          'intake_instructions': assoc['intake_instructions'] ?? '',
        });
      }


      setState(() {
        prescriptionData = patientPrescription;
      });
      debugPrint("prescriptionData: $prescriptionData");
    } catch (e) {
      debugPrint("Error: $e");
      _showSnackbarMessage("No Data found.");

      return;
    }
  }

  Future<String?> _getPrescriptionId() async {
    try {
      final conn = await createConnection();
      final queryResult = await conn.execute(
        'SELECT prescription_id '
        'FROM patient_prescriptions '
        'WHERE prescription_id = :prescriptionId', 
        {'prescriptionId': prescriptionId}
      );

      if (queryResult.rows.isNotEmpty) {
        return queryResult.rows.first.colAt(0);
      }
        return null;

    } catch (e) {
      debugPrint("Error fetching medications: $e");
      return null;
    }

    // return prescriptionId;
  }

  void updateQRCodeFilePath() async {
    try {

    if (prescriptionData.isEmpty) {
      debugPrint("Error: prescriptionData is null or empty");
      _showSnackbarMessage("No prescription data available!");
      return;
    }

      final qrData = generateQRCodeData(prescriptionData);
      final qrFilePath = await saveQRCode(qrData);
    
      final prescriptionId = await _getPrescriptionId();

      // if (prescriptionId == null) {
      //   debugPrint("Prescription ID not found");
      //   _showSnackbarMessage("Prescription ID not found!");
      //   return;
      // }

      final conn = await createConnection();
      await conn.execute(
        'UPDATE patient_prescriptions '
        'SET qr_code_filepath = :new_qr_filepath '
        'WHERE prescription_id = 1',
        {
          'prescriptionId': prescriptionId,
          'new_qr_filepath': qrFilePath
        }
      );

      await conn.close();

    } catch (e) {
      debugPrint("$e");
      _showSnackbarMessage("QR Code wasn't saved!");
    }
  }

// Saves data into a QR Code into your local Documents folder
  Future<String> saveQRCode(String qrData) async {
    final qrValidationResult = QrValidator.validate(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        gapless: false,
        emptyColor: Colors.white,
      );

      createFolder();

      // For IOS Devices
      if (Platform.isIOS) {
        downloadDirectory = await getApplicationDocumentsDirectory();
      } else {
      // For Android Devices
        downloadDirectory = androidDownloadDirectory;
      }
      
      if (downloadDirectory == null) {
        throw 'Could not get downloads directory';
      }

      final qrFilePath = "$downloadDirectory/qr_code_${DateTime.now().millisecondsSinceEpoch}.png";

      // Convert QR code to an image file
      final picData = await painter.toImageData(500);
      final bytes = picData!.buffer.asUint8List();
      final qrFile = File(qrFilePath);
      await qrFile.writeAsBytes(bytes);

      mediaScan();

      _showSnackbarMessage("QR Code Successfully downloaded!");

      return qrFilePath; // Return the file path
      
    } else {

      _showSnackbarMessage("QR Code wasn't downloaded!");
      throw Exception("Invalid QR data");

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
                updateQRCodeFilePath();
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
