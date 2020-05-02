import 'package:multimer/db/db_helper.dart';
import 'package:multimer/models/timer.dart';
import 'package:sqflite/sqflite.dart';

class TimerDB{
    static final TimerDB _singleton = new TimerDB._internal();
    Database db;

    factory TimerDB() {
        return _singleton;
    }

    TimerDB._internal();

    Future<void> initiateDB() async {
        db = await DBHelper.instance.database;
    }



    Future<Timer> insert(Timer timer) async {
        timer.id = await db.insert(tableTimer, timer.toMap());
        return timer;
    }

    Future<Timer> update(Timer timer) async {
        await db.update(tableTimer, timer.toMap(), where: '$columnId = ?', whereArgs: [timer.id]);
        return timer;
    }

    Future<void> delete(Timer timer) async {
        await db.delete(
            tableTimer,
            where: '$columnId = ?',
            whereArgs: [timer.id]
        );
    }

    Future<Timer> get(int id) async{
        List<Map> maps = await db.query(
            tableTimer,
            columns: [columnId, columnHours, columnMinutes, columnSeconds, columnDisplayOrder,
                columnMultiTimer],
            where: '$columnId = ?',
            whereArgs: [id]
        );
        if (maps.length > 0){
            return Timer.fromMap(maps.first);
        }
        return null;
    }

    Future<List<Timer>> getAllTimers() async{
        List<Map> maps = await db.query(
            tableTimer,
            columns: [columnId, columnHours, columnMinutes, columnSeconds, columnDisplayOrder,
                columnMultiTimer]
        );
        List<Timer> timers = [];
        if (maps.length > 0){
            for (Map map in maps) {
                timers.add(Timer.fromMap(map));
            }
            return timers;
        }
        return timers;
    }

    Future<List<Timer>> getTimersFromMultiTimer(int id) async{
        List<Map> maps = await db.query(
            tableTimer,
            columns: [columnId, columnHours, columnMinutes, columnSeconds, columnMultiTimer],
            where: '$columnMultiTimer = ?',
            orderBy: columnDisplayOrder,
            whereArgs: [id]
        );
        List<Timer> timers = [];
        if (maps.length > 0){
            for (Map map in maps) {
                timers.add(Timer.fromMap(map));
            }
        }
        return timers;
    }
}