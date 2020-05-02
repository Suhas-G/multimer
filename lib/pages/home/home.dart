import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multimer/db/multitimer_db.dart';
import 'package:multimer/db/timer_db.dart';
import 'package:multimer/models/multitimer.dart';
import 'package:multimer/models/timer.dart';
import 'package:multimer/icons/icons.dart';
import 'package:multimer/pages/home/group_timer.dart';
import 'package:multimer/pages/home/navigation_bar.dart';
import 'package:multimer/pages/home/single_timer.dart';
import 'package:multimer/pages/home/stop_watch.dart';

const int TIMER = 0;
const int GROUP_TIMER = 1;
const int STOPWATCH = 2;

class MultiTimerCard {
  bool isExpanded = false;
  MultiTimer multiTimer;
  MultiTimerCard({this.isExpanded, this.multiTimer});
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<NavBarItem> items = [
    NavBarItem(Icons.hourglass_full, 'Timer'),
    NavBarItem(CustomIcons.group_hour_glass, 'Group Timer'),
    NavBarItem(Icons.timer, 'Stopwatch')
  ];
  int selectedIndex = 0;
  bool reloadTimers = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: selectedIndex == GROUP_TIMER? _buildFloatingActionButton() : null,
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  BottomNavigationBar _buildNavigationBar() {
    return getBottomNavigationBar(items, selectedIndex, onNavTabSelected);
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'MULTIMER',
        style: TextStyle(
          fontFamily: 'UnicaOne',
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    print('Building body $reloadTimers');
    Widget widget;
    switch (selectedIndex){
      case TIMER:
        widget = SingleTimerScreen();
        break;
      case GROUP_TIMER:
        print('home widget $reloadTimers');
        widget = GroupTimerScreen(reloadTimers);
        break;
      case STOPWATCH:
        widget = Container(
          child: StopWatch(),
        );
        break;
      default:
        widget = Container(
          child: Text('An error has occured, please restart the app.'),
        );
    }
    return widget;
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async {
        final _result = await Navigator.pushNamed(context, '/new');
        Map<String, dynamic> result = _result;
        print(result);
        if (result['reloadTimers'] ?? false){
          print(result['reloadTimers']);
          setState(() {
            reloadTimers = true;
          });
        }
      },
    );
  }

  onNavTabSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
