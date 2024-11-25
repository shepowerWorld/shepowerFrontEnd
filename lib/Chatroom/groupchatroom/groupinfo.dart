import 'dart:convert';
import 'dart:io';
import 'package:Shepower/Chatroom/Models/create_group.model.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/services/chatservice.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class GroupInfoScreen extends StatefulWidget {
  final String? groupId;
  final String? otherId;
  final String? roomId;
  final bool? groupBoolina;

  const GroupInfoScreen(
      {Key? key,
      required this.groupId,
      required this.otherId,
      required this.roomId,
      required this.groupBoolina})
      : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final chatService = ChatService();
  final storage = const FlutterSecureStorage();
  CreateGroupModel? group;
  CreateGroupModel? otherId;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  TextEditingController _groupNameController = TextEditingController();
  bool iamAdmin = false;
  String myId = '';
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    String? id = await storage.read(key: '_id');

    CreateGroupModel? image = await chatService.viewGroupInfo(widget.groupId);
    print('viewinfoooo....${image!.adminId!.sId}');

    setState(() {
      group = image;
    });
    if (image.adminId!.sId == id) {
      setState(() {
        iamAdmin = true;
      });
    }

    if (id != null) {
      setState(() {
        myId = id;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(
      source: source,
    );

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });

      // Call the update API when an image is picked
      await _updateGroup();
    }
  }

  Future<void> _updateGroup() async {
    if (_image != null) {
      String imagePath = _image!.path;
      String groupId = widget.groupId ?? '';
      String groupName = group?.groupName ?? '';
      String groupAbout = group?.groupabout ?? '';

      // Call the updateGroup API with the selected image
      CreateGroupModel? updatedGroup = await ChatService().updateGroup(
        imagePath,
        groupName,
        groupId,
        groupAbout,
      );

      print('updatedGroupImg.....$updatedGroup');

      if (updatedGroup != null) {
        setState(() {
          group = updatedGroup;
        });
        print('Successfully updated group with image!');
        // Show success dialog
        _showDialog('Image Update', 'update sucessfully');
      } else {
        print('Failed to update group with image.');
        // Show error dialog
        _showDialog('Image Update', 'Failed to update group with image.');
      }
    }
  }

  Future<void> _updateGroupName() async {
    String groupId = widget.groupId ?? '';
    String groupName = _groupNameController.text;
    // print('groupId,groupName...$groupId.... $groupName');

    // Call the updateGroup API with the selected image
    CreateGroupModel? updateprofilegroup =
        await ChatService().updateProfilegroup(groupId, groupName);
    print('updatedGroupName...$updateprofilegroup');

    init();
    setState(() {
      _groupNameController.clear();
    });
  }

  Future<void> deleteGroup() async {
    print('myidingroupinfo..$myId and roomid..${widget.groupId}');
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('DELETE',
        Uri.parse('${ApiConfig.baseUrl}deleteroom/${widget.groupId}'));
    request.body = json.encode({"admin_id": myId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print('deleteroom...${await response.stream.bytesToString()}');
    if (response.statusCode == 200) {
      _showExitDialog('Successfully deleted the group!');
      print('Successfully deleted the group!');
    } else {
      print(response.reasonPhrase);
      _showExitDialog('Failed to delete the group. Please try again.');
      print('Failed to delete the group.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  onTapImage() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showExitDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exit Group'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 1000,
          width: double.maxFinite,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Change Group Name",
                style: TextStyle(
                  fontFamily: 'Akzidenz-Grotesk BQ',
                  fontWeight: FontWeight.w500,
                  fontSize: 12.0,
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _groupNameController,
                maxLines: 1,
                maxLength: 25,
                decoration: InputDecoration(
                  labelText: "Type Here",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        // Handle submission here
                        _updateGroupName();
                        // print("Reason: ${_groupNameController.text}");
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back navigation here
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        body: ListView(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.maxFinite,
                      height: 350,
                      child: Card(
                        elevation: 5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    _image != null
                                        ? GestureDetector(
                                            onTap: () {
                                              onTapImage();
                                            },
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  FileImage(File(_image!.path)),
                                              radius: 120,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              onTapImage();
                                            },
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                '${imagespath.baseUrl}${group?.groupProfileImg}',
                                              ),
                                              radius: 120,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    group?.groupName ?? ' ',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    width: 15.h,
                                  ),
                                  GestureDetector(
                                    onTap: () => _openModal(context),
                                    child: Image.asset(
                                      'assets/profile/edit.png',
                                      fit: BoxFit.contain,
                                      height: 25,
                                      width: 25,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                    Container(
                      height: 70,
                      width: 400,
                      child: Card(
                        elevation: 40,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                bool exitSuccess =
                                    await ChatService().exitGroup(
                                  widget.otherId,
                                  widget.groupId,
                                );

                                if (exitSuccess) {
                                  _showExitDialog(
                                      'Successfully exited the group!');
                                  print('Successfully exited the group!');
                                } else {
                                  _showExitDialog(
                                      'Failed to exit the group. Please try again.');
                                  print('Failed to exit the group.');
                                }
                              },
                              icon: Icon(
                                Icons.exit_to_app,
                                size: 30.0,
                                color: Colors.red,
                              ),
                              label: Text(
                                'Exit Group',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Set background color to transparent
                                elevation: 0, // Remove shadow
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.w,
                    ),
                    Visibility(
                      visible: iamAdmin,
                      child: Container(
                        height: 70,
                        width: 400,
                        child: Card(
                          elevation: 40,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  deleteGroup();
                                },
                                icon:const Icon(
                                  Icons.exit_to_app,
                                  size: 30.0,
                                  color: Colors.red,
                                ),
                                label:const Text(
                                  'Delete Group',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Set background color to transparent
                                  elevation: 0, // Remove shadow
                                ),
                              ),
                            ),
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
    );
  }
}
