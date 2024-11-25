import 'dart:async';
import 'dart:convert';

import 'package:Shepower/Myprofile/WeShare.dart';
import 'package:Shepower/Myprofile/postDetails.dart';
import 'package:Shepower/Myprofile/profile.dart';
import 'package:Shepower/Ratings/ratingReviews.dart';
import 'package:Shepower/Request.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/sos/Citizen/sos.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:video_thumbnail/video_thumbnail.dart';

class Post {
  final String postId;
  final int likes;
  final List<String> comments;
  final int shares;

  Post({
    required this.postId,
    required this.likes,
    required this.comments,
    required this.shares,
  });
}

class MyProfile extends StatefulWidget {
  final String myId;

  MyProfile({Key? key, required this.myId}) : super(key: key);

  @override
  State<MyProfile> createState() => _ProfileState();
}

class _ProfileState extends State<MyProfile> {
  final secureStorage = const FlutterSecureStorage();
  List<dynamic> postsData = [];

  String profileID = '';
  String profileImg = '';
  String location = '';
  String firstname = '';
  String lastname = '';
  String connection = '';
  String? rating;
  String? sosCount;
  String? groupCount;
  String? overallAmount;
  Timer? _profileTimer;
  Timer? _postTimer;
  bool isLoading = false;
  bool isWeShareOn = false;

 

  @override
  void initState() {
    super.initState();
    Future.microtask(init);
  }



  Future<void> init() async {
    print('init method called');

    try {
      setState(() {
        isLoading = true;
      });
      await _loadProfileID();
      await getAllPostsofMe();
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

  @override
  void dispose() {
    _profileTimer?.cancel();
    _postTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileID() async {
    final profileData = await GetMyProfile();
    setState(() {
      profileImg = profileData['profileImg'];
      profileID = profileData['profileID'];
      location = profileData['location'];
      firstname = profileData['firstname'];
      lastname = profileData['lastname'];
      connection = profileData['connection'];
      isWeShareOn = profileData['weShearOnOff'] ?? false;
    });
  }

  Future<Map<String, dynamic>> GetMyProfile() async {
    final storage = FlutterSecureStorage();

    String? id = await storage.read(key: '_id');
    print('application$id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request = http.Request(
        'GET', Uri.parse('${ApiConfig.baseUrl}getMyprofile/${widget.myId}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      processData(data);
      String profileID = data['result']['profileID'];
      String profileImg = data['result']['profile_img'];
      String location = data['result']['location'];
      String firstname = data['result']['firstname'];
      String lastname = data['result']['lastname'];
      String email = data['result']['email'];
      String dob = data['result']['dob'];
      String education = data['result']['education'];
      String proffession = data['result']['proffession'];

      String connection = data['Connection'].toString();
      bool weShearOnOff = data['result']['weShearOnOff'] ?? false;

      return {
        'profileID': profileID,
        'profileImg': profileImg,
        'location': location,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'dob': dob,
        'proffession': proffession,
        'education': education,
        'connection': connection,
        'weShearOnOff': weShearOnOff
      };
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  void processData(Map<String, dynamic> data) {
    if (data.containsKey('rating') && data['rating'] != null) {
      setState(() {
        rating = data['rating'].toStringAsFixed(2);
      });
    } else {
      setState(() {
        rating = '0.00';
      });
    }
    if (data.containsKey('sosCount')) {
      setState(() {
        sosCount = data['sosCount'].toString();
      });
    }
    if (data.containsKey('groupCount')) {
      setState(() {
        groupCount = data['groupCount'].toString();
      });
    }
    if (data.containsKey('overallAmount') && data['overallAmount'] != null) {
      setState(() {
        overallAmount = data['overallAmount'].toString();
      });
    } else {
      setState(() {
        overallAmount = '0.00';
      });
    }
  }

  Future<void> getAllPostsofMe() async {
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
    request.body = json.encode({"user_id": widget.myId});
    print(request.body);

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

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

  Post mapToPost(Map<String, dynamic> data) {
    return Post(
      postId: data['Post'],
      likes: data['Likes'],
      comments: List<String>.from(data['Comments']),
      shares: data['Shares'],
    );
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
    final double screenHeight = MediaQuery.of(context).size.height;

    final double fontSize = screenWidth * 0.025;
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [
                    Color.fromRGBO(216, 6, 163, 1),
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
          title: Text('My Profile'.tr(),
              style: GoogleFonts.montserrat(
                  color: const Color.fromRGBO(25, 41, 92, 1),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(33.5),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        '${imagespath.baseUrl}$profileImg'),
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
                                      shortenLocation('$firstname', 10),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.62.sp,
                                        color: const Color(0xFFD80683),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Text(
                                      shortenLocation('$location', 10),
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
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (context) => const Profile(),
                                  ),
                                )
                                    .then((value) {
                                  _loadProfileID();
                                });
                              },
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    colors: [
                                      Color.fromRGBO(99, 7, 114, 1),
                                      Color.fromRGBO(216, 6, 131, 1),
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
                                      color:
                                          const Color.fromRGBO(99, 1, 114, 0.8),
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.navigate_next,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                      overlayColor:
                                          MaterialStateColor.resolveWith(
                                              (states) =>
                                                  Colors.pink.withOpacity(0.4)),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return DisplayPosts(
                                                postId: widget.myId);
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                        '${postsData.length}\n ${"Posts".tr()} ',
                                        textAlign: TextAlign.center,
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
                                            return Connections(
                                                userid: widget.myId);
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                        '$connection\n  ${"Connection".tr()}',
                                        textAlign: TextAlign.center,
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
                              Visibility(
                                visible: isWeShareOn == true,
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
                                                (states) => Colors.pink
                                                    .withOpacity(0.4)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => WeShare()),
                                        );
                                      },
                                      child: Text(
                                          '${overallAmount.toString().length > 2 ? overallAmount.toString().replaceRange(overallAmount.toString().length - 2, overallAmount.toString().length, "") : overallAmount.toString()} INR \n ${"We Share".tr()}',
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
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
                                                (states) => Colors.pink
                                                    .withOpacity(0.4)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return const Option3Content();
                                            },
                                          ),
                                        );
                                      },
                                      child: Text(
                                          '$sosCount\nSOS ${"Completed".tr()}',
                                          textAlign: TextAlign.center,
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
                                                (states) => Colors.pink
                                                    .withOpacity(0.4)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return GetRatingScreen(
                                                userId: widget.myId,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Text(
                                        '$rating \n ${"Reviews".tr()}',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: fontSize,
                                          color: const Color.fromRGBO(
                                              24, 25, 31, 1),
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
                                    color: const Color.fromARGB(
                                        255, 241, 228, 239),
                                    child: TextButton(
                                      style: ButtonStyle(
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.pink
                                                    .withOpacity(0.4)),
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                          '$groupCount \n ${"My Groups".tr()}',
                                          textAlign: TextAlign.center,
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
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10.h),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Posts'.tr(),
                            style: GoogleFonts.poppins(
                                fontSize: 14.48,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(0, 0, 0, 1),
                                height: 2.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      postsData.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 16.h), // Add some spacing
                                Text(
                                   'No photos uploaded'.tr(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromRGBO(0, 0, 0, 1),
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
                                              postId: widget.myId)),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: post != null && post['Post'] != null
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
                                        : SizedBox(),
                                  ),
                                );
                              },
                            )
                    ],
                  ),
                ),
        ));
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
