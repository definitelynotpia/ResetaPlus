import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:resetaplus/services/connection_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:resetaplus/account_type_picker_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'patient pages/dashboard_page.dart';
import 'patient pages/store_page.dart';
import 'patient pages/history_page.dart';
import 'patient pages/profile_page.dart';
import 'patient pages/map_page.dart';

import 'doctor pages/doctor_dashboard_page.dart';
import 'doctor pages/doctor_profile_page.dart';
import 'doctor pages/doctor_add_prescription.dart';

import 'pharmacy pages/pharmacy_dashboard_page.dart';
import 'pharmacy pages/pharmacy_scan_qr_page.dart';
import 'pharmacy pages/pharmacy_profile_page.dart';
import 'pharmacy pages/pharmacy_add_medications.dart';
import 'pharmacy pages/pharmacy_medications_view.dart';

final mediaStorePlugin = MediaStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await MediaStore.ensureInitialized();
  }

  List<Permission> permissions = [
    Permission.storage,
  ];

  //   if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
  //   permissions.add(Permission.photos);
  //   permissions.add(Permission.audio);
  //   permissions.add(Permission.videos);
  // }

  await permissions.request();
  // we are not checking the status as it is an example app. You should (must) check it in a production app

  // You have set this otherwise it throws AppFolderNotSetException
  MediaStore.appFolder = "ResetaPlus";

  await dotenv.load(fileName: "assets/.env");
  runApp(const MainApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  // allow other devices to scroll
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  Future<bool> _getLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Checks if 'loggedIn' key exists; if not, it sets a default value of false
    if (!prefs.containsKey('loggedIn')) {
      await prefs.setBool('loggedIn', false);
    }

    return prefs.getBool('loggedIn') ?? false;
  }

  //final bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getLoggedInStatus(),
        builder: (context, snapshot) {
          // Display a loading spinner while the future is being resolved
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there's an error, display an error message
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading preferences'));
          }

          // Get the loggedIn status from the snapshot data
          final bool loggedIn = snapshot.data ?? false;
          return MaterialApp(
            title: "Reseta+", // app title
            theme: ThemeData(
              fontFamily: "Montserrat", // set custom font as default
              // textTheme: Theme.of(context).textTheme.apply(
              //       fontFamily: "Montserrat",
              //       fontSizeFactor: 1.2,
              //     ),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            scrollBehavior:
                MyCustomScrollBehavior().copyWith(scrollbars: false),
            // if user is logged in, go to Home; else, go to Login
            home: loggedIn ? const HomePage() : const RoleSelectionPage(),
          );
        });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double iconSize = 40;

  int currentTab = 0;
  String currentPageTitle = "Dashboard";

  // Patient Navigation Page Keys
  final Key storePage = const PageStorageKey("storePage");
  final Key mapPage = const PageStorageKey("mapPage");
  final Key dashboardPage = const PageStorageKey("dashboardPage");
  final Key historyPage = const PageStorageKey("historyPage");
  final Key profilePage = const PageStorageKey("profilePage");

// Doctor Navigation Page Keys
  final Key doctorAddPrescriptionPage =
      const PageStorageKey("doctorAddPrescriptionPage");
  final Key doctorDashboardPage = const PageStorageKey("doctorDashboardPage");
  final Key doctorProfilePage = const PageStorageKey("doctorProfilePage");

// Pharmacy Navigation Page Keys

  final Key pharmacyDashboardPage =
      const PageStorageKey("pharmacyDashboardPage");
  final Key pharmacyScanQRPage = const PageStorageKey("pharmacyScanQRPage");
  final Key pharmacyProfilePage = const PageStorageKey("pharmacyProfilePage");
  final Key pharmacyAddMedicationsPage =
      const PageStorageKey("pharmacyAddMedicationsPage");
  final Key pharmacyMedicationsPage =
      const PageStorageKey("pharmacyMedicationsPage");

  late StorePage one;
  late MapPage two;
  late DashboardPage three;
  late HistoryPage four;
  late ProfilePage five;

  late DoctorAddPrescriptionPage six;
  late DoctorDashboardPage seven;
  late DoctorProfilePage eight;

  late PharmacyDashboardPage nine;
  late PharmacyScanQRPage ten;
  late PharmacyAddMedicationsPage eleven;
  late PharmacyMedicationsPage twelve;
  late PharmacyProfilePage thirteen;

  late List<Widget> pages;
  // Shows Loading Default page
  late Widget currentPage = const Center(child: CircularProgressIndicator());

  final PageStorageBucket bucket = PageStorageBucket();

  String _usernameSession = "John Doe";
  String _userType = "Default";

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  // Currently used for testing out the logout button
  void _setLoggedInStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', status);
  }

  // Function for getting the user type. Currently used upon initialization
  Future<void> _getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userType = prefs.getString('userType') ?? "Default";
    });
  }

  // Function for getting the username session. Currently used upon initialization
  Future<void> _setusernameSession() async {
    // Await the asynchronous call to get the username
    String? username = await getUsernameSession();

    // Use setState to update the username session
    setState(() {
      _usernameSession = username; // Now username is a String or null
    });
  }

  Future<void> _initializeUserData() async {
    await _setusernameSession();
    await _getUserType();
    setState(() {
      if (_userType == 'Patient') {
        one = StorePage(
          key: storePage,
          title: "Store",
        );
        two = MapPage(
          key: mapPage,
          title: "Map",
        );
        three = DashboardPage(
          key: dashboardPage,
          title: "Dashboard",
        );
        four = HistoryPage(
          key: historyPage,
          title: "History",
        );
        five = ProfilePage(
          key: profilePage,
          title: "Profile",
        );

        pages = [one, two, three, four, five];

        currentTab = 2;
        currentPage = three;
      } else if (_userType == 'Doctor') {
        six = DoctorAddPrescriptionPage(
          key: doctorAddPrescriptionPage,
          title: "Add Prescription",
        );

        seven = DoctorDashboardPage(
          key: doctorDashboardPage,
          title: "Dashboard",
        );

        eight = DoctorProfilePage(
          key: doctorProfilePage,
          title: "Profile",
        );

        pages = [six, seven, eight];

        currentTab = 1;
        currentPage = seven;
      } else if (_userType == 'Pharmacy') {
        nine = PharmacyDashboardPage(
          key: pharmacyDashboardPage,
          title: "Dashboard",
        );

        ten = PharmacyScanQRPage(
          key: pharmacyScanQRPage,
          title: "Scan QR",
        );

        eleven = PharmacyAddMedicationsPage(
            key: pharmacyAddMedicationsPage, title: "Add Medications");

        twelve = PharmacyMedicationsPage(
            key: pharmacyMedicationsPage, title: "Medications View");

        thirteen = PharmacyProfilePage(
          key: pharmacyProfilePage,
          title: "Profile",
        );

        pages = [nine, ten, eleven, twelve, thirteen];

        currentTab = 1;
        currentPage = nine;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // late List<BottomNavigationBarItem> navbarItems;
    List<BottomNavigationBarItem> navbarItems = _patientNavItems;

    if (_userType == 'Patient') {
      navbarItems = _patientNavItems;
    } else if (_userType == 'Doctor') {
      navbarItems = _doctorNavItems;
    } else if (_userType == 'Pharmacy') {
      navbarItems = _pharmacyNavItems;
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8F6F5),
      extendBody: true,

      appBar: AppBar(
        // titleSpacing: MediaQuery.of(context).size.width * 0.03,
        toolbarHeight: 60,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: (currentPage is ProfilePage ||
                  currentPage is DoctorProfilePage ||
                  currentPage is PharmacyProfilePage)
              // if on Profile Page
              ? <Widget>[
                  // Page title
                  Text(
                    _usernameSession,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    _userType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),

                  const Spacer(),

                  // info button
                  IconButton(
                    visualDensity: const VisualDensity(horizontal: -2.0),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.info_outline),
                    color: Colors.white,
                    onPressed: () {},
                  ),

                  // settings button
                  IconButton(
                    visualDensity: const VisualDensity(horizontal: -2.0),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.settings),
                    color: Colors.white,
                    onPressed: () {},
                  ),

                  const SizedBox(width: 4),

                  ElevatedButton(
                    onPressed: () {
                      // Action to perform when the button is pressed
                      _setLoggedInStatus(false);
                      Navigator.pop(context);
                      Navigator.push(
                          context, // Opens another instance of MainApp
                          MaterialPageRoute(
                              builder: (context) => const MainApp()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white),
                        )),
                    child: const Text(
                      "Logout",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ]
              : <Widget>[
                  // Page title
                  Text(
                    currentPageTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),

                  const Spacer(),

                  // info button
                  IconButton(
                    visualDensity: const VisualDensity(horizontal: -2.0),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.info_outline),
                    color: Colors.white,
                    onPressed: () {},
                  ),

                  // settings button
                  IconButton(
                    visualDensity: const VisualDensity(horizontal: -2.0),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.settings),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffa16ae8),
                Color(0xff94b9ff),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: PageStorage(
                    bucket: bucket,
                    child: currentPage,
                  ),
                ),
              ],
            )),
      ),

      // Bottom navbar
      bottomNavigationBar: Stack(
        children: [
          // bottom appbar gradient background
          Container(
            height: MediaQuery.of(context).size.height / 9,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )),
          ),

          // bottom navbar
          SizedBox(
            // navbar height
            height: MediaQuery.of(context).size.height * .1,
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              // selected design
              selectedFontSize: 0,
              selectedItemColor: Colors.white,
              // unselected design
              unselectedFontSize: 0,
              unselectedItemColor: const Color(0x66402e52),
              type: BottomNavigationBarType.fixed,
              elevation: 0,

              // navbar index
              currentIndex: currentTab,
              onTap: (int index) {
                setState(() {
                  currentTab = index;
                  currentPage = pages[index];
                  currentPageTitle = (pages[index] as dynamic).title;
                });
              },

              items: navbarItems,
            ),
          ),
        ],
      ),
    );
  }
}

/*

NOTES:

These are functions to display the navbar items (icons)
The Lists were made to eliminate the need to always add 
the "const" modifier to every item and instead 
we only add it at the top of the List declaration

These functions can be deleted but I'm keeping them incase
we need to write something similar or we run into problems
while trying to display the navbar items on runtime -

-Mike

*/
// List<BottomNavigationBarItem> _doctorNavItems(){
//     return [
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.add_outlined,color: Color(0xffF8F6F5),size: 30,),
//         label: "Create Prescription",
//         tooltip: "Create Prescription for Patient",
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.person,color: Color(0xffF8F6F5),size: 30,),
//         label: "Patient List",
//         tooltip: "Patient List",
//       )
//     ];
// }

// List<BottomNavigationBarItem> _patientNavItems(){
//     return [
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.add_outlined,color: Color(0xffF8F6F5),size: 30,),
//         label: "Create Prescription",
//         tooltip: "Create Prescription for Patient",
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.person,color: Color(0xffF8F6F5),size: 30,),
//         label: "Patient List",
//         tooltip: "Patient List",
//       )
//     ];
// }

/*

NOTES:

These are Lists of NavBar items (icons) that will be displayed
according to the type of user that is logged in.

*/

const List<BottomNavigationBarItem> _doctorNavItems = [
  //Create Prescription
  BottomNavigationBarItem(
    icon: Icon(
      Icons.add_outlined,
      size: 30,
    ),
    label: "Create Prescription",
    tooltip: "Create Prescription for Patient",
  ),

  //Patient List
  BottomNavigationBarItem(
    icon: Icon(
      Icons.people,
      size: 30,
    ),
    label: "Patient List",
    tooltip: "View Patient List",
  ),

  //Doctor Profile
  BottomNavigationBarItem(
    icon: Icon(
      Icons.person,
      size: 30,
    ),
    label: "Profile",
    tooltip: "Edit Profile Settings",
  )
];

const List<BottomNavigationBarItem> _patientNavItems = [
  //Medicine Lookup Page
  BottomNavigationBarItem(
    icon: Icon(
      Icons.medication,
      size: 30,
    ),
    label: "Medicine Lookup",
    tooltip: "Medicine Lookup",
  ),

  // Pharmacy Locator Map Page
  BottomNavigationBarItem(
    icon: Icon(
      Icons.store,
      size: 30,
    ),
    label: "Pharmacy Locator",
    tooltip: "Pharmacy Locator",
  ),

  // Dashboard Home Page
  BottomNavigationBarItem(
    icon: Icon(
      Icons.home,
      size: 30,
    ),
    label: "Home",
    tooltip: "Home",
  ),

  // Medical History Page (prescriptions)
  BottomNavigationBarItem(
    icon: Icon(
      Icons.history,
      size: 30,
    ),
    label: "Medical History",
    tooltip: "Medical History",
  ),

  // User Profile Page
  BottomNavigationBarItem(
    icon: Icon(
      Icons.person,
      size: 30,
    ),
    label: "Profile",
    tooltip: "Profile",
  )
];

const List<BottomNavigationBarItem> _pharmacyNavItems = [
  // Dashboard
  BottomNavigationBarItem(
    icon: Icon(
      Icons.home,
      size: 30,
    ),
    label: "Home",
    tooltip: "Home Page",
  ),

  // QR Code Scanner
  BottomNavigationBarItem(
    icon: Icon(
      Icons.qr_code,
      size: 30,
    ),
    label: "QR Code Scanner",
    tooltip: "QR Code Scanner",
  ),
  // Add Medications
  BottomNavigationBarItem(
    icon: Icon(
      Icons.add,
      color: Color(0xffF8F6F5),
      size: 30,
    ),
    label: "Add Medications",
    tooltip: "Add Medications",
  ),
  // Medications View
  BottomNavigationBarItem(
    icon: Icon(
      Icons.medical_information,
      color: Color(0xffF8F6F5),
      size: 30,
    ),
    label: "Medications View",
    tooltip: "Medications View",
  ),
  // User Profile Page
  BottomNavigationBarItem(
    icon: Icon(
      Icons.person,
      color: Color(0xffF8F6F5),
      size: 30,
    ),
    label: "Profile",
    tooltip: "Profile",
  )
];
