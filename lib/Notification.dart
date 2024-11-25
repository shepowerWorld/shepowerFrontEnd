import 'dart:convert';

import 'package:Shepower/Dashboard/Explorescreen.dart';
import 'package:Shepower/Otherprofile/OtherProfile.dart';
import 'package:Shepower/sos/Citizen/CitiGetsos.dart';
import 'package:Shepower/sos/Leaderside/help.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'common/cache.service.dart';
import 'service.dart'; // Import your service if it contains the ApiConfig class.

class NotificationItem {
  final String title;
  final String body;
  final String icon;
  final String userId;
  final String grouprequestId;
  final String groupId;
  final bool groupRequested;
  final bool isGroupNotification;
  final bool isConnectionNotification;
  final bool isSOSNotification;
  final bool sosClosed;
  final String createdAt;
  final String settings;
  final bool likespost;
  final bool comment;
  final bool accpeted;
  final bool likecomment;
  final bool replyComment;
  final bool replyCommentlike;
  final bool sosAccept;
  final bool mentioned;
  final String requestedid;
  final String sosid;
  final String accpetedid;

  NotificationItem(
      {required this.title,
      required this.body,
      required this.icon,
      required this.userId,
      required this.sosid,
      required this.grouprequestId,
      required this.groupId,
      required this.groupRequested,
      required this.isGroupNotification,
      required this.isConnectionNotification,
      required this.isSOSNotification,
      required this.sosClosed,
      required this.createdAt,
      required this.settings,
      required this.likespost,
      required this.comment,
      required this.accpeted,
      required this.likecomment,
      required this.replyComment,
      required this.replyCommentlike,
      required this.sosAccept,
      required this.mentioned,
      required this.accpetedid,
      required this.requestedid});
}

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // Fetch notifications from the API
  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    print('accessToken:$accesstoken, $id');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request = http.Request(
        'GET', Uri.parse('${ApiConfig.baseUrl}getNotification/$id'));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print('responseBody,,,$responseBody');
      final data = json.decode(responseBody);
      final notificationItems = data['response'];

      List<T> reverseArray<T>(List<T> array) {
        return array.reversed.toList();
      }

      setState(() {
        notifications =
            reverseArray(notificationItems).map<NotificationItem>((itemData) {
          Map<String, dynamic>? notificationData;

          // Check for different notification types
          if (itemData['sosNotification'] != null) {
            notificationData = itemData['sosNotification'];
          } else if (itemData['grouprequest'] != null ||
              itemData['groupaccept'] != null) {
            notificationData =
                itemData['grouprequest'] ?? itemData['groupaccept'];
          } else if (itemData['accpeted'] != null) {
            notificationData = itemData['accpeted'];
          } else if (itemData['accpeted_id'] != null) {
            notificationData = itemData['accpeted_id'];
          } else if (itemData['likespost'] != null) {
            notificationData = itemData['likespost'];
          } else if (itemData['comment'] != null) {
            notificationData = itemData['comment'];
          } else if (itemData['mentioned'] != null) {
            notificationData = itemData['mentioned'];
          } else if (itemData['sosClosed'] != null) {
            notificationData = itemData['sosClosed'];
          } else if (itemData['likecomment'] != null) {
            notificationData = itemData['likecomment'];
          } else if (itemData['replyComment'] != null) {
            notificationData = itemData['replyComment'];
          } else if (itemData['replyCommentlike'] != null) {
            notificationData = itemData['replyCommentlike'];
          } else if (itemData['sosAccept'] != null) {
            notificationData = itemData['sosAccept'];
          } else if (itemData['request'] != null) {
            notificationData = itemData['request'];
          } else if (itemData['requestedid'] != null) {
            notificationData = itemData['requestedid'];
          }

          if (notificationData != null) {
            return NotificationItem(
              title: notificationData['title'] ?? '',
              body: notificationData['body'] ?? '',
              icon: notificationData['icon'] ?? '',
              userId: itemData['user_id'] ?? '',
              accpetedid: itemData['accpeted_id'] ?? "",
              sosid: itemData['sosId'] ?? '',
              requestedid: itemData['requested_id'] ?? '',
              groupId: itemData['group_id'] ?? '',
              groupRequested: itemData['requested'] ?? false,
              grouprequestId: itemData['grouprequest_id'] ?? '',
              isGroupNotification: itemData['grouprequest'] != null,
              isConnectionNotification: true,
              isSOSNotification: itemData['sosNotification'] != null,
              sosClosed: itemData['sosClosed'] != null,
              createdAt: itemData['createdAt'] ?? '',
              settings: itemData['settings'] ?? '',
              likespost: itemData['likespost'] != null,
              comment: itemData['comment'] != null,
              accpeted: itemData['accpeted'] != null,
              likecomment: itemData['likecomment'] != null,
              replyComment: itemData['replyComment'] != null,
              replyCommentlike: itemData['replyCommentlike'] != null,
              sosAccept: itemData['sosAccept'] != null,
              mentioned: itemData['mentioned'] != null,
            );
          }
          return NotificationItem(
            title: '',
            createdAt: '',
            settings: '',
            body: '',
            icon: '',
            userId: '',
            accpetedid: '',
            sosid: '',
            requestedid: '',
            grouprequestId: '',
            groupId: '',
            groupRequested: false,
            isGroupNotification: false,
            isConnectionNotification: false,
            isSOSNotification: false,
            sosClosed: false,
            likespost: false,
            comment: false,
            accpeted: false,
            likecomment: false,
            replyComment: false,
            replyCommentlike: false,
            sosAccept: false,
            mentioned: false,
          );
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to fetch notifications');
    }
  }

  void acceptRequest(String requestedid) async {
    const storage = FlutterSecureStorage();

    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}acceptRequest'));
    request.body = json.encode({"fromUser": requestedid, "toUser": id});

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      fetchNotifications();
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NotificationScreen()),
      );
    } else {
      print(response.reasonPhrase);
    }
  }

  void rejectRequest(String requestedid) async {
    const storage = FlutterSecureStorage();

    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}rejectRequest'));
    request.body = json.encode({"fromUser": requestedid, "toUser": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      fetchNotifications();
    } else {
      print(response.reasonPhrase);
    }
  }

  void reject(String groupId, String userId) async {
    const storage = FlutterSecureStorage();

    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}rejectGroupRequest'));
    request.body = json.encode({"fromUser": userId, "group_id": groupId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      fetchNotifications();
    } else {
      print(response.reasonPhrase);
    }
  }

  void accept(String groupId, String userId) async {
    const storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}acceptGroupRequest'));
    request.body = json.encode({"fromUser": userId, "group_id": groupId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      fetchNotifications();
    } else {
      print(response.reasonPhrase);
    }
  }

  void showDialog(String message, String groupId, String userId) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      // Handle Accept button tap
                      Navigator.of(context).pop('accept');
                      accept(
                          groupId, userId); // You can pass any value you need
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
                            'Accept',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Handle Reject button tap
                      Navigator.of(context).pop('reject');
                      reject(
                          groupId, userId); // You can pass any value you need
                    },
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD80123),
                            Color(0xFF630123),
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
                            'Reject',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
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
          title: Text('Notifications'.tr(),
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: const Color.fromRGBO(25, 41, 92, 12))),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : notifications.isEmpty
                ? const Center(
                    child: Text("No notifications available."),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: InkWell(
                          onTap: () async {
                            final myId = await CacheService.getUserId();
                            if (notification.groupRequested) {
                              showDialog(
                                  notification.body,
                                  notification.groupId,
                                  notification.grouprequestId);
                            }
                            if (notification.isSOSNotification) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HelpTabViewscreen(),
                                ),
                              );
                            } else if (notification.sosClosed) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Option2Content(),
                                ),
                              );
                            } else if (notification.likespost) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Explorescreen(),
                                ),
                              );
                            } else if (notification.comment) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Explorescreen(),
                                ),
                              );
                            } else if (notification.likecomment) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Explorescreen(),
                                ),
                              );
                            } else if (notification.accpeted) {
                              if (myId == null) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => Otherprofile(
                                    userId: notification.accpetedid,
                                    myId: myId,
                                  ),
                                ),
                              );
                            } else if (notification.replyComment) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Explorescreen(),
                                ),
                              );
                            } else if (notification.replyCommentlike) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Explorescreen(),
                                ),
                              );
                            } else if (notification.sosAccept) {
                              print('sosid,,,,${notification.sosid}');
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => CityGetsosdata(
                                    sosId: notification.sosid,
                                  ),
                                ),
                              );
                            } else if (notification.mentioned) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Explorescreen(),
                                ),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 23.r,
                                    backgroundImage: NetworkImage(
                                      '${imagespath.baseUrl}${notification.icon}',
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            250.0, // Set your desired maximum width
                                        child: Text.rich(
                                          TextSpan(
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: notification.body
                                                    .split(' ')
                                                    .first, // Get the first word
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.sp,
                                                  height: 1.21875,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    ' ${notification.body.split(' ').skip(1).join(' ')}', // Get the rest of the text
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14.sp,
                                                  height: 1.21875,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Text(
                                        formatNotificationTime(
                                            notification.createdAt),
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          height: 1.21875,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              if (notification.settings == "private" ||
                                  notification.settings == "connected")
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 60),
                                      child: SizedBox(
                                        width: 115.w,
                                        height: 30.h,
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color.fromRGBO(216, 6, 131, 1),
                                                Color.fromRGBO(99, 7, 114, 1)
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30.r,
                                            ),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              acceptRequest(
                                                  notification.requestedid);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  30.r,
                                                ),
                                              ),
                                            ),
                                            child: Text("Accept",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14.sp,
                                                    color: const Color.fromRGBO(
                                                        255, 255, 255, 1))),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 30.w),
                                    SizedBox(
                                      width: 115.w,
                                      height: 30.h,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color.fromRGBO(216, 6, 131, 1),
                                              Color.fromRGBO(99, 7, 114, 1)
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30.r,
                                          ),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            rejectRequest(
                                                notification.requestedid);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Colors.transparent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                30.r,
                                              ),
                                            ),
                                          ),
                                          child: Text("Reject",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.sp,
                                                  color: const Color.fromRGBO(
                                                      255, 255, 255, 1))),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ));
  }

  String formatNotificationTime(String createdAt) {
    try {
      final currentTime = DateTime.now();
      final notificationTime = DateTime.parse(createdAt);
      final timeDifference = currentTime.difference(notificationTime);

      if (timeDifference.inMinutes < 1) {
        return 'Just now';
      } else if (timeDifference.inHours < 1) {
        return '${timeDifference.inMinutes} minute${timeDifference.inMinutes > 1 ? 's' : ''} ago';
      } else if (timeDifference.inHours < 24) {
        return '${timeDifference.inHours} hour${timeDifference.inHours > 1 ? 's' : ''} ago';
      } else if (timeDifference.inDays < 7) {
        return '${timeDifference.inDays} day${timeDifference.inDays > 1 ? 's' : ''} ago';
      } else if (timeDifference.inDays < 30) {
        final weeks = (timeDifference.inDays / 7).floor();
        return '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else if (timeDifference.inDays < 365) {
        final months = (timeDifference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else {
        final years = (timeDifference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      // Handle the parsing error gracefully. You can return a default message or format.
      return 'Invalid Date Format';
    }
  }
}
