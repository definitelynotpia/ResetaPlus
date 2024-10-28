import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

import 'package:resetaplus/widgets/custom_store_product.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  // generate global key, uniquely identify Form widget and allow form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // row = filter button, search bar, search button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //use expended if you are using textformfield in row
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // search form
                    child: Form(
                      key: _formKey,
                      // search box
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: GradientOutlineInputBorder(
                            gradient: const LinearGradient(
                                colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                            width: 1.0,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          prefixIcon: const Icon(
                            Icons.mail,
                            color: Color(0xFFa16ae8),
                          ),
                          hintText: "Search",
                        ),
                      ),
                    )),
              ),

              // spacer
              const SizedBox(width: 10),

              // filter button
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.sort,
                    size: 26,
                  ),
                ),
              )
            ],
          ),

          // search results
          Expanded(
              child: ListView(
            shrinkWrap: true,
            children: const [
              StoreProduct(),
              StoreProduct(),
              StoreProduct(),
              StoreProduct(),
              StoreProduct(),
              StoreProduct(),
            ],
          ))
          // container = prescription
          // scrollview = cards
          // data from
        ],
      ),
    );
  }
}
