import 'dart:convert';

import 'package:Shepower/Chatroom/Chatroom.dart';
import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'CreateGroup.dart'; // Import CreateGroup if it's in a separate file.
import 'Models/chat_user.model.dart';

class Allchats extends StatefulWidget {
  final String myId;

  Allchats({Key? key, required this.myId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Allchats> {
  List<ChatUser> users = [];
  String profileId = '';
  RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      init();
    });
  }

  init() async {
    print('init method called');
    // Utils().showLoader(context); // Show the loader
    try {
      _loadProfileID();
      await GetChathistory();
    } catch (e) {
    } finally {}
  }

  Future<void> _loadProfileID() async {
    final profileData = await getProfileProfile();
    print('profileData: $profileData');
    setState(() {
      profileId = profileData['profileID'];
    });
  }

  Future<Map<String, dynamic>> getProfileProfile() async {
    // ignore: prefer_const_constructors
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

  Future<void> GetChathistory() async {
    try {
      const storage = FlutterSecureStorage();
      String? _id = await storage.read(key: '_id');
      String? accesstoken = await storage.read(key: 'accessToken');

      if (_id == null || _id == "") return null;

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request =
          http.Request('POST', Uri.parse('${ApiConfig.baseUrl}ChatHistory'));
      request.body = json.encode({"user_id": _id});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        var data = json.decode(responseBody);
        print('listlist..............................$responseBody');

        List responses = data['response'];

        List<ChatUser> list =
            responses.map<ChatUser>((json) => ChatUser.fromJson(json)).toList();
        print('listlist..............................$list');

        setState(() {
          users = list;
        });
        _refreshController.refreshCompleted();
      } else {
        print(response.reasonPhrase);
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      print(e);
      _refreshController.refreshCompleted();
    }
  }

  Future<void> GetGrouphistory() async {
    try {
      const storage = FlutterSecureStorage();
      String? _id = await storage.read(key: '_id');
      String? accesstoken = await storage.read(key: 'accessToken');

      if (_id == null || _id == "") return null;

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request =
          http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getAllGroups'));
      request.body = json.encode({"user_id": _id});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      print(data);

      List responses = data['result'];

      List<ChatUser> list =
          responses.map<ChatUser>((json) => ChatUser.fromJson(json)).toList();

      setState(() {
        users = list;
      });
      print('prineddate$users');
    } catch (e) {
      print(e);
    }
  }

  String getUserProfileImage(ChatUser? user) {
    if (user?.profileImg == null) {
      ChatData? chatData;

      if (user?.senderId == widget.myId) {
        chatData = user?.otherData;
      } else {
        chatData = user?.senderData;
      }

      if (chatData?.profileImg != null) {
        return "${imagespath.baseUrl}${chatData?.profileImg}";
      } else {
        return "${imagespath.baseUrl}${chatData?.profileImg}";
      }
    } else {
      return "${imagespath.baseUrl}${user?.profileImg}";
    }

    return "";
  }

  String getUserName(ChatUser? user) {
    if (user?.GroupName == null) {
      ChatData? chatData;

      if (user?.senderId == widget.myId) {
        chatData = user?.otherData;
      } else {
        chatData = user?.senderData;
      }
      return chatData?.firstname ?? "";
    } else {
      return user!.GroupName
          .toString(); // Use the non-null assertion operator (!) because you checked for null
    }

    return ""; // Default return if none of the conditions are met
  }

  String getLastMessage(ChatUser user) {
    if (user.data == null || user.data!.isEmpty) return "";
    return user.data?.last.message ?? "";
  }

  String getLastMessageTime(ChatUser user) {
    try {
      if (user.data == null || user.data!.isEmpty) return "";
      String date = user.data?.last.createdAt ?? "";
      DateTime dateTime = DateTime.parse(date);
      return DateFormat("hh:mm s").format(dateTime);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          elevation: 0,
          toolbarHeight: 115.h,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        IconButton(
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
                                  width: 1.5.w,
                                  color: const Color.fromRGBO(215, 215, 215, 1),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Icon(
                                Icons.navigate_before,
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(width: 7.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'chat'.tr(),
                              style: GoogleFonts.montserrat(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.8,
                                  color: const Color.fromRGBO(25, 41, 92, 1)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEDEE),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: Color.fromARGB(255, 209, 53, 173),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.roboto(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'chat_search'.tr(),
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                              color: Colors.grey.withOpacity(0.8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color.fromRGBO(0, 97, 117, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SmartRefresher(
          onRefresh: () => GetChathistory(),
          controller: _refreshController,
          enablePullDown: true, // Enable pull-to-refresh
          header: const WaterDropHeader(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Text(
                        'all_msg'.tr(),
                        style: GoogleFonts.aDLaMDisplay(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: profileId.startsWith('Leader'),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return CreateGroup();
                            },
                          ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(17.0),
                          child: Text(
                            'create_group'.tr(),
                            style: GoogleFonts.aDLaMDisplay(
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                              color: const Color.fromRGBO(0, 0, 0, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  itemCount: users.length,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, i) {
                    // Sort the users list by the timestamp of the last message in descending order (most recent first)
                    // users.sort((a, b) {
                    //   DateTime dateTimeA =
                    //       DateTime.parse(a.data?.last.createdAt ?? "");
                    //   DateTime dateTimeB =
                    //       DateTime.parse(b.data?.last.createdAt ?? "");
                    //   return dateTimeB.compareTo(dateTimeA);
                    // });
                    ChatUser user = users[i];
                    ChatData? chatData;

                    if (user.senderId == widget.myId) {
                      chatData = user.otherData;
                    } else {
                      chatData = user.senderData;
                    }

                    return InkWell(
                      // Wrap with InkWell for tap gestures
                      onTap: () {
                        // Navigate to the chat room screen with room ID and other ID.
                        socket.emit('joinRoom', user.roomId);
                        print("dddddd ${user.GroupName},${user.roomId} ");
                        print("socket ${socket.id}");
                        // Navigate to the chat room screen with room ID and other ID.
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatScreen1(
                                Roomid: user.roomId!,
                                userId: user?.GroupName == null
                                    ? chatData!.sId!
                                    : user!.sId!,
                                GroupBoolina:
                                    user?.GroupName == null ? false : true),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            getUserProfileImage(user),
                          ),
                        ),
                        title: Text(getUserName(user)),
                        subtitle: Text(getLastMessage(user)),
                        trailing: Text(getLastMessageTime(user)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
