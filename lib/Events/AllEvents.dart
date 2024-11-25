import 'package:Shepower/Events/createeven.services.dart';
import 'package:Shepower/Events/models/event.model.dart';
import 'package:Shepower/Events/widgets/all_event.wiget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({Key? key}) : super(key: key);

  @override
  _AllEventsScreenState createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  List<EventModel> allEvents = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      init();
    });
  }

  init() async {
    // Utils().showLoader(context); // Show the loader
    try {
      setState(() {
        isLoading = true;
      });
      final events = await EventService().getAllEvents();
      print("qqqqqq ${events?.first.Id}");
      setState(() {
        allEvents = events ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // } finally {
      //   // Utils().dismissLoader(context); // Dismiss the loader
      //   setState(() {
      //     isLoading = false;
      //   });
    }
  }

  String formatEventDate(String date) {
    final formattedDate =
        DateFormat('EEEE, MMMM d, y').format(DateTime.parse(date));
    return formattedDate;
  }

  String formatEventTime(String startTime, String endTime) {
    final formattedStartTime =
        DateFormat('h:mm a').format(DateTime.parse(startTime));
    final formattedEndTime =
        DateFormat('h:mm a').format(DateTime.parse(endTime));
    return 'Time: $formattedStartTime - $formattedEndTime';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color.fromRGBO(99, 7, 114, 0.8),
                  Color.fromRGBO(228, 65, 163, 0.849),
                ],
              ).createShader(bounds);
            },
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1,
                  color: const Color.fromRGBO(99, 1, 114, 0.8),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(
                Icons.navigate_before,
                color: Color(0xFFD80683),
              ),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'all_events'.tr(),
          style: GoogleFonts.montserrat(
            textStyle:const TextStyle(
              color: Color(0xFFD80683),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height:
                        10,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: allEvents.length,
                      // shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final event = allEvents[index];
                        return AllEventItem(
                          item: event,
                        );
                      },
                    ),
                  ),
                  // List of events
                  ListView.builder(
                    itemCount: allEvents.length,
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (context, index) {
                      final event = allEvents[index];
                      return AllEventItem(
                        item: event,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
