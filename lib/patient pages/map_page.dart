import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> pharmacies = [
    {
      'name': 'Pharmacy One',
      'address': '123 Main Street',
      'contact': '123-456-7890',
    },
    {
      'name': 'HealthPlus Pharmacy',
      'address': '456 Elm Avenue',
      'contact': '234-567-8901',
    },
    {
      'name': 'WellCare Pharmacy',
      'address': '789 Pine Road',
      'contact': '345-678-9012',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F6F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  'Pharmacy Locator',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF602E9E),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for pharmacies...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 20),

              // List of Pharmacies
              Expanded(
                child: ListView.builder(
                  itemCount: pharmacies.length,
                  itemBuilder: (context, index) {
                    if (_searchController.text.isEmpty ||
                        pharmacies[index]['name']!
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase())) {
                      return PharmacyCard(
                        name: pharmacies[index]['name']!,
                        address: pharmacies[index]['address']!,
                        contact: pharmacies[index]['contact']!,
                      );
                    } else {
                      return Container(); // Hide items not matching the search
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PharmacyCard extends StatelessWidget {
  final String name;
  final String address;
  final String contact;

  const PharmacyCard({
    Key? key,
    required this.name,
    required this.address,
    required this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background for pharmacy card
        borderRadius: BorderRadius.circular(12),
        border: GradientBoxBorder(
          width: 2,
          gradient: LinearGradient(
            colors: [Color(0xffA16AE8), Color(0xff94b9ff)],
          ),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF602E9E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              address,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  contact,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
