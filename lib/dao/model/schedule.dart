import 'dart:convert';

import 'meal.dart';

class Schedule {
  List<Meal> meals;
  DateTime date;

  Schedule({
    required this.meals,
    required this.date
  });

  Map<String, dynamic> toMap() {
    return {
      'meals': jsonEncode(meals),
      'id': id(),
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final mealsData = json['m'] as List<dynamic>?;
    return Schedule(
        meals: mealsData != null ? mealsData.map((data) => Meal.fromJson(data)).toList() : [],
        date: DateTime.fromMillisecondsSinceEpoch(json['id'] as int)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'm': jsonEncode(meals),
      'id': id(),
    };
  }

  static Schedule deserialize(String mealsString, int dateEpoch) {
    print("deserialize: " + mealsString);
    return Schedule(
      meals: jsonDecode(mealsString),
      date: DateTime.fromMillisecondsSinceEpoch(dateEpoch)
    );
  }


  int id() {
    return date.millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return 'Schedule{meals: $meals, date: $date}';
  }
}