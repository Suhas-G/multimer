import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multimer/db/multitimer_db.dart';
import 'package:multimer/db/timer_db.dart';
import 'package:multimer/router.dart';


class LoadingScreen extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    _initiateDB();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, Router.getHomeScreen());
    });

    return Scaffold(
      body: _buildBody(),
    );
  }



  Widget _buildBody(){
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: CircleAvatar(
                backgroundColor: ThemeData.dark().accentColor,
                radius: 90.0,
                child: SpinKitPouringHourglass(
                  size: 80.0,
                  color: Colors.redAccent
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'multimer',
                style: TextStyle(
                  fontFamily: 'UnicaOne',
                  fontSize: 40.0,
                ),),
            ),
          ],
        )
      ),
    );
  }

  _initiateDB() async {
    MultiTimerDB multiTimerService = new MultiTimerDB();
    TimerDB timerService = new TimerDB();

    await multiTimerService.initiateDB();
    await timerService.initiateDB();
  }
}
