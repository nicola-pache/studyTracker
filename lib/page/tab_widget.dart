import 'package:flutter/material.dart';

/// TabBarWidget, part 1. Creates the state for the widget.
class TabBarWidget extends StatefulWidget {
  const TabBarWidget(this._tabNames, this._tabWidgets, {Key? key}) : super(key: key);

  /// List of names of tabs.
  final List<String> _tabNames;

  /// List of widgets shown in tabs: their order MUST match the order
  /// in _tabNames.
  final List<Widget> _tabWidgets;

  @override
  _TabBarWidgetState createState() => _TabBarWidgetState();
}

/// TabBarWidget, part 2. Handles the state of the widget.
class _TabBarWidgetState extends State<TabBarWidget> with AutomaticKeepAliveClientMixin {

  /// Defines fontSize for Tab-Labels.
  TextStyle textStyle = const TextStyle(fontSize: 20.0);

  /// Builds the TabBar
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: widget._tabNames.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: TabBar(
              labelStyle: textStyle,
              unselectedLabelStyle: textStyle,
              tabs: [
                Tab(text: widget._tabNames[0]),
                Tab(text: widget._tabNames[1])
              ],
            ),
          ),
        ),
        body: TabBarView(
          // the user can't scroll through tabs, because the user should
          // only scroll through the pages of the app
            physics: const NeverScrollableScrollPhysics(),
            children: [widget._tabWidgets[0], widget._tabWidgets[1]]
        ),
      ),
    );
  }

  /// Makes sure the currently selected tab stays selected after switching pages.
  @override
  bool get wantKeepAlive => true;
}