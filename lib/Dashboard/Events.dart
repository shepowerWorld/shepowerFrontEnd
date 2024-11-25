import 'dart:async';
import 'dart:convert';

import 'package:Shepower/Events/AllEvents.dart';
import 'package:Shepower/Events/createeven.services.dart';
import 'package:Shepower/Events/models/event.model.dart';
import 'package:Shepower/Events/widgets/my_event.widget.dart';
import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../Events/CreateEvent.dart';

class Eventscreen extends StatefulWidget {
  const Eventscreen({Key? key}) : super(key: key);

  @override
  State<Eventscreen> createState() => _EventscreenState();
}

class _EventscreenState extends State<Eventscreen> {
  // bool isLoading = false;
  List<EventModel> myEvents = [];
  List<EventModel> upcoming = [];
  List<EventModel> liveEvents = [];
  String profileID = '';
  String profileImg = '';
  String location = '';
  String myId = '';

  @override
  void initState() {
    super.initState();
    init();
    _loadProfileID();

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

      print('EventProfile ID: $profileID');
      print('Location: $location');
      print('My ID: $myId');

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

  init() async {
    print('init method called');
    // Utils().showLoader(context); // Show the loader
    try {
      await EventService().getMyEvents().then((value) {
        setState(() {
          myEvents = value ?? [];
        });
      }).catchError((e) {});

      await EventService().getUpComingEvents().then((value) {
        setState(() {
          upcoming = value ?? [];
        });
      }).catchError((e) {});

      await EventService().getLiveEvents().then((value) {
        setState(() {
          liveEvents = value ?? [];
        });
      }).catchError((e) {});
    } finally {
      // Utils().dismissLoader(context); // Dismiss the loader
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
           
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: profileID.startsWith('Leader'),
                    child: GestureDetector(
                      onTap: () async {
                        bool? result = await Navigator.of(context)
                            .push(MaterialPageRoute<bool>(
                          builder: (BuildContext context) {
                            return CreateEventScreen();
                          },
                          fullscreenDialog: true,
                        ));

                        init();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20, left: 16),
                            child: Image.asset(
                              'assets/Event/Plus.png',
                              width: 40.57.w,
                              height: 40.57.h,
                            ),
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 35, left: 0),
                            child: Text(
                              'create_Event'.tr(),
                              style: GoogleFonts.montserrat(
                                  fontSize: 16.sp,
                                  color: Color.fromRGBO(18, 13, 38, 1),
                                  fontWeight: FontWeight.w500,
                                  height: 0.5.h),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Conditionally display "My Events" text
                  if (myEvents.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'my_events'.tr(),
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              color: Color.fromRGBO(18, 13, 38, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: IconButton(
                            icon: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color.fromRGBO(216, 6, 131, 1),
                                    Color.fromRGBO(99, 7, 114, 1),
                                  ],
                                ).createShader(bounds);
                              },
                              child: Container(
                                height: 30.h,
                                width: 30.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    width: 1,
                                    color:
                                        const Color.fromRGBO(99, 1, 114, 0.8),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.navigate_next,
                                  color: Color(0xFFD80683),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AllEventsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  if (myEvents.isNotEmpty)
                    Container(
                      height: 231.18.w,
                      padding: EdgeInsets.only(left: 16.w),
                      child: ListView.builder(
                        itemCount: myEvents.length,
                        shrinkWrap: true,
                        primary: false,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          EventModel item = myEvents[i];
                          return EventItem(item: item);
                        },
                      ),
                    ),
                  // Live Events Section
                  if (liveEvents.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            'live_events'.tr(),
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              color: Color.fromRGBO(18, 13, 38, 1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: IconButton(
                            icon: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color.fromRGBO(216, 6, 131, 1),
                                    Color.fromRGBO(99, 7, 114, 1),
                                  ],
                                ).createShader(bounds);
                              },
                              child: Container(
                                height: 30.h,
                                width: 30.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    width: 1,
                                    color:
                                        const Color.fromRGBO(99, 1, 114, 0.8),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.navigate_next,
                                  color: Color(0xFFD80683),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AllEventsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  if (liveEvents.isNotEmpty)
                    Container(
                      height: 231.18.h,
                      padding: EdgeInsets.only(left: 16.w),
                      child: ListView.builder(
                        itemCount: liveEvents.length,
                        shrinkWrap: true,
                        primary: false,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          EventModel item = liveEvents[i];
                          return EventItem(item: item);
                        },
                      ),
                    ),
                  // Upcoming Events Section
                  if (upcoming.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'up_events'.tr(),
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              color: Color.fromRGBO(18, 13, 38, 1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: IconButton(
                            icon: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color.fromRGBO(216, 6, 131, 1),
                                    Color.fromRGBO(99, 7, 114, 1),
                                  ],
                                ).createShader(bounds);
                              },
                              child: Container(
                                height: 30.h,
                                width: 30.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    width: 1,
                                    color:
                                        const Color.fromRGBO(99, 1, 114, 0.8),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.navigate_next,
                                  color: Color(0xFFD80683),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AllEventsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  if (upcoming.isNotEmpty)
                    Container(
                      height: 231.1.h,
                      padding: EdgeInsets.only(left: 16.w),
                      child: ListView.builder(
                        itemCount: upcoming.length,
                        shrinkWrap: true,
                        primary: false,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          EventModel item = upcoming[i];
                          return EventItem(item: item);
                        },
                      ),
                    ),
                  SizedBox(height: 80),
                ],
              )
           
          ],
        ),
      ),
    );
  }
}
