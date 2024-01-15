import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class scheduleCard extends StatelessWidget {
  const scheduleCard(this.color, this.opacityColor,
      {Key? key,
      required this.lectureStartTime,
      required this.lectureEndTime,
      required this.lectureName,
      required this.facultyName,
      required this.facultyImageurl,
      required this.lectureBatch})
      : super(key: key);
  final Color? color;
  final Color? opacityColor;
  final String lectureStartTime;
  final String lectureEndTime;
  final String lectureName;
  final String facultyName;
  final String facultyImageurl;
  final String lectureBatch;

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    var _theme = Theme.of(context);
    var _boxshadow = BoxShadow(
      color: _theme.primaryColorDark,
      spreadRadius: 1,
      blurRadius: 2,
      offset: const Offset(0, 1),
    );
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.0,
            height: 60.0,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15.0),
                bottom: Radius.circular(15.0),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateFormat('E').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 11.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 250.0,
            height: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: _theme.primaryColorLight,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(30),
                right: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 10, 0),
                  child: Text(
                    "$lectureStartTime-$lectureEndTime",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _theme.textTheme.headline1!.color,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 8, 0),
                      child: Text(
                        lectureName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: _theme.textTheme.headline1!.color,
                          fontWeight: FontWeight.w400,
                          fontSize: 17.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   height: 8.0,
                    // ),
                    // FittedBox(
                    //   fit: BoxFit.scaleDown,
                    //   child: Text(
                    //     'Batch : $lectureBatch',
                    //     style: TextStyle(
                    //       color: _theme.textTheme.headline2!.color,
                    //       fontWeight: FontWeight.w300,
                    //       fontSize: 17.0,
                    //       letterSpacing: 1.0,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 10.0,
                    // ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 8, 0),
                      child: Text(
                        facultyName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
