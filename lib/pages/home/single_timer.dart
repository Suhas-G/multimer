import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:multimer/pages/play_multi_timer/timer_progress.dart';

class SingleTimerScreen extends StatefulWidget {
  @override
  _SingleTimerScreenState createState() => _SingleTimerScreenState();
}

class _SingleTimerScreenState extends State<SingleTimerScreen> with TickerProviderStateMixin {
  Widget centerWidget;
  Widget buttonBar;
  AnimationController controller;
  bool animationPaused = false;
  bool animationStopped = false;
  bool alarmStarted = false;
  Duration time;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    centerWidget = timePickerWidget();
    buttonBar = buildSingleButtonBar();
  }

  @override
  Widget build(BuildContext context) {
    if (time == null) {
      time = Duration();
    }

    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: centerWidget,
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: AnimatedSwitcher(
                    key: GlobalKey(),
                    duration: const Duration(milliseconds: 300),
                    child: buttonBar,
                  ),
                )),
          )
        ],
      ),
    );
  }

  Widget timePickerWidget() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: getTimePickerLabels(),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: getTimerPicker(),
          ),
        ],
      ),
    );
  }

  Widget getSpinner(int count, Function onSelectedItemChanged) {
    return Container(
      child: CupertinoPicker.builder(
        itemExtent: 50.0,
        itemBuilder: (BuildContext context, int index) {
          return Center(
            heightFactor: 1.0,
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(color: ThemeData.dark().textSelectionColor),
            ),
          );
        },
        childCount: count,
        onSelectedItemChanged: onSelectedItemChanged,
        backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
      ),
    );
  }

  Widget getTimerPicker() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: getSpinner(24, (int _hours) {
            hours = _hours;
            time = Duration(hours: hours, minutes: minutes, seconds: seconds);
          }),
        ),
        Expanded(
          flex: 1,
          child: getSpinner(60, (int _minutes) {
            minutes = _minutes;
            time = Duration(hours: hours, minutes: minutes, seconds: seconds);
          }),
        ),
        Expanded(
          flex: 1,
          child: getSpinner(60, (int _seconds) {
            seconds = _seconds;
            time = Duration(hours: hours, minutes: minutes, seconds: seconds);
          }),
        )
      ],
    );
  }

  Widget getTimePickerLabels() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Center(
              child: Text(
            "Hours",
            style: TextStyle(fontSize: 16.0),
          )),
        ),
        Expanded(
          flex: 1,
          child: Center(
              child: Text(
            "Minutes",
            style: TextStyle(fontSize: 16.0),
          )),
        ),
        Expanded(
          flex: 1,
          child: Center(
              child: Text(
            "Seconds",
            style: TextStyle(fontSize: 16.0),
          )),
        )
      ],
    );
  }

  Widget buildButtonBar() {
    print('Building bar');
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget child){
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                child: playPauseIcon(),
                onPressed: () {
                  if (controller.isAnimating) {
                      controller.stop();
                  } else {
                    controller.forward(
                      from: controller.value == 1.0 ? 0.0 : controller.value);
                  }
                  setState(() {
                    animationPaused = controller.isAnimating;
                  });
                },
                heroTag: null,
              ),
              FloatingActionButton(
                child: Icon(Icons.stop),
                backgroundColor: Colors.redAccent,
                onPressed: () {
                  controller.value = 0;
                  _stopAlarm();
                  resetScreen();
                },
                heroTag: null,
              )
            ],
          ),
        );
      },
    );
  }

  Widget playPauseIcon() {
    return (controller != null && controller.isAnimating ? new Icon(Icons.pause) : new Icon(Icons.play_arrow));
  }

  Widget buildSingleButtonBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () {
              if (time.compareTo(Duration()) != 0) {
                setState(() {
                  controller = AnimationController(
                    duration: time,
                    vsync: this,
                  );
                  addStatusListener();
                  centerWidget = buildProgressBar();
                  buttonBar = buildButtonBar();
                });
                controller.forward();
              }
            },
            heroTag: null,
          ),
        ],
      ),
    );
  }

  Widget buildProgressBar() {
    return Center(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
        constraints: BoxConstraints.expand(),
        child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget child) {
            return new CustomPaint(
              painter: TimerPainter(
                controller, Colors.lightGreenAccent.withAlpha(100), Colors.greenAccent, 15.0, 1 / 2),
                child: Center(child: buildTimeDisplay()),
            );
          },
        ),
      ),
    );
  }

  Widget buildTimeDisplay(){
    Duration currentTimer = controller.duration *
      (1 - (controller.value));
    String seconds = (currentTimer.inSeconds % 60).toString().padLeft(2, '0');
    String minutes = (currentTimer.inMinutes % 60).toString().padLeft(2, '0');
    String hours = (currentTimer.inHours).toString().padLeft(2, '0');
    String timeText = '$hours : $minutes : $seconds';
    return new Text(timeText, style: TextStyle(fontSize: 30),);
  }


  addStatusListener(){
    controller.addStatusListener((status) {
      print(status);
      switch (status) {
        case AnimationStatus.completed:
          _startAlarm();
          break;
        default:
          break;
      }
    });
  }

  _stopAlarm() {
    if (alarmStarted){
      FlutterRingtonePlayer.stop();
      alarmStarted = false;
    }
  }

  _startAlarm() {
    if (!alarmStarted) {
      alarmStarted = true;
      FlutterRingtonePlayer.playAlarm(looping: true);
      Future.delayed(Duration(seconds: 8), (){
        _stopAlarm();
        resetScreen();
      });
    }
  }

  resetScreen(){
    setState(() {
      time = Duration();
      hours = 0;
      minutes = 0;
      seconds = 0;
      centerWidget = timePickerWidget();
      buttonBar = buildSingleButtonBar();
    });
  }
}
