import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_schedule/bld_input.dart';
import 'package:meal_schedule/dao/model/schedule.dart';
import 'package:meal_schedule/dao/sqlite/sql_db.dart';

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({super.key});

  @override
  State<ScheduleWidget> createState() => ScheduleState();
}

class ScheduleState extends State<ScheduleWidget> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, Schedule> _scheduleMap = {};
  late SqlDatabase _sqlDatabase;
  int selectedIndex = 0;

  late DateTime today;
  late DateTime oneMonthAfter;
  late DateTime oneMonthBefore;

  void scroll(double pixels) {
    _scrollController.animateTo(pixels, duration: const Duration(seconds: 1), curve: Curves.ease); // in pixels
  }

  @override
  void initState() {
    var now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    oneMonthAfter = DateTime(today.year, today.month + 1, today.day);
    oneMonthBefore = DateTime(today.year, today.month - 1, today.day);
    selectedIndex = today.difference(oneMonthBefore).inDays + 1;

    _sqlDatabase = SqlDatabase();
    _sqlDatabase.init().whenComplete(() async {
      final schedules = await _sqlDatabase.schedule();
      setState(() {
        _scheduleMap.addAll({for (var schedule in schedules) schedule.id() : schedule});
      });
    });

    var totalSize = oneMonthAfter.difference(oneMonthBefore).inDays;
    for (int i=0;i<totalSize;i++) {
      DateTime day = DateTime(oneMonthBefore.year, oneMonthBefore.month, oneMonthBefore.day + i);
      _scheduleMap[day.millisecondsSinceEpoch] = Schedule(meals: [], date: day);
    }
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => scroll(selectedIndex * 55));
  }

  // void onChange(int index) {
  //   setState(() {
  //     for (int i = 0;i < _isSelected.length; i++) {
  //       if (i != index) {
  //         _isSelected[i] = false;
  //       }
  //     }
  //     _isSelected[index] = !_isSelected[index];
  //   });
  // }

  int? getCurrentDate() {
    var currentDate = DateTime(oneMonthBefore.year, oneMonthBefore.month, oneMonthBefore.day + selectedIndex - 1);
    return currentDate.millisecondsSinceEpoch;
  }

  void onUpdateMeal(Schedule updatedSchedule) async {
    setState(() {
      _scheduleMap[updatedSchedule.date.millisecondsSinceEpoch] = updatedSchedule;
    });
    await _sqlDatabase.insertSchedule(updatedSchedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 148.0,
        title: Column(
          children: [
            Row(
              children: const [
                // Icon(
                //   Icons.arrow_back_ios,
                //   color: Colors.orange,
                // ),
                Expanded(
                    child: Text("Meal Planner",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        )))
              ],
            ),
            const SizedBox(height: 16.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              controller: _scrollController,
              child: Row(
                children: List.generate(
                   oneMonthAfter.difference(oneMonthBefore).inDays,
                      (index) {
                    final currentDate =
                    oneMonthAfter.add(Duration(days: index + 1));
                    final dayName = DateFormat('E').format(currentDate);
                    return Padding(
                      padding: EdgeInsets.only(
                          left: index == 0 ? 16.0 : 0.0, right: 16.0),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          selectedIndex = index;
                        }),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text(
                              dayName.substring(0, 1),
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                            height: 42.0,
                            width: 42.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                            color: selectedIndex == index
                            ? Colors.orange
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(44.0),
                            ),
                            child: Text(
                                "${oneMonthBefore.add(Duration(days: index)).day}",
                                style: TextStyle(
                                  fontSize: 26.0,
                                  color: selectedIndex == index
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                              height: 2.0,
                              width: 28.0,
                              color: selectedIndex == index
                                  ? Colors.orange
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(child: Center(
            child: Column(
              children: [
                BLDWidget(schedule: _scheduleMap[getCurrentDate()]!, callback: onUpdateMeal)
              ]),
            )
      )
    );
  }
}