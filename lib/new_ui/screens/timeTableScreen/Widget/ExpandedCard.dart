// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:tsec_app/utils/timetable_util.dart';

final dayProvider = StateProvider.autoDispose<DateTime>((ref) {
  DateTime day = DateTime.now();
  // debugPrint(day);
  return day;
});

class ExpandedCard extends ConsumerStatefulWidget {
  final int itemCount;

  const ExpandedCard({Key? key, required this.itemCount}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpandedCardState();
}

class _ExpandedCardState extends ConsumerState<ExpandedCard> {
  static const colorList = [Colors.red, Colors.teal];
  static const opacityList = [
    Color.fromRGBO(255, 0, 0, 0.2),
    Color.fromARGB(51, 0, 255, 225),
  ];

  Future<String> getFacultyImageUrl(String facultyName) async {
    final ref = FirebaseStorage.instance.ref().child("faculty/comps/$facultyName.jpg");
    String url = (await ref.getDownloadURL()).toString();
    return url;
  }

  List<OccasionModel> occasionList = [];

  void fetchOccasionDetails() {
    ref.watch(occasionListProvider).when(
          data: (data) {
            occasionList.addAll(data ?? []);
            // debugPrint("all occasions are : " + occasionList.toString());
          },
          loading: () {
            const CircularProgressIndicator();
          },
          error: (Object error, StackTrace? stackTrace) {},
        );
  }

  @override
  Widget build(BuildContext context) {
    bool val = false;
    final data = ref.watch(counterStreamProvider);
    DateTime day = ref.watch(dayProvider);
    String dayStr = getweekday(day.weekday);

    fetchOccasionDetails();
    // debugPrint("data is ${data.toString()}");

    final dat = ref.watch(notificationTypeProvider);
    debugPrint("time table batch details: ${dat?.yearBranchDivTopic}");
    return data.when(
      data: (data) {
        if (data == null) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text(
                "Unable to fetch timetable. Please check if you have entered your details correctly in the profile section.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (data[dayStr] == null) {
          return const SliverToBoxAdapter(
            child: Center(child: Text("Happy Weekend !")),
          );
        } else if (checkOccasion(day, occasionList) != "") {
          return SliverToBoxAdapter(
            child: Center(child: Text("Happy ${checkOccasion(day, occasionList)}!")),
          );
        } else {
          List<TimetableModel> timeTableDay = getTimetablebyDay(data, dayStr);
          if (timeTableDay.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(child: Text("No lectures Today ! ")),
            );
          } else {
            return SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    val = !val;
                  });
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 320,
                        height: val ? 500 : 300, // Set the height according to your requirements
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            Text("Today's Schedule", style: Theme.of(context).textTheme.headlineMedium),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 500),
                              crossFadeState: val ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                              firstChild: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.itemCount,
                                itemBuilder: (context, itemCount) {
                                  bool labs = checkLabs(timeTableDay[itemCount].lectureName);
                                  final color = labs ? colorList[1] : colorList[0];
                                  final opacity = labs ? opacityList[1] : opacityList[0];
                                  final lectureFacultyname = timeTableDay[itemCount].lectureFacultyName;
                                  return scheduleCard(
                                    color,
                                    opacity,
                                    lectureEndTime: timeTableDay[itemCount].lectureEndTime,
                                    lectureName: timeTableDay[itemCount].lectureName,
                                    lectureStartTime: timeTableDay[itemCount].lectureStartTime,
                                    facultyImageurl: getFacultyImagebyName(lectureFacultyname),
                                    facultyName: !checkTimetable(lectureFacultyname) ? "---------" : lectureFacultyname,
                                    lectureBatch: timeTableDay[itemCount].lectureBatch,
                                  );
                                },
                              ),
                              secondChild: ListView.builder(
                                shrinkWrap: true,
                                itemCount: timeTableDay.length,
                                itemBuilder: (context, index) {
                                  bool labs = checkLabs(timeTableDay[index].lectureName);
                                  final color = labs ? colorList[1] : colorList[0];
                                  final opacity = labs ? opacityList[1] : opacityList[0];
                                  final lectureFacultyname = timeTableDay[index].lectureFacultyName;

                                  return scheduleCard(
                                    color,
                                    opacity,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
      error: (error, stackTrace) {
        return SliverToBoxAdapter(
          child: Center(child: Text(error.toString())),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  List<TimetableModel> getTimetablebyDay(Map<String, dynamic> data, String day) {
    List<TimetableModel> timeTableDay = [];
    final daylist = data[day];
    for (final item in daylist) {
      StudentModel? studentModel = ref.watch(studentModelProvider);
      // debugPrint(studentModel!.batch.toString());
      if (item['lectureBatch'] == studentModel!.batch.toString() || item['lectureBatch'] == 'All') {
        debugPrint("in timetable, item is $item");
        timeTableDay.add(TimetableModel.fromJson(item));
      }
    }
    debugPrint(timeTableDay.toString());
    return timeTableDay;
  }

  bool checkLabs(String lectureName) {
    if (lectureName.toLowerCase().endsWith('labs') || lectureName.toLowerCase().endsWith('lab')) {
      return true;
    }
    return false;
  }

  bool checkTimetable(String lectureFacultyName) {
    if (lectureFacultyName.isEmpty || lectureFacultyName == " ") return true;
    return true;
  }
}
