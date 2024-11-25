// home_screen.dart

import 'dart:async';
import 'dart:convert';

import 'package:Shepower/Allusers/getallleaders.dart';
import 'package:Shepower/Allusers/getlallcitizen.dart';
import 'package:Shepower/Chatroom/Chat.dart';
import 'package:Shepower/Chatroom/Models/all_groups.model.dart';
import 'package:Shepower/Dashboard/home/homescreen.widget.dart';
import 'package:Shepower/Dashboard/locationdash.dart';
import 'package:Shepower/Events/AllEvents.dart';
import 'package:Shepower/Myprofile/myprofile.dart';
import 'package:Shepower/Notification.dart';
import 'package:Shepower/OnBoarding/Splash.dart';
import 'package:Shepower/common/api.service.dart';
import 'package:Shepower/common/cache.service.dart';
import 'package:Shepower/core/utils/image_constant.dart';
import 'package:Shepower/leneargradinent.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/services/chatservice.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../Events/EventDetails_screen.dart';
import '../Events/createeven.services.dart';
import '../Events/models/event.model.dart';
import '../Otherprofile/OtherProfile.dart';

class Homescreen extends StatefulWidget {
  final String? groupId;
  const Homescreen({Key? key, this.groupId}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<EventModel> allEvents = [];
  List<dynamic> Citizendata = [];
  TextEditingController textEditingController = TextEditingController();
  List<dynamic>? pachageData;
  List<dynamic> Leaderdata = [];
  String profileID = ''; // Define profileID heres
  String profileImg = '';
  String location = '';
  String myId = '';
  bool locations = false;
  double lat = 0.0; // Initialize with a default value
  double Long = 0.0;
  String locationss = '';
  String locationName = '';
  int count = 0;
  int selectedindex = 0;
  List<AllgroupsModel> allgroups = [];
  List<EventModel> filteredEvents = [];
  List<dynamic> filteredCitizens = [];
  List<dynamic> filteredLeaders = [];
  List<AllgroupsModel> filteredGroups = [];
  RefreshController _refreshController = RefreshController();
  bool isLoading = false;

  var storage = FlutterSecureStorage();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double fontSizeFactor = 0.10;
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

  Future<void> getId() async {
    final String? id = await _secureStorage.read(key: '_id');
    if (id != null) {
      setState(() {
        myId = id;
      });
    }
  }

  void connectToServer() async {
    print('Connecting to the server${socket}');

    socket.onError((error) {
      final IO.Socket socket = IO.io(
        '${ApiConfig.socket}',
        IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders(
            {'foo': 'bar'}).build(),
      );

      print("Socket error: $error");
      if (error.toString().contains('Timeout')) {}
    });

    final String? id = await _secureStorage.read(key: '_id');
    final Map<String, dynamic> data = {'userid': id, 'socketid': socket.id};
    socket.emit('userLogin', data);

    socket.onConnect((data) {
      print("Connected");
    });

    socket.onDisconnect((_) {
      print("Socket disconnected");
    });

    socket.connect();
  }

  @override
  void initState() {
    super.initState();
    socket.on('firstDeviceLogout1', (data) async {
      // Check if the widget is still mounted

      print('firstdevicelogoutrequest..$data');
      String? myDeviceId = await _secureStorage.read(key: 'DeviceId');
      print('otherdeviceid${data['data']['device']}');
      if (data['data']['device'] != myDeviceId) {
        String msg =
            'New Login detected from another device. Hence you will be logged out from this device';
        showdialogue(msg);
        await Future.delayed(const Duration(seconds: 3));
        handleFirstDeviceLogout(context);
      }
    });
    socket.on('userBlockStatus', (data) async {
      print('userBlockStatus${data['data']['adminBlock']}');
      if (data['data']['adminBlock'] == true) {
        String msg = 'You have been blocked by ShePower Team';
        showdialogue(msg);
        await Future.delayed(const Duration(seconds: 3));
        handleFirstDeviceLogout(context);
      }
    });

    getId();
    connectToServer();
    storage.write(key: "istrue", value: "false");

    Future(() {
      print('High Priority Task');
      init();
    });

    Future.microtask(() {
      init();
    });

    // Set up a timer to call the API every 5 minutes
    const fiveseconds = Duration(milliseconds: 1000);
    Timer.periodic(fiveseconds, (Timer timer) {
      requestCount();
    });
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadProfileID();
      ();
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(Homescreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadProfileID();
    ();
  }

  void showdialogue(String message) {
    showPlatformDialog(
      context: context,
      builder: (_) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: BasicDialogAlert(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    // Handle Accept button tap
                    Navigator.of(context).pop();
                    // You can pass any value you need
                  },
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD80683),
                          Color(0xFF630772),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ok',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkLogout(data) async {
    String? myDeviceId = await _secureStorage.read(key: 'DeviceId');
    if (data['data']['device'] != myDeviceId) {
      handleFirstDeviceLogout(context);
    }
  }

  Future<void> handleFirstDeviceLogout(BuildContext context) async {
    await _secureStorage.deleteAll();

    // Navigate to the Splash screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Splash()),
    );
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
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    print('application$id');
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

  Widget _buildRatings(double user) {
    double rating = user; // Example rating value

    int filledStars = rating.floor(); // Get the integer part of the rating
    double fractionalPart = rating - filledStars; // Get the fractional part

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Filled stars
        for (int i = 0; i < filledStars; i++)
          Icon(
            Icons.star,
            color: Colors.orange,
            size: 20,
          ),
        // Partially filled or empty star
        if (fractionalPart > 0)
          Icon(
            Icons.star_half,
            color: Colors.orange,
            size: 20,
          ),
        // Empty stars
        for (int i = 0; i < 5 - rating.ceil(); i++)
          Icon(
            Icons.star_border,
            color: Colors.orange,
            size: 20,
          ),
      ],
    );
  }

  init() async {
    try {
      setState(() {
        isLoading = true;
      });
      var istrue = await storage.read(key: "istrue");
      //print('objectistrue: $istrue');
      if (istrue == "false") {
        print("hellllllslsls");
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        double latitude = position.latitude;
        double longitude = position.longitude;
        await getLocationName(latitude, longitude);
        setState(() {
          lat = latitude;
          Long = longitude;
        });
        await _loadProfileID();
        await fetchNearbyCitizens();
        await fetchNearbyLeaders();
      }

      final events = await EventService().getAllEvents();
      final groups = await ChatService().getAllGroups();

      print('getallground not ge  why  i dontknow$groups');
      setState(() {
        allEvents = events ?? [];
        allgroups = groups ?? [];
        isLoading = false;
        _refreshController.refreshCompleted();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle errors here
    }
  }

  Future<void> fetchNearbyLeaders() async {
    String? _id = await CacheService.getUserId();
    String? accesstoken = await storage.read(key: 'accessToken');

    if (_id == null || _id == "") return null;

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };

      var request =
          http.Request('POST', Uri.parse('${ApiConfig.baseUrl}nearbyleaders'));
      request.body = json.encode({
        "latitude": lat,
        "longitude": Long,
        "updatedIds": [_id],
        "viewer_id": _id
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        // Filter out leader data where user_id._id == _id
        List<dynamic> filteredLeaders = jsonResponse['leaderlocation']
            .where((leader) => leader['user_id']['_id'] != myId)
            .toList();

        setState(() {
          Leaderdata = filteredLeaders;
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchNearbyCitizens() async {
    String? _id = await CacheService.getUserId();
    String? accesstoken = await storage.read(key: 'accessToken');

    if (_id == null || _id == "") return null;
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };

      var request =
          http.Request('POST', Uri.parse('${ApiConfig.baseUrl}nearbycitizens'));

      request.body = json.encode({
        "latitude": lat,
        "longitude": Long,
        "updatedIds": [_id],
        "viewer_id": _id
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        List<dynamic> filteredCitizens = jsonResponse['citizenlocation']
            .where((leader) => leader['user_id']['_id'] != myId)
            .toList();

        setState(() {
          Citizendata = filteredCitizens;
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchNearbyCitizens1(double lat2, double long2) async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request =
          http.Request('POST', Uri.parse('${ApiConfig.baseUrl}nearbycitizens'));
      request.body = json.encode({
        "latitude": lat2,
        "longitude": long2,
        "updatedIds": [id],
        "viewer_id": id
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        List<dynamic> filteredCitizens = jsonResponse['citizenlocation']
            .where((leader) => leader['user_id']['_id'] != myId)
            .toList();

        setState(() {
          Citizendata = filteredCitizens;
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchNearbyLeaders1(double lat1, double long1) async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request =
          http.Request('POST', Uri.parse('${ApiConfig.baseUrl}nearbyleaders'));

      request.body = json.encode({
        "latitude": lat1,
        "longitude": long1,
        "updatedIds": [id],
        "viewer_id": id
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        // Filter out leader data where user_id._id == _id
        List<dynamic> filteredLeaders = jsonResponse['leaderlocation']
            .where((leader) => leader['user_id']['_id'] != myId)
            .toList();

        setState(() {
          Leaderdata = filteredLeaders;
        });
      } else {
        print(response.reasonPhrase);
        // Handle the error
      }
    } catch (e) {
      print('Error: $e');
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
        print('objectobject$city, $state, $country');
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

  Future<void> sendGroupRequest(String? sId) async {
    final storage = FlutterSecureStorage();

    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}sendRequestGroup'));
    request.body = json.encode({"fromUser": myId, "group_id": sId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print('sendRequestGroup....${await response.stream.bytesToString()}');
    if (response.statusCode == 200) {
      final groups = await ChatService().getAllGroups();
      setState(() {
        allgroups = groups ?? [];
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  void filterData() {
    setState(() {
      filteredEvents = filterEvents(allEvents, _searchQuery);
      filteredCitizens = filterCitizens(Citizendata, _searchQuery);
      filteredLeaders = filterLeaders(Leaderdata, _searchQuery);
      filteredGroups = filterGroups(allgroups, _searchQuery);
    });
    print(
        'filtereddata....$filteredEvents,, $filteredCitizens,, $filteredLeaders,, $filteredGroups');
  }

  List<EventModel> filterEvents(
      List<EventModel> allEvents, String searchQuery) {
    if (searchQuery.isEmpty) {
      return allEvents;
    }

    final lowercaseQuery = searchQuery.toLowerCase();

    return allEvents
        .where((event) => (event.eventname != null &&
            event.eventname!.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  List<dynamic> filterCitizens(List<dynamic> Citizendata, String searchQuery) {
    if (searchQuery.isEmpty) {
      return Citizendata;
    }

    final lowercaseQuery = searchQuery.toLowerCase();

    return Citizendata.where((citizenData) {
      final user = citizenData['user_id'];
      return (user != null &&
          user['firstname'] != null &&
          user['firstname'].toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  List<dynamic> filterLeaders(List<dynamic> Leaderdata, String searchQuery) {
    if (searchQuery.isEmpty) {
      return Leaderdata;
    }

    final lowercaseQuery = searchQuery.toLowerCase();

    return Leaderdata.where((leaderData) {
      final user = leaderData['user_id'];
      return (user != null &&
          user['firstname'] != null &&
          user['firstname'].toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  List<AllgroupsModel> filterGroups(
      List<AllgroupsModel> allgroups, String searchQuery) {
    if (searchQuery.isEmpty) {
      return allgroups;
    }

    final lowercaseQuery = searchQuery.toLowerCase();

    return allgroups
        .where((group) => (group.groupName != null &&
                group.groupName!.toLowerCase().contains(lowercaseQuery))
            // Add more conditions if needed for other fields in AllgroupsModel
            )
        .toList();
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: selectedindex == 2
            ? Text(
                'She Power',
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: screenWidth * fontSizeFactor,
                  fontFamily: 'LavishlyYours',
                  fontWeight: FontWeight.w400,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Image.asset(
                        'assets/homedashboardicon/Location1.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (locationss.isNotEmpty && locationss.length > 10)
                              ? locationss.substring(0, 10) + '...'
                              : (locationName.length > 10)
                                  ? locationName.substring(0, 10) + '...'
                                  : locationName,
                          style: const TextStyle(
                            color: Color(0xFFD80683),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          (locationName.length > 10)
                              ? locationName.substring(0, 10) + '...'
                              : locationName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Montserrat',
                            fontSize: 12,
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
                              builder: (context) => locationPick(),
                            ),
                          );
                          if (result != null) {
                            String selectedCity = result['selectedCity'];
                            double latitude = result['latitude'];
                            double longitude = result['longitude'];
                            await storage.write(key: "istrue", value: "true");
                            await storage.write(key: "istrue1", value: "true1");
                            await fetchNearbyCitizens1(latitude, longitude);
                            await fetchNearbyLeaders1(latitude, longitude);
                            setState(() {
                              locationss = selectedCity;
                            });
                            await init();
                          }
                        },
                        child: Image.asset(
                          'assets/homedashboardicon/ADown.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return NotificationScreen();
                },
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
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return Allchats(myId: myId);
                },
              ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                'assets/homedashboardicon/message.png',
                width: 27,
                height: 27,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(builder: (context) => MyProfile(myId: myId)),
              )
                  .then((value) {
                _loadProfileID();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  '${imagespath.baseUrl}$profileImg',
                ),
                radius: 17,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEDEE),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Color.fromARGB(255, 209, 53, 173),
                  width: 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Icon(
                      Icons.search,
                      size: 30.0,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                          filterData();
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Search events, leaders, groups here....'.tr(),
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SmartRefresher(
              onRefresh: () => init(),
              controller: _refreshController,
              enablePullDown: true,
              header: const WaterDropHeader(),
              child: ListView(
                children: [
                  // Explore Events section
                  if (!allEvents.isEmpty) exploreheading(),
                  if (!allEvents.isEmpty)
                    exploreevents()
                  else
                    emptydata("No Explore events available"),
                  const SizedBox(height: 35),

                  // Leaders section

                  if (Leaderdata.isNotEmpty) nearByLedersHeading(),
                  if (Leaderdata.isNotEmpty)
                    nearbyleaders()
                  else
                    emptydata("No leaders available"),

                  const SizedBox(height: 4),
                  // Citizens section
                  if (Citizendata.length > 0) nearbyCitizenHeading(),
                  if (Citizendata.length > 0)
                    nearbycitizens()
                  else
                    emptydata("No Citizens available"),

                  const SizedBox(height: 10),
                  if (allgroups.isNotEmpty) groupsHeading(),
                  groupsdata(),
                ],
              ),
            ),
    );
  }

// explore events Widgets........
  Widget exploreheading() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Explore Events".tr(),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Color(0xFFD80683),
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            child: IconButton(
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
    );
  }

  Widget exploreevents() {
    return Container(
      height: 400,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount:
            _searchQuery.isEmpty ? allEvents.length : filteredEvents.length,
        itemBuilder: (BuildContext context, int index) {
          final event =
              _searchQuery.isEmpty ? allEvents[index] : filteredEvents[index];
          final formattedDate = formatEventDate(event.eventtime ?? "");
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(item: event),
                ),
              );
            },
            child: ExploreEventScreen(
              event: event,
              formattedDate: formattedDate,
            ),
          );
        },
      ),
    );
  }

//Nearby Leaders Widgets.......

  Widget nearByLedersHeading() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Nearby Leaders".tr(),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Color(0xFFD80683),
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            child: IconButton(
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
                    Icons.navigate_next,
                    color: Color(0xFFD80683),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => getallusers(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget nearbyleaders() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        height: 500, // Set your desired height
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:
              _searchQuery.isEmpty ? Leaderdata.length : filteredLeaders.length,
          itemBuilder: (context, index) {
            final data = _searchQuery.isEmpty
                ? Leaderdata[index]
                : filteredLeaders[index];
            final user = data['user_id'];
            final userId = user['_id'];
            final Review =
                data['rating'] != null ? data['rating'].toDouble() : 0.0;
            final isconnected = data['isConnected'] ?? false;
            final requestExists = data['_isRequestedid'] ?? false;

            final profileImageUrl =
                '${imagespath.baseUrl}${user['profile_img']}';

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Otherprofile(
                      userId: userId,
                      myId: myId,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 250,
                  height: 500,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          profileImageUrl,
                          width: 250,
                          height: 350,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user['firstname']}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildRatings(Review ?? 0.0),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                String result =
                                    await ApiService.sendRequest(userId);
                                if (result == 'success') {
                                  fetchNearbyLeaders();
                                }
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 209, 53, 173),
                                        width: 1),
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0,
                                        bottom: 5.0,
                                        left: 20,
                                        right: 20),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [Colors.blue, Colors.purple],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds),
                                      child: Text(
                                        (isconnected == true &&
                                                requestExists == false)
                                            ? "Following"
                                            : (isconnected == true &&
                                                    requestExists == true)
                                                ? "Connected"
                                                : "Connect",
                                        style: const TextStyle(
                                          color: Colors
                                              .white, // This color will be overridden by the gradient
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

//Nearby Citizens Widgets......

  Widget nearbyCitizenHeading() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Nearby Citizens".tr(),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Color(0xFFD80683),
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            child: IconButton(
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
                    Icons.navigate_next,
                    color: Color(0xFFD80683),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => getallCitizenusers(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget nearbycitizens() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        height: 500, // Set your desired height
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _searchQuery.isEmpty
              ? Citizendata.length
              : filteredCitizens.length,
          itemBuilder: (context, index) {
            final data = _searchQuery.isEmpty
                ? Citizendata[index]
                : filteredCitizens[index];
            final user = data['user_id'];
            final userId = user['_id'];
            final isconnected = data['isConnected'] ?? false;
            final requestExists = data['_isRequestedid'] ?? false;

            final profileImageUrl =
                '${imagespath.baseUrl}${user['profile_img']}';

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Otherprofile(
                      userId: userId,
                      myId: myId,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 250,
                  height: 500,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          profileImageUrl,
                          width: 250,
                          height: 350,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user['firstname']}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                String result =
                                    await ApiService.sendRequest(userId);
                                if (result == 'success') {
                                  fetchNearbyCitizens();
                                }
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 209, 53, 173),
                                        width: 1),
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0,
                                        bottom: 5.0,
                                        left: 20,
                                        right: 20),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [Colors.blue, Colors.purple],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds),
                                      child: Text(
                                        (isconnected == true &&
                                                requestExists == false)
                                            ? "Following"
                                            : (isconnected == true &&
                                                    requestExists == true)
                                                ? "Connected"
                                                : "Connect",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ))),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget emptydata(String emptytext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emptytext,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Color(0xFFD80683),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

//Groups Widgets ......
  Widget groupsHeading() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10, right: 10),
      child: Text(
        'Send Request',
        style: GoogleFonts.montserrat(
          fontSize: 14,
          color: Color(0xFFD80683),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget groupsdata() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(
            width: 2,
          );
        },
        itemCount:
            _searchQuery.isEmpty ? allgroups.length : filteredGroups.length,
        itemBuilder: (context, index) {
          final group =
              _searchQuery.isEmpty ? allgroups[index] : filteredGroups[index];
          bool isMyIdInJoiningGroup = false;
          bool isMyIdInTotalRequest = false;
          if (group.joiningGroup != null && group.joiningGroup is List) {
            for (var member in group.joiningGroup!) {
              if (member.sId == myId) {
                isMyIdInJoiningGroup = true;
                break;
              }
            }
          }

          if (group.adminId != null) {
            if (group.adminId?.sId == myId) {
              isMyIdInJoiningGroup = true;
            }
          }

          if (group.totalrequests != null && group.totalrequests is List) {
            for (var request in group.totalrequests!) {
              if (request.sId == myId) {
                isMyIdInTotalRequest = true;
                break;
              }
            }
          }
          if (!isMyIdInJoiningGroup) {
            return SizedBox(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xFFFDEAF5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Image.network(
                            "${imagespath.baseUrl}${group.groupProfileImg}" ??
                                "",
                            height: 78,
                            width: 78,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Container(
                                color: const Color(0xFFFDEAF5),
                                height: 78,
                                width: 70,
                                child: Center(
                                  child: Image.asset(
                                    ImageConstant.imgImage20331x235,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8, 16, 4, 6),
                          child: Column(
                            children: [
                              Text(
                                group.groupName ?? "",
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 17),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 10.h),
                                child: SizedBox(
                                  height: 35.13.h,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20.56.r),
                                      gradient: isLoading ? null : gradient,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: isMyIdInTotalRequest
                                          ? null
                                          : () => sendGroupRequest(group.sId),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.56.r),
                                        ),
                                      ),
                                      child: isMyIdInTotalRequest
                                          ? Text(
                                              "Requested",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10.sp,
                                                color: const Color.fromRGBO(
                                                    255, 255, 255, 1),
                                              ),
                                            )
                                          : Text(
                                              "Send request",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10.sp,
                                                color: const Color.fromRGBO(
                                                    255, 255, 255, 1),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
