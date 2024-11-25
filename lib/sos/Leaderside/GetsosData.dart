import 'dart:convert';

import 'package:Shepower/common/cache.service.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/sos/Citizen/Commentscreen.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart'; // Instead of 'geocoder'
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class sosDetails {
  bool? status;
  String? message;
  Result? result;

  sosDetails({this.status, this.message, this.result});

  sosDetails.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['message'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['message'] = this.message;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class Result {
  Location? location;
  String? sId;
  UserId? userId;
  String? attachment;
  String? text;
  String? sosId;
  bool? closed;
  List<Accptedleader>? accptedleader;
  int? notificationCount;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Result(
      {this.location,
      this.sId,
      this.userId,
      this.attachment,
      this.text,
      this.sosId,
      this.closed,
      this.accptedleader,
      this.notificationCount,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Result.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    userId =
        json['user_id'] != null ? new UserId.fromJson(json['user_id']) : null;
    attachment = json['attachment'];
    text = json['text'];
    sosId = json['sosId'];
    closed = json['closed'];
    if (json['accptedleader'] != null) {
      accptedleader = <Accptedleader>[];
      json['accptedleader'].forEach((v) {
        accptedleader!.add(new Accptedleader.fromJson(v));
      });
    }
    notificationCount = json['notificationCount'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['_id'] = this.sId;
    if (this.userId != null) {
      data['user_id'] = this.userId!.toJson();
    }
    data['attachment'] = this.attachment;
    data['text'] = this.text;
    data['sosId'] = this.sosId;
    data['closed'] = this.closed;
    if (this.accptedleader != null) {
      data['accptedleader'] =
          this.accptedleader!.map((v) => v.toJson()).toList();
    }
    data['notificationCount'] = this.notificationCount;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}

class UserId {
  String? sId;
  String? firstname;
  int? mobilenumber;
  String? profileImg;
  String? token;

  UserId(
      {this.sId,
      this.firstname,
      this.mobilenumber,
      this.profileImg,
      this.token});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstname = json['firstname'];
    mobilenumber = json['mobilenumber'];
    profileImg = json['profile_img'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['firstname'] = this.firstname;
    data['mobilenumber'] = this.mobilenumber;
    data['profile_img'] = this.profileImg;
    data['token'] = this.token;
    return data;
  }
}

class Accptedleader {
  String? sId;
  String? firstname;
  int? mobilenumber;
  String? profileImg;
  String? token;

  Accptedleader(
      {this.sId,
      this.firstname,
      this.mobilenumber,
      this.profileImg,
      this.token});

  Accptedleader.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstname = json['firstname'];
    mobilenumber = json['mobilenumber'];
    profileImg = json['profile_img'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['firstname'] = this.firstname;
    data['mobilenumber'] = this.mobilenumber;
    data['profile_img'] = this.profileImg;
    data['token'] = this.token;
    return data;
  }
}

class Getsosdata extends StatefulWidget {
  final String sosId;

  Getsosdata({Key? key, required this.sosId}) : super(key: key);

  @override
  State<Getsosdata> createState() => _Option1ContentState();
}

class _Option1ContentState extends State<Getsosdata> {
  final PlayerController playerController = PlayerController();
  String sosid = '';
  String locationName = '';
  String userName = '';
  String userMobileNumber = '';
  String userprofile = '';
  bool isLoading = true;
  bool hasError = false;
  bool isPlaying = true;
  String attachment = '';
  String text = '';
  Result? sosdata;
  String? acceptedLeaderId;
  // final AudioPlayer player = AudioPlayer();
  late VideoPlayerController _videoController;
  late AudioPlayer audioPlayer;
  bool accepted = false;
  bool play = false;

  @override
  void initState() {
    super.initState();

    initializeVideoPlayer('${imagespath.baseUrl}$attachment');
    initializeAudioPlayer('${imagespath.baseUrl}$attachment');
    GetSosData();
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

  Future<void> GetSosData() async {
    final String? MyId = await CacheService.getUserId();
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
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
        var data = json.decode(responseBody);

        print(data);

        final userDataMap = data['result']['user_id'];
        final usersosId = data['result']['sosId'];
        final attachmentData = data['result']['attachment'];

        final locationLatitude = data['result']['location']['latitude'];
        final locationLongitude = data['result']['location']['longitude'];
        if (data['result']['accptedleader'] != null) {
          bool acceptedbyme = data['result']['accptedleader']
              .any((item) => item["_id"] == MyId);
          print("acttttt ${acceptedbyme}");
          setState(() {
            accepted = acceptedbyme;
          });
        }

        await getLocationName(locationLatitude, locationLongitude);

        setState(() {
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
        print('attachment=========${sosdata}');
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

  Future<void> AceptSos() async {
   final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}acceptSos'));
    request.body = json.encode({"sosId": sosid, "leader_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print('acceptsos...${await response.stream.bytesToString()}');
    if (response.statusCode == 200) {
      print("sssssss-----$accepted");
      setState(() {
        accepted = true;
      });
      Navigator.of(context).pop();
    } else {
      print(response.reasonPhrase);
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
        title: Text(
          'GetSos Details',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      body: SafeArea(
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
                            SizedBox(height: 20.0),
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
                                  Center(
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        '${imagespath.baseUrl}$userprofile',
                                      ),
                                      radius: 80.0,
                                    ),
                                  ),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
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
                                    'Location: $locationName',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CommentScreen(
                                                citizensosis: sosid)),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.comment),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: 170,
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
                                  if (!accepted) {
                                    AceptSos();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  accepted ? "Accepted" : "Accept",
                                  style: const TextStyle(
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
                              width: attachment
                                          .toLowerCase()
                                          .endsWith('.mp3') ||
                                      attachment.toLowerCase().endsWith('.mp4')
                                  ? 150
                                  : 0,
                              height: attachment
                                          .toLowerCase()
                                          .endsWith('.mp3') ||
                                      attachment.toLowerCase().endsWith('.mp4')
                                  ? 50
                                  : 0,
                              decoration: attachment
                                          .toLowerCase()
                                          .endsWith('.mp3') ||
                                      attachment.toLowerCase().endsWith('.mp4')
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
                                      attachment.toLowerCase().endsWith('.mp4')
                                  ? ElevatedButton(
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
                                          print('Unsupported attachment type');
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
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            if (_videoController.value.isInitialized)
                              AspectRatio(
                                aspectRatio: _videoController.value.aspectRatio,
                                child: VideoPlayer(_videoController),
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Visibility(
                          visible: text.isNotEmpty,
                          child: Container(
                            child: Text(
                              text, // Use text or an empty string if text is null
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
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
