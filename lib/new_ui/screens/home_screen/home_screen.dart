// ignore_for_file: lines_longer_than_80_chars

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tsec_app/models/event_model/event_model.dart';
import 'package:tsec_app/models/student_model/student_model.dart';
import 'package:tsec_app/new_ui/screens/home_screen/widget/containerIconWithLabel.dart';
import 'package:tsec_app/new_ui/screens/timeTableScreen/Widget/ExpandedCard.dart';
import 'package:tsec_app/new_ui/screens/timeTableScreen/timeTable.dart';
import 'package:tsec_app/provider/auth_provider.dart';
import 'package:tsec_app/provider/event_provider.dart';
import 'package:tsec_app/screens/departmentlist_screen/department_list.dart';
import 'package:tsec_app/screens/main_screen/widget/card_display.dart';
import 'package:tsec_app/screens/profile_screen/profile_screen.dart';
import 'package:tsec_app/utils/image_assets.dart';
import 'package:url_launcher/url_launcher_string.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedPage = 0;
  List<Widget> widgets = <Widget>[
    const HomeWidget(),
    const Text(
      'Library',
    ),
    TimeTable(),
    const Text(
      'Railway Concession',
    ),
    ProfilePage(
      justLoggedIn: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Colors.black,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            activeIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: "Library",
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            activeIcon: Icon(Icons.calendar_today),
            icon: Icon(Icons.calendar_today_outlined),
            label: "Time Table",
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: Icon(Icons.directions_railway_outlined),
            activeIcon: Icon(Icons.directions_railway_filled),
            label: "Railway",
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: selectedPage,
        onTap: (index) {
          setState(() {
            selectedPage = index;
          });
        },
      ),
      body: widgets[selectedPage],
    );
  }
}

class HomeWidget extends ConsumerStatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<HomeWidget> {
  List<EventModel> eventList = [];
  bool shouldLoop = true;

  void launchUrlcollege() async {
    var url = "https://tsec.edu/";

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url.toString());
    } else
      throw "Could not launch url";
  }

  void fetchEventDetails() {
    ref.watch(eventListProvider).when(
        data: ((data) {
          eventList.addAll(data ?? []);
          imgList.clear();
          for (var data in eventList) {
            imgList.add(data.imageUrl);
          }
          // imgList = [imgList[0]];
          if (imgList.length == 1) shouldLoop = false;
        }),
        loading: () {
          const CircularProgressIndicator();
        },
        error: (Object error, StackTrace? stackTrace) {});
  }

  static List<String> imgList = [];
  final CarouselController carouselController = CarouselController();

  //static const _sidePadding = EdgeInsets.symmetric(horizontal: 15);
  static int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    StudentModel? data = ref.watch(studentModelProvider);
    fetchEventDetails();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi 👋🏻 ${data != null ? data.name : "Tsecite"}",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 25),
                ),
                Text(
                  "Welcome Back",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 25),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),

          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //     (BuildContext context, int index) {
          //       return const Padding(
          //         padding: EdgeInsets.all(20),
          //         child: CircularDateWidget(),
          //       );
          //     },
          //     childCount: 1,
          //   ),
          // ),
          if (data != null) const ExpandedCard(itemCount: 1),
          if (data != null)
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ContainerIconWithName(
                    text: "Railway",
                    icon: Icons.directions_railway_outlined,
                    onPressed: () {},
                  ),
                  ContainerIconWithName(
                    text: "Library",
                    icon: Icons.menu_book_rounded,
                    onPressed: () {},
                  )
                ],
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              width: 300.0,
              height: 200.0,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: Stack(
                  children: [
                    CarouselSlider(
                      items: imgList
                          .map(
                            (item) => GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(item),
                                        fit: BoxFit.fill,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(1),
                                          BlendMode.modulate,
                                        ),
                                      ),
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  GoRouter.of(context).pushNamed("details_page", queryParameters: {
                                    "Event Name": eventList[_currentIndex].eventName,
                                    "Event Time": eventList[_currentIndex].eventTime,
                                    "Event Date": eventList[_currentIndex].eventDate,
                                    "Event decription": eventList[_currentIndex].eventDescription,
                                    "Event registration url": eventList[_currentIndex].eventRegistrationUrl,
                                    "Event Image Url": item,
                                    "Event Location": eventList[_currentIndex].eventLocation,
                                    "Committee Name": eventList[_currentIndex].committeeName
                                  });
                                }),
                          )
                          .toList(),
                      options: CarouselOptions(
                        scrollPhysics: const BouncingScrollPhysics(),
                        autoPlay: true,
                        aspectRatio: 2,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// _currentIndex = index;
class CircularDateWidget extends StatelessWidget {
  const CircularDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.0,
      height: 60.0,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 24.0,
                color: Colors.white,
              ),
            ),
            Text(
              DateFormat('E').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// return CustomScaffold(
//   body: SafeArea(
//     child: CustomScrollView(
//       slivers: [
//         const SliverToBoxAdapter(
//           child: MainScreenAppBar(sidePadding: _sidePadding),
//         ),
//         data == null
//             ? const DepartmentList()
//             : SliverPadding(
//                 padding: const EdgeInsets.all(20),
//                 sliver: SliverToBoxAdapter(
//                   child: Container(
//                     width: _size.width * 0.9,
//                     decoration: BoxDecoration(
//                       color: _theme.primaryColor,
//                       borderRadius: BorderRadius.circular(15.0),
//                       border: Border.all(
//                         color: _theme.primaryColorLight,
//                         width: 1,
//                         style: BorderStyle.solid,
//                       ),
//                       boxShadow: [_boxshadow],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(15.0),
//                       child: DatePicker(
//                         DateTime.now(),
//                         monthTextStyle: _theme.textTheme.subtitle2!,
//                         dayTextStyle: _theme.textTheme.subtitle2!,
//                         dateTextStyle: _theme.textTheme.subtitle2!,
//                         initialSelectedDate: DateTime.now(),
//                         selectionColor: Colors.blue,
//                         onDateChange: ((selectedDate) async {
//                           ref
//                               .read(dayProvider.notifier)
//                               .update((state) => selectedDate);
//                         }),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//         data != null ? const CardDisplay() : const SliverToBoxAdapter()
//       ],
//     ),
//   ),
// );

class MainScreenAppBar extends ConsumerStatefulWidget {
  final EdgeInsets _sidePadding;
  const MainScreenAppBar({
    Key? key,
    required EdgeInsets sidePadding,
  })  : _sidePadding = sidePadding,
        super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenAppBarState();
}

class _MainScreenAppBarState extends ConsumerState<MainScreenAppBar> {
  // List<EventModel> eventList = [];
  bool shouldLoop = true;

  void launchUrlcollege() async {
    var url = "https://tsec.edu/";

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url.toString());
    } else
      throw "Could not launch url";
  }

  // void fetchEventDetails() {
  //   ref.watch(eventListProvider).when(
  //       data: ((data) {
  //         eventList.addAll(data ?? []);
  //         imgList.clear();
  //         for (var data in eventList) {
  //           imgList.add(data.imageUrl);
  //         }
  //         // imgList = [imgList[0]];
  //         if (imgList.length == 1) shouldLoop = false;
  //       }),
  //       loading: () {
  //         const CircularProgressIndicator();
  //       },
  //       error: (Object error, StackTrace? stackTrace) {});
  // }

  static List<String> imgList = [];

  //static const _sidePadding = EdgeInsets.symmetric(horizontal: 15);
  static int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    StudentModel? data = ref.watch(studentModelProvider);
    return Container();
    // fetchEventDetails();
    // return Padding(
    //   padding: widget._sidePadding.copyWith(top: 15),
    //   child: Column(
    //     children: [
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: <Widget>[
    //           Flexible(
    //             flex: 4,
    //             child: GestureDetector(
    //               onTap: () {
    //                 launchUrlcollege();
    //               },
    //               child: Text("Thadomal Shahani Engineering College",
    //                   style: Theme.of(context).textTheme.headline3),
    //             ),
    //           ),
    //           data == null
    //               ? const SizedBox()
    //               : Flexible(
    //                   flex: 1,
    //                   child: GestureDetector(
    //                     onTap: () =>
    //                         GoRouter.of(context).push("/notifications"),
    //                     child: Container(
    //                       padding: const EdgeInsets.all(5),
    //                       decoration: BoxDecoration(
    //                         color: Theme.of(context).colorScheme.secondary,
    //                         borderRadius: BorderRadius.circular(5),
    //                       ),
    //                       child: const IconTheme(
    //                         data: IconThemeData(color: kLightModeLightBlue),
    //                         child: Icon(Icons.notifications),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //         ],
    //       ),
    //       const SizedBox(height: 10),
    //       GestureDetector(
    //         onTap: () => launchUrl(
    //           "https://goo.gl/maps/5DzApsKqUQ91T5yK7",
    //           context,
    //         ),
    //         child: Row(
    //           children: <Widget>[
    //             Image.asset(
    //               ImageAssets.locationIcon,
    //               width: 20,
    //             ),
    //             Text(
    //               "Bandra, Mumbai",
    //               style: Theme.of(context)
    //                   .primaryTextTheme
    //                   .bodyText1!
    //                   .copyWith(color: kLightModeDarkBlue),
    //             ),
    //           ],
    //         ),
    //       ),
    //       const SizedBox(
    //         height: 15,
    //       ),
    //       imgList.isEmpty
    //           ? ClipRRect(
    //               child: Image.asset(ImageAssets.tsecImg),
    //               borderRadius: BorderRadius.circular(15),
    //             )
    //           : Column(
    //               children: [
    //                 Row(
    //                   children: [
    //                     Text(
    //                       "Upcoming Events",
    //                       style: Theme.of(context).textTheme.bodyLarge,
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(
    //                   height: 15,
    //                 ),
    //                 CarouselSlider(
    //                   items: imgList
    //                       .map(
    //                         (item) => GestureDetector(
    //                             child: Padding(
    //                               padding: const EdgeInsets.symmetric(
    //                                   horizontal: 8.0),
    //                               child: Container(
    //                                 width:
    //                                     MediaQuery.of(context).size.width * 0.6,
    //                                 height:
    //                                     MediaQuery.of(context).size.width * 0.4,
    //                                 decoration: BoxDecoration(
    //                                   image: DecorationImage(
    //                                     image: CachedNetworkImageProvider(item),
    //                                     fit: BoxFit.fill,
    //                                     colorFilter: ColorFilter.mode(
    //                                       Colors.white.withOpacity(1),
    //                                       BlendMode.modulate,
    //                                     ),
    //                                   ),
    //                                   color: Colors.white,
    //                                   borderRadius: const BorderRadius.all(
    //                                     Radius.circular(20),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                             onTap: () {
    //                               GoRouter.of(context).pushNamed("details_page",
    //                                   queryParameters: {
    //                                     "Event Name":
    //                                         eventList[_currentIndex].eventName,
    //                                     "Event Time":
    //                                         eventList[_currentIndex].eventTime,
    //                                     "Event Date":
    //                                         eventList[_currentIndex].eventDate,
    //                                     "Event decription":
    //                                         eventList[_currentIndex]
    //                                             .eventDescription,
    //                                     "Event registration url":
    //                                         eventList[_currentIndex]
    //                                             .eventRegistrationUrl,
    //                                     "Event Image Url": item,
    //                                     "Event Location":
    //                                         eventList[_currentIndex]
    //                                             .eventLocation,
    //                                     "Committee Name":
    //                                         eventList[_currentIndex]
    //                                             .committeeName
    //                                   });
    //                             }),
    //                       )
    //                       .toList(),
    //                   options: CarouselOptions(
    //                     autoPlay: shouldLoop,
    //                     enableInfiniteScroll: shouldLoop,
    //                     enlargeCenterPage: true,
    //                     viewportFraction: .7,
    //                     onPageChanged: (index, reason) {
    //                       setState(() {
    //                         _currentIndex = index;
    //                       });
    //                     },
    //                   ),
    //                 ),
    //               ],
    //             ),
    //       const SizedBox(
    //         height: 30,
    //       ),
    //       Row(
    //         children: [
    //           Text(
    //             data != null ? "Time Table" : "Departments ",
    //             style: Theme.of(context).textTheme.bodyLarge,
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}
