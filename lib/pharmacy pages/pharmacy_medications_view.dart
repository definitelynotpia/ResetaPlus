import 'package:flutter/material.dart';
import 'package:resetaplus/services/connection_service.dart';

class PharmacyMedicationsPage extends StatefulWidget {
  const PharmacyMedicationsPage({super.key, required this.title});

  final String title;

  @override
  State<PharmacyMedicationsPage> createState() =>
      _PharmacyMedicationsPageState();
}

class _PharmacyMedicationsPageState extends State<PharmacyMedicationsPage> {
  List<Map<String, dynamic>> medications = [];
  String? selectedMedicationForm;

  @override
  void initState() {
    super.initState();
    fetchMedications();
  }

  Future<void> fetchMedications() async {
    try {
      final conn = await createConnection();
      var result = await conn.execute('SELECT * FROM medications;');

      List<Map<String, dynamic>> fetchedMedications = [];
      for (var row in result.rows) {
        var assoc = row.assoc();
        fetchedMedications.add({
          'id': assoc['medication_id'],
          'name': assoc['medication_name'],
          'form': assoc['medication_form'],
          'manufacturer': assoc['manufacturer'],
          'info': assoc['medication_info'],
          'description': assoc['medication_description'],
        });
      }
      await conn.close();

      setState(() {
        medications = fetchedMedications;
      });
    } catch (e) {
      debugPrint("Error fetching medications: $e");
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      final conn = await createConnection();
      // Delete associated dosages first
      await conn.execute(
        'DELETE FROM medications_dosage WHERE medication_id = :id',
        {'id': id},
      );
      await conn.execute('DELETE FROM medications WHERE medication_id = :id', {
        'id': id,
      });
      await conn.close();

      setState(() {
        medications.removeWhere((medication) => medication['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medication deleted successfully.")),
      );
    } catch (e) {
      debugPrint("Error deleting medication: $e");
    }
  }

  Future<void> updateMedication(String id, String name, String form,
      String manufacturer, String info, String description) async {
    try {
      final conn = await createConnection();
      await conn.execute('''
        UPDATE medications 
        SET medication_name = :name, medication_form = :form, manufacturer = :manufacturer, 
            medication_info = :info, medication_description = :description
        WHERE medication_id = :id
      ''', {
        'id': id,
        'name': name,
        'form': form,
        'manufacturer': manufacturer,
        'info': info,
        'description': description,
      });
      await conn.close();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medication updated successfully.")),
      );

      fetchMedications(); // Refresh the list
    } catch (e) {
      debugPrint("Error updating medication: $e");
    }
  }

  void showDeleteConfirmation(
      BuildContext context, String medicationName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Medication'),
          content: Text('Are you sure you want to delete "$medicationName"?'),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            // Confirm button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Call the callback to handle deletion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _showEditPopup(Map<String, dynamic> medication) {
    final _formKey = GlobalKey<FormState>();
    String name = medication['name'];
    String form = medication['form'];
    String manufacturer = medication['manufacturer'];
    String info = medication['info'];
    String description = medication['description'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Medication'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) => name = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    items: const [
                      DropdownMenuItem(
                          value: 'capsule', child: Text('Capsule')),
                      DropdownMenuItem(value: 'tablet', child: Text('Tablet')),
                    ],
                    onChanged: (value) => form = value!,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    decoration: const InputDecoration(labelText: 'Form'),
                  ),
                  TextFormField(
                    initialValue: manufacturer,
                    decoration:
                        const InputDecoration(labelText: 'Manufacturer'),
                    onChanged: (value) => manufacturer = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    initialValue: info,
                    decoration: const InputDecoration(labelText: 'Information'),
                    onChanged: (value) => info = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) => description = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  updateMedication(medication['id'], name, form, manufacturer,
                      info, description);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
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
        title: const Text('Medications'),
      ),
      body: ListView.builder(
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                medication['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Form: ${medication['form']}'),
                  Text('Manufacturer: ${medication['manufacturer']}'),
                  Text('Information: ${medication['info']}'),
                  Text('Description: ${medication['description']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Open the edit popup
                      _showEditPopup(medication);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDeleteConfirmation(context, medication['name'], () {
                        deleteMedication(medication['id']);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
