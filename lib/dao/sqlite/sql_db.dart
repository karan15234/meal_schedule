import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:meal_schedule/dao/model/schedule.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/meal.dart';

class SqlDatabase {

  static late Future<Database> _database;

  Future<Database> init() async {
    print("Initializing database");
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    _database = openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
          join(await getDatabasesPath(), 'schedule_database.db'),
          onCreate: (db, version) async {
            // await db.execute('DELETE FROM schedule');
            await db.execute(
            'CREATE TABLE IF NOT EXISTS schedule(id INTEGER PRIMARY KEY, meals TEXT)',
            );
          },
      version: 1,
    );
    return _database;
  }

  Future<void> insertSchedule(Schedule schedule) async {
    // Get a reference to the database.
    final db = await _database;

    // Insert the Schedule into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same Schedule is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'schedule',
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Schedule>> schedule() async {
    // init();

    // Get a reference to the database.
    final db = await _database;

    // Query the table for all Schedules
    final List<Map<String, dynamic>> maps = await db.query('schedule');


    // Convert the List<Map<String, dynamic> into a List<Schedule>.
    return List.generate(maps.length, (i) {
      final mealsData = jsonDecode(maps[i]['meals']) as List<dynamic>?;
      return Schedule(
          meals: mealsData != null ? mealsData.map((data) => Meal.fromJson(data)).toList() : [],
          date: DateTime.fromMillisecondsSinceEpoch(maps[i]['id'] as int)
      );
      // return Schedule.deserialize(maps[i]['meals'], maps[i]['id']);
    });
  }

  Future<void> updateSchedule(Schedule schedule) async {
    // Get a reference to the database.
    final db = await _database;

    // Update the given Dog.
    await db.update(
      'schedule',
      schedule.toMap(),
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [schedule.id()],
    );
  }

  Future<void> deleteSchedule(int id) async {
    // Get a reference to the database.
    final db = await _database;

    // Remove the Schedule from the database.
    await db.delete(
      'schedule',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Schedule's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}