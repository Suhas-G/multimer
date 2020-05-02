import 'package:flutter/material.dart';
import 'package:multimer/models/multitimer.dart';
import 'package:multimer/pages/home/home.dart';
import 'package:multimer/services/multitimer_service.dart';

class GroupTimerScreen extends StatefulWidget {
  bool reloadTimers;

  GroupTimerScreen(this.reloadTimers);

  @override
  _GroupTimerScreenState createState() => _GroupTimerScreenState();
}

class _GroupTimerScreenState extends State<GroupTimerScreen> {

  List<MultiTimer> multiTimers = [];
  List<MultiTimerCard> multiTimerCards = [];
  bool reloadTimers = false;
  MultiTimerService service;



  @override
  void initState() {
    super.initState();
    print('Initiating group timer state');
    service = MultiTimerService();
  }

  @override
  Widget build(BuildContext context) {
    reloadTimers = widget.reloadTimers;
    if (reloadTimers){
      _loadTimers();
    }
    print('Building again');
    return (multiTimers.length > 0 ? _buildMultiTimerListView() : _buildEmptyView());
  }

  Widget _buildEmptyView(){
    return Container(
      constraints: BoxConstraints.expand(),
      child: Center(
        child: Text(
          'No timers found',
        ),
      ),
    );
  }

  Widget _buildMultiTimerListView() {
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
              key: GlobalKey(),
              children: _buildExpandableMultiTimerList(),
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

  List<ExpansionPanel> _buildExpandableMultiTimerList() {
    return multiTimerCards.map<ExpansionPanel>((MultiTimerCard multiTimerCard) {
      return ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(multiTimerCard.multiTimer.name),
            subtitle: Text('No of Timers: ${multiTimerCard.multiTimer.timers.length}'),
          );
        },
        body: ListTile(
          title: _buildMultiTimerCardButtonBar(multiTimerCard),
        ),
        isExpanded: multiTimerCard.isExpanded,
        canTapOnHeader: true,
      );
    }).toList();
  }

  ButtonBar _buildMultiTimerCardButtonBar(MultiTimerCard multiTimerCard) {
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
            setState(() {
              widget.reloadTimers = reloadTimers;
            });
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
            _confirmDelete(multiTimerCard);
          },
        )
      ],
      alignment: MainAxisAlignment.spaceAround,
    );
  }

  Future<void> _confirmDelete(MultiTimerCard multiTimerCard) {
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
                await service.initiateDB();
                await service.delete(multiTimerCard.multiTimer);
                Navigator.of(context).pop();
                setState(() {
                  reloadTimers = true;
                  widget.reloadTimers = true;
                });
              },
            )
          ],
        );
      });
  }

  Future<void> _loadTimers() async {
    print('loading timers');
    await service.initiateDB();
    multiTimers = await service.getAllMultiTimers();
    multiTimerCards = [];
    for (MultiTimer multiTimer in multiTimers) {
      multiTimerCards.add(MultiTimerCard(isExpanded: false, multiTimer: multiTimer));
    }
    setState(() {
      reloadTimers = false;
      widget.reloadTimers = false;
    });
  }


}
