// ref: https://stackoverflow.com/a/69387027
import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final List<Widget> tabs;
  final List<String> tabNames;

  const CustomTabBar({
    super.key,
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
      unselectedLabelColor: const Color.fromARGB(36, 0, 0, 0),
      labelColor: Colors.purple,
      tabs: tabList,
      controller: tabController,
      indicatorSize: TabBarIndicatorSize.tab,
    );
  }

  Widget getTabs(List<Widget> tabs) {
    List<Widget> tabList = <Widget>[];

    for (var i = 0; i < tabs.length; i++) {
      tabList.add((Padding(
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
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // generate customizable tab bar with tab names
          getTabBar(widget.tabNames),
          // generate customizable tabview with provided widget list
          getTabs(widget.tabs),
        ],
      ),
    );
  }
}
