import 'package:multimer/db/timer_db.dart';
import 'package:multimer/db/multitimer_db.dart';
import 'package:multimer/models/multitimer.dart';
import 'package:multimer/models/timer.dart';


class MultiTimerService{
  static final MultiTimerService _singleton = new MultiTimerService._internal();
  MultiTimerDB multiTimerDB = new MultiTimerDB();
  TimerDB timerDB = new TimerDB();

  factory MultiTimerService(){
    return _singleton;
  }

  MultiTimerService._internal(){
    initiateDB();
  }

  Future<void> initiateDB() async {
    await multiTimerDB.initiateDB();
    await timerDB.initiateDB();
  }

  Future<MultiTimer> insertMultiTimer(MultiTimer multiTimer) async {
    multiTimer = await multiTimerDB.insert(multiTimer);
    multiTimer = await insertTimers(multiTimer);
    return multiTimer;
  }

  Future<MultiTimer> insertTimers(MultiTimer multiTimer) async {
    for (int index = 0; index < multiTimer.timers.length; index++){
      Timer timer = multiTimer.timers[index];
      timer.multitimer = multiTimer.id;
      timer.displayOrder = index;
      Timer savedTimer = await timerDB.insert(timer);
      timer.id = savedTimer.id;
    }
    return multiTimer;
  }

  Future<MultiTimer> updateMultiTimer(MultiTimer multiTimer) async {

    multiTimer = await multiTimerDB.update(multiTimer);
    List<Timer> oldTimers = await timerDB.getTimersFromMultiTimer(multiTimer.id);
    for (Timer timer in oldTimers){
      timerDB.delete(timer);
    }
    multiTimer = await insertTimers(multiTimer);
    return multiTimer;
  }

  Future<List<MultiTimer>> getAllMultiTimers() async {
    List<MultiTimer> multiTimers = await multiTimerDB.getAllMultiTimers();
    for (MultiTimer multiTimer in multiTimers) {
      List<Timer> timers = await timerDB.getTimersFromMultiTimer(multiTimer.id);
      multiTimer.setTimers(timers);
    }
    return multiTimers;
  }

  Future<void> delete(MultiTimer multiTimer) async {
    await multiTimerDB.delete(multiTimer);
  }

}