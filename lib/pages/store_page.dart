import 'package:flutter/material.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      // add Column widget to have multiple Widgets
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // row = filter button, search bar, search button
          Row(
            children: [
              //use expended if you are using textformfield in row
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 10,
                            spreadRadius: 3,
                            offset: const Offset(5, 5))
                      ]),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search here...',
                        prefixIcon: Icon(Icons.search)),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),

              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 10,
                            spreadRadius: 3,
                            offset: const Offset(5, 5))
                      ]),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.sort,
                      size: 26,
                    ),
                  ))
            ],
          )

          // container = otc
          // scrollview = cards
          // container = prescription
          // scrollview = cards
          // data from
        ],
      ),
    );
  }
}
