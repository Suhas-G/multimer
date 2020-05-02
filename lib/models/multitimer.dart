import 'package:multimer/models/timer.dart';

final String tableMultiTimer = 'multitimer';
final String columnId = '_id';
final String columnName = 'name';


class MultiTimer {

    int id;
    String name;
    List<Timer> timers = [];

    MultiTimer({this.name});

    MultiTimer.fromMap(Map<String, dynamic> map){
        id = map[columnId];
        name = map[columnName];
    }

    Map<String, dynamic> toMap(){
        var map = <String, dynamic>{
            columnName: name
        };
        if (id != null){
            map[columnId] = id;
        }
        return map;
    }

    void addTimer(Timer timer){
        this.timers.add(timer);
    }

    void addAllTimers(List<Timer> timers){
        this.timers.addAll(timers);
    }

    void setTimers(List<Timer> timers){
        this.timers = timers;
    }

    int getTotalSeconds(){
        int seconds = 0;
        for (int i = 0; i < this.timers.length; i++){
            seconds += this.timers[i].getTotalSeconds();
        }
        return seconds;
    }
}