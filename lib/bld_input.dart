import 'dart:math';

import 'package:flutter/material.dart';
import 'dao/model/meal.dart';
import 'package:intl/intl.dart';

import 'dao/model/option.dart';
import 'dao/model/schedule.dart';

class BLDWidget extends StatefulWidget {
  final Schedule schedule;
  final Function(Schedule) callback;

  const BLDWidget({super.key, required this.schedule, required this.callback});

  // final Function(int) callback;
  // final int index;
  // bool isActive;
  // DayWidget({super.key, required this.date, required this.callback, required this.index, this.isActive = false});

  @override
  State<BLDWidget> createState() => BLDState();
}

class BLDState extends State<BLDWidget> {
  final _biggerFont = const TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  final _mediumFont = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  Meal getMealForType(MealType mealType) {
    for (Meal meal in widget.schedule.meals) {
      if (meal.type == mealType) {
        return meal;
      }
    }
    Meal newMeal = Meal(name: '', type: mealType);
    widget.schedule.meals.add(newMeal);
    return newMeal;
  }

  void updateMeal(Meal updatedMeal) {
    setState(() {
      widget.callback(widget.schedule);
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Column(children: [
      SizedBox(height: 50),
      Center(
        child: (
          Column(children: [
            Text("Schedule for ${DateFormat('EEEEE').format(widget.schedule.date)}", style:_biggerFont),
            const SizedBox(height: 5),
            Text(DateFormat('MMMMd').format(widget.schedule.date), style:_mediumFont),
          ])
        )
      ),
      Container(
          margin: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 5.0),
        child: MealWidget(meal: getMealForType(MealType.breakfast), callback: updateMeal)
      ),
      Container(
          margin: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
          child: MealWidget(meal: getMealForType(MealType.lunch), callback: updateMeal)
      ),
      Container(
          margin: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
          child: MealWidget(meal: getMealForType(MealType.dinner), callback: updateMeal)
      ),
      SizedBox(height: 120),
    ]);
  }
}

class MealWidget extends StatefulWidget {

  final Meal meal;
  final Function(Meal) callback;

  const MealWidget({super.key, required this.meal,required this.callback });

  @override
  State<MealWidget> createState() => MealState();
}

class MealState extends State<MealWidget> {
  late String mealName;
  late String mealValueDefault;
  late Icon mealIcon;
  bool editing = false;
  final _random = Random();
  late List<String> mealOptions;

  @override
  void initState() {
    mealOptions = MealOption.getOptionsForType(widget.meal.type).toList();
    switch(widget.meal.type) {
      case MealType.breakfast: {
        mealName = "Breakfast";
        mealValueDefault = 'eggs / cereal / pancakes';
        mealIcon = const Icon(Icons.egg, color: Colors.white, size: 25);
        break;
      }
      case MealType.lunch: {
        mealName = "Lunch";
        mealValueDefault = 'pizza / salads / sandwich';
        mealIcon = const Icon(Icons.local_pizza, color: Colors.brown, size: 25);
        break;
      }
      case MealType.dinner: {
        mealName = "Dinner";
        mealValueDefault = 'curry / rice / steak';
        mealIcon = const Icon(Icons.dining, size: 25);
        break;
      }
    }
    super.initState();
  }

  void onTextChange(String updatedString) {
    setState(() {
      widget.meal.name = updatedString;
      widget.callback(widget.meal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Flexible(
        flex: 3,
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Row(
            children: [
              mealIcon,
              SizedBox(width: 2),
              Expanded(child: Text(mealName)),
            ],
          ),
        ),
      ),
      Flexible(
        flex: 7,
        child: CustomPaint(
          foregroundPainter: NotchPainter(notchSize: 8),
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Color(0xFFEEEEEE),//Colors.black12,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Row(children: [
              SizedBox(width: 10),
              Expanded(child:
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return mealOptions.where((String option) {
                    return option.contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  onTextChange(selection);
                },
                fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                  textEditingController.text  = widget.meal.name;
                  textEditingController.selection = TextSelection.collapsed(
                                offset: widget.meal.name.length);
                  return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onChanged: onTextChange,
                      decoration: new InputDecoration.collapsed(
                        border: InputBorder.none,
                        hintText: mealValueDefault,
                        hintStyle: TextStyle(color: Color(0XFFD6D6D6)),
                      ),
                    );
                }
              ),
              ),
            SizedBox.fromSize(
                size: Size(35, 35),
                  child: Material(
                    color: Colors.black12,
                    child: InkWell(
                      splashColor: Colors.orange,
                      onTap: () {
                        onTextChange(mealOptions[_random.nextInt(mealOptions.length)]);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.shuffle),
                          // Text("Buy"), // <-- Text
                        ],
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    ]);
  }
}
class NotchPainter extends CustomPainter {
  late double notchSize;
  NotchPainter({
    this.notchSize = 5,
  });
  @override
  void paint(Canvas canvas, Size size) {
    var path = Path()
      ..moveTo(0, size.height / 2 - notchSize)
      ..relativeLineTo(notchSize, notchSize)
      ..relativeLineTo(-notchSize, notchSize)
      ..close();
    var paint = Paint()..color = Colors.orange;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}