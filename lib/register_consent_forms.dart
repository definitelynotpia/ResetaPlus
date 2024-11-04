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
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Image.asset('assets/logo_ResetaPlus_name.png'),
              ),
            ),

            Expanded(
              // TabView container
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CustomTabBar(
                  tabIndex: widget.page,
                  tabNames: const [
                    "TERMS & CONDITIONS",
                    "PRIVACY POLICY",
                  ],
                  tabs: const <Widget>[
                    // terms & conditions
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "1. Introduction",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "2. User Responsibilities",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "3. Privacy Policy",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Donec ullamcorper nulla non metus auctor fringilla. Nullam id dolor id nibh ultricies vehicula ut id elit.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "4. Intellectual Property",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Curabitur blandit tempus porttitor. Aenean lacinia bibendum nulla sed consectetur. Etiam porta sem malesuada magna mollis euismod. Cras mattis consectetur purus sit amet fermentum.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "5. Limitation of Liability",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "6. Changes to Terms",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Vestibulum id ligula porta felis euismod semper. Cras mattis consectetur purus sit amet fermentum. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Donec ullamcorper nulla non metus auctor fringilla.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "7. Governing Law",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Maecenas faucibus mollis interdum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),

                    // privacy policy
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "1. Introduction",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae elit libero, a pharetra augue. Aenean lacinia bibendum nulla sed consectetur.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "2. Information We Collect",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Sed posuere consectetur est at lobortis. Curabitur blandit tempus porttitor. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "3. How We Use Your Information",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Cras justo odio, dapibus ac facilisis in, egestas eget quam. Proin eget tortor risus. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "4. Data Protection",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Etiam porta sem malesuada magna mollis euismod. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Vestibulum id ligula porta felis euismod semper.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "5. Sharing Your Information",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Donec sed odio dui. Vestibulum id ligula porta felis euismod semper. Nulla vitae elit libero, a pharetra augue.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "6. Cookies and Tracking Technologies",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh. Cras mattis consectetur purus sit amet fermentum.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "7. Your Data Rights",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Nulla vitae elit libero, a pharetra augue. Aenean lacinia bibendum nulla sed consectetur.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "8. Changes to This Privacy Policy",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Vestibulum id ligula porta felis euismod semper. Cras mattis consectetur purus sit amet fermentum.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "9. Contact Us",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Aenean lacinia bibendum nulla sed consectetur. Nulla vitae elit libero, a pharetra augue.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Consent forms buttons
            Padding(
              padding: const EdgeInsets.all(10),
              // return to Register
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Color(0xff8d4fdf),
                    ),
                    SizedBox(width: 3),
                    Text(
                      "Back to Register",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff8d4fdf),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
