// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:gradient_borders/gradient_borders.dart';
import 'package:resetaplus/services/connection_service.dart';
import './custom_ticket_card.dart';

class PrescriptionCard extends StatefulWidget {
  const PrescriptionCard(
      {super.key,
      required this.drugName,
      required this.drugInfo,
      required this.description,
      required this.prescriptionId});

  final double borderRadiussSize = 10;
  final String drugName;
  final String drugInfo;
  final String description;
  final String prescriptionId;

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
  // String? prescriptionId;
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
    getPrescriptionId(widget.prescriptionId);
    getPrescriptionData();
  }

  // Refreshes Media folders of the device
  // This ensures the that QR code we download shows up in the gallery
  mediaScan() {
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('com.example.resetaplus/fileScanner');
        channel.invokeMethod('scanFile',
            {'path': androidDownloadDirectory, 'mimeType': 'image/png'});
      } catch (e) {
        debugPrint("Error triggering media scan: $e");
      }
    }
  }

  // Creates folder named ResetaPlus
  createFolder() async {
    if (Platform.isAndroid) {
      downloadDirectory = androidDownloadDirectory;
      dirExists = await Directory(downloadDirectory).exists();

      if (!dirExists) {
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
      'Drug Name': widget.drugName,
      'Patient Name': firstEntry['fetched_patient_name'],
      'Start Date': firstEntry['fetched_prescription_date'],
      'End Date': firstEntry['fetched_prescription_end_date'],
      'Take every': firstEntry['fetched_frequency'],
      'Dosage': firstEntry['fetched_dosage'],
      'Duration': firstEntry['fetched_duration'],
      'Refills': firstEntry['fetched_refills'],
      'Medication Status': firstEntry['fetched_status'],
      'Intake Instructions': firstEntry['fetched_intake_instructions'],
    };

    return qrDataMap.toString();
  }

  Future<void> getPrescriptionData() async {
    final prescriptionId = await getPrescriptionId(widget.prescriptionId);

    try {
      final conn = await createConnection();
      final queryResult = await conn.execute(
        //TODO

        // ADJUST QUERY TO FETCH THE FF:
        // MEDICATION NAME
        // PATIENT NAME
        // *USE JOIN FOR THIS
        '''
        SELECT 
            u.username,
            p.prescription_date,
            p.prescription_end_date,
            p.frequency,
            p.dosage,
            p.duration,
            p.refills,
            p.status,
            p.intake_instructions
        FROM
          reseta_plus.patient_prescriptions p
        JOIN
          reseta_plus.patient_accounts u ON p.patient_id = u.patient_id
        WHERE
          p.prescription_id = :fetchedPrescriptionId;
        ''',
        {
          'fetchedPrescriptionId': prescriptionId,
        },
      );

      List<Map<String, String>> patientPrescription = [];

      for (var row in queryResult.rows) {
        var assoc = row.assoc();
        patientPrescription.add({
          // Specify which columns to get
          'fetched_patient_name': assoc['username'] ?? '',
          'fetched_prescription_date': assoc['prescription_date'] ?? '',
          'fetched_prescription_end_date': assoc['prescription_end_date'] ?? '',
          'fetched_frequency': assoc['frequency'] ?? '',
          'fetched_dosage': assoc['dosage'] ?? '',
          'fetched_duration': assoc['duration'] ?? '',
          'fetched_refills': assoc['refills'] ?? '',
          'fetched_status': assoc['status'] ?? '',
          'fetched_intake_instructions': assoc['intake_instructions'] ?? '',
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

  Future<String?> getPrescriptionId(String prescriptionId) async {
    try {
      final conn = await createConnection();
      final queryResult = await conn.execute(
          // Where are we getting the PrescriptionId?
          // we're specifying a prescriptionId here
          // however we're not getting it from anywhere
          'SELECT prescription_id '
          'FROM patient_prescriptions '
          'WHERE prescription_id = :fetchedPrescriptionId',
          {'fetchedPrescriptionId': prescriptionId});

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

      final prescriptionId = await getPrescriptionId(widget.prescriptionId);

      if (prescriptionId == null) {
        debugPrint("Prescription ID not found");
        _showSnackbarMessage("Prescription ID not found!");
        return;
      }

      final conn = await createConnection();
      await conn.execute(
          'UPDATE patient_prescriptions '
          'SET qr_code_filepath = :new_qr_filepath '
          'WHERE prescription_id = :fetchedPrescriptionId',
          {
            'fetchedPrescriptionId': prescriptionId,
            'new_qr_filepath': qrFilePath
          });

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

      final qrFilePath =
          "$downloadDirectory/qr_code_${DateTime.now().millisecondsSinceEpoch}.png";

      // Convert QR code to an image file
      const double padding = 50.0; // Adjust padding size
      final picData = await painter.toImageData(500);
      final bytes = picData!.buffer.asUint8List();
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      final image = frame.image;

      final paddedImage = await _addPadding(image, padding);

      final qrFile = File(qrFilePath);
      final paddedBytes =
          (await paddedImage.toByteData(format: ImageByteFormat.png))!
              .buffer
              .asUint8List();
      await qrFile.writeAsBytes(paddedBytes);

      mediaScan();

      _showSnackbarMessage("QR Code Successfully downloaded!");

      return qrFilePath; // Return the file path
    } else {
      _showSnackbarMessage("QR Code wasn't downloaded!");
      throw Exception("Invalid QR data");
    }
  }

  Future<ui.Image> _addPadding(ui.Image original, double padding) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final newWidth = original.width + (padding * 2).toInt();
    final newHeight = original.height + (padding * 2).toInt();

    final paint = Paint()..color = Colors.white; // Padding color
    canvas.drawRect(
        Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()), paint);

    canvas.drawImage(original, Offset(padding, padding), Paint());
    final picture = recorder.endRecording();

    return picture.toImage(newWidth, newHeight);
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
          // Prescription No.
          Text(
            widget.prescriptionId,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF602E9E),
            ),
          ),
          SizedBox(height: 5),
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
