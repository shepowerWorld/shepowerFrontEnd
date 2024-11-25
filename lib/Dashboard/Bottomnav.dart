import 'dart:async';
import 'dart:convert';

import 'package:Shepower/Chatroom/Chat.dart';
import 'package:Shepower/Dashboard/Events.dart';
import 'package:Shepower/Dashboard/Explorescreen.dart';
import 'package:Shepower/Dashboard/Home.dart';
import 'package:Shepower/Dashboard/WeSharescreen.dart';
import 'package:Shepower/Dashboard/locationdash.dart';
import 'package:Shepower/Myprofile/myprofile.dart';
import 'package:Shepower/Notification.dart';
import 'package:Shepower/core/utils/image_constant.dart';
import 'package:Shepower/notification_services.dart.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/sos/Citizen/sos.dart';
import 'package:Shepower/sos/Leaderside/help.dart';
import 'package:Shepower/widgets/custom_image_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Bottomnavscreen extends StatefulWidget {
  // ignore: use_super_parameters
  const Bottomnavscreen({Key? key}) : super(key: key);

  @override
  State<Bottomnavscreen> createState() => _BottomnavscreenState();
}

class _BottomnavscreenState extends State<Bottomnavscreen> {
  StreamSubscription<Position>? locationSubscription;
  DateTime? currentBackPressTime;
  String? currentLocation;
  int selectedindex = 0;
  int count = 0;
  final storage = const FlutterSecureStorage();
  bool? profile;
  String profileID = '';
  String profileImg = '';
  String location = '';
  String myId = '';
  String locationName = '';
  String userlocation = '';
  // String newLocationName = '';
  late PageController _pageController;

  String locationss = '';
  double lat = 0.0;
  double lang = 0.0;
  String placemarks = '';
  late PageController pageController;

  List<Widget> pages = [
    const Explorescreen(),
    const Homescreen(),
    const Eventscreen(),
    const WeSharescreen(),
  ];

  bool? trueed;

  NotificationServices1 notificationServices = NotificationServices1();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {});
    init();
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    requestCount();
    fetchLocation();
    updateLocation().then((newLocationName) {
      setState(() {
        locationName = newLocationName;
      });
    });
    _loadProfileID();
    _pageController = PageController(initialPage: selectedindex);

    // Set up a timer to call the API every 5 minutes
    const fiveMinutes = Duration(milliseconds: 100000);
    Timer.periodic(fiveMinutes, (Timer timer) {
      _loadProfileID();
      requestCount();
      fetchLocation();
    });

    getStoredParameters();

    startLocationUpdates();
  }

  init() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      await getLocationName(latitude, longitude);
    } catch (e) {
      // Handle errors here
    }
  }

  Future<String> updateLocation() async {
    await Future.delayed(const Duration(milliseconds: 10000));
    return '$locationName';
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  void startLocationUpdates() {
    // Subscribe to the location stream
    locationSubscription =
        Geolocator.getPositionStream().listen((Position position) async {
      // Perform reverse geocoding to get the address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        setState(() {
          currentLocation =
              '${placemark.thoroughfare}, ${placemark.locality}, ${placemark.country}';
        });
      } else {
        setState(() {
          currentLocation = 'Address not found';
        });
      }
    });
  }

  Future<Map<String, String?>> getStoredParameters() async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    return {
      'id': id,
      'Authorization': accesstoken,
    };
  }

  Future<void> _loadProfileID() async {
    final profileData = await GetProfileProfile();
    setState(() {
      profileImg = profileData['profileImg'];
      profileID = profileData['profileID'];
      location = profileData['location'];
      myId = profileData['myId'];
    });
  }

  Future<Map<String, dynamic>> GetProfileProfile() async {
    final storage = const FlutterSecureStorage();
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

  Future<void> fetchLocation() async {
    if (profile == true || profileID.startsWith('Leader')) {
      final storage = const FlutterSecureStorage();
      String? id = await storage.read(key: '_id');

      String? accesstoken = await storage.read(key: 'accessToken');

      try {
        print('Fetching location...');
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print('Location fetched: ${position.latitude}, ${position.longitude}');

        double lat1 = position.latitude;
        double lang = position.longitude;
        setState(() {
          lat = lat1;
          lang = lang;
        });
        await getLocationName(lat, lang);
        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accesstoken'
        };
        var request = http.Request(
            'POST', Uri.parse('${ApiConfig.baseUrl}locationUpdate'));
        request.body = json.encode({
          "_ids": [id],
          "latitude": lat,
          "longitude": lang
        });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print('Location update successful');
          print(
              'Location fetched: ${position.latitude}, ${position.longitude}');
          print(await response.stream.bytesToString());

          print('Location Name..: $locationName');
        } else {
          print('Location update failed: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error fetching or updating location: $e');
      }
    } else if (profile == true || profileID.startsWith('citizen')) {
      final storage = const FlutterSecureStorage();
      String? id = await storage.read(key: '_id');
      String? accesstoken = await storage.read(key: 'accessToken');

      try {
        print('Fetching location...');
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print('Location fetched: ${position.latitude}, ${position.longitude}');

        double lat = position.latitude;
        double lang = position.longitude;

        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accesstoken'
        };
        var request = http.Request(
            'POST', Uri.parse('${ApiConfig.baseUrl}locationUpdatecitizen'));
        request.body = json.encode({
          "_ids": [id],
          "latitude": lat,
          "longitude": lang
        });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print('Location update successful');
          print(
              'Location fetched: ${position.latitude}, ${position.longitude}');
          print(await response.stream.bytesToString());
          await getLocationName(lat, lang);
          print('Location Name..: $locationName');
        } else {
          print('Location update failed: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error fetching or updating location: $e');
      }
    } else {
      print('USER NOT AVAILABLE....');
    }
  }

  Future<void> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        final city = placemark.locality ?? '';
        final state = placemark.administrativeArea ?? '';
        final country = placemark.country ?? '';
        setState(() {
          locationName = '$city, $state, $country';
        });
      } else {
        setState(() {
          locationName = 'Location not found';
        });
      }
    } catch (e) {
      setState(() {
        locationName = 'Error fetching location';
      });
    }
  }

  Future<void> requestCount() async {
    const storage = FlutterSecureStorage();

    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'GET', Uri.parse('${ApiConfig.baseUrl}getNotificationCount/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final newCount = jsonResponse['count'];
      if (jsonResponse['status'] == true) {
        setState(() {
          count = newCount;
        });
      } else {
        print('api response count dint get ');
      }

      print('totalRequestCount:$count');
    } else {
      print(response.reasonPhrase);
    }
  }

  void restartApp() async {
    await storage.write(key: "istrue1", value: "true122");
    trueed = false;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Bottomnavscreen()),
      (route) => false,
    );
  }

  void convertotrue() async {
    setState(() {
      trueed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context);
      },
      child: Scaffold(
        appBar: (selectedindex != 1)
            ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                elevation: 10,
                toolbarHeight: SizeExtension(60).h,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        (selectedindex == 0 ||
                                selectedindex == 2 ||
                                selectedindex == 3)
                            ? Container(
                                width: 100,
                                height: 60,
                                child:
                                    Image.asset("assets/Splash/shepower.png"))
                            : Container(
                                height: 500,
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 0.0),
                                      child: Image.asset(
                                        'assets/homedashboardicon/Location1.png',
                                        width: 25.w,
                                        height: SizeExtension(25).h,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (locationss.isNotEmpty &&
                                                  locationss.length > 10)
                                              ? '${locationss.substring(0, 10)}...'
                                              : (locationName.length > 10)
                                                  ? '${locationName.substring(0, 10)}...'
                                                  : locationName,
                                          style: GoogleFonts.montserrat(
                                            color: const Color(0xFFD80683),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        Text(
                                          (locationName.length > 10)
                                              ? locationName.substring(0, 10) +
                                                  '...'
                                              : locationName,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const locationPick(),
                                            ),
                                          );
                                          if (result != null) {
                                            String selectedCity =
                                                result['selectedCity'];
                                            double latitude =
                                                result['latitude'];
                                            double longitude =
                                                result['longitude'];
                                            print(
                                                'Selected City: $selectedCity');
                                            print('Latitude: $latitude');
                                            print('Longitude: $longitude');
                                          }
                                        },
                                        child: Image.asset(
                                          'assets/homedashboardicon/ADown.png',
                                          width: 24.w,
                                          height: SizeExtension(24).h,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ));
                    },
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/homedashboardicon/not.png',
                          width: 30.w,
                          height: SizeExtension(30).h,
                        ),
                        if (count > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromRGBO(216, 6, 131, 1),
                                    Color.fromRGBO(99, 7, 114, 1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Allchats(myId: myId),
                      ));
                    },
                    child: Image.asset(
                      'assets/homedashboardicon/message.png',
                      width: 27.w,
                      height: SizeExtension(27).h,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                            builder: (context) => MyProfile(myId: myId)),
                      )
                          .then((value) {
                        _loadProfileID();
                      });
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        '${imagespath.baseUrl}$profileImg',
                      ),
                      radius: 17.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
              )
            : null,
        body: IndexedStack(
          index: selectedindex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromARGB(255, 219, 5, 94),
          unselectedItemColor: Colors.black,
          currentIndex: selectedindex,
          selectedLabelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFD80683),
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111111),
            fontWeight: FontWeight.w400,
          ),
          onTap: (value) {
            setState(() {
              selectedindex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              activeIcon: CustomImageView(
                imagePath: ImageConstant.imgNavHome24x24,
                height: 24,
                width: 24,
              ),
              icon: CustomImageView(
                imagePath: ImageConstant.imgNavHome,
                height: 24,
                width: 24,
              ),
              label: 'Home'.tr(),
            ),
            BottomNavigationBarItem(
              activeIcon: CustomImageView(
                imagePath: ImageConstant.imgNavExplore24x24,
                height: 24,
                width: 24,
              ),
              icon: CustomImageView(
                imagePath: ImageConstant.imgNavExplore,
                height: 24,
                width: 24,
              ),
              label: 'Explore'.tr(),
            ),
            BottomNavigationBarItem(
              activeIcon: CustomImageView(
                imagePath: ImageConstant.imgNavEvents24x24,
                height: 24,
                width: 24,
              ),
              icon: CustomImageView(
                imagePath: ImageConstant.imgNavEvents,
                height: 24,
                width: 24,
              ),
              label: 'Events'.tr(),
            ),
            BottomNavigationBarItem(
              activeIcon: CustomImageView(
                imagePath: ImageConstant.imgNavWeShare24x24,
                height: 24,
                width: 24,
              ),
              icon: CustomImageView(
                imagePath: ImageConstant.imgNavWeShare,
                height: 24,
                width: 24,
              ),
              label: 'Weshare'.tr(),
            ),
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            if (profileID.startsWith('citizen')) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Emergencysos(),
              ));
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const HelpTabViewscreen(),
              ));
            }
          },
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color:
                  profileID.startsWith('citizen') ? Colors.red : Colors.yellow,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 2.5,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.light_mode,
                    color: profileID.startsWith('citizen')
                        ? Colors.white
                        : Colors.red,
                    size: 18.0,
                  ),
                  profileID.startsWith('citizen')
                      ? const Icon(
                          Icons.sos_outlined,
                          color: Colors.white,
                          size: 24.0,
                        )
                      : const Text(
                          'HELP',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    Completer<bool> exitApp = Completer<bool>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App?'),
          content: const Text('Do you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                exitApp.complete(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                exitApp.complete(true);
                SystemNavigator.pop(); //
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    return exitApp.future;
  }
}
