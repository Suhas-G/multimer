import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multimer/models/multitimer.dart';
import 'package:multimer/pages/play_multi_timer/timer_progress.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class PlayMultiTimer extends StatefulWidget {

  MultiTimer multiTimer;


  PlayMultiTimer(this.multiTimer);

  @override
  _PlayMultiTimerState createState() => _PlayMultiTimerState();
}

class _PlayMultiTimerState extends State<PlayMultiTimer> with TickerProviderStateMixin{



  AnimationController innerProgressController;
  AnimationController outerProgressController;
  bool animationPaused = false;
  bool animationStopped = false;
  bool alarmStarted = false;
  int timerIndex = 0;


  @override
  void initState() {
    super.initState();
    innerProgressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: this.widget.multiTimer.getTotalSeconds()),
    );
    outerProgressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: this.widget.multiTimer.timers.first.getTotalSeconds()),
    );
    
    addStatusListener();
    addTickListener();

  }


  @override
  void dispose() {
    innerProgressController.dispose();
    outerProgressController.dispose();
    FlutterRingtonePlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  AppBar buildAppBar(){
    String title = widget.multiTimer.name;
    return AppBar(
      title: Text(title),
    );
  }

  Widget buildBody(){

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: width,
            height: height - 0.3*height,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: innerProgressController,
                    builder: (BuildContext context, Widget child){
                      return new CustomPaint(
                        painter: TimerPainter(
                          innerProgressController,
                          Colors.lightGreenAccent.withAlpha(100),
                          Colors.greenAccent,
                          20.0,
                          1/5
                        ),
                        child: Center(
                          child: Text('${timerIndex + 1} / ${widget.multiTimer.timers.length}',
                                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                        )
                      );
                    },
                  )
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: outerProgressController,
                    builder: (BuildContext context, Widget child) {
                      return new CustomPaint(
                        painter: TimerPainter(
                          outerProgressController,
                          ThemeData.dark().accentColor.withAlpha(100),
                          Colors.redAccent,
                          10.0,
                          1/3
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          ),
          AnimatedBuilder(
            animation: innerProgressController,
            builder: (BuildContext context, Widget child) {
              return buildTimeDisplay();
            },
          ),
          AnimatedBuilder(
            animation: innerProgressController,
            builder: (BuildContext context, Widget child){
              return buildButtonBar();
            },
          )
        ],
      ),
    );
  }

  Widget buildTimeDisplay(){
    Duration currentTimer = outerProgressController.duration *
      (1 - (outerProgressController.value));
    String seconds = (currentTimer.inSeconds % 60).toString().padLeft(2, '0');
    String minutes = (currentTimer.inMinutes % 60).toString().padLeft(2, '0');
    String hours = (currentTimer.inHours).toString().padLeft(2, '0');
    String timeText = '$hours : $minutes : $seconds';
    return new Text(timeText, style: TextStyle(fontSize: 40),);
  }

  Widget playPauseIcon(){
    return (innerProgressController.isAnimating ? new Icon(Icons.pause) : new Icon(Icons.play_arrow));
  }

  Widget buildButtonBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            child: playPauseIcon(),
            onPressed: (){
              if (innerProgressController.isAnimating) {
                innerProgressController.stop();
                outerProgressController.stop();
                _stopAlarm();
                setState(() {
                  animationPaused = true;
                });
              } else {
                innerProgressController.forward(
                  from: innerProgressController.value == 1.0 ? 0.0 : innerProgressController.value);
                outerProgressController.forward(
                  from: outerProgressController.value == 1.0 ? 0.0 : outerProgressController.value);
                animationPaused = false;
              }
            },
            heroTag: null,
          ),
          FloatingActionButton(
            child: Icon(Icons.stop),
            backgroundColor: Colors.redAccent,
            onPressed: () {
              animationStopped = true;
              innerProgressController.value = 0;
              outerProgressController.value = 0;
              _stopAlarm();
            },
            heroTag: null,
          )
        ],
      ),
    );
  }

  addStatusListener(){
    outerProgressController.addStatusListener((status) {
      switch (status){
        case AnimationStatus.completed:
          timerIndex += 1;
          _stopAlarm();
          if (timerIndex < widget.multiTimer.timers.length){
            outerProgressController.duration = Duration(
              seconds: widget.multiTimer.timers[timerIndex].getTotalSeconds()
            );
            outerProgressController.value = 0;
            outerProgressController.forward(from: 0);
          } else {
            timerIndex = 0;
            outerProgressController.duration = Duration(
              seconds: widget.multiTimer.timers[timerIndex].getTotalSeconds()
            );
          }
          break;
        case AnimationStatus.dismissed:
          if (animationStopped){
            timerIndex = 0;
            animationStopped = false;
            outerProgressController.duration = Duration(
              seconds: widget.multiTimer.timers[timerIndex].getTotalSeconds()
            );
          }
          break;
        default:
          break;
      }
    });
  }

  addTickListener() {
    outerProgressController.addListener(() {
      Duration currentTimer = outerProgressController.duration *
        (1 - (outerProgressController.value));
      if (currentTimer.inSeconds < 10){
        _startAlarm();
      } else if(currentTimer.inSeconds < 1 && alarmStarted){
        _stopAlarm();
      }
    });
  }

  _stopAlarm() {
    if (alarmStarted){
      FlutterRingtonePlayer.stop();
      alarmStarted = false;
    }
  }

  _startAlarm(){
    if (!alarmStarted && !animationPaused && !animationStopped){
      alarmStarted = true;
      FlutterRingtonePlayer.playAlarm(looping: false);
    }
  }

}
