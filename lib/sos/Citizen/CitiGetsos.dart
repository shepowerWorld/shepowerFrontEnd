import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:Shepower/sos/Citizen/Acceptedleaderrating.dart';
import 'package:Shepower/sos/Citizen/Commentscreen.dart';
import 'package:Shepower/sos/Citizen/sos.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stylish_dialog/stylish_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class Leader {
  final String id;
  final String firstname;
  final int mobilenumber;
  final String profileImg;
  final String token;

  Leader({
    required this.id,
    required this.firstname,
    required this.mobilenumber,
    required this.profileImg,
    required this.token,
  });

  factory Leader.fromJson(Map<String, dynamic> json) {
    return Leader(
      id: json['_id'],
      firstname: json['firstname'],
      mobilenumber: json['mobilenumber'],
      profileImg: json['profile_img'],
      token: json['token'],
    );
  }
}

class CityGetsosdata extends StatefulWidget {
  final String sosId;

  CityGetsosdata({Key? key, required this.sosId}) : super(key: key);

  @override
  State<CityGetsosdata> createState() => _Option1ContentState();
}

class _Option1ContentState extends State<CityGetsosdata> {
  final PlayerController playerController = PlayerController();
  String sosid = '';
  String locationName = '';
  String userName = '';
  String Emergencytext = '';
  String userMobileNumber = '';
  String userprofile = '';
  List<Leader> allLeaders = [];
  List<Leader> accptedleadeLeaders = [];

  bool isLoading = true;
  bool hasError = false;
  bool isPlaying = true;
  String attachment = '';
  // final AudioPlayer player = AudioPlayer();
  late VideoPlayerController _videoController;
  late AudioPlayer audioPlayer;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getSosData();
    initializeVideoPlayer('${imagespath.baseUrl}$attachment');
  }

  void initializeVideoPlayer(String attachmentUrl) {
    try {
      _videoController =
          VideoPlayerController.network('${imagespath.baseUrl}$attachment')
            ..initialize().then((_) {
              if (mounted) {
                setState(() {
                  // Start playing the video when it's initialized
                  _videoController.play();
                });
              }
            });
    } catch (e) {
      print('Attachment is not an Video file.');
    }
  }

  void initializeAudioPlayer(String audioUrl) async {
    audioPlayer = AudioPlayer();

    try {
      await audioPlayer.setUrl('${imagespath.baseUrl}$attachment');
      audioPlayer.play();
    } catch (e) {
      print('Error playing audio');
      // Handle the error as needed, e.g., show an error message to the user.
    }
  }

  Future<void> playAudio(String audioUrl) async {
    initializeAudioPlayer('${imagespath.baseUrl}$attachment');
  }

  Future<void> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        final subThoroughfare = placemark.reactive ?? '';

        setState(() {
          locationName = '$subThoroughfare';
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

  Future<void> getSosData() async {
    const storage = FlutterSecureStorage();

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getSosData'));
    request.body = json.encode({"sosId": widget.sosId});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        final userDataMap = data['result']['user_id'];
        final usersosId = data['result']['sosId'];
        final attachmentData = data['result']['attachment'];

        final locationLatitude = data['result']['location']['latitude'];
        final locationLongitude = data['result']['location']['longitude'];
        final leadersData = data['result']['leaders']; // Extract leaders data
        final accptedleaderData = data['result']['accptedleader'];

        await getLocationName(locationLatitude, locationLongitude);

        setState(() {
          allLeaders = leadersData
              .map<Leader>((leaderJson) => Leader.fromJson(leaderJson))
              .toList();
          accptedleadeLeaders = accptedleaderData
              .map<Leader>((leaderJson) => Leader.fromJson(leaderJson))
              .toList();
          Emergencytext = data['result']['text'];
          userName = userDataMap['firstname'];
          userMobileNumber = userDataMap['mobilenumber'].toString();
          userprofile = userDataMap['profile_img'];
          sosid = usersosId;
          isLoading = false;
          attachment = attachmentData;
          if (attachment.toLowerCase().endsWith('.mp3')) {
            playAudio('${imagespath.baseUrl}$attachment');
          } else if (attachment.toLowerCase().endsWith('.mp4')) {
            initializeVideoPlayer('${imagespath.baseUrl}$attachment');
          } else {
            print('Unsupported attachment type');
          }
        });
      } else {
        print(response.reasonPhrase);
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> closeSos() async {
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
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}closeSos'));
    request.body = json.encode({"sosId": sosid, "citizen_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(response);
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      showSuccessDialog(context);

      setState(() {
        isLoading = false;
      });
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSuccessDialog(BuildContext context) {
    StylishDialog(
      context: context,
      alertType: StylishDialogType.SUCCESS,
      content: Column(
        children: [
          Text('SOS Closed successfully'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AcceptLeaderScreen(
                        accptedleadeLeaders: accptedleadeLeaders,
                        usersosid: sosid)),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    ).show();
  }

  Future<void> _onRefresh() async {
    await getSosData();
    _refreshController.refreshCompleted();
  }

  void _openMap() async {
    final String latitude = '12.9716';
    final String longitude = '77.5946';
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black,
              ),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'GetSos Details',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: _onRefresh,
          header: const WaterDropHeader(),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : hasError
                  ? Center(
                      child: Text('Failed to load data.'),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(''),
                                        Text(''),
                                        // TextButton(
                                        //     onPressed: _openMap,
                                        //     child: Icon(
                                        //       Icons.location_on,
                                        //     ))
                                      ],
                                    ),
                                    Center(
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          '${imagespath.baseUrl}$userprofile',
                                        ),
                                        radius: 80.0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        getSosData();
                                      },
                                      child: Text(
                                        userName,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Mobile Number: $userMobileNumber',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      'Sosid: $sosid',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      'Location Details:\n$locationName',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      'message: $Emergencytext',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (accptedleadeLeaders
                                                .isNotEmpty) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CommentScreen(
                                                          citizensosis: sosid),
                                                ),
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                msg:
                                                    "No  accepted leaders available",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0,
                                              );
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Icon(Icons.comment),
                                                Text(
                                                  'Comment',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (accptedleadeLeaders
                                                .isNotEmpty) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      accLeaderScreen(
                                                          leaders:
                                                              accptedleadeLeaders),
                                                ),
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                msg:
                                                    "No  accepted leaders available",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0,
                                              );
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Icon(Icons.people),
                                                Text(
                                                  'Accepted  \n Leaders',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LeaderScreen(
                                                        leaders: allLeaders),
                                              ),
                                            );
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Icon(Icons.people),
                                                Text(
                                                  'Near By \n Leaders',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                width: 150,
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
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    closeSos();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    "Close",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: 200,
                                height: 50,
                                decoration: attachment
                                            .toLowerCase()
                                            .endsWith('.mp3') ||
                                        attachment
                                            .toLowerCase()
                                            .endsWith('.mp4')
                                    ? BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color.fromRGBO(216, 6, 131, 1),
                                            Color.fromRGBO(99, 7, 114, 1),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      )
                                    : null,
                                child: attachment
                                            .toLowerCase()
                                            .endsWith('.mp3') ||
                                        attachment
                                            .toLowerCase()
                                            .endsWith('.mp4')
                                    ? Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (attachment
                                                .toLowerCase()
                                                .endsWith('.mp3')) {
                                              if (isPlaying) {
                                                audioPlayer.pause();
                                              } else {
                                                audioPlayer.play();
                                              }
                                            } else if (attachment
                                                .toLowerCase()
                                                .endsWith('.mp4')) {
                                              if (isPlaying) {
                                                _videoController.pause();
                                              } else {
                                                _videoController.play();
                                              }
                                            } else {
                                              print(
                                                  'Unsupported attachment type');
                                            }

                                            setState(() {
                                              isPlaying = !isPlaying;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          ),
                                          child: Text(
                                            isPlaying
                                                ? (attachment
                                                        .toLowerCase()
                                                        .endsWith('.mp3')
                                                    ? "Pause Audio"
                                                    : (attachment
                                                            .toLowerCase()
                                                            .endsWith('.mp4')
                                                        ? "Pause Video"
                                                        : ""))
                                                : (attachment
                                                        .toLowerCase()
                                                        .endsWith('.mp3')
                                                    ? "Play Audio"
                                                    : (attachment
                                                            .toLowerCase()
                                                            .endsWith('.mp4')
                                                        ? "Play Video"
                                                        : "")),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              if (_videoController.value.isInitialized)
                                AspectRatio(
                                  aspectRatio:
                                      _videoController.value.aspectRatio,
                                  child: VideoPlayer(_videoController),
                                ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
        ),
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
            0, 0, 0, 0.6), // Semi-transparent background color
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => Emergencysos(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: const CircleBorder(),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => Emergencysos(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text(
                    'SOS Closed Successfully',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

class LeaderScreen extends StatelessWidget {
  final List<Leader> leaders;

  const LeaderScreen({Key? key, required this.leaders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Near by Leaders'),
      ),
      body: ListView.builder(
        itemCount: leaders.length,
        itemBuilder: (context, index) {
          final leader = leaders[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(
                leader.firstname,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Mobile: ${leader.mobilenumber}'),
              leading: CircleAvatar(
                radius: 35,
                backgroundImage:
                    NetworkImage('${imagespath.baseUrl}${leader.profileImg}'),
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

class accLeaderScreen extends StatelessWidget {
  final List<Leader> leaders;

  const accLeaderScreen({Key? key, required this.leaders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Accept Leaders'),
      ),
      body: ListView.builder(
        itemCount: leaders.length,
        itemBuilder: (context, index) {
          final leader = leaders[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(
                leader.firstname,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Mobile: ${leader.mobilenumber}'),
              leading: CircleAvatar(
                radius: 35,
                backgroundImage:
                    NetworkImage('${imagespath.baseUrl}${leader.profileImg}'),
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}




  // void _showLeaderDetails(BuildContext context, Leader leader) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text(leader.firstname),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Mobile: ${leader.mobilenumber}'),
  //             SizedBox(height: 8),
  //             Text('Token: ${leader.token}'),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }