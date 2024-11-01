import 'package:flutter/material.dart';
import './widgets/custom_tabview.dart';

class RegisterConsentForms extends StatefulWidget {
  int page;

  RegisterConsentForms({
    super.key,
    required this.page,
  });

  @override
  State<RegisterConsentForms> createState() => _RegisterConsentFormsState();
}

class _RegisterConsentFormsState extends State<RegisterConsentForms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F6F5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // logo
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.04,
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
                child: Image.asset('assets/logo_ResetaPlus.png'),
              ),
            ),

            const Expanded(
              child: // TabView container
                  CustomTabBar(
                tabNames: [
                  "TERMS & CONDITIONS",
                  "PRIVACY POLICY",
                ],
                tabs: <Widget>[
                  // terms & conditions
                  SingleChildScrollView(
                    child: Center(
                      child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  // privacy policy
                  SingleChildScrollView(
                    child: Center(
                      child: Text(
                        "Suspendisse euismod ante neque, non convallis ante faucibus non.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
