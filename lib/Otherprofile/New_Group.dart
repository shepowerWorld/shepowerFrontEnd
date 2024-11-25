import 'dart:convert';
import 'dart:io';

import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../Chatroom/GroupChatRoom.dart';

class NewGroupScreen extends StatefulWidget {
  final String response;

  NewGroupScreen({required this.response});

  @override
  _NewGroupScreenState createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  late Future<void> _groupDataFuture;
  File? PickimagePath;
  var messages;
  String profileimg = '';
  TextEditingController Groupname = TextEditingController();
  String myId = '';
  bool groupBoolina = true;
  String roomId = '';

  @override
  void initState() {
    super.initState();
    _groupDataFuture = getAllGroups();
  }

  Future<void> getAllGroups() async {
 final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}viewgroupinfo'));
    request.body = json.encode({"_id": widget.response});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      final storage = const FlutterSecureStorage();
      String? id = await storage.read(key: '_id');

      Map<String, dynamic> apiResponse = data;

      messages = apiResponse['response'];

      setState(() {
        myId = apiResponse['response']['admin_id']['_id'];
        roomId = apiResponse['response']['room_id'];
      });

      print('messages: $messages');
    } else {
      print(response.reasonPhrase);
    }
  }

  showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Group Creator',
            style: TextStyle(
              color: Colors.pink,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Your group has been created successfully.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(
                  // Navigate to the chat screen
                  MaterialPageRoute(
                    builder: (context) {
                      return GroupChatRoom(
                        groupId: widget.response,
                        otherId: myId,
                        roomId: roomId,
                        groupBoolina: groupBoolina,
                      );
                    },
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF630772), Color(0xFFE441A3)],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  showErrorAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Message"),
            content: const Text("Please select image"),
            actions: [TextButton(onPressed: () {}, child: const Text("OK"))],
          );
        });
  }

  Future<void> updateGroup(pickedFile, BuildContext context) async {
     final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

   
    try {
      if (pickedFile == null) {
        // Show a dialog indicating that the user needs to select an image
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Image not selected'),
              content: const Text(
                  'Please select an image before creating the group.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
      var headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken'
          };
      var request = http.MultipartRequest(
          'PUT', Uri.parse('${ApiConfig.baseUrl}updategroupimage'));
      request.fields.addAll({
        'groupName': Groupname.text,
        '_id': widget.response,
        'Groupabout': ''
      });
      request.files
          .add(await http.MultipartFile.fromPath('profile_img', pickedFile));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final responseJson = jsonDecode(responseString);
        print('updategroupimage.........................$responseJson');
        final storage = const FlutterSecureStorage();
        await storage.write(key: 'groupId', value: widget.response);
        socket.emit('joinRoom', responseJson['result']['room_id']);
        showAlert();
      } else {
        print('Update failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating group: $error');
    }
  }

  // Future<void> updateGroup(File pickedFile) async {
  //   try {
  //     var request = http.MultipartRequest(
  //         'PUT', Uri.parse('${ApiConfig.baseUrl}updategroupimage'));
  //     request.fields.addAll({
  //       'groupName': Groupname.text,
  //       '_id': widget.response,
  //       'Groupabout': ''
  //     });
  //     request.files.add(
  //         await http.MultipartFile.fromPath('profile_img', pickedFile.path));

  //     http.StreamedResponse response = await request.send();

  //     if (response.statusCode == 200) {
  //       // print(await response.stream.bytesToString());
  //       final responseString = await response.stream.bytesToString();
  //       final responseJson = jsonDecode(responseString);
  //       // If the update is successful, show a pop-up modal.
  //       print('updategroupimage.........................$responseJson');
  //       final storage = const FlutterSecureStorage();
  //       await storage.write(key: 'groupId', value: widget.response);
  //       socket.emit('joinRoom', responseJson['result']['room_id']);
  //       // ignore: use_build_context_synchronously
  //       showAlert();
  //     } else {
  //       print('Update failed with status code: ${response.statusCode}');
  //       // print('Response body: ${response.body}');
  //       // Handle the error or show a message to the user.
  //     }
  //   } catch (error) {
  //     print('Error updating group: $error');
  //     // Handle the error or show a message to the user.
  //   }
  // }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      profileimg = pickedFile!.path;
      PickimagePath = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          'New Groups',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(
              0xFFD80683,
            ),
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _groupDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading data'),
            );
          } else {
            return buildGroupDataWidget();
          }
        },
      ),
    );
  }

  Widget buildGroupDataWidget() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                        onTap: pickImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(67),
                          child: PickimagePath == null
                              ? Container(
                                  width: 70,
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF630772),
                                        Color(0xFFE441A3)
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor: Colors
                                      .transparent, // Make the CircleAvatar background transparent
                                  child: Image.file(
                                    File(profileimg),
                                    alignment: Alignment.center,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Enter group name Here',
                          border: UnderlineInputBorder(),
                        ),
                        controller: Groupname, // Use the controller here
                        keyboardType: TextInputType.text,
                        cursorColor: const Color.fromARGB(162, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Participants',
                      style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    for (var participant in messages['joining_group'])
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              '${imagespath.baseUrl}${participant['profile_img']}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(participant['firstname']),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 300,
          child: ElevatedButton(
            onPressed: () {
              updateGroup(PickimagePath?.path, context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Colors.transparent,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(99, 7, 114, 0.8),
                    Color.fromRGBO(228, 65, 163, 0.849),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 300,
                  minHeight: 50,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Create Group',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
