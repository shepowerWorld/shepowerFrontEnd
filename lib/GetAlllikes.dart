import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class getalllikes extends StatefulWidget {
  final String postId;

  const getalllikes({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<getalllikes> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<getalllikes> {
  List<Map<String, dynamic>> likedPersons = [];

  @override
  void initState() {
    super.initState();
    getLikesOfPost();
  }

  Future<void> getLikesOfPost() async {
    const storage = FlutterSecureStorage();

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getLikesOfPost'));
    request.body = json.encode({"post_id": widget.postId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseBody);
      List<dynamic> likes = responseData['response']['likesofposts'];

      // Extract liked persons' data
      List<Map<String, dynamic>> likedPersonsData = [];
      for (var like in likes) {
        likedPersonsData.add({
          'firstname': like['firstname'],
          'profile_img': like['profile_img'],
        });
      }

      setState(() {
        likedPersons = likedPersonsData;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GetAll Likes',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        // Add a leading widget for the back button
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            // Navigate back to the previous screen
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: likedPersons.length,
        itemBuilder: (BuildContext context, int index) {
          final likedPerson = likedPersons[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                '${imagespath.baseUrl}${likedPerson['profile_img']}',
              ),
            ),
            title: Text(
              likedPerson['firstname'],
              style: TextStyle(color: Colors.black),
            ),
          );
        },
      ),
    );
  }
}
