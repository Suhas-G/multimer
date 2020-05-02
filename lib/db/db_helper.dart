import 'dart:io';
import 'package:synchronized/synchronized.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:multimer/models/timer.dart' as timer;
import 'package:multimer/models/multitimer.dart' as multitimer;


class DBHelper{

    final _lock = new Lock();

    // This is the actual database filename that is saved in the docs directory.
    static final _databaseName = "MultiTimer.db";
    // Increment this version when you need to change the schema.
    static final _databaseVersion = 1;

    // Make this a singleton class.
    DBHelper._privateConstructor();
    static final DBHelper instance = DBHelper._privateConstructor();

    // Only allow a single open connection to the database.
    static Database _database;
    Future<Database> get database async {

        if(_database == null){
            await _lock.synchronized(() async {
                if(_database == null) {
                    print('Initiating new DB instance');
                    _database = await _initDatabase();
                }
            });
        }

        return _database;
    }

    // open the database
    _initDatabase() async {
        // The path_provider plugin gets the right directory for Android or iOS.
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        String path = join(documentsDirectory.path, _databaseName);
        // Open the database. Can also add an onUpdate callback parameter.
        print('Initiating database');
        return await openDatabase(path,
            version: _databaseVersion,
            onConfigure: _onConfigure,
            onCreate: _onCreate);
    }

    Future _onConfigure(Database db) async {
        // Add support for cascade delete
        await db.execute("PRAGMA foreign_keys = ON");
    }

    // SQL string to create the database
    Future _onCreate(Database db, int version) async {

        await db.execute('''
            CREATE TABLE IF NOT EXISTS ${multitimer.tableMultiTimer} (
                ${multitimer.columnId} INTEGER PRIMARY KEY,
                ${multitimer.columnName} TEXT NOT NULL
            )
        ''');


        await db.execute('''
              CREATE TABLE IF NOT EXISTS ${timer.tableTimer} (
                ${timer.columnId} INTEGER PRIMARY KEY,
                ${timer.columnHours} INTEGER NOT NULL,
                ${timer.columnMinutes} INTEGER NOT NULL,
                ${timer.columnSeconds} INTEGER NOT NULL,
                ${timer.columnDisplayOrder} INTEGER NOT NULL,
                ${timer.columnMultiTimer} INTEGER NOT NULL,
                FOREIGN KEY(${timer.columnMultiTimer}) REFERENCES ${multitimer.tableMultiTimer}(${multitimer.columnId}) ON DELETE CASCADE
              )
              ''');
    }
}