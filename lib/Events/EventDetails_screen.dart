import 'dart:async';
import 'dart:convert';

import 'package:Shepower/Dashboard/Bottomnav.dart';
import 'package:Shepower/Events/AllEvents.dart';
import 'package:Shepower/Events/CreateEvent.dart';
import 'package:Shepower/Events/createeven.services.dart';
import 'package:Shepower/Events/models/event.model.dart';
import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel item;

  EventDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  String googleMeetLink = '';
  bool isLoading = false; // Add a loading indicator flag
  bool isLeader = true; // Set this to true for leaders, false for citizens
  String profileID = '';
  String profileImg = '';
  String location = '';
  String myId = '';
  String? loggedInUserId;

  bool _canJoinEvent(EventModel event) {
    final endTime = DateTime.parse(event.eventendtime ?? "");
    final currentTime = DateTime.now();
    bool isExpired = currentTime.isAfter(endTime);
    return !isExpired;
  }

  String formatEventTime(String startTime, String endTime) {
    final formattedStartTime =
        DateFormat('hh:mm a').format(DateTime.parse(startTime));
    final formattedEndTime =
        DateFormat('hh:mm a').format(DateTime.parse(endTime));
    return '$formattedStartTime to $formattedEndTime';
  }

  String formatEventDate(String date) {
    final formattedDate = DateFormat('E, d-MMMM').format(DateTime.parse(date));
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();

    googleMeetLink = widget.item.eventlink ?? "";
    // Call the API immediately when the widget is initialized
    _loadProfileID();
    // Set up a timer to call the API every 5 minutes
    const fiveMinutes = const Duration(minutes: 5);
    Timer.periodic(fiveMinutes, (Timer timer) {
      _loadProfileID();
    });
  }

  Future<void> _loadProfileID() async {
    final profileData = await GetProfileProfile();
    print('profileData: $profileData');
    setState(() {
      profileImg = profileData['profileImg'];
      profileID = profileData['profileID'];
      location = profileData['location'];
      myId = profileData['myId'];
      loggedInUserId = myId; // Set the logged-in user's ID here

      print('Locationwswsw: $location');
    });
  }

  Future<Map<String, dynamic>> GetProfileProfile() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request =
        http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getMyprofile/$id'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      print('responseBody data: $data');

      String profileID = data['result']['profileID'];
      String profileImg = data['result']['profile_img'];
      String location = data['result']['location'];
      String myId = data['result']['_id'];

      print('Profile ID: $profileID');

      print('Location: $location');
      print('My ID: $myId');

      // Return the data as a Map
      return {
        'profileID': profileID,
        'profileImg': profileImg,
        'location': location,
        'myId': myId,
      };
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<bool?> _showDeleteDialog() async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD80683),
                      Color(0xFF630772),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.done,
                  size: 48.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Event deleted successfully!',
                style: TextStyle(
                  color: Color(0xFFD80683),
                  fontFamily: 'Monstrate',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD80683),
                    Color(0xFF630772),
                  ],
                ),
              ),
              child: TextButton(
                onPressed: () {
                  // Navigator.pop(context, true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Bottomnavscreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Responsive layout adjustments
    final double imageSize = isPortrait ? 350.0 : screenWidth * 0.5;
    final double buttonWidth = isPortrait ? 200.0 : screenWidth * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(
            color: Color(0xFFD80683),
            fontWeight: FontWeight.bold, // Set the text color to black
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Color(0xFFD80683), 
        ),
        actions: <Widget>[
          Visibility(
            visible: loggedInUserId ==
                widget.item
                    .userId,
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFFD80683),
              ),
              onSelected: (value) async {
                if (value == 'update') {
                  setState(() {
                    isLoading = true;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateEventScreen(item: widget.item),
                    ),
                  );
                } else if (value == 'delete') {
                  setState(() {
                    isLoading = true;
                  });
                  bool? result = await EventService()
                      .deleteEvent(widget.item.userId!, widget.item.Id!);
                  if (result == true) {
                    setState(() {
                      isLoading = false;
                    });
                    bool? isDelete = await _showDeleteDialog();
                    if (isDelete == null || !isDelete) return;
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllEventsScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete event.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return ['update', 'delete'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "${imagespath.baseUrl}${widget.item.eventimage}",
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text(
                  '${widget.item.eventname}',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFFD80683),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Card(
                  elevation: 4, // Adjust the elevation to control the shadow
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(50.0), // Make it circular
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(
                        8.0), // Optional: Adjust padding as needed
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Specify the color you want here
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFD80683), // Set the text color to black
                    ),
                  ),
                ),
                title: Text(
                  ' ${widget.item.eventlocation}',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Card(
                  elevation: 4, // Adjust the elevation to control the shadow
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(50.0), // Make it circular
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(
                        8.0), // Optional: Adjust padding as needed
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Specify the color you want here
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFD80683), // Set the text color to black
                    ),
                  ),
                ),
                title: Text(
                  formatEventDate(widget.item.eventtime ?? ""),
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Card(
                  elevation: 4, // Adjust the elevation to control the shadow
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(50.0), // Make it circular
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(
                        8.0), // Optional: Adjust padding as needed
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Specify the color you want here
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xFFD80683), // Set the text color to black
                    ),
                  ),
                ), // Icon color), // Use the "access_time" icon for a clock
                title: Text(
                  formatEventTime(
                    widget.item.eventtime ?? "",
                    widget.item.eventendtime ?? "",
                  ),
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    textStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      if (googleMeetLink.isNotEmpty) {
                        if (_canJoinEvent(widget.item)) {
                          launch(googleMeetLink);
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  'Event Completed',
                                  style: TextStyle(color: Color(0xFFD80683)),
                                ),
                                content: const Text(
                                  'This event has already been completed and can no longer be joined.',
                                  style: TextStyle(color: Color(0xFFD80683)),
                                ),
                                actions: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFD80683),
                                          Color(0xFF630772),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          12.0), // Rounded corners
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    child: Container(
                      margin:const EdgeInsets.symmetric(horizontal:75),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD80683), Color(0xFFA30056)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'JOIN EVENT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
             const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


