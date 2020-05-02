import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multimer/db/multitimer_db.dart';
import 'package:multimer/db/timer_db.dart';
import 'package:multimer/models/multitimer.dart';
import 'package:multimer/models/timer.dart';

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
  Map data = {};
  HomeBody homeBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        'MULTIMER',
        style: TextStyle(
          fontFamily: 'UnicaOne',
        ),),
        centerTitle: true,
    );
  }

  Widget buildBody() {
    return HomeBody(
      data: data,
    );
  }

  FloatingActionButton buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        final dynamic result = await Navigator.pushNamed(context, '/new');
        data = result;
      },
      child: Icon(Icons.add),
    );
  }
}

class HomeBody extends StatefulWidget {
  Map data = {};

  HomeBody({this.data});

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  MultiTimerDB multiTimerService = new MultiTimerDB();
  TimerDB timerService = new TimerDB();

  List<MultiTimer> multiTimers = [];
  List<MultiTimerCard> multiTimerCards = [];

  bool reloadTimers = true;

  @override
  Widget build(BuildContext context) {
    if ((widget.data.containsKey('reloadTimers') && widget.data['reloadTimers']) || reloadTimers) {
      loadTimers();
    }

    return (multiTimers.length > 0 ? buildMultiTimerListView() : buildEmptyView());
  }

  ButtonBar buildMultiTimerCardButtonBar(MultiTimerCard multiTimerCard) {
    return ButtonBar(
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.mode_edit,
            color: Colors.lightBlueAccent,
          ),
          onPressed: () async {
            final dynamic result = await Navigator.pushNamed(context, '/new',
                arguments: {'isUpdate': true, 'multiTimer': multiTimerCard.multiTimer});
            Map resultMap = result;
            if (resultMap.containsKey('reloadTimers')) {
              reloadTimers = resultMap['reloadTimers'];
            }
          },
        ),
        IconButton(
          icon: Icon(
            Icons.play_circle_filled,
            color: ThemeData.dark().accentColor,
            size: 28,
          ),
          onPressed: () {
            final dynamic result = Navigator.pushNamed(context, '/play',
                arguments: {'multiTimer': multiTimerCard.multiTimer});
          },
        ),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.redAccent,
          ),
          onPressed: () {
            confirmDelete(multiTimerCard);
          },
        )
      ],
      alignment: MainAxisAlignment.spaceAround,
    );
  }

  Future<void> confirmDelete(MultiTimerCard multiTimerCard) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return AlertDialog(
            title: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.warning,
                      color: Colors.amber,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Delete',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Divider()
              ],
            ),
            content: Text('Are you sure you want to delete?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () async {
                  await multiTimerService.delete(multiTimerCard.multiTimer);
                  Navigator.of(context).pop();
                  setState(() {
                    reloadTimers = true;
                  });
                },
              )
            ],
          );
        });
  }

  Widget buildEmptyView() {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Center(
        child: Text(
          'No timers found',
        ),
      ),
    );
  }

  Widget buildMultiTimerListView() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.sort, size: 28.0,),
              title: Text('Timer Groups',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
              contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 5),
              dense: true,
            ),
            ExpansionPanelList(
              children: buildExpandableMultiTimerList(),
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  multiTimerCards[index].isExpanded = !isExpanded;
                });
              },
            ),
          ],
        )
      ),
    );
  }

  List<ExpansionPanel> buildExpandableMultiTimerList() {
    return multiTimerCards.map<ExpansionPanel>((MultiTimerCard multiTimerCard) {
      return ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(multiTimerCard.multiTimer.name),
            subtitle: Text('No of Timers: ${multiTimerCard.multiTimer.timers.length}'),
          );
        },
        body: ListTile(
          title: buildMultiTimerCardButtonBar(multiTimerCard),
        ),
        isExpanded: multiTimerCard.isExpanded,
        canTapOnHeader: true,
      );
    }).toList();
  }

  Future<void> loadTimers() async {
    await multiTimerService.initiateDB();
    await timerService.initiateDB();
    multiTimers = await multiTimerService.getAllMultiTimers();

    multiTimerCards = [];
    for (MultiTimer multiTimer in multiTimers) {
      multiTimerCards.add(MultiTimerCard(isExpanded: false, multiTimer: multiTimer));
      List<Timer> timers = await timerService.getTimersFromMultiTimer(multiTimer.id);
      multiTimer.setTimers(timers);
    }
    setState(() {
      reloadTimers = false;
      widget.data['reloadTimers'] = false;
    });
  }
}
