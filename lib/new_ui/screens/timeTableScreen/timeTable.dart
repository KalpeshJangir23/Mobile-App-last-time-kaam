// ignore_for_file: lines_longer_than_80_chars
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsec_app/models/student_model/student_model.dart';
import 'package:tsec_app/models/timetable_model/timetable_model.dart';
import 'package:tsec_app/new_ui/screens/timeTableScreen/Widget/ExpandedCard.dart';
import 'package:tsec_app/provider/auth_provider.dart';
import 'package:tsec_app/provider/timetable_provider.dart';
import 'package:tsec_app/screens/departmentlist_screen/department_list.dart';
import 'package:tsec_app/screens/main_screen/widget/card_display.dart';
import 'package:tsec_app/utils/timetable_util.dart';
import 'package:tsec_app/widgets/custom_scaffold.dart';

import 'package:date_picker_timeline/date_picker_timeline.dart';

final dayProvider = StateProvider.autoDispose<DateTime>((ref) {
  DateTime day = DateTime.now();
  // debugPrint(day);
  return day;
});

class TimeTable extends ConsumerStatefulWidget {
  const TimeTable({Key? key}) : super(key: key);

  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends ConsumerState<TimeTable> {
  static const colorList = [Colors.red, Colors.teal, Colors.blue];
  static const opacityList = [
    Color.fromRGBO(255, 0, 0, 0.2),
    Color.fromARGB(51, 0, 255, 225),
    Color.fromARGB(51, 0, 153, 255),
  ];

  @override
  Widget build(BuildContext context) {
    // List<TimetableModel> timeTableDay = getTimetablebyDay(data as Map<String, dynamic>, dayStr);

    final _size = MediaQuery.of(context).size;
    var _theme = Theme.of(context);
    var _boxshadow = BoxShadow(
      color: _theme.primaryColorDark,
      spreadRadius: 1,
      blurRadius: 2,
      offset: const Offset(0, 1),
    );
    StudentModel? studentData = ref.watch(studentModelProvider);

    return CustomScaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            studentData == null
                ? const DepartmentList()
                : SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        width: _size.width * 0.9,
                        decoration: BoxDecoration(
                          color: _theme.primaryColor,
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            color: _theme.primaryColorLight,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                          boxShadow: [_boxshadow],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: DatePicker(
                            DateTime.now(),
                            monthTextStyle: _theme.textTheme.subtitle2!,
                            dayTextStyle: _theme.textTheme.subtitle2!,
                            dateTextStyle: _theme.textTheme.subtitle2!,
                            initialSelectedDate: DateTime.now(),
                            selectionColor: Colors.blue,
                            onDateChange: ((selectedDate) async {
                              ref.read(dayProvider.notifier).update((state) => selectedDate);
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
            studentData != null ? const ExpandedCard(itemCount: 2) : const SliverToBoxAdapter()
          ],
        ),
      ),
    );
  }
}
