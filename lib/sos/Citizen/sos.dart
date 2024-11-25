import 'dart:convert';

import 'package:Shepower/Dashboard/Bottomnav.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/sos/Citizen/CitiGetsos.dart';
import 'package:Shepower/sos/Citizen/audio1.dart';
import 'package:Shepower/sos/Citizen/video.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';

class Emergencysos extends StatefulWidget {
  const Emergencysos({
    super.key,
  });

  @override
  State<Emergencysos> createState() => _sosScreenState();
}

class _sosScreenState extends State<Emergencysos> {
  int currentIndex = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  final List<Tab> _tabs = [
    Tab(text: 'Create'.tr()),
    Tab(text: 'OnGoing'.tr()),
    Tab(text: 'Completed'.tr()),
  ];

  @override
  Widget build(BuildContext context) {
    const double defaultFontSize = 12.0;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            indicatorColor: Colors.pink,
            tabs: _tabs.map((tab) {
              return Tab(
                child: Text(
                  tab.text.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width *
                        defaultFontSize /
                        375,
                  ),
                ),
              );
            }).toList(),
          ),
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
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(99, 7, 114, 1),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [
                        Color.fromRGBO(216, 6, 131, 1),
                        Color.fromRGBO(99, 7, 114, 1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_sharp,
                    color: Colors.white,
                    size: 22, // Set the icon size
                  ),
                ),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const Bottomnavscreen(),
                ),
              );
            },
          ),
          title: Text(
            'Emergency Rescue'.tr(),
            style: const TextStyle(
              color: Color.fromRGBO(25, 41, 91, 1),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Option1Content(
              onAudioReceived: (String audioPath) {},
              myaudioPath: 'myaudioPath',
            ),
            const Option2Content(),
            const Option3Content(),
          ],
        ),
      ),
    );
  }
}

//====================11111111111Create SOS

// ignore: must_be_immutable
class Option1Content extends StatefulWidget {
  final Function(String) onAudioReceived;

  String myaudioPath;

  // ignore: use_super_parameters
  Option1Content({
    Key? key,
    required this.onAudioReceived,
    required this.myaudioPath,
  }) : super(key: key);

  @override
  State<Option1Content> createState() => _Option1ContentState();
}

class _Option1ContentState extends State<Option1Content> {
  final TextEditingController textEditingController = TextEditingController();
  bool sendButtonVisible = false;
  String locationName = '';
  String userName = '';
  String userMobileNumber = '';
  String userprofile = '';
  int currentIndex = 0;
  bool isPressed = false;
  String mysos = '';
  String ssosId = ""; // Initialize ssosId
  bool cclosed = false; // Initialize cclosed
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSosData();
  }

  Future<void> fetchSosData() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}ongoingSos'));
    request.body = json.encode({"_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      String sosId = jsonResponse['result'][0]['sosId'];
      GetSosData(sosId);
    } else {
      print(response.reasonPhrase);
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> GetSosData(String sosId) async {
    const storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getSosData'));
    request.body = json.encode({"sosId": sosId});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        // Extract the "sosId" and "closed" values from the response
        String userSosId = data['result']['sosId'];
        bool userClosed = data['result']['closed'];

        setState(() {
          ssosId = userSosId;
          cclosed = userClosed;
        });
      } else {
        print(response.reasonPhrase);
        setState(() {});
      }
    } catch (e) {
      print('Error: $e');
      setState(() {});
    }
  }

  Future<void> navigateToAudioScreen() async {
    final audioPath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioScreen(onAudioRecorded: (path) {
          setState(() {
            widget.myaudioPath = path;
          });
        }),
      ),
    );

    if (audioPath != null) {
      setState(() {
        widget.myaudioPath = audioPath;
      });
      print('Audio Path: $audioPath');
    }
  }

  //audiopath

  Future<void> sendRequest() async {
    setState(() {
      isLoading = true;
    });
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String text = textEditingController.text;

    var status = await Permission.location.request();
    if (status.isDenied) {
      print('Location permission is denied');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      String? accesstoken = await storage.read(key: 'accessToken');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiConfig.baseUrl}CreateSos'));
      request.fields.addAll({
        'citizen_id': id ?? '',
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'text': text, // Text field
      });
      request.headers.addAll(headers);
      if (widget.myaudioPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'attachment',
          widget.myaudioPath,
          contentType: MediaType('audio', 'mp4'),
        ));
      }

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        fetchSosData();
        setState(() {
          isLoading = false;
        });
        print('Partner Location Data Fetched Successfully with attachment');
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        print('sos created...$data');

        if (data['status'] == false) {
          showSErrorDialog();
        } else {
          print(data);
          final userSosId = data['result']['sosId'];
          setState(() {
            ssosId = userSosId;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return IconOverlay();
            },
          );
        }
      } else {
        showSErrorDialog();
        print(response.reasonPhrase);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      direct();
      print('Partner Location Data Fetched Successfully with direct');
      print('Error sending request: $e');
    }
  }

  void showSErrorDialog() {
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
              Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD80683),
                      Color(0xFF630772),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      size: 48.0,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Center(
                child: Text(
                  "There are no leaders found nearby. Please contact the leaders directly on the app.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
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
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
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

  Future<void> direct() async {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String text = textEditingController.text;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      String? accesstoken = await storage.read(key: 'accessToken');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiConfig.baseUrl}CreateSos'));
      request.fields.addAll({
        'citizen_id': id ?? '',
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'text': text // Text field
      });
      request.headers.addAll(headers);

      print(request.fields);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        print(data);
        final usersosId = data['result']['sosId'];
        print('USER SOSID$usersosId');
        setState(() {
          ssosId = usersosId;
          textEditingController.clear();
        });
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return IconOverlay();
          },
        );
      } else {
        showSErrorDialog();
        print(response.reasonPhrase);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error sending request: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: isLoading
              ? Container(
                  margin: const EdgeInsets.only(top: 200.0),
                  child: const Center(child: CircularProgressIndicator()))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 60, // Set the desired height
                          width: 340, // Set the desired width
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.transparent, // Set the border color
                              width: 2.0, // Set the border width
                            ),
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the radius as needed
                          ),
                          child: ElevatedButton(
                              onPressed: navigateToAudioScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(241, 244,
                                    245, 1), // Set the button background color
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        colors: [
                                          Color.fromRGBO(216, 6, 131, 1),
                                          Color.fromRGBO(99, 7, 114, 1),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ).createShader(bounds);
                                    },
                                    child: const Icon(
                                      Icons.mic,
                                      size: 30,
                                      // Icon color
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        8, // Add some space between the icon and text
                                  ),
                                  Text(
                                    'audio'.tr(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromRGBO(83, 87, 103, 1),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 60, // Set the desired height

                          width: 340, // Set the desired width
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.transparent, // Set the border color
                              width: 2.0, // Set the border width
                            ),
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the radius as needed
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const VideoScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPressed
                                  ? const Color.fromRGBO(214, 6, 114, 1)
                                  : const Color.fromRGBO(241, 244, 245,
                                      1), // Set the button background color
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image.asset('assets/vedio.png'),
                                ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        colors: [
                                          Color.fromRGBO(216, 6, 131, 1),
                                          Color.fromRGBO(99, 7, 114, 1),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ).createShader(bounds);
                                    },
                                    child: const Icon(
                                      Icons.videocam,
                                      size: 30,
                                    )),
                                const SizedBox(
                                  width:
                                      8, // Add some space between the icon and text
                                ),
                                Text(
                                  'video'.tr(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromRGBO(83, 87, 103, 1)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 200,
                          width: 340,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(241, 244, 245, 1),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: TextField(
                                  controller: textEditingController,
                                  onChanged: (text) {
                                    if (text.isNotEmpty) {
                                      setState(() {
                                        sendButtonVisible = true;
                                      });
                                    } else {
                                      setState(() {
                                        sendButtonVisible = false;
                                      });
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Describe the scenario',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(83, 87, 103, 1),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(216, 6, 131, 1),
                Color.fromRGBO(99, 7, 114, 1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ElevatedButton(
              onPressed: ssosId.startsWith('sos')
                  ? null
                  : () {
                      sendRequest();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                ssosId.startsWith('sos')
                    ? "Requested".tr()
                    : "Request Help".tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
        ),
      ),
    );
  }
}

//=================================>>>>>>>>>>>>>>>>>>>>>>>2222222
// OnGoing TabScreen

class UserData {
  final String id;
  final String firstName;
  final int mobileNumber;
  final String profileImg;

  UserData({
    required this.id,
    required this.firstName,
    required this.mobileNumber,
    required this.profileImg,
  });
}

class Option2Content extends StatefulWidget {
  const Option2Content({super.key});

  @override
  State<Option2Content> createState() => _Option2ContentState();
}

class _Option2ContentState extends State<Option2Content> {
  List<dynamic> sosData = [];

  @override
  void initState() {
    super.initState();
    fetchSosData();
    citizenlocationupdate();
  }

  Future<void> fetchSosData() async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}ongoingSos'));
    request.body = json.encode({"_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      setState(() {
        sosData = jsonResponse['result'];
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> citizenlocationupdate() async {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double latitude = position.latitude;
    double longitude = position.longitude;

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}locationUpdatecitizen'));
    request.body = json.encode({
      "_ids": [id],
      "latitude": latitude,
      "longitude": longitude
    });
    print('request.body ===>>>${request.body}');
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: sosData.length,
        itemBuilder: (context, index) {
          final data = sosData[index];
          final user = data['user_id'];
          // final location = data['location'];
          // final attachment = data['attachment'];
          final sosId = data['sosId'];
          final profileImageUrl = '${imagespath.baseUrl}${user['profile_img']}';

          return InkWell(
            onTap: () {
              // Navigate to GetSosScreen and pass the sosId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityGetsosdata(sosId: sosId),
                ),
              );
            },
            child: Card(
              elevation: 10.0,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        profileImageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
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
                        Text(
                          'SOS ID: $sosId',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black, // Customize the color
                          ),
                        ),
                        Text(
                          'Mobile Number: ${user['mobilenumber']}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black, // Customize the color
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//============================>>>>>>>>>>>>333333

class UserData1 {
  final String id;
  final String firstName;
  final int mobileNumber;
  final String profileImg;

  UserData1({
    required this.id,
    required this.firstName,
    required this.mobileNumber,
    required this.profileImg,
  });
}

class Option3Content extends StatefulWidget {
  const Option3Content({super.key});

  @override
  State<Option3Content> createState() => _Option3ContentState();
}

class _Option3ContentState extends State<Option3Content> {
  List<dynamic> sosData = [];

  @override
  void initState() {
    super.initState();
    fetchSosData();
  }

  Future<void> fetchSosData() async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}completedSos'));
    request.body = json.encode({"_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      setState(() {
        sosData = jsonResponse['result'];
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: sosData.length,
        itemBuilder: (context, index) {
          final data = sosData[index];
          final user = data['user_id'];
          // final location = data['location'];
          // final attachment = data['attachment'];
          final sosId = data['sosId'];
          final profileImageUrl = '${imagespath.baseUrl}${user['profile_img']}';

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityGetsosdata(sosId: sosId),
                ),
              );
            },
            child: Card(
              elevation: 10.0,
              margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        profileImageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
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
                        Text(
                          'SOS ID: $sosId',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black, // Customize the color
                          ),
                        ),
                        Text(
                          'Mobile Number: ${user['mobilenumber']}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black, // Customize the color
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class IconOverlay extends StatelessWidget {
  final Function()? onPressed;

  IconOverlay({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(216, 6, 131, 1),
                      Color.fromRGBO(99, 7, 114, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(216, 6, 131, 1),
                      Color.fromRGBO(99, 7, 114, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sent to Nearby Leaders',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
