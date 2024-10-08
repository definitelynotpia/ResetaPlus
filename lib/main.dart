import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mysql_client/mysql_client.dart';

import './pages/login_page.dart';
import './pages/dashboard_page.dart';
import './pages/store_page.dart';
import './pages/history_page.dart';
import './pages/profile_page.dart';
import './pages/map_page.dart';

void main() {
  runApp(const MainApp());
}

String hashPassword(String password, String salt) {
  // Combine password and salt
  final bytes = utf8.encode(password + salt);

  // Hash the combined bytes using SHA-256
  final digest = sha256.convert(bytes);

  return digest.toString(); // Return the hashed password as a string
}

bool verifyPassword(String enteredPassword, String storedPasswordHash,
    String storedSalt, encrypt.Key storedKey, encrypt.IV storedIv) {
  // Create an encrypter using the AES algorithm and the stored encryption key
  final encrypter = encrypt.Encrypter(encrypt.AES(storedKey));

  // Decode the stored password hash from a base64 string to bytes
  final encryptedPasswordHash =
      encrypt.Encrypted.fromBase64(storedPasswordHash);

  // Decrypt the password hash using the encrypter and the stored initialization vector
  final decryptedPasswordHash =
      encrypter.decrypt(encryptedPasswordHash, iv: storedIv);

  // Hash the entered password using the stored salt to compare with the decrypted hash
  String hashedEnteredPassword = hashPassword(enteredPassword, storedSalt);

  // Compare the hashed entered password with the decrypted password hash
  return hashedEnteredPassword == decryptedPasswordHash;
}

Future<MySQLConnection> createConnection() async {
  final conn = await MySQLConnection.createConnection(
    host:
        "192.168.1.3", // !!NOTICE!! Please change this to your local MySQL server IP address
    port: 3306,
    userName: "root",
    password: "root",
    databaseName: "reseta_plus",
  );

  await conn.connect(); // Ensure you await the connection
  return conn; // Return the connection object
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
  // TODO: add user session
  final bool loggedIn = true;

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Reseta+", // app title
      theme: ThemeData(
        fontFamily: "Montserrat", // set custom font as default
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      scrollBehavior: MyCustomScrollBehavior().copyWith(scrollbars: false),
      // if user is logged in, go to Home; else, go to Login
      home: loggedIn ? const HomePage() : const LoginPage(title: "Login"),
    );
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

  // navigation page keys
  final Key storePage = const PageStorageKey("storePage");
  final Key mapPage = const PageStorageKey("mapPage");
  final Key dashboardPage = const PageStorageKey("dashboardPage");
  final Key historyPage = const PageStorageKey("historyPage");
  final Key profilePage = const PageStorageKey("profilePage");

  late StorePage one;
  late MapPage two;
  late DashboardPage three;
  late HistoryPage four;
  late ProfilePage five;

  late List<Widget> pages;
  late Widget currentPage;

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
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

    currentPage = three;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F6F5),
      extendBody: true,

      appBar: AppBar(
        titleSpacing: MediaQuery.of(context).size.width * 0.03,
        toolbarHeight: MediaQuery.of(context).size.height * 0.16,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // title and subtitle
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  "John Doe",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                  ),
                ),
                // User type = patient, health professional
                Text(
                  "Patient",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                )
              ],
            ),
            // profile picture
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xffa16ae8),
              ),
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
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
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
              selectedFontSize: 0,
              unselectedFontSize: 0,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              elevation: 0,

              // navbar index
              currentIndex: currentTab,
              onTap: (int index) {
                setState(() {
                  currentTab = index;
                  currentPage = pages[index];
                });
              },

              // navbar buttons
              items: const <BottomNavigationBarItem>[
                // medicine search page
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.medication,
                    color: Color(0xffF8F6F5),
                    size: 30,
                  ),
                  label: "Medicine Lookup",
                  tooltip: "Medicine Lookup",
                ),
                // pharmacy locator map page
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.store,
                    color: Color(0xffF8F6F5),
                    size: 30,
                  ),
                  label: "Pharmacy Locator",
                  tooltip: "Pharmacy Locator",
                ),
                // dashboard home page
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    color: Color(0xffF8F6F5),
                    size: 30,
                  ),
                  label: "Home",
                  tooltip: "Home",
                ),
                // medical history page (prescriptions)
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.history,
                    color: Color(0xffF8F6F5),
                    size: 30,
                  ),
                  label: "Medical History",
                  tooltip: "Medical History",
                ),
                // user profile page
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                    color: Color(0xffF8F6F5),
                    size: 30,
                  ),
                  label: "Profile",
                  tooltip: "Profile",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
