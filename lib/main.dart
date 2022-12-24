import 'package:flutter/material.dart';
import 'package:meal_schedule/schedule.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meals for the Week',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.grey,
        ),
      ),
      home: const ScheduleWidget()
    );
  }
}