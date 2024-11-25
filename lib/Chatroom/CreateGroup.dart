import 'dart:async';
import 'dart:convert';

import 'package:Shepower/Otherprofile/New_Group.dart';
import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:http/http.dart' as http;

class CreateGroup extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<CreateGroup> {
  String id = '';
  List<Map<String, dynamic>> _profilesData = [];
  List<String> selectedIds = [];
  @override
  void initState() {
    super.initState();
    GetallProfiles();
    getStoredParameters();

    final storage = FlutterSecureStorage();

    storage.read(key: '_id').then((value) {
      if (value != null) {
        setState(() {
          id = value;
        });
      }
    });
  }

  void onTilePressed(String profileId) {
    // Check if the ID is already selected
    if (selectedIds.contains(profileId)) {
      // If selected, remove it from the array
      setState(() {
        selectedIds.remove(profileId);
      });
    } else {
      // If not selected, add it to the array
      setState(() {
        selectedIds.add(profileId);
      });
    }

    // Force a rebuild of the UI to reflect the change in selection

    // Print or use the selected IDs array as needed
    print("Selected IDs: $selectedIds");
  }

  Future<Map<String, String?>> getStoredParameters() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    print('CreateGroup$id');

    return {
      'id': id,
    };
  }

  Future<void> GetallProfiles() async {
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
      "_id": id,
    });
    print('ididid$id');
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      Map<String, dynamic> apiResponse = json.decode(responseBody);

      List<Map<String, dynamic>> profiles =
          (apiResponse['result']['connections'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      print('profilesprofiles2$profiles');
      setState(() {
        _profilesData = profiles;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  void showApiErrorDialog(BuildContext context, String title, String message) {
    // String message = "An error occurred.";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> CreateGroup() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    print('creategrp..$id,,$accesstoken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}creategroup'));

    request.body = json.encode({"user_id": id, "joining_group": selectedIds});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();
    print('creategrp1..$responseBody');
    final data = json.decode(responseBody);
    print('creategroup.......$data');
    if (response.statusCode == 200) {
      if (data['status'] == 'Success') {
        print('group created');

        Map<String, dynamic> apiResponse = json.decode(responseBody);

        BuildContext currentContext = context;

        // Navigate to the second screen when the image is tapped.
        Navigator.pushReplacement(currentContext,
            MaterialPageRoute(builder: (context) {
          return NewGroupScreen(response: data['response']['_id']);
        }));
      } else {
        print('APImeassage....${data['message']}');
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        elevation: 0,
        toolbarHeight: 124.h,
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
                                color: const Color.fromRGBO(255, 255, 255, 1),
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
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create Group1',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: Color.fromRGBO(25, 41, 91, 1))),
                          Text('Add Participants',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.sp,
                                  color: Color.fromRGBO(25, 41, 92, 1))),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.group_add, // You can use the appropriate icon
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // Add your logic here to create a group with selectedIds
                    print("Create Group Button Pressed");
                    print("Selected IDs: $selectedIds");
                    if (selectedIds.length > 0) {
                      CreateGroup();
                    }

                    // Add your logic to create a group with selectedIds
                  },
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: 317.w,
                height: 50.h,
                decoration: BoxDecoration(
                  border: GradientBoxBorder(
                    gradient: const LinearGradient(colors: [
                      Color.fromRGBO(254, 143, 210, 1),
                      Color.fromRGBO(99, 7, 114, 1),
                    ]),
                    width: 1.w,
                  ),
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextFormField(
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'search your connection here',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(13.0),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                    ),
                    // Add your search functionality here
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _profilesData.length,
              itemBuilder: (context, index) {
                final messageId = _profilesData[index]['_id'];
                final isSelected = selectedIds.contains(messageId);
                return InkWell(
                 
                  onTap: () {
                    if (isSelected) {
                      selectedIds.remove(messageId);
                    } else {
                      selectedIds.add(messageId);
                    }
                    print('selectedIds: $selectedIds');
                    setState(() {});
                  },
                  child: Container(
                    color: isSelected ? Colors.grey.withOpacity(0.5) : null,
                    child: ListTile(
                      selected:
                          selectedIds.contains(_profilesData[index]['_id']),
                      tileColor:
                          selectedIds.contains(_profilesData[index]['_id'])
                              ? Colors.grey.withOpacity(0.5)
                              : null,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          '${imagespath.baseUrl}${_profilesData[index]['profile_img']}',
                          width: 49.w,
                          height: 49.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        '${_profilesData[index]['firstname']}',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
