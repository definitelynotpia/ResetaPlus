import 'package:flutter/material.dart';
import '../widgets/custom_iconbutton.dart';

import './dashboard_page.dart';
import './store_page.dart';
import './history_page.dart';
import './profile_page.dart';
import './map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double iconSize = 30;

  int currentTab = 0;

  // navigation page keys
  final Key dashboardPage = const PageStorageKey("dashboardPage");
  final Key storePage = const PageStorageKey("storePage");
  final Key mapPage = const PageStorageKey("mapPage");
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

      // app bar (page name)

      // body
      body: PageStorage(
        bucket: bucket,
        child: currentPage,
      ),

      // Bottom navbar
      bottomNavigationBar: Stack(
        children: [
          // bottom appbar gradient background
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          // bottom navbar
          BottomNavigationBar(
            backgroundColor: Colors.transparent,
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
                ),
                label: "Medicine Lookup",
                tooltip: "Medicine Lookup",
              ),
              // pharmacy locator map page
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.store,
                  color: Color(0xffF8F6F5),
                ),
                label: "Pharmacy Locator",
                tooltip: "Pharmacy Locator",
              ),
              // dashboard home page
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: Color(0xffF8F6F5),
                ),
                label: "Home",
                tooltip: "Home",
              ),
              // medical history page (prescriptions)
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.history,
                  color: Color(0xffF8F6F5),
                ),
                label: "Medical History",
                tooltip: "Medical History",
              ),
              // user profile page
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  color: Color(0xffF8F6F5),
                ),
                label: "Profile",
                tooltip: "Profile",
              ),
            ],
          )
        ],
      ),

      // QR button for current prescription
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: implement qrcode generator package
        },
        tooltip: "Home",
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            Icons.qr_code_2,
            // Icons.home,
            size: iconSize + 20,
          ),
        ),
      ),

      // home page docking location
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
