// ignore_for_file: lines_longer_than_80_chars, camel_case_types, avoid_unnecessary_containers

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tsec_app/models/occassion_model/occasion_model.dart';
import 'package:tsec_app/models/student_model/student_model.dart';
import 'package:tsec_app/models/timetable_model/timetable_model.dart';
import 'package:tsec_app/new_ui/screens/timeTableScreen/Widget/scheduleCard.dart';
import 'package:tsec_app/provider/auth_provider.dart';
import 'package:tsec_app/provider/timetable_provider.dart';
import 'package:tsec_app/screens/main_screen/widget/schedule_card.dart';
import 'package:tsec_app/provider/occasion_provider.dart';

import 'package:tsec_app/utils/faculty_details.dart';
import 'package:tsec_app/utils/notification_type.dart';
import 'package:tsec_app/utils/timeContainer.dart';
import 'package:tsec_app/utils/timetable_util.dart';

final dayProvider = StateProvider.autoDispose<DateTime>((ref) {
  DateTime day = DateTime.now();
  return day;
});

class cardDisplay extends ConsumerStatefulWidget {
  const cardDisplay({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _cardDisplayState();
}

class _cardDisplayState extends ConsumerState<cardDisplay> {
  static const colorList = [Colors.red, Colors.teal];
  static const opacityList = [
    Color.fromRGBO(255, 0, 0, 0.2),
    Color.fromARGB(51, 0, 255, 225),
  ];
  bool isExpanded = false;

  Future<String> getFacultyImageUrl(String facultyName) async {
    final ref = FirebaseStorage.instance.ref().child("faculty/comps/$facultyName.jpg");
    String url = (await ref.getDownloadURL()).toString();
    return url;
  }

  List<OccasionModel> occasionList = [];

  void fetchOccasionDetails() {
    ref.watch(occasionListProvider).when(
          data: ((data) {
            occasionList.addAll(data ?? []);
          }),
          loading: () {
            const CircularProgressIndicator();
          },
          error: (Object error, StackTrace? stackTrace) {},
        );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(counterStreamProvider);
    DateTime day = ref.watch(dayProvider);
    String dayStr = getweekday(day.weekday);
    var _theme = Theme.of(context);

    fetchOccasionDetails();

    final dat = ref.watch(notificationTypeProvider);
    debugPrint("time table batch details: ${dat?.yearBranchDivTopic}");
    return data.when(
      data: (data) {
        if (data == null) {
          return const Center(
            child: Text(
              "Unable to fetch timetable. Please check if you have entered your details correctly in the profile section.",
              textAlign: TextAlign.center,
            ),
          );
        }
        if (data[dayStr] == null) {
          return const Center(child: Text("Happy Weekend !"));
        } else if (checkOccasion(day, occasionList) != "") {
          return Center(child: Text("Happy ${checkOccasion(day, occasionList)}!"));
        } else {
          List<TimetableModel> timeTableDay = getTimetablebyDay(data, dayStr);
          if (timeTableDay.isEmpty) {
            return const Center(child: Text("No lectures Today ! "));
          } else {
            return Container(
              height: 400,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: _theme.colorScheme.tertiary,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), //
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      child: Text(
                        "Today’s Schedule",
                        style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 20, color: _theme.colorScheme.onPrimary),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: Container(
                        //padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TimeContainer(),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                child: ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: timeTableDay.length,
                                  itemBuilder: (context, index) {
                                    final lectureFacultyname = timeTableDay[index].lectureFacultyName;
                                    return scheduleCard(
                                      lectureEndTime: timeTableDay[index].lectureEndTime,
                                      lectureName: timeTableDay[index].lectureName,
                                      lectureStartTime: timeTableDay[index].lectureStartTime,
                                      facultyImageurl: getFacultyImagebyName(lectureFacultyname),
                                      facultyName: !checkTimetable(lectureFacultyname) ? "---------" : lectureFacultyname,
                                      lectureBatch: timeTableDay[index].lectureBatch,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        }
      },
      error: (error, stackTrace) {
        return Center(child: Text(error.toString()));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  List<TimetableModel> getTimetablebyDay(Map<String, dynamic> data, String day) {
    List<TimetableModel> timeTableDay = [];
    final daylist = data[day];
    for (final item in daylist) {
      StudentModel? studentModel = ref.watch(studentModelProvider);
      if (item['lectureBatch'] == studentModel!.batch.toString() || item['lectureBatch'] == 'All') {
        timeTableDay.add(TimetableModel.fromJson(item));
      }
    }
    return timeTableDay;
  }

  bool checkLabs(String lectureName) {
    return lectureName.toLowerCase().endsWith('labs') || lectureName.toLowerCase().endsWith('lab');
  }

  bool checkTimetable(String lectureFacultyName) {
    return lectureFacultyName.isEmpty || lectureFacultyName == " ";
  }
}
