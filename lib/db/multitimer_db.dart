import 'package:multimer/db/db_helper.dart';
import 'package:multimer/models/multitimer.dart';
import 'package:sqflite/sqflite.dart';

class MultiTimerDB{
    static final MultiTimerDB _singleton = new MultiTimerDB._internal();
    Database db;

    factory MultiTimerDB(){
        return _singleton;
    }

    MultiTimerDB._internal();

    Future<void> initiateDB() async {
        db = await DBHelper.instance.database;
    }

    Future<MultiTimer> insert(MultiTimer multiTimer) async {
        multiTimer.id = await db.insert(tableMultiTimer, multiTimer.toMap());
        return multiTimer;
    }

    Future<MultiTimer> update(MultiTimer multiTimer) async {
        await db.update(tableMultiTimer, multiTimer.toMap(), where: '$columnId = ?', whereArgs: [multiTimer.id]);
        return multiTimer;
    }

    Future<MultiTimer> get(int id) async {
        List<Map> maps = await db.query(
            tableMultiTimer,
            columns: [columnId, columnName],
            where: '$columnId = ?',
            whereArgs: [id]
        );
        if (maps.length > 0){
            return MultiTimer.fromMap(maps.first);
        }
        return null;
    }

    Future<List<MultiTimer>> getAllMultiTimers() async {
        List<Map> maps = await db.query(tableMultiTimer, columns: [columnId, columnName]);
        List<MultiTimer> multiTimers = [];
        if (maps.length > 0){
            for (Map map in maps){
                multiTimers.add(MultiTimer.fromMap(map));
            }
        }
        return multiTimers;
    }

    Future<void> delete(MultiTimer multiTimer) async {
        await db.delete(tableMultiTimer, where: '$columnId = ?', whereArgs: [multiTimer.id]);
    }


}