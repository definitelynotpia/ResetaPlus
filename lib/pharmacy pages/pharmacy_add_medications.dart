import 'package:flutter/material.dart';
import 'package:resetaplus/main.dart';
import 'package:searchfield/searchfield.dart';

class SearchItem {
  final String name;
  final String id;

  SearchItem({required this.name, required this.id});

  @override
  String toString() =>
      name; // This ensures the name is displayed in the SearchField
}

class PharmacyAddMedicationsPage extends StatefulWidget {
  const PharmacyAddMedicationsPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _PharmacyAddMedicationsState();
}

class _PharmacyAddMedicationsState extends State<PharmacyAddMedicationsPage> {
  // generate global key, uniquely identify Form widget and allow form validation
  final _medicationFormKey = GlobalKey<FormState>();
  final _dosageFormKey = GlobalKey<FormState>();

  String? medicationName;
  String? selectedMedicationForm;
  String? manufacturer;
  String? medicationInfo;
  String? medicationDescription;

  String? selectedMedication;
  String? selectedMedicationId;
  String? dosageAmount;
  List<Map<String, dynamic>> medications = [];
  @override
  void initState() {
    super.initState();
    fetchMedications();
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
              Text('Medication Name: $medicationName'),
              Text('Medication Form: ${selectedMedicationForm ?? 'Unknown'}'),
              Text('Manufacturer: $manufacturer'),
              Text('Medication Information: $medicationInfo'),
              Text('Medication Description: $medicationDescription'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                insertMedication();
                fetchMedications(); //update dosage form
              },
              child: const Text('Submit Medication'),
            ),
          ],
        );
      },
    );
  }

  Future<void> insertDosage() async {
    try {
      final conn = await createConnection();

      await conn.execute(
        'INSERT INTO medications_dosage (medication_id, dosage) '
        'VALUES (:medication_id, :dosage);',
        {
          'medication_id': selectedMedicationId,
          'dosage': dosageAmount,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dosage successfully added.")),
      );

      await conn.close();
    } catch (e) {
      debugPrint("Error: $e");
      _showErrorSnackBar("Failed to add dosage. Please try again.");
    }
  }

  Future<void> fetchMedications() async {
    try {
      final conn = await createConnection();
      var medicationInfo = await conn.execute('''
      SELECT m.medication_id, m.medication_name FROM reseta_plus.medications m;
      ''');

      List<Map<String, dynamic>> medicationDetails = [];

      for (var row in medicationInfo.rows) {
        var assoc = row.assoc();
        medicationDetails.add({
          'medication_id': assoc['medication_id'] ?? '',
          'medication_name': assoc['medication_name'] ?? '',
        });
      }
      await conn.close();
      setState(() {
        medications = medicationDetails;
      });
    } catch (e) {
      _showErrorSnackBar("Error fetching medications: $e");
    }
  }

  Future<void> insertMedication() async {
    final conn = await createConnection();
    ;
    try {
      await conn.execute(
          'INSERT INTO medications ('
          'medication_name,'
          'medication_form,'
          'manufacturer,'
          'medication_info,'
          'medication_description)'
          'VALUES ('
          ':medication_name,'
          ':medication_form,'
          ':manufacturer,'
          ':medication_info,'
          ':medication_description)',
          {
            'medication_name': medicationName,
            'medication_form': selectedMedicationForm,
            'manufacturer': manufacturer,
            'medication_info': medicationInfo,
            'medication_description': medicationDescription,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Medication successfully added.")));
      }
    } catch (e) {
      debugPrint("Error: $e");
      _showErrorSnackBar("Failed to insert medication. Please try again.");
    } finally {
      await conn.close();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Medication and Dosage'),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            // Section: Medication Form
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _medicationFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Medication',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Medication Name Field
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Medication Name'),
                        onChanged: (value) {
                          setState(() {
                            medicationName = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Medication Name cannot be empty.";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Dropdown for Medication Form
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Medication Form'),
                        value: selectedMedicationForm,
                        items: const [
                          DropdownMenuItem(
                              value: 'capsule', child: Text('Capsule')),
                          DropdownMenuItem(
                              value: 'tablet', child: Text('Tablet')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedMedicationForm = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a medication form.";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Manufacturer Field
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Manufacturer'),
                        onChanged: (value) {
                          setState(() {
                            manufacturer = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Manufacturer cannot be empty.";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Medication Information Field
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Medication Information'),
                        onChanged: (value) {
                          setState(() {
                            medicationInfo = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Medication Information cannot be empty.";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Medication Information Field
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Medication Description'),
                        onChanged: (value) {
                          setState(() {
                            medicationDescription = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Medication Description cannot be empty.";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Submit Button for Medication
                      ElevatedButton(
                        onPressed: () {
                          if (_medicationFormKey.currentState!.validate()) {
                            _showPrescriptionSummary(); // Insert medication function
                          }
                        },
                        child: const Text('Add Medication'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section: Dosage Form
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _dosageFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Dosage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

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
                                  width: 2,
                                  color: Colors.blue.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          maxSuggestionsInViewPort: 6,
                          itemHeight: 50,
                          suggestionsDecoration: SuggestionDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onSuggestionTap:
                              (SearchFieldListItem<SearchItem> item) {
                            setState(() {
                              selectedMedication = item.item!.name;
                              selectedMedicationId = item.item!.id;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              value = selectedMedication;
                              return "Field cannot be empty.";
                            }
                            return null;
                          },
                          suggestions: medications
                              .map((medication) =>
                                  SearchFieldListItem<SearchItem>(
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

                      const SizedBox(height: 10),

                      // Dosage Field
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Dosage Amount'),
                        onChanged: (value) {
                          dosageAmount = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Dosage cannot be empty.";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Submit Button for Dosage
                      ElevatedButton(
                        onPressed: () {
                          if (_dosageFormKey.currentState!.validate()) {
                            insertDosage(); // Insert dosage function
                          }
                        },
                        child: const Text('Add Dosage'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
