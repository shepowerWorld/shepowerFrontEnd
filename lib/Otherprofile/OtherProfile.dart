import 'dart:async';
import 'dart:convert';

import 'package:Shepower/Chatroom/Chatroom.dart';
import 'package:Shepower/Myprofile/myprofile.dart';
import 'package:Shepower/Myprofile/postDetails.dart';
import 'package:Shepower/Ratings/ratingReviews.dart';
import 'package:Shepower/Request.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/sos/Citizen/sos.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:video_thumbnail/video_thumbnail.dart';

import 'model/connection.model.dart';

class Settings {
  bool public;
  bool private;
  bool connected;

  Settings({
    this.public = false,
    this.private = false,
    this.connected = false,
  });
}

class Otherprofile extends StatefulWidget {
  final String userId;
  final String myId; // Add the myId property here

  const Otherprofile({Key? key, required this.userId, required this.myId})
      : super(key: key);

  @override
  State<Otherprofile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<Otherprofile> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<dynamic> postsData = [];
  Map<String, dynamic> profileData = {};
  List<Map<String, dynamic>> connectionData = [];
  List<Connection> connections = [];
  String interestsString = "";
  String? weShare = '';
  String? overallAverageRating;
  String? sosCount;
  String? groupCount;
  String? overallAmount;
  bool? Connected;
  bool? RequestExists;
  Timer? _profileTimer;
  Timer? _postTimer;
  String profileID = "";

  Map<String, dynamic> dobsetting = {};
  Map<String, dynamic> educationsetting = {};
  Map<String, dynamic> professionsetting = {};
  Map<String, dynamic> locationsetting = {};
  Map<String, dynamic> familymemeberssetting = {};
  Map<String, dynamic> languagessetting = {};
  bool? cjeckingid;

  bool isLoading = false;
  String myid = '';

  @override
  void initState() {
    super.initState();
    getCheckid();
    _loadProfileData();
    ConnectionData();
    _fetchUserPosts();
    init();

    Future.microtask(() {
      init();
    });
  }

  init() async {
    print('init method called');
    try {
      setState(() {
        isLoading = true;
      });
      await _loadProfileData();
      await _fetchUserPosts();
      await ConnectionData();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getCheckid() async {
    bool result11 = await checkId();
    print('result11$result11');
    print('objectobjectobject1');
    String? id = await _secureStorage.read(key: '_id');
    setState(() {
      cjeckingid = result11;
      myid = id!;
    });
  }

  @override
  void dispose() {
    _profileTimer?.cancel();
    _postTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getOtherprofile'));
    request.body = json.encode({"_id": widget.userId, "viewer_id": id});
    request.headers.addAll(headers);
    print(request.body);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();

      final data1 = json.decode(responseBody);
      final data = json.decode(responseBody)['result'];
      final data2 = json.decode(responseBody)['result']['areaofintrest'];

      final isConnected = data1['isConnected'];
      final requestExists = data1['requestExists'];

      processData(data1);

      setState(() {
        profileID = data['profileID'];
        profileData = {
          'profileID': data['profileID'],
          'profileImg': data['profile_img'],
          'location': data['location'],
          'myId': data['_id'],
          'firstname': data['firstname'],
          'lastname': data['lastname'],
          'email': data['email'],
          'dob': data['dob'],
          'proffession': data['proffession'],
          'education': data['education'],
          'connection': data['Connection'].toString(),
          'connected': data['connected'],
          'languages': data['languages'].join(' '),
          'familyMembers': data['familymembers'].join(' '),
          'movies': data2['movies'].join(' '),
          'music': data2['music'].join(' '),
          'books': data2['books'].join(' '),
          'dance': data2['dance'].join(' '),
          'sports': data2['sports'].join(' '),
          'otherintrests': data2['otherintrests'].join(' '),
          'weShearOnOff': data['weShearOnOff'] ?? false,
        };

        setState(() {
          dobsetting = {
            'public': data['dobsettings']['public'],
            'private': data['dobsettings']['private'],
            'connected': data['dobsettings']['connected']
          };
          educationsetting = {
            'public': data['educationsettings']['public'],
            'private': data['educationsettings']['private'],
            'connected': data['educationsettings']['connected']
          };
          professionsetting = {
            'public': data['proffessionsettings']['public'],
            'private': data['proffessionsettings']['private'],
            'connected': data['proffessionsettings']['connected']
          };
          locationsetting = {
            'public': data['locationsionsettings']['public'],
            'private': data['locationsionsettings']['private'],
            'connected': data['locationsionsettings']['connected']
          };
          familymemeberssetting = {
            'public': data['familymemberssionsettings']['public'],
            'private': data['familymemberssionsettings']['private'],
            'connected': data['familymemberssionsettings']['connected']
          };
          languagessetting = {
            'public': data['languagessionsettings']['public'],
            'private': data['languagessionsettings']['private'],
            'connected': data['languagessionsettings']['connected']
          };
        });

        Connected = isConnected;
        RequestExists = requestExists;
      });
      print('profileData---${profileData['weShearOnOff']}');
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  void processData(Map<String, dynamic> data1) {
    if (data1.containsKey('overallAverageRating') &&
        data1['overallAverageRating'] != null) {
      setState(() {
        overallAverageRating = data1['overallAverageRating'].toStringAsFixed(2);
      });
    } else {
      setState(() {
        overallAverageRating = '0.00';
      });
    }
    if (data1.containsKey('sosCount') && data1['sosCount'] != null) {
      setState(() {
        sosCount = data1['sosCount'].toString();
      });
    } else {
      setState(() {
        sosCount = '0';
      });
    }

    if (data1.containsKey('groupCount') && data1['groupCount'] != null) {
      setState(() {
        groupCount = data1['groupCount'].toString();
      });
    } else {
      setState(() {
        groupCount = '0';
      });
    }

    if (data1.containsKey('overallAmount') && data1['overallAmount'] != null) {
      setState(() {
        overallAmount = data1['overallAmount'].toString();
      });
    } else {
      setState(() {
        overallAmount = '0.0';
      });
    }
  }

  Future<void> _fetchUserPosts() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}getAllPostsofMe'),
    );
    request.body = json.encode({"user_id": widget.userId});
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      List<dynamic> posts = data['results'][0]['posts'];

      setState(() {
        postsData = posts;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> _sendRequest() async {
    final storage = FlutterSecureStorage();
    String? storedId = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}sendRequestOrConnect'),
    );
    request.body = json.encode({"fromUser": storedId, "toUser": widget.userId});
    print('sendRequestOrConnect${request.body}');
    request.headers.addAll(headers);
    final response = await request.send();
    print('sendRequestOrConnect');
    if (response.statusCode == 200) {
      await _loadProfileData();
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> CreateRoom() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}createChat'));
    request.body = json.encode({"sender_id": id, "other_id": widget.userId});
    print('Request body: ${request.body}');
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      print('Response Body: ${responseBody}');

      if (jsonResponse['Message'] == "Cannot create chat with private user") {
        showPlatformDialog(
          context: context,
          builder: (context) {
            return BasicDialogAlert(
              title: Text("Private Account"),
              content: Text(
                  "This is a private account. You cannot create a chat with a private user."),
              actions: <Widget>[
                BasicDialogAction(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  title: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        print('Message: ${jsonResponse['Message']}');
        final roomId = jsonResponse['response'][0]['room_id'];
        print('ROOMSIDS$roomId');
        socket.emit('joinRoom', roomId);

        if (jsonResponse['message'] == "room created") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen1(
                  userId: widget.userId, Roomid: roomId, GroupBoolina: false),
            ),
          );
        } else {
          print('Room not created');
        }

        print('User Room Created Successfully');
        print('Room ID: $roomId');
      }
    } else {
      print('Response Status Code: ${response.statusCode}');
      print('Response Reason Phrase: ${response.reasonPhrase}');
    }
  }

  Future<void> ConnectionData() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getConnections'));
    request.body = json.encode({
      "_id": widget.userId,
    });

    print(request.body);
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (data['status'] == true) {
        final result = data['result'];
        List<Connection> l = result['connections']
            .map<Connection>((json) => Connection.fromJson(json))
            .toList();
        setState(() {
          connections = l;
        });

        print(connections);
      } else {}
    } else {
      print('Failed to fetch connection data: ${response.reasonPhrase}');
    }
  }

  Future<bool> checkId() async {
    const storage = FlutterSecureStorage();
    final idss = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getConnections'));
    request.body = json.encode({"_id": widget.userId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      print('data==>>$data');
      if (data['status'] == true) {
        final result = data['result'];
        List<String> listofconnections = List<String>.from(result['connections']
            .map((connection) => connection["_id"].toString()));

        print('listofconnections==>>${listofconnections.contains(idss)}');
        bool myvalue = listofconnections.contains(idss);
        print("myvalue$myvalue");
        return myvalue;
      } else {
        print(response.reasonPhrase);
        return false;
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  String shortenLocation(String location, int maxLength) {
    if (location.length <= maxLength) {
      return location;
    } else {
      return '${location.substring(0, maxLength)}...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.025;

    String birthDateStr = '';
    DateTime birthDate;
    String formattedBirthDate;

    if (profileData['dob'] != null) {
      birthDateStr = profileData['dob'].split('T')[0];

      try {
        birthDate = DateTime.parse(birthDateStr);
        formattedBirthDate = DateFormat('dd-MM-yyyy').format(birthDate);
      } catch (e) {
        formattedBirthDate = "Invalid date";
        print("Error parsing birth date: $e");
      }
    } else {
      formattedBirthDate = "DOB not available";
    }

    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
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
          '${profileData['firstname'] ?? ''}',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: const Color(0xFFD80683),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(33.5),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  '${imagespath.baseUrl}${profileData['profileImg']}', // Replace with actual profile image URL
                                ),
                                radius: 23.5,
                              ),
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shortenLocation(
                                      '${profileData['firstname']}', 10),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize,
                                    color: const Color(0xFFD80683),
                                  ),
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Text(
                                  shortenLocation(
                                      '${profileData['location']}', 10),
                                  style: const TextStyle(
                                    fontSize: 12.42,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    height: 1.21,
                                    color: Color(0xFFD80683),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chat,
                                size: 31.sp,
                                color: const Color.fromARGB(255, 168, 40, 115),
                              ),
                              onPressed: () {
                                CreateRoom();
                              },
                            ),
                            SizedBox(
                              width: 120.w,
                              height: 31.h,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: ElevatedButton(
                                    onPressed: () {
                                      _sendRequest();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.transparent,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      (Connected == true &&
                                              RequestExists == false)
                                          ? "Following"
                                          : (Connected == true &&
                                                  RequestExists == true)
                                              ? "Connected"
                                              : "Connect",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                      ),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0)),
                                color: Color.fromARGB(255, 241, 228, 239),
                              ),
                              child: TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.pink.withOpacity(0.4)),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return DisplayPosts(
                                            postId: widget.userId);
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                    '${postsData.length}\n  ${"Posts".tr()} ',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: fontSize,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 1))),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Expanded(
                            child: Container(
                              color: Color.fromARGB(255, 241, 228, 239),
                              child: TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.pink.withOpacity(0.4)),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return Connections(
                                          userid: widget.userId,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  '${connections.length}\n  ${"Connection".tr()} ',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    fontSize: fontSize,
                                    color: const Color.fromRGBO(24, 25, 31, 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Visibility(
                            visible: profileData['weShearOnOff'] == true,
                            child: Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(0)),
                                  color: Color.fromARGB(255, 241, 228, 239),
                                ),
                                child: TextButton(
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
                                            (states) =>
                                                Colors.pink.withOpacity(0.4)),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                      '${overallAmount.toString().length > 2 ? overallAmount.toString().replaceRange(overallAmount.toString().length - 2, overallAmount.toString().length, "") : overallAmount.toString()} INR \n  ${"We Share".tr()} ',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: fontSize,
                                          color: const Color.fromRGBO(
                                              24, 25, 31, 1))),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Visibility(
                        visible: profileID.startsWith('Leader'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Container(
                                color: Color.fromARGB(255, 241, 228, 239),
                                child: TextButton(
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
                                            (states) =>
                                                Colors.pink.withOpacity(0.4)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Option3Content();
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                      '$sosCount\n ${"Completed".tr()}  ',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: fontSize,
                                          color: const Color.fromRGBO(
                                              24, 25, 31, 1))),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 1,
                            ),
                            Expanded(
                              child: Container(
                                color: Color.fromARGB(255, 241, 228, 239),
                                child: TextButton(
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
                                            (states) =>
                                                Colors.pink.withOpacity(0.4)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return GetRatingScreen(
                                            userId: widget.userId,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    '$overallAverageRating \n  ${"Reviews".tr()} ',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: fontSize,
                                      color:
                                          const Color.fromRGBO(24, 25, 31, 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 1,
                            ),
                            Expanded(
                              child: Container(
                                color: Color.fromARGB(255, 241, 228, 239),
                                child: TextButton(
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
                                            (states) =>
                                                Colors.pink.withOpacity(0.4)),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                      '$groupCount \n  ${"My Groups".tr()} ',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: fontSize,
                                          color: const Color.fromRGBO(
                                              24, 25, 31, 1))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      if (educationsetting['public'] == true ||
                          cjeckingid == true &&
                              educationsetting['connected'] == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/OtherProfile/Group1.png',
                                  height: 60.h,
                                  width: 60.w,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 16.w,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Education'.tr(),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 2.18,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 0.7))),
                                Text('${profileData['education']}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.21,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 1))),
                              ],
                            ),
                          ],
                        ),

                      if (professionsetting['public'] == true ||
                          cjeckingid == true &&
                              professionsetting['connected'] == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/OtherProfile/Group2.png',
                                height: 60,
                                width: 60,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align text to the left side
                              children: [
                                Text('Profession'.tr(),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 2.18,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 0.7))),
                                Text('${profileData['proffession']}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 1.21,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 1))),
                              ],
                            ),
                          ],
                        ),

                      if (languagessetting['public'] == true ||
                          cjeckingid == true &&
                              languagessetting['connected'] == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/OtherProfile/Group3.png',
                                height: 60,
                                width: 60,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('App Languages'.tr(),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 2.18,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 0.7))),
                                Text('${profileData['languages']}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 1.21,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 1))),
                              ],
                            ),
                          ],
                        ),

                      if (dobsetting['public'] == true ||
                          cjeckingid == true && dobsetting['connected'] == true)
                        Container(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  'assets/OtherProfile/birth.png',
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                      'Date Of Birth'.tr(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          height: 2.18,
                                          color: const Color.fromRGBO(
                                              24, 25, 31, 0.7),
                                        ),
                                      ),
                                      Text(
                                        formattedBirthDate,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          height: 1.21,
                                          color: const Color.fromRGBO(
                                              24, 25, 31, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Add more conditional content here based on your requirements
                                ],
                              )
                            ],
                          ),
                        ),

                      if (locationsetting['public'] == true ||
                          cjeckingid == true &&
                              locationsetting['connected'] == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/OtherProfile/city.png',
                                height: 60,
                                width: 60,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align text to the left side
                              children: [
                                Text('City'.tr(),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 2.18,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 0.7))),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: 150
                                        .w, // Set a maximum width for the location text
                                  ),
                                  child: Text('${profileData['location']}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(24, 25, 31, 1),
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),

                      if (familymemeberssetting['public'] == true ||
                          cjeckingid == true &&
                              familymemeberssetting['connected'] == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/OtherProfile/family.png',
                                height: 60,
                                width: 60,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Family Members'.tr(),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 2.18,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 0.7))),
                                Text('${profileData['familyMembers']}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 1.21,
                                        color: const Color.fromRGBO(
                                            24, 25, 31, 1))),
                              ],
                            ),
                          ],
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/OtherProfile/Group4.png',
                              height: 36,
                              width: 60,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Areas of Interests'.tr(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 2.18,
                                  color: const Color.fromRGBO(24, 25, 31, 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Wrap(
                          alignment: WrapAlignment
                              .center, // Aligns the children to the start of the line

                          children: [
                            if (profileData['movies'] != null)
                              Text(
                                '${profileData['movies']}',
                                textAlign: TextAlign
                                    .center, // Aligns text to the center horizontally
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.21,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                ),
                              ),
                            if (profileData['music'] != null)
                              Text(
                                '${profileData['music']}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.21,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                ),
                              ),
                            if (profileData['books'] != null)
                              Text(
                                '${profileData['books']}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.21,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                ),
                              ),
                            if (profileData['dance'] != null)
                              Text(
                                '${profileData['dance']}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.21,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                ),
                              ),
                            if (profileData['sports'] != null)
                              Text(
                                '${profileData['sports']}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.21,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                ),
                              ),
                            if (profileData['otherintrests'] != null)
                              Text(
                                '${profileData['otherintrests']}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.21,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10.0),
                      Container(
                        width: 360.w,
                        height: 136.h,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 1.5, color: Colors.grey),
                            bottom: BorderSide(width: 1.5, color: Colors.grey),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 26, top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Connection'.tr(),
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(24, 25, 31, 1))),
                              SizedBox(
                                height: 100, // Adjust the height as needed
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: connections.length,
                                  itemBuilder: (context, index) {
                                    final connection = connections[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              String user = connection.Id ?? "";

                                              print("ffffffffff------$myid");
                                              print("eeeeeeeee-----$user");
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    if (myid == user) {
                                                      return MyProfile(
                                                        myId: myid,
                                                      );
                                                    } else {
                                                      return Otherprofile(
                                                        userId: user,
                                                        myId: myid,
                                                      );
                                                    }
                                                  },
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                CircleAvatar(
                                                  radius:
                                                      30, // Adjust the size as needed
                                                  backgroundImage: NetworkImage(
                                                      '${imagespath.baseUrl}${connection.profileImg ?? ""}'),
                                                ),
                                                Text(
                                                    connection.firstname ?? "-",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color.fromRGBO(
                                                          24, 25, 31, 0.7),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 26),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Posts'.tr(),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 2.5,
                                color: Color(0xFF2C2C2C),
                              )),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Check if there are posts to display
                      postsData.isEmpty
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 16), // Add some spacing
                                Text(
                                  'No photos uploaded',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                  ),
                                ),
                              ],
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5.0,
                                mainAxisSpacing: 10.0,
                              ),
                              itemCount: postsData.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final post = postsData[index];
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DisplayPosts(
                                                postId: widget.userId)),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: post != null &&
                                              post['Post'] != null
                                          ? post['Post'].endsWith('.mp4')
                                              ? FutureBuilder<Widget>(
                                                  future: displayVideoThumbnail(
                                                      '${imagespath.baseUrl}${post['Post']}'),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      return snapshot.data ??
                                                          SizedBox();
                                                    } else {
                                                      return Container(
                                                        width: 30.w,
                                                        height: 80.h,
                                                        color: Colors.grey[300],
                                                      );
                                                    }
                                                  },
                                                )
                                              : Image.network(
                                                  '${imagespath.baseUrl}${post['Post']}',
                                                  width: 30.w,
                                                  height: 80.h,
                                                  fit: BoxFit.fill,
                                                )
                                          : SizedBox(), // Fallback if post or post['Post'] is null
                                    ));
                              },
                            )
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void showEnlargedPostDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: 300, // Adjust the height as needed
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Widget> displayVideoThumbnail(String videoUrl) async {
    final thumbnailData = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 100,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(thumbnailData!, fit: BoxFit.cover),
        const Positioned(
          top: 8,
          left: 8,
          child: Icon(Icons.play_circle_filled, color: Colors.white, size: 25),
        ),
      ],
    );
  }
}
