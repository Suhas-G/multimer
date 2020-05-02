import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:multimer/models/multitimer.dart';

import 'package:multimer/models/timer.dart';
import 'package:multimer/db/timer_db.dart';
import 'package:multimer/db/multitimer_db.dart';
import 'package:multimer/services/multitimer_service.dart';

class AddMultiTimer extends StatefulWidget {

  final bool isUpdateFlow;
  final MultiTimer multiTimer;


  AddMultiTimer(this.isUpdateFlow, this.multiTimer);

  @override
  _AddMultiTimerState createState() => _AddMultiTimerState();
}

class _AddMultiTimerState extends State<AddMultiTimer> {

  final saveMultiTimerNotifier = StreamController.broadcast();
  bool _multiTimerSaved = false;
  bool isUpdateFlow = false;
  MultiTimer multiTimer;

  @override
  void initState() {
    super.initState();
    isUpdateFlow = this.widget.isUpdateFlow;
    multiTimer = this.widget.multiTimer;
  } //  Map data = {};



  @override
  Widget build(BuildContext context) {
    Widget scaffoldBody = buildScaffoldBody();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: buildAppBar(scaffoldBody),
        body: scaffoldBody,
      ),
    );
  }

  Future<bool> _onWillPop(){
    Navigator.pop(context, {'reloadTimers': _multiTimerSaved || this.isUpdateFlow});
    return Future.value(false);
  }

  void onSave(){
    _multiTimerSaved = true;
  }

  @override
  void dispose() {
    saveMultiTimerNotifier.close();
    super.dispose();
  }

  AppBar buildAppBar(ScaffoldBody scaffoldBody) {
    return AppBar(
      title: buildAppBarTitle(),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.check),
          onPressed: () => saveMultiTimerNotifier.sink.add(null),
        )
      ],
    );
  }

  Widget buildAppBarTitle(){

    String title = this.isUpdateFlow ? 'Update Timer' : 'Add Timer';
    return Text(title);
  }

  Widget buildScaffoldBody(){
    return ScaffoldBody(shouldTriggerSave: saveMultiTimerNotifier.stream, onSave: onSave,
                      isUpdateFlow: isUpdateFlow, multiTimer: multiTimer);
  }
}

class ScaffoldBody extends StatefulWidget {

  final Stream shouldTriggerSave;
  final Function onSave;
  final bool isUpdateFlow;
  final MultiTimer multiTimer;

  ScaffoldBody({this.shouldTriggerSave, this.onSave, this.isUpdateFlow, this.multiTimer});

  @override
  _ScaffoldBodyState createState() => _ScaffoldBodyState();
}

class _ScaffoldBodyState extends State<ScaffoldBody> {

  StreamSubscription saveSubscription;

  MultiTimer multiTimer = new MultiTimer();
  List<Timer> timers = [Timer(hours: 0, minutes: 1, seconds: 0)];


  final _nameTextFocusNode = new FocusNode();
  final _nameTextController = new TextEditingController();
  bool _isNameValid = true;


  final noTimerSnackBar = SnackBar(
    content: Text(
      'Provide atleast one timer!',
      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
    )
  );

  final successfulTimerSave = SnackBar(
    content: Text(
      'Timer has been saved successfully!',
      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
    ),
  );

  MultiTimerDB multiTimerDb = new MultiTimerDB();
  TimerDB timerDb = new TimerDB();

  MultiTimerService multiTimerService = new MultiTimerService();

  @override
  void initState() {
    super.initState();
    saveSubscription = widget.shouldTriggerSave.listen((_) => saveMultiTimer());
  }

  @override
  didUpdateWidget(ScaffoldBody old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerSave != old.shouldTriggerSave) {
      saveSubscription.cancel();
      saveSubscription = widget.shouldTriggerSave.listen((_) => saveMultiTimer());
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  @override
  void dispose() {
    _nameTextFocusNode.dispose();
    _nameTextController.dispose();
    super.dispose();
  }



  Widget buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          timers.length > 0? 'Timer List': '',
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  List<Card> buildTimerCards() {
    List<Card> timerCards = [];
    if (timers.isEmpty){
      return timerCards;
    }

    for (int index = 0; index < timers.length; index++) {
      Card timerCard = Card(
        key: ValueKey(index),
        child: ListTile(
          onTap: () {
            showTimePicker(timers[index], index);
          },
          title: Text(timers[index].toString()),
          trailing: IconButton(
            onPressed: () {
              deleteTimer(index);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
          )),
      );
      timerCards.add(timerCard);
    }
    return timerCards;
  }

  Widget buildTimerList() {
    return Expanded(
      child: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ReorderableListView(onReorder: reOrderTimerCards, children: buildTimerCards()),
        ),
      ),
    );
  }

  Widget buildButtonBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton.icon(
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.green),
            ),
            splashColor: Colors.green,
            color: Colors.green,
            onPressed: () {
              addTimer();
            },
            icon: Icon(Icons.add),
            label: Text('Add')),
        ],
      ),
    );
  }

  Widget buildBody() {

    if (widget.isUpdateFlow){
      multiTimer = widget.multiTimer;
      timers = multiTimer.timers;
      _nameTextController.text = multiTimer.name;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            autofocus: false,
            controller: _nameTextController,
            focusNode: _nameTextFocusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
              errorText: _isNameValid ? null : 'Provide a name for Multi timer!',
            ),
          ),
          Divider(
            height: 30,
          ),
          buildTitle(),
          buildTimerList(),
          buildButtonBar()
        ],
      ),
    );
  }

  void reOrderTimerCards(int oldIndex, int newIndex) {

    setState(() {
      Timer timerToMove = timers[oldIndex];
      if (oldIndex > newIndex) {
        for (int pos = oldIndex; pos > newIndex; pos--) {
          timers[pos] = timers[pos - 1];
        }
        timers[newIndex] = timerToMove;
      } else {
        newIndex -= 1;
        for (int pos = oldIndex; pos < newIndex; pos++) {
          timers[pos] = timers[pos + 1];
        }
        timers[newIndex] = timerToMove;
      }
    });
  }

  void deleteTimer(int index) {
    setState(() {
      timers.removeAt(index);
    });
  }

  void addTimer() {
    showTimePicker(Timer(hours: 0, minutes: 0, seconds: 0), timers.length);
  }

  void setTime(int index, DateTime time) {
    Timer newTimer = Timer(hours: time.hour, minutes: time.minute, seconds: time.second);
    setState(() {
      if (index == timers.length) {
        timers.add(newTimer);
      } else {
        timers[index] = newTimer;
      }
    });
  }

  void showTimePicker(Timer currentTimer, int index) {
    removeFocusFromName();
    DatePicker.showTimePicker(context,
      theme: DatePickerTheme(
        titleHeight: 50,
        containerHeight: 150,
        backgroundColor: ThemeData.dark().backgroundColor,
        headerColor: ThemeData.dark().highlightColor,
        cancelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500
        ),
        doneStyle: TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.w500
        ),
        itemStyle: TextStyle(
          color: Colors.white
        ),
        itemHeight: 40
      ),
      showTitleActions: true,
      currentTime:
      DateTime(0, 0, 0, currentTimer.hours, currentTimer.minutes, currentTimer.seconds),
      onConfirm: (time) {
        setTime(index, time);
      });
  }

  void removeFocusFromName() {
    _nameTextFocusNode.unfocus();
  }

  bool isValid() {
    _isNameValid = _nameTextController.text.isNotEmpty;
    bool _isTimerValid = timers.length >= 1;


    if (!_isTimerValid) {
      Scaffold.of(context).showSnackBar(noTimerSnackBar);
    }
    return _isNameValid && _isTimerValid;
  }

  Future<void> saveMultiTimer() async {
    if (isValid()) {
      await multiTimerService.initiateDB();
      multiTimer.name = _nameTextController.text;
      multiTimer.setTimers(timers);
      if (widget.isUpdateFlow){
        multiTimer = await multiTimerService.updateMultiTimer(multiTimer);
      } else {
        multiTimer = await multiTimerService.insertMultiTimer(multiTimer);
      }

      widget.onSave();

      Scaffold.of(context).showSnackBar(successfulTimerSave);
    }
    setState(() {});
  }
}

