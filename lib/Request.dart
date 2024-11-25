import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ConnectionRequest {
  final String firstname;
  final String location;
  final String profileImg;
  final String userid;

  ConnectionRequest({
    required this.firstname,
    required this.location,
    required this.profileImg,
    required this.userid,
  });
}

class Connections extends StatefulWidget {
  final String userid;
  Connections({Key? key, required this.userid}) : super(key: key);

  @override
  State<Connections> createState() => _ConnectionState();
}

class _ConnectionState extends State<Connections> {
  List<ConnectionRequest> requests = [];

  String myId = '';

  @override
  void initState() {
    super.initState();
    fetchRequests();
    _loadProfileID();
  }

  Future<void> _loadProfileID() async {
    final profileData = await GetMyProfile();
    setState(() {
      myId = profileData['myId'];
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
        'GET', Uri.parse('${ApiConfig.baseUrl}getMyprofile/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      String myId = data['result']['_id'];
      return {
        'myId': myId,
      };
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<void> fetchRequests() async {
    const storage = FlutterSecureStorage();

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getConnections'));
    request.body = json.encode({"_id": widget.userid});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();

      final data = json.decode(responseBody);
      final connectionRequests = data['result']['connections'];

      print('connections$connectionRequests');

      setState(() {
        requests = connectionRequests.map<ConnectionRequest>((requestData) {
          return ConnectionRequest(
            firstname: requestData['firstname'] ?? '',
            location: requestData['location'] ?? '',
            profileImg: requestData['profile_img'] ?? '',
            userid: requestData['_id'] ?? '',
          );
        }).toList();
      });
    } else {
      print('Failed to fetch connection requests');
    }
  }

  void removeConnection(String userId) async {
    final storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');
    String? id = await storage.read(key: '_id');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}disconnectUsers'));
    request.body = json.encode({"fromUser": id, "toUser": userId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print("removeConnection${await response.stream.bytesToString()}");
      setState(() {
        requests.removeWhere((element) => element.userid == userId);
      });
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
          'Connection'.tr(),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: requests.isEmpty
          ? const Center(
              child: Text("No connection requests available."),
            )
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey[100]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      '${imagespath.baseUrl}${request.profileImg}',
                                    ),
                                    radius: 30,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 19),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            request.firstname,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                        ])),
                              ]),
                          Visibility(
                            visible: myId == widget.userid,
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              height: 40,
                              width: 100,
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
                              child: TextButton(
                                  onPressed: () {
                                    removeConnection(request.userid);
                                  },
                                  child: const Text(
                                    "remove",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      )),
                );
              },
            ),
    );
  }
}


  // Card(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(
  //                       16.0), // Adjust the radius as needed
  //                 ),
  //                 elevation: 10.0,
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(10.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           GestureDetector(
  //                             onTap: () async {
  //                               final myId = await CacheService.getUserId();
  //                               if (myId == null) return;
  //                               Navigator.of(context).pushReplacement(
  //                                 MaterialPageRoute(
  //                                   builder: (context) => Otherprofile(
  //                                     userId: request.userid,
  //                                     myId: myId,
  //                                   ),
  //                                 ),
  //                               );
  //                             },
  //                             child: CircleAvatar(
  //                               backgroundImage: NetworkImage(
  //                                 '${imagespath.baseUrl}${request.profileImg}',
  //                               ),
  //                               radius:30,
  //                             ),
  //                           ),
  //                           SizedBox(width: 10,),
  //                           Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 request.firstname,
  //                                 style: const TextStyle(
  //                                   fontSize: 20,
  //                                   fontWeight: FontWeight.w600,
  //                                 ),
  //                               ),
  //                               Text(
  //                                 request.location,
  //                                 style: const TextStyle(
  //                                   fontSize: 16,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
                       
  //                     ],
  //                   ),
  //                 ),
  //               );

  //  void acceptRequest(String userId) async {
  //   final storage = FlutterSecureStorage();

  //   String? id = await storage.read(key: '_id');
  //   var headers = {'Content-Type': 'application/json'};
  //   var request =
  //       http.Request('POST', Uri.parse('${ApiConfig.baseUrl}acceptRequest'));
  //   request.body = json.encode({"fromUser": id, "toUser": userId});

  //   request.headers.addAll(headers);

  //   http.StreamedResponse response = await request.send();
  //   print(await response.stream.bytesToString());

  //   if (response.statusCode == 200) {
  //     print(await response.stream.bytesToString());
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }
