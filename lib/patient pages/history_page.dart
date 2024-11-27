import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Map<String, String>> medicalHistory = [
    {
      'date': '2023-01-15',
      'condition': 'Flu',
      'treatment': 'Rest and hydration',
    },
    {
      'date': '2023-03-22',
      'condition': 'Allergy',
      'treatment': 'Antihistamines',
    },
    {
      'date': '2023-06-10',
      'condition': 'Fractured Arm',
      'treatment': 'Cast for 6 weeks',
    },
  ];

  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();

  void _addEntry() {
    final String condition = _conditionController.text;
    final String treatment = _treatmentController.text;
    if (condition.isNotEmpty && treatment.isNotEmpty) {
      setState(() {
        medicalHistory.add({
          'date': DateTime.now().toLocal().toString().split(' ')[0],
          'condition': condition,
          'treatment': treatment,
        });
        _conditionController.clear();
        _treatmentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  'Medical History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF602E9E),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Container for Adding New Entry
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF602E9E), width: 2),
                ),
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a New Entry',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF602E9E),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _conditionController,
                      decoration: InputDecoration(
                        labelText: 'Condition',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _treatmentController,
                      decoration: InputDecoration(
                        labelText: 'Treatment',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addEntry,
                      child: Text('Add Entry'),
                    ),
                  ],
                ),
              ),

              // List of Medical History Entries
              ListView.builder(
                itemCount: medicalHistory.length,
                shrinkWrap: true, // Use shrinkWrap to limit height
                physics: NeverScrollableScrollPhysics(), // Disable scrolling
                itemBuilder: (context, index) {
                  return MedicalHistoryCard(
                    date: medicalHistory[index]['date']!,
                    condition: medicalHistory[index]['condition']!,
                    treatment: medicalHistory[index]['treatment']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicalHistoryCard extends StatelessWidget {
  final String date;
  final String condition;
  final String treatment;

  const MedicalHistoryCard({
    Key? key,
    required this.date,
    required this.condition,
    required this.treatment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF602E9E), width: 2),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Condition: $condition',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Treatment: $treatment',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
