import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Centered Title - Account Information
                const Center(
                  child: Text(
                    'Account Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xff602E9E),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Container for Profile Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: GradientBoxBorder(
                      width: 2,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffa16ae8),
                          Color(0xff94b9ff),
                        ],
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ProfileDetailRow(title: 'Age', value: '24'),
                      ProfileDetailRow(title: 'Sex', value: 'Female'),
                      ProfileDetailRow(title: 'Blood Type', value: 'O+'),
                      ProfileDetailRow(title: 'Height', value: '5\'6"'),
                      ProfileDetailRow(title: 'Weight', value: '60 kg'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Sections with information
                const SectionWithDetails(
                  sectionTitle: 'Contact Information',
                  details: [
                    {'Phone': '0917-123-4567'},
                    {'Email': 'example@email.com'},
                  ],
                ),
                const SectionWithDetails(
                  sectionTitle: 'Home Address',
                  details: [
                    {'Street': '123 Fairy Lane'},
                    {'City': 'Magic City'},
                    {'Country': 'Dreamland'},
                  ],
                ),
                const SectionWithDetails(
                  sectionTitle: 'Medical History',
                  details: [
                    {'Condition': 'Allergy - Pollen'},
                    {'Medications': 'Vitamin C, Allergy Relief'},
                  ],
                ),
                const SectionWithDetails(
                  sectionTitle: 'Emergency Contact',
                  details: [
                    {'Name': 'Jane Doe'},
                    {'Relationship': 'Sister'},
                    {'Phone': '0922-987-6543'},
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final String title;
  final String value;

  const ProfileDetailRow({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionWithDetails extends StatelessWidget {
  final String sectionTitle;
  final List<Map<String, String>> details;

  const SectionWithDetails({
    Key? key,
    required this.sectionTitle,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xff602E9E),
            ),
          ),
          const SizedBox(height: 10),
          // List of details under the section
          ...details.map((detail) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    detail.keys.first,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    detail.values.first,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
