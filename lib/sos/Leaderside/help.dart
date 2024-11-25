import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:Shepower/sos/Leaderside/GetsosData.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HelpTabViewscreen extends StatefulWidget {
  const HelpTabViewscreen({
    super.key,
  });

  @override
  State<HelpTabViewscreen> createState() => _sosScreenState();
}

class _sosScreenState extends State<HelpTabViewscreen> {
  int currentIndex = 0;

  final List<Tab> _tabs = [
     Tab(text: 'OnGoing'.tr()),
     Tab(text: 'Completed'.tr()),
  ];

  @override
  Widget build(BuildContext context) {
    final double defaultFontSize = 12.0;

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
              Navigator.of(context).pop();
            },
          ),
          title:  Text(
            'emergency_Requests',
            style: TextStyle(
              color: Color.fromRGBO(25, 41, 91, 1),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Option2Content(),
            Option3Content(),
          ],
        ),
      ),
    );
  }
}

//=====================>>>>>>>>>>>>>>>>>.222222222222222

class Option2Content extends StatefulWidget {
  const Option2Content({Key? key});

  @override
  State<Option2Content> createState() => _Option2ContentState();
}

class _Option2ContentState extends State<Option2Content> {
  List<dynamic> sosData = [];
  bool isLoading = false; // Flag to track whether data is loading

  @override
  void initState() {
    super.initState();
    fetchSosData();
  }

  Future<void> fetchSosData() async {
    setState(() {
      isLoading = true;
    });
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

      setState(() {
        sosData = jsonResponse['result'];
        isLoading = false;
      });
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : sosData.isEmpty
              ? Center(
                  child: Text('No data Available')) // Show loading indicator
              : ListView.builder(
                  itemCount: sosData.length,
                  itemBuilder: (context, index) {
                    final data = sosData[index];
                    final user = data['user_id'];
                    // final location = data['location'];
                    // final attachment = data['attachment'];
                    final sosId = data['sosId'];
                    final profileImageUrl =
                        '${imagespath.baseUrl}${user['profile_img']}';

                    return InkWell(
                      onTap: () {
                        // Navigate to GetSosScreen and pass the sosId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Getsosdata(sosId: sosId),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 10.0,
                        margin: EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user['firstname']}${user['lastname'] ?? ''}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'SOS ID: $sosId',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Mobile Number: ${user['mobilenumber']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
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

//======================>>>>>>>>>>>>>>3333333333

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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSosData();
  }

  Future<void> fetchSosData() async {
    setState(() {
      isLoading = true;
    });
    final storage = FlutterSecureStorage();
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
        isLoading = false;
      });
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : sosData.isEmpty
              ? Center(
                  child: Text('No data Available')) // Show loading indicator
              : ListView.builder(
                  itemCount: sosData.length,
                  itemBuilder: (context, index) {
                    final data = sosData[index];
                    final user = data['user_id'];
                    // final location = data['location'];
                    // final attachment = data['attachment'];
                    final sosId = data['sosId'];
                    final profileImageUrl =
                        '${imagespath.baseUrl}${user['profile_img']}';

                    return InkWell(
                      onTap: () {
                        // Navigate to GetSosScreen and pass the sosId
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => CityGetsosdata(sosId: sosId),
                        //   ),
                        // );
                      },
                      child: Card(
                        elevation: 10.0,
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                              SizedBox(width: 12.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user['firstname']}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'SOS ID: $sosId',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Colors.black, // Customize the color
                                    ),
                                  ),
                                  Text(
                                    'Mobile Number: ${user['mobilenumber']}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Colors.black, // Customize the color
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
  final IconData icon;
  final double iconSize;
  final Function()? onPressed;

  IconOverlay({required this.icon, required this.iconSize, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        color: const Color.fromRGBO(
            0, 0, 0, 0.5), // Semi-transparent background color
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
                child: ElevatedButton(
                  onPressed: () {
                    // Add your button's onPressed logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: const CircleBorder(),
                  ),
                  child: Icon(
                    icon,
                    size: 50,
                    color: Colors.white,
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
                  onPressed: () {
                    // _shareAudioFile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text('Sent to Nearby Leaders'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
