import 'dart:convert';

class Meal {
  String name = "";
  MealType type = MealType.unknown;

  Meal({
    required this.name,
    required this.type,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(name: json['n'] as String, type: MealType.values.byName(json['t'] as String));
  }

  Map<String, dynamic> toJson() {
    // print("Converting to json: " + name + "::" + type.name);
    return {
      'n': name,
      't': type.name,
    };
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  unknown
}