import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resetaplus/main.dart';

class SearchItem {
  final String name;
  final String id;

  SearchItem({required this.name, required this.id});

  @override
  String toString() =>
      name; // This ensures the name is displayed in the SearchField
}

class PrescriptionPopupForm extends StatefulWidget {
  @override
  _PrescriptionPopupFormState createState() => _PrescriptionPopupFormState();
}

class _PrescriptionPopupFormState extends State<PrescriptionPopupForm> {
  final _formKey = GlobalKey<FormState>();

  String? selectedPatient;
  String? selectedMedication;
  String? selectedDosage;
  String? selectedPatientId;
  String? selectedMedicationId;
  String? frequency;
  String? duration;
  String? intakeInstructions;
  String? doctorId;
  String refills = '0';
  String status = 'active';
  List<Map<String, String>> patients = [];
  List<Map<String, String>> medications = [];
  List<String> dosages = [];

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
        'INSERT INTO patient_prescriptions (patient_id, medication_id, prescription_date, prescription_end_date, frequency, dosage, duration, refills, status, intake_instructions, doctor_id) VALUES (:patient_id, :medication_id, :prescription_date, :prescription_end_date, :frequency, :dosage, :duration, :refills, :status, :intake_instructions, :doctor_id)',
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Prescription'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // SearchField for Patient Selection
              Padding(
                padding: EdgeInsets.all(8.0),
                child: SearchField<SearchItem>(
                  hint: 'Search for Patient',
                  searchInputDecoration: SearchInputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueGrey.shade200, width: 1),
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
                      return "Field cannot be empty.";
                    }
                    return null;
                  },
                  suggestions: patients
                      .map((patient) => SearchFieldListItem<SearchItem>(
                            patient['patient_username'] ?? "Unknown",
                            item: SearchItem(
                              name: patient['patient_username'] ?? "Unknown",
                              id: patient['patient_id'] ?? "",
                            ),
                          ))
                      .toList(),
                ),
              ),

              // SearchField for Medication Selection
              Padding(
                padding: EdgeInsets.all(8.0),
                child: SearchField<SearchItem>(
                  hint: 'Search for Medication',
                  searchInputDecoration: SearchInputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueGrey.shade200, width: 1),
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
                      return "Field cannot be empty.";
                    }
                    return null;
                  },
                  suggestions: medications
                      .map((medication) => SearchFieldListItem<SearchItem>(
                            medication['medication_name'] ?? "Unknown",
                            item: SearchItem(
                              name: medication['medication_name'] ?? "Unknown",
                              id: medication['medication_id'] ?? "",
                            ),
                          ))
                      .toList(),
                ),
              ),

              // Dropdown for Dosage Selection
              Padding(
                padding: EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blueGrey.shade200, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 2, color: Colors.blue.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  value: selectedDosage,
                  hint: Text('Select Dosage'),
                  items: dosages.map((dosage) {
                    return DropdownMenuItem(
                      child: Text(dosage),
                      value: dosage,
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedDosage = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a dosage.";
                    }
                    return null;
                  },
                ),
              ),

              // TextFields for Frequency, Duration, and Intake Instructions
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Frequency(times/day)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    frequency = value;
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
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Duration (in days)'),
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
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Intake Instructions'),
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

              // Submit Button
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      insertPrescription();
                      Navigator.of(context)
                        .pop(); // Close the dialog after submitting
                    }
                  },
                  child: Text('Submit Prescription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
