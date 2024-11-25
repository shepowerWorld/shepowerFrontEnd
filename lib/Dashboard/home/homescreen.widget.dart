import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Events/models/event.model.dart';

class ExploreEventScreen extends StatelessWidget {
  final EventModel event;
  final String formattedDate;

  const ExploreEventScreen({
    Key? key,
    required this.event,
    required this.formattedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = "${imagespath.baseUrl}${event.eventimage}";

    // Parse the formatted date string
    DateTime dateTime = _parseFormattedDate(formattedDate);

    // Extract individual date components
    String day = dateTime.day.toString();
    String weekday = _getWeekday(dateTime.weekday);
    String month = _getMonthName(dateTime.month).substring(0, 3);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(9.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          color: Colors.grey[50],
        ),
        width: 237.h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(right: 1.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  height: 230.h,
                  width: 218.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  day,
                                  style: TextStyle(color: Colors.amber[900],fontWeight:FontWeight.bold,fontSize: 20),
                                ),
                                Text(
                                  month.toUpperCase(),
                                  style: TextStyle(color: Colors.amber[900],fontSize: 16),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 13),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                event.eventname ?? "-",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 219, 4, 112),
                ),
              ),
            ),
            SizedBox(height: 11),
            Padding(
              padding: EdgeInsets.only(left: 7.h),
              child: Row(
                children: [
                  Text(
                    _formatEventTime(
                        event.eventtime ?? "", event.eventendtime ?? ""),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseFormattedDate(String formattedDate) {
    // Split the formatted date string by comma and space
    List<String> parts = formattedDate.split(', ');

    // Extract the day and month
    String dayMonth = parts[1];

    // Split the day and month
    List<String> dayMonthParts = dayMonth.split('-');

    // Extract the day and month names
    int day = int.parse(dayMonthParts[0]);
    String month = dayMonthParts[1];

    // Convert the month name to its numerical representation
    int monthNumber = _getMonthNumber(month);

    // Create a new date time object
    DateTime now = DateTime.now();
    return DateTime(now.year, monthNumber, day);
  }

  int _getMonthNumber(String monthName) {
    switch (monthName) {
      case 'January':
        return 1;
      case 'February':
        return 2;
      case 'March':
        return 3;
      case 'April':
        return 4;
      case 'May':
        return 5;
      case 'June':
        return 6;
      case 'July':
        return 7;
      case 'August':
        return 8;
      case 'September':
        return 9;
      case 'October':
        return 10;
      case 'November':
        return 11;
      case 'December':
        return 12;
      default:
        throw ArgumentError('Invalid month name: $monthName');
    }
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  String _formatEventTime(String startTime, String endTime) {
    final formattedStartTime =
        DateFormat('hh:mm a').format(DateTime.parse(startTime));
    final formattedEndTime =
        DateFormat('hh:mm a').format(DateTime.parse(endTime));
    return '$formattedStartTime to $formattedEndTime';
  }
}




//  Padding(
//     padding: const EdgeInsets.only(left: 10),
//     child: Card(
//       color: Colors.white,
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: SizedBox(
//         height: 150,
//         width: 250.w,
//         child: Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Image.network(
//                 imageUrl,
//                 fit: BoxFit.fill,
//                 height: 120,
//                 width: double.infinity,
//               ),
//             ),
//             Positioned(
//               top: 0,
//               left: 0,
//               child: Container(
//                 padding: EdgeInsets.all(8),
//                 color: Colors.black.withOpacity(0.5),
//                 child: Text(
//                   formattedDate,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 120), // Spacer for the image
//                   Text(
//                     event.eventname ?? "-",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.montserrat(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(255, 219, 4, 112),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     formatEventTime(
//                         event.eventtime ?? "", event.eventendtime ?? ""),
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.montserrat(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );