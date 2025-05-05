// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:driveguard/features/history/presentation/history_page.dart';
// import 'package:driveguard/features/home/presentation/ui/location_popup.dart';
// import 'package:driveguard/features/home/presentation/ui/turn_by_turn_nav_page.dart';
// import 'package:flutter/material.dart';

// import 'package:driveguard/features/ml%20section/ui/start_screen.dart';
// import 'package:driveguard/features/widgets/home_slider.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     void _showLocationBottomSheet(BuildContext context) {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled:
//             true, // This allows the sheet to take up variable height
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//         ),
//         builder: (BuildContext context) {
//           // Calculate the height to be half the screen
//           final screenHeight = MediaQuery.of(context).size.height;
//           final halfScreenHeight = screenHeight * 0.5;

//           return Container(
//             height: halfScreenHeight,
//             child: LocationBottomSheet(),
//           );
//         },
//       );
//     }

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(223, 228, 228, 228),
//       // appBar: AppBar(
//       //   backgroundColor: const Color.fromARGB(223, 228, 228, 228),
//       //   title: Center(
//       //     child: Text(
//       //       'DriveGuard',
//       //       style: Theme.of(context)
//       //           .textTheme
//       //           .titleMedium!
//       //           .copyWith(color: Colors.black),
//       //     ),
//       //   ),
//       //   leading: _buildIcon('assets/png/icons/hamburger.png'),
//       //   actions: [_buildIcon('assets/png/icons/hamburger.png')],
//       //   elevation: 0,
//       // ),
//       body: Padding(
//         padding: const EdgeInsets.all(18.0),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 50,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 _buildIcon('assets/png/icons/hamburger.png'),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('DriveGuard',
//                         style: Theme.of(context).textTheme.titleLarge),
//                     Text(
//                       'Lets Drive Safer',
//                       style: Theme.of(context).textTheme.labelMedium!.copyWith(
//                           color: const Color.fromARGB(255, 111, 111, 111)),
//                     )
//                   ],
//                 ),
//                 // _buildIcon('assets/png/icons/hamburger.png')
//               ],
//             ),
//             SizedBox(
//               height: 45,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 InkWell(
//                   onTap: () {
//                     Navigator.of(context).push(
//                         MaterialPageRoute(builder: (context) => HistoryPage()));
//                   },
//                   child: Hometiles(
//                     iconPath: 'assets/png/icons/history.png',
//                     title: 'Previous',
//                     subText: '4',
//                   ),
//                 ),
//                 Hometiles(
//                   iconPath: 'assets/png/icons/meter.png',
//                   title: 'Top Speed',
//                   subText: '120',
//                   isSpeed: true,
//                 ),
//                 Hometiles(
//                   iconPath: 'assets/png/icons/trophy.png',
//                   title: 'Ranking',
//                   subText: '10',
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 40,
//             ),
//             Transform.scale(
//               scale: 1.55,
//               child: Image.asset(
//                   'assets/png/cars/933ce91a-78d8-43a7-a7fe-5a74344b7206.webp'),
//             ),
//             Expanded(child: SizedBox()),
//             Divider(
//               color: Colors.black,
//             ),
//             Padding(
//               padding: EdgeInsets.all(40).copyWith(),
//               child: CustomSliderButton(
//                 imagePath: 'assets/png/icons/previous.png',
//                 func: () async {
//                   // Navigator.of(context).push(
//                   //     MaterialPageRoute(builder: (context) => NavigationApp()));
//                   _showLocationBottomSheet(context);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildIcon(String assetPath) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 25.0),
//       child: Container(
//         height: 60,
//         width: 60,
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             // borderRadius: BorderRadius.circular(10),
//             shape: BoxShape.circle),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Image.asset(assetPath),
//         ),
//       ),
//     );
//   }
// }

// class Hometiles extends StatelessWidget {
//   final String title;
//   final String iconPath;
//   final String subText;
//   final bool isSpeed;
//   final bool ishome;
//   const Hometiles({
//     super.key,
//     required this.title,
//     required this.iconPath,
//     required this.subText,
//     this.isSpeed = false,
//     this.ishome = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     double dh = MediaQuery.of(context).size.height;

//     double dw = MediaQuery.of(context).size.width;
//     return Container(
//       height: dh * 0.20,
//       width: 120,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0).copyWith(left: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//                 height: dh * 0.08,
//                 width: dw * 0.09,
//                 child: Image.asset(iconPath)),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               title,
//               style: Theme.of(context).textTheme.titleSmall,
//             ),
//             isSpeed
//                 ? Row(
//                     children: [
//                       Text(
//                         subText,
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 10.0),
//                         child: Text(
//                           'Kmph',
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleSmall!
//                               .copyWith(fontSize: 10),
//                         ),
//                       )
//                     ],
//                   )
//                 : Text(
//                     subText,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   )
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:driveguard/common/hive/trip_data_hive_model.dart';
import 'package:driveguard/common/hive/trip_statistics_hive.dart';
import 'package:driveguard/features/history/presentation/history_page.dart';
import 'package:driveguard/features/home/presentation/ui/location_popup.dart';
import 'package:driveguard/features/home/presentation/ui/turn_by_turn_nav_page.dart';
import 'package:flutter/material.dart';

import 'package:driveguard/features/ml%20section/ui/start_screen.dart';
import 'package:driveguard/features/widgets/home_slider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This allows the sheet to take up variable height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        // Calculate the height to be half the screen
        final screenHeight = MediaQuery.of(context).size.height;
        final halfScreenHeight = screenHeight * 0.5;

        return Container(
          height: halfScreenHeight,
          child: LocationBottomSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(223, 228, 228, 228),
      // appBar: AppBar(
      //   backgroundColor: const Color.fromARGB(223, 228, 228, 228),
      //   title: Center(
      //     child: Text(
      //       'DriveGuard',
      //       style: Theme.of(context)
      //           .textTheme
      //           .titleMedium!
      //           .copyWith(color: Colors.black),
      //     ),
      //   ),
      //   leading: _buildIcon('assets/png/icons/hamburger.png'),
      //   actions: [_buildIcon('assets/png/icons/hamburger.png')],
      //   elevation: 0,
      // ),
      body: ValueListenableBuilder<Box<TripData>>(
        valueListenable: Hive.box<TripData>('trip_history').listenable(),
        builder: (context, box, _) {
          final highSpeed = TripStatisticsService.getHighestMaxSpeed();
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildIcon('assets/png/icons/hamburger.png'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DriveGuard',
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          'Lets Drive Safer',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color:
                                      const Color.fromARGB(255, 111, 111, 111)),
                        )
                      ],
                    ),
                    // _buildIcon('assets/png/icons/hamburger.png')
                  ],
                ),
                SizedBox(
                  height: 45,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HistoryPage()));
                      },
                      child: Hometiles(
                        iconPath: 'assets/png/icons/history.png',
                        title: 'Previous',
                        subText: '',
                      ),
                    ),
                    Hometiles(
                      iconPath: 'assets/png/icons/meter.png',
                      title: 'Top Speed',
                      subText:
                          highSpeed > 0 ? '${highSpeed.ceil()}' : 'No data',
                      isSpeed: true,
                    ),
                    // Hometiles(
                    //   iconPath: 'assets/png/icons/trophy.png',
                    //   title: 'Ranking',
                    //   subText: '10',
                    // ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Transform.scale(
                  scale: 1.55,
                  child: Image.asset(
                      'assets/png/cars/933ce91a-78d8-43a7-a7fe-5a74344b7206.webp'),
                ),
                Expanded(child: SizedBox()),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.all(40).copyWith(),
                  child: CustomSliderButton(
                    imagePath: 'assets/png/icons/previous.png',
                    func: () async {
                      // Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (context) => NavigationApp()));
                      _showLocationBottomSheet(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon(String assetPath) {
    return Padding(
      padding: const EdgeInsets.only(right: 25.0),
      child: Container(
        height: 60,
        width: 60,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(10),
            shape: BoxShape.circle),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(assetPath),
        ),
      ),
    );
  }
}

class Hometiles extends StatelessWidget {
  final String title;
  final String iconPath;
  final String subText;
  final bool isSpeed;
  final bool ishome;
  const Hometiles({
    super.key,
    required this.title,
    required this.iconPath,
    required this.subText,
    this.isSpeed = false,
    this.ishome = true,
  });

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;

    double dw = MediaQuery.of(context).size.width;
    return Container(
      height: dh * 0.20,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0).copyWith(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: dh * 0.08,
                width: dw * 0.09,
                child: Image.asset(iconPath)),
            SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            isSpeed
                ? Row(
                    children: [
                      Text(
                        subText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Kmph',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontSize: 10),
                        ),
                      )
                    ],
                  )
                : Text(
                    subText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
          ],
        ),
      ),
    );
  }
}
