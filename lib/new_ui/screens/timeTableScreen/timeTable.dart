// ignore_for_file: lines_longer_than_80_chars, unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsec_app/models/student_model/student_model.dart';
import 'package:tsec_app/models/timetable_model/timetable_model.dart';
import 'package:tsec_app/new_ui/screens/home_screen/widget/ExpandedCard.dart';
import 'package:tsec_app/new_ui/screens/timeTableScreen/Widget/cardDisplay.dart';
import 'package:tsec_app/provider/auth_provider.dart';
import 'package:tsec_app/provider/timetable_provider.dart';
import 'package:tsec_app/screens/departmentlist_screen/department_list.dart';
import 'package:tsec_app/screens/main_screen/widget/card_display.dart';
import 'package:tsec_app/utils/timetable_util.dart';
import 'package:tsec_app/widgets/custom_scaffold.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

final dayProvider = StateProvider.autoDispose<DateTime>((ref) {
  DateTime day = DateTime.now();
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
    final _size = MediaQuery.of(context).size;
    var _theme = Theme.of(context);
    var _boxshadow = BoxShadow(
      color: _theme.primaryColorDark,
      spreadRadius: 1,
      blurRadius: 2,
      offset: const Offset(0, 1),
    );
    StudentModel? studentData = ref.watch(studentModelProvider);
    double _height = 200;
    bool _seletedColor = false;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schedule",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 44),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: _size.width * 0.85,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: DatePicker(
                  DateTime.now(),
                  monthTextStyle: _theme.textTheme.headlineSmall!.copyWith(
                    fontSize: 15,
                    color: _theme.colorScheme.onTertiary,
                  ),
                  dayTextStyle: _theme.textTheme.headlineSmall!.copyWith(
                    fontSize: 15,
                    color: _theme.colorScheme.onTertiary,
                  ),
                  dateTextStyle: _theme.textTheme.headlineSmall!.copyWith(
                    fontSize: 15,
                    color: _theme.colorScheme.onTertiary,
                  ),
                  selectedTextColor: _theme.colorScheme.tertiaryContainer, // black
                  initialSelectedDate: DateTime.now(),
                  selectionColor: _theme.colorScheme.onSecondary, // white
                  onDateChange: ((selectedDate) async {
                    ref.read(dayProvider.notifier).update((state) => selectedDate);
                  }),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const cardDisplay(),
          ],
        ),
      ),
    );
  }
}
