// ref: https://stackoverflow.com/a/69387027
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class CustomTabBar extends StatefulWidget {
  final int tabIndex;
  final List<Widget> tabs;
  final List<String> tabNames;

  const CustomTabBar({
    super.key,
    required this.tabIndex,
    required this.tabNames,
    required this.tabs,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  Widget getTabBar(List<String> tabNames) {
    List<Widget> tabList = <Widget>[];

    for (var i = 0; i < tabNames.length; i++) {
      tabList.add((Tab(text: tabNames[i])));
    }
    return TabBar(
      // label decoration
      labelColor: const Color(0xff8d4fdf),
      unselectedLabelColor: const Color(0xff9881b5),
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
      indicatorSize: TabBarIndicatorSize.tab,
      // indicator for selected tab
      indicator: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: GradientBoxBorder(
          width: 1,
          gradient:
              LinearGradient(colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
        ),
      ),
      indicatorColor: Colors.white,
      // isScrollable: true,
      tabs: tabList,
      controller: tabController,
    );
  }

  Widget getTabs(List<Widget> tabs) {
    List<Widget> tabList = <Widget>[];

    for (var i = 0; i < tabs.length; i++) {
      tabList.add(SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: tabs[i],
      )));
    }
    return Expanded(
      child: TabBarView(
        controller: tabController,
        children: tabList,
      ),
    );
  }

  @override
  void initState() {
    tabController = TabController(length: widget.tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.tabIndex,
      length: widget.tabs.length,
      child: Stack(
        children: [
          // tabbar + tabview container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: const GradientBoxBorder(
                width: 1,
                gradient: LinearGradient(
                    colors: [Color(0xffa16ae8), Color(0xff94b9ff)]),
              ),
              color: const Color(0xfff4f2f7),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 35),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(children: [getTabs(widget.tabs)]),
              ),
            ),
          ),

          // tabbar stacked on Container to prevent double border
          SizedBox(
            height: 35,
            width: (MediaQuery.of(context).size.width - 20) + 4,
            child: getTabBar(widget.tabNames),
          ),

          // cover bottom border of active tab indicator with white
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              transform: Matrix4.translationValues(0, 33, 0),
              height: 10,
              width: (MediaQuery.of(context).size.width - 20) - 2,
              color: Colors.white,
            ),
          ),

          // cover bottom border of active tab indicator with white
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              transform: Matrix4.translationValues(0, -1, 0),
              height: 10,
              width: (double.infinity - 30) - 2,
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
