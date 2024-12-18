// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:searchfield/searchfield.dart';
// import 'package:gradient_borders/gradient_borders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resetaplus/services/connection_service.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:media_store_plus/media_store_plus.dart';

class SearchItem {
  final String name;
  final String id;

  SearchItem({required this.name, required this.id});

  @override
  String toString() =>
      name; // This ensures the name is displayed in the SearchField
}

class DoctorAddPrescriptionPage extends StatefulWidget {
  const DoctorAddPrescriptionPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _DoctorAddPrescriptionState();
}

class _DoctorAddPrescriptionState extends State<DoctorAddPrescriptionPage> {
  // generate global key, uniquely identify Form widget and allow form validation
  final _formKey = GlobalKey<FormState>();

  String? selectedPatient;
  String? selectedMedication;
  String? selectedDosage;
  String? selectedPatientId;
  String? selectedMedicationId;
  String? frequency;
  String frequencyUnit = 'hours';
  String? duration;
  String? intakeInstructions;
  String? doctorId;
  String refills = '0';
  String status = 'active';
  String qrFilePath = 'No QR Code';
  List<Map<String, String>> patients = [];
  List<Map<String, String>> medications = [];
  List<String> dosages = [];
  bool dirExists = false;
  dynamic downloadDirectory;
  dynamic androidDownloadDirectory = '/storage/emulated/0/Download/ResetaPlus';

  @override
  void initState() {
    super.initState();
    fetchPatients();
    fetchMedications();
    _getDoctorId();
  }

  void fetchPatients() async {
    try {
      final conn = await createConnection();
      var patientInfo = await conn.execute('''
      SELECT p.patient_id, p.username FROM reseta_plus.patient_accounts p;
      ''');

      List<Map<String, String>> patientDetails = [];

      for (var row in patientInfo.rows) {
        var assoc = row.assoc();
        patientDetails.add({
          'patient_id': assoc['patient_id'] ?? '',
          'patient_username': assoc['username'] ?? '',
        });
      }

      setState(() {
        patients = patientDetails;
      });
    } catch (e) {
      _showErrorSnackBar("Error fetching patients: $e");
    }
  }

  void fetchMedications() async {
    try {
      final conn = await createConnection();
      var medicationInfo = await conn.execute('''
      SELECT m.medication_id, m.medication_name FROM reseta_plus.medications m;
      ''');

      List<Map<String, String>> medicationDetails = [];

      for (var row in medicationInfo.rows) {
        var assoc = row.assoc();
        medicationDetails.add({
          'medication_id': assoc['medication_id'] ?? '',
          'medication_name': assoc['medication_name'] ?? '',
        });
      }

      setState(() {
        medications = medicationDetails;
      });
    } catch (e) {
      _showErrorSnackBar("Error fetching medications: $e");
    }
  }

  void fetchDosages(String medication) async {
    try {
      final conn = await createConnection();
      var dosageInfo = await conn.execute('''
      SELECT d.dosage FROM reseta_plus.medications m
      JOIN reseta_plus.medications_dosage d ON d.medication_id = m.medication_id
      WHERE m.medication_name = :medication_name
      ''', {'medication_name': medication});

      List<String> dosageDetails = [];

      for (var row in dosageInfo.rows) {
        var assoc = row.assoc();
        String? dosage = assoc['dosage'];
        if (dosage != null) {
          dosageDetails.add(dosage);
        }
      }

      setState(() {
        dosages = dosageDetails;
        selectedDosage = null;
      });
    } catch (e) {
      _showErrorSnackBar("Error fetching dosages: $e");
    }
  }

  Future<void> _getDoctorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      doctorId = prefs.getString('doctor_id') ?? '0';
    });
  }

  Future<void> insertPrescription() async {
    try {
      final conn = await createConnection();
      await conn.execute(
        'INSERT INTO patient_prescriptions ('
        'patient_id,'
        'medication_id,'
        'prescription_date,'
        'prescription_end_date,'
        'frequency,'
        'dosage,'
        'duration,'
        'refills,'
        'status,'
        'intake_instructions,'
        'doctor_id,'
        'qr_code_filepath)'
        'VALUES ('
        ':patient_id,'
        ':medication_id,'
        ':prescription_date,'
        ':prescription_end_date,'
        ':frequency,'
        ':dosage,'
        ':duration,'
        ':refills,'
        ':status,'
        ':intake_instructions,'
        ':doctor_id,'
        ':qr_code_filepath)',
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
          'qr_code_filepath': qrFilePath,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Prescription successfully made.")));
      }
      await conn.close();
    } catch (e) {
      debugPrint("Error: $e");
      _showErrorSnackBar("Failed to insert prescription. Please try again.");
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showPrescriptionSummary() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Prescription Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please ensure all the fields are correct'),
              Text('Patient: ${selectedPatient ?? 'Unknown'}'),
              Text('Medication: ${selectedMedication ?? 'Unknown'}'),
              Text('Dosage: ${selectedDosage ?? 'Unknown'}'),
              Text('Frequency: $frequency'),
              Text('Duration: $duration'),
              Text('Intake Instructions: $intakeInstructions'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                insertPrescription();
              },
              child: const Text('Submit Prescription'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Prescription'),
        ),
        body: Center(
            child: Form(
                key: _formKey,
                child: ListView(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchField<SearchItem>(
                      hint: 'Search for Patient',
                      searchInputDecoration: SearchInputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blueGrey.shade200, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Colors.blue.withOpacity(0.8)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxSuggestionsInViewPort: 6,
                      itemHeight: 50,
                      suggestionsDecoration: SuggestionDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSuggestionTap: (SearchFieldListItem<SearchItem> item) {
                        setState(() {
                          selectedPatient = item.item!.name;
                          selectedPatientId = item.item!.id;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          value = selectedPatient;
                          return "Field cannot be empty.";
                        }
                        return null;
                      },
                      suggestions: patients
                          .map((patient) => SearchFieldListItem<SearchItem>(
                                patient['patient_username'] ?? "Unknown",
                                item: SearchItem(
                                  name:
                                      patient['patient_username'] ?? "Unknown",
                                  id: patient['patient_id'] ?? "",
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchField<SearchItem>(
                      hint: 'Search for Medication',
                      searchInputDecoration: SearchInputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blueGrey.shade200, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Colors.blue.withOpacity(0.8)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxSuggestionsInViewPort: 6,
                      itemHeight: 50,
                      suggestionsDecoration: SuggestionDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSuggestionTap: (SearchFieldListItem<SearchItem> item) {
                        setState(() {
                          selectedMedication = item.item!.name;
                          selectedMedicationId = item.item!.id;
                          fetchDosages(selectedMedication!);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          value = selectedDosage;
                          return "Field cannot be empty.";
                        }
                        return null;
                      },
                      suggestions: medications
                          .map((medication) => SearchFieldListItem<SearchItem>(
                                medication['medication_name'] ?? "Unknown",
                                item: SearchItem(
                                  name: medication['medication_name'] ??
                                      "Unknown",
                                  id: medication['medication_id'] ?? "",
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // Dropdown for Dosage Selection
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blueGrey.shade200, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Colors.blue.withOpacity(0.8)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: selectedDosage,
                      hint: Text(dosages.isEmpty
                          ? 'No Dosage Available'
                          : 'Select Dosage'),
                      items: dosages.map((dosage) {
                        return DropdownMenuItem(
                          value: dosage,
                          child: Text(dosage),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedDosage = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          value = selectedDosage;
                          return "Please select a dosage.";
                        }
                        return null;
                      },
                    ),
                  ),

                  // Frequency Text Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Frequency Input Field
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Frequency (times per period)'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                frequency = value.isNotEmpty
                                    ? '$value $frequencyUnit'
                                    : null;
                              });
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  int.tryParse(value) == null) {
                                return "Frequency must be a valid number.";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Dropdown for "days" or "hours"
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey.shade200, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2,
                                    color: Colors.blue.withOpacity(0.8)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            value: frequencyUnit,
                            hint: const Text('Select unit'),
                            items: ['days', 'hours'].map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                frequencyUnit = newValue!;
                                frequency = frequency != null
                                    ? '${frequency!.split(' ').first} $frequencyUnit'
                                    : null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration Text Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Duration (in days)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        duration = value;
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return "Duration must be a valid number.";
                        }
                        return null;
                      },
                    ),
                  ),

                  // Intake Instructions Text Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Intake Instructions'),
                      onChanged: (value) {
                        intakeInstructions = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Intake instructions cannot be empty.";
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _showPrescriptionSummary();
                          }
                        },
                        child: const Text('Submit')),
                  )
                ]))));
  }
}
