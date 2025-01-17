import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shepower/Otherprofile/OtherProfile.dart';
import 'package:Shepower/service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'groupchatroom/groupinfo.dart';

class ChatScreen1 extends StatefulWidget {
  final String? userId;
  final String? Roomid;
  final bool? GroupBoolina;

  ChatScreen1(
      {required this.userId, required this.Roomid, required this.GroupBoolina});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen1> {
  final TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  String profileID = '';
  String profileImg = '';
  String location = '';
  String myId = '';
  String firstname = '';
  String groupname = '';
  String groupImg = "";
  String groupId = "";
  Map<String, dynamic> profileData = {};
  String? id;
  File? selectedFile;
  List<PlatformFile> selectedFiles = [];
  String fileName = '';
  String path = '';
  String roomId = '';

  @override
  void initState() {
    super.initState();
    init();

    Future(() {
      init();
      print('High Priority Task');
      connectToServer();
      // Perform high priority tasks here
    });

    getMyId();
    print("Statementtt ${widget.GroupBoolina == false}");

    _loadProfileID();
    if (widget.GroupBoolina == false) {
      getOtherprofile();
    } else {
      getGroupData();
    }
    print("group: ${groupname.isEmpty}");
    print('RRRRRRR ${profileData['firstname']}');
  }

  init() async {
    try {
      await getmessage();
      await getOtherprofile();
      await getGroupData();
    } catch (e) {
    } finally {}
  }

  Future<void> getGroupData() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}viewgroupinfo'));
    request.body = json.encode({"_id": widget.userId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      print('responseBody data111: $data');

      String profileImg = data['response']['group_profile_img'];
      String firstname = data['response']['groupName'];
      String gId = data['response']['_id'];
      String roomId = data['response']['room_id'];
      print('profileImgprofileImg$profileImg');
      print('firstnamefirstname$firstname');
      print('groupIdoooooo $gId');

      setState(() {
        groupImg = profileImg;
        groupname = firstname;
        groupId = gId;
        roomId = roomId;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> getMyId() async {
    final storage = FlutterSecureStorage();
    id = await storage.read(key: '_id');
  }

  void connectToServer() async {
    print('Connecting to the server${socket}');

    // Assuming you have initialized the `socket` object somewhere in your code

    socket.onError((error) {
      final IO.Socket socket = IO.io(
        '${ApiConfig.socket}',
        IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders(
            {'foo': 'bar'}).build(),
      );

      print("Socket error: $error");
      // Handle socket errors, such as timeouts
      if (error.toString().contains('Timeout')) {
        // Perform any necessary actions, like reconnecting
        // You may also want to display a message to the user
        // indicating the connection issue.
      }
    });

    socket.on('messageSend', (data) {
      // Check if the widget is still mounted
      if (!mounted) return;

      print('$messages');
      print('messagesnowalraedy$data');
      final arrays = {
        "sender_id": data['sender_id'],
        "senderName": data['senderName'],
        "message": data['message'],
        "room_id": data['room_id'],
        "_id": data['_id'],
        "attachment": data['attachment'],
        "createdAt": data['createdAt'],
        "updatedAt": data['updatedAt'],
      };

      // Check if the widget is still mounted before calling setState
      if (mounted)
        setState(() {
          messages.add(arrays);
        });
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });

    socket.onConnect((data) {
      print("Connected");
      socket.on("online message1", (msg) {
        print(msg);
      });
    });

    socket.onDisconnect((_) {
      print("Socket disconnected");
      // Handle disconnection, perform any necessary actions
    });

    socket.on('online message1', (data) {
      print("Connected: $data");
    });

    // Only one connection is needed
    socket.connect();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadProfileID() async {
    final profile = await GetProfileProfile();
    print('profileData: $profile');
    if (mounted) if (mounted)
      setState(() {
        profileImg = profile['profileImg'];
        profileID = profile['profileID'];
        location = profile['location'];
        myId = profile['myId'];
        firstname = profile['firstname'];

        print('firstname: $firstname');
      });
  }

  Future<Map<String, dynamic>> GetProfileProfile() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
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
      String firstname = data['result']['firstname'];

      print('Profile ID: $profileID');
      print('Location: $location');
      print('My ID: $myId');

      // Return the data as a Map
      return {
        'profileID': profileID,
        'profileImg': profileImg,
        'location': location,
        'myId': myId,
        'firstname': firstname
      };
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<void> getOtherprofile() async {
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
      final data = json.decode(responseBody)['result'];
      print('www---$data');
      if (mounted)
        setState(() {
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
            'weShare': data['weShare'].toString(),
            'connected': data['connected'],
            'languages': data['languages'].join(', '),
          };
          print("fffff ${profileData}");
        });
      print('profileData$profileData');
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<void> _handleSubmitted(String chat) async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}storeMessage'));
    request.body = json.encode({
      "sender_id": id,
      "room_id": widget.Roomid,
      "senderName": firstname,
      "msg": chat,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String message = await response.stream.bytesToString();
      final responseData = json.decode(message);
      print('messagemessage${responseData['results']}');

      final resposed = responseData['result'] != null
          ? responseData['result']
          : responseData['results'];
      socket.emit('message', resposed);

      print(message);

      if (mounted)
        setState(() {
          _textController.clear();
        });
      _scrollToBottom();
      // FocusScope.of(context).unfocus();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> getmessage() async {
    const storage = FlutterSecureStorage();
    String? _id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request = http.Request(
        'GET', Uri.parse('${ApiConfig.baseUrl}getmessage/${widget.Roomid}'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final responseData = json.decode(responseString);
      final messagesData = responseData['result'];

      if (mounted)
        setState(() {
          messages = List<Map<String, dynamic>>.from(messagesData);
        });
    } else {
      print(response.reasonPhrase);
    }
  }

  Set<String> selectedMessageIds = Set<String>();

  void deleteSelectedMessages() async {
    if (selectedMessageIds.isEmpty) {
      return;
    }

    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('DELETE', Uri.parse('${ApiConfig.baseUrl}deleteMesage'));
    request.body = json.encode({
      "_id": selectedMessageIds.toList(),
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      // Remove the selected messages from the local messages list
      if (mounted)
        setState(() {
          messages.removeWhere(
              (message) => selectedMessageIds.contains(message['_id']));
        });
      // Clear the selected messages set
      selectedMessageIds.clear();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> clearChat() async {
    const storage = FlutterSecureStorage();
    String? _id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'DELETE', Uri.parse('${ApiConfig.baseUrl}clearChat/${widget.Roomid}'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      if (mounted)
        setState(() {
          messages = [];
        });
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> sendImage(File image) async {
    const storage = FlutterSecureStorage();
    String? _id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${ApiConfig.baseUrl}sendAttachment'));
    request.fields.addAll({
      'room_id': widget.Roomid ?? "",
      'senderName': firstname,
      'sender_id': myId
    });
    request.files.add(await http.MultipartFile.fromPath(
      'attachment',
      image.path,
      contentType: MediaType('image', 'png'),
    ));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final responseJson = json.decode(responseString);
      print('sendAttachment........${responseJson}');

      // // Emit the attachment immediately
      socket.emit('message', responseJson['result'][0]);

      if (mounted)
        setState(() {
          _textController.clear();
        });
      _scrollToBottom();
      FocusScope.of(context).unfocus();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> sendDocument() async {
    const storage = FlutterSecureStorage();
    String? _id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${ApiConfig.baseUrl}sendAttachment'));
    request.fields.addAll({
      'room_id': widget.Roomid ?? "",
      'senderName': firstname,
      'sender_id': myId
    });
    request.files.add(await http.MultipartFile.fromPath(
      'attachment',
      path,
      filename: fileName,
      contentType: MediaType('application', 'pdf'),
    ));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final responseJson = json.decode(responseString);
      print('sendAttachment........${responseJson}');

      // Emit the attachment immediately
      socket.emit('message', responseJson['result'][0]);
      if (mounted)
        setState(() {
          _textController.clear();
        });
      _scrollToBottom();
      FocusScope.of(context).unfocus();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> _showDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Images'),
                  ),
                  onTap: () async {
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        selectedFile = File(pickedFile.path);
                      });
                    }
                    Navigator.of(context).pop();
                    _showMediaAndChatBottomSheet(context);
                  },
                ),
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.insert_drive_file),
                    title: Text('Document'),
                  ),
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        selectedFile = File(result.files.single.path ?? "");
                        fileName = selectedFile!.path.split('/').last;
                        path = selectedFile!.path;
                      });
                    }
                    Navigator.of(context).pop();
                    _showDocumentBottomSheet(context);
                    // sendDocument();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMediaAndChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      // Display the modal as a full-screen sheet
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height -
              20, // Adjust the height as needed
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: [
              const Center(
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                  size: 50,
                ),
              ),
              Expanded(
                child: SelectedMediaWidget(
                    image: selectedFile, files: selectedFiles),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Expanded(
                    //   child: TextField(
                    //     controller: _textController,
                    //     decoration: InputDecoration(
                    //       hintText: 'Type mention...',
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(30.0),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      width: 12.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await sendImage(selectedFile!);

                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDocumentBottomSheet(BuildContext context) {
    final Completer<PDFViewController> _controller =
        Completer<PDFViewController>();
    int? pages = 0;
    int? currentPage = 0;
    bool isReady = false;
    String errorMessage = '';
    showModalBottomSheet(
      isScrollControlled: true,
      // Display the modal as a full-screen sheet
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height -
              20, // Adjust the height as needed
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: [
              const Center(
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                  size: 50,
                ),
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    PDFView(
                      filePath: path,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: true,
                      pageSnap: true,
                      defaultPage: currentPage!,
                      fitPolicy: FitPolicy.BOTH,
                      preventLinkNavigation:
                          false, // if set to true the link is handled in flutter
                      onRender: (_pages) {
                        setState(() {
                          pages = _pages;
                          isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          errorMessage = error.toString();
                        });
                        print(error.toString());
                      },
                      onPageError: (page, error) {
                        setState(() {
                          errorMessage = '$page: ${error.toString()}';
                        });
                        print('$page: ${error.toString()}');
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        _controller.complete(pdfViewController);
                      },
                      onLinkHandler: (String? uri) {
                        print('goto uri: $uri');
                      },
                      onPageChanged: (int? page, int? total) {
                        print('page change: $page/$total');
                        setState(() {
                          currentPage = page;
                        });
                      },
                    ),
                    errorMessage.isEmpty
                        ? !isReady
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container()
                        : Center(
                            child: Text(errorMessage),
                          )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Expanded(
                    //   child: TextField(
                    //     controller: _textController,
                    //     decoration: InputDecoration(
                    //       hintText: 'Type mention...',
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(30.0),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      width: 12.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await sendDocument();

                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void naviation() {
    socket.emit('leaveRoom', widget.Roomid);
    print('leaveRoomleaveRoom');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        naviation();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          leading: IconButton(
            icon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [
                    Color.fromRGBO(216, 6, 131, 1),
                    Color.fromRGBO(99, 7, 114, 1)
                  ],
                ).createShader(bounds);
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    width: 1.w,
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
              naviation();
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to the group info screen when the profile image is clicked
                  groupname.isEmpty
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Otherprofile(
                              userId: widget.userId!,
                              myId: myId,
                            ),
                          ),
                        )
                      : Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GroupInfoScreen(
                                groupId: groupId,
                                otherId: myId,
                                roomId: widget.Roomid,
                                groupBoolina: widget.GroupBoolina),
                          ),
                        );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      groupname.isEmpty
                          ? '${imagespath.baseUrl}${profileData['profileImg']}'
                          : '${imagespath.baseUrl}${groupImg}',
                    ),
                    radius: 16.r,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                  groupname.isEmpty
                      ? '${profileData['firstname'] ?? ''}'
                      : groupname ?? '',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 17.28.sp,
                    color: const Color.fromRGBO(0, 0, 0, 1),
                  )),
            ],
          ),
          actions: <Widget>[
            Visibility(
              visible: selectedMessageIds.isNotEmpty,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
                onPressed: () {
                  deleteSelectedMessages();
                },
              ),
            ),
            if (widget.GroupBoolina == false)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
                onSelected: (String choice) async {
                  if (choice == 'clearChat') {
                    try {
                      await clearChat();
                    } catch (error) {
                      print("Error clearing chat: $error");
                    }
                  } else if (choice == 'more') {
                    // Handle other options
                  } else if (choice == 'exportChat') {
                    // Handle other options
                  } else if (choice == 'hhhhhh') {
                    // Handle other options
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'clearChat',
                    child: Text('Clear Chat'),
                  ),
                  // const PopupMenuItem<String>(
                  //   value: 'more',
                  //   child: Text('More ...'),
                  // ),
                  const PopupMenuItem<String>(
                    value: 'exportChat',
                    child: Text('Export Chat'),
                  ),
                  // const PopupMenuItem<String>(
                  //   value: 'hhhhhh',
                  //   child: Text('hhhhhh'),
                  // ),
                ],
              ),
            if (widget.GroupBoolina == true)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
                onSelected: (String choice) async {
                  if (choice == 'clearChat') {
                    try {
                      await clearChat();
                    } catch (error) {
                      print("Error clearing chat: $error");
                    }
                  } else if (choice == 'more') {
                    // Handle other options
                  } else if (choice == 'Group Info') {
                    // Navigate to GroupInfoScreen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GroupInfoScreen(
                            groupId: groupId,
                            otherId: myId,
                            roomId: widget.Roomid,
                            groupBoolina: widget.GroupBoolina),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'clearChat',
                    child: Text('Clear Chat'),
                  ),
                  // const PopupMenuItem<String>(
                  //   value: 'more',
                  //   child: Text('More ...'),
                  // ),
                  const PopupMenuItem<String>(
                    value: 'Group Info',
                    child: Text('Group Info'),
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final messageId = message['_id'];

                  return MessageBubble(
                    message: message['message'] ?? '',
                    attachment: message['attachment'] ?? '',
                    isMyMessage: message['sender_id'] == id,
                    selected: selectedMessageIds.contains(messageId),
                    onLongPress: () {
                      final messageId = message['_id'];
                      if (messageId != null) {
                        if (selectedMessageIds.isEmpty) {
                          // If no messages are selected, select the current message on long-press
                          selectedMessageIds.add(messageId);
                          setState(
                              () {}); // Update the UI to reflect the selection
                        }
                      }
                    },
                    onTap: () {
                      final messageId = message['_id'];
                      if (messageId != null) {
                        if (selectedMessageIds.contains(messageId)) {
                          // If the message is already selected, unselect it
                          selectedMessageIds.remove(messageId);
                        } else {
                          // If the message is not selected, select it
                          selectedMessageIds.add(messageId);
                        }
                        setState(
                            () {}); // Update the UI to reflect the selection
                      }
                    },
                  );
                },
              ),
            ),
            Container(
              width: 350.w,
              height: 47.04.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                ),
                border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.25)),
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.pink,
                    ),
                    onPressed: () {
                      _showDialog(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12.0),
                      ),
                      onSubmitted: null,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                      if (_textController.text.isNotEmpty) {
                        _handleSubmitted(_textController.text);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.send,
                        color: Colors.pink,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isMyMessage;
  final String attachment;
  final bool selected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  MessageBubble({
    required this.message,
    required this.isMyMessage,
    this.attachment = '',
    required this.selected,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();

  int? pages = 0;

  int? currentPage = 0;

  bool isReady = false;

  String errorMessage = '';

  bool isLoading = false;

  void _showDocumentBottomSheet(BuildContext context, String path) {
    final Completer<PDFViewController> _controller =
        Completer<PDFViewController>();
    int? pages = 0;
    int? currentPage = 0;
    bool isReady = false;
    String errorMessage = '';
    showModalBottomSheet(
      isScrollControlled: true,
      // Display the modal as a full-screen sheet
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height -
              20, // Adjust the height as needed
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: [
              const Center(
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                  size: 50,
                ),
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    PDFView(
                      filePath: path,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: true,
                      pageSnap: true,
                      defaultPage: currentPage!,
                      fitPolicy: FitPolicy.BOTH,
                      preventLinkNavigation:
                          false, // if set to true the link is handled in flutter
                      onRender: (_pages) {
                        setState(() {
                          pages = _pages;
                          isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          errorMessage = error.toString();
                        });
                        print(error.toString());
                      },
                      onPageError: (page, error) {
                        setState(() {
                          errorMessage = '$page: ${error.toString()}';
                        });
                        print('$page: ${error.toString()}');
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        _controller.complete(pdfViewController);
                      },
                      onLinkHandler: (String? uri) {
                        print('goto uri: $uri');
                      },
                      onPageChanged: (int? page, int? total) {
                        print('page change: $page/$total');
                        setState(() {
                          currentPage = page;
                        });
                      },
                    ),
                    errorMessage.isEmpty
                        ? !isReady
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container()
                        : Center(
                            child: Text(errorMessage),
                          )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _downloadAndDisplayPdf(BuildContext context, String pdfUrl) async {
    setState(() {
      isLoading = true;
    });
    print('pdfUrl.............$pdfUrl');
    try {
      // Create a Dio instance
      Dio dio = Dio();

      // Define the directory where you want to save the downloaded file
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String downloadPath = appDocDir.path;

      // Define the file name for the downloaded PDF
      String fileName = 'downloaded_file.pdf';

      // Define the complete file path
      String filePath = '$downloadPath/$fileName';

      // Start the download
      await dio.download(pdfUrl, filePath);

      _showDocumentBottomSheet(context, filePath);
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print('Error downloading PDF: $error');
      setState(() {
        isLoading = false;
      });
      // Handle errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
      child: Container(
        color: widget.selected
            ? Colors.grey
            : Colors.transparent, // Apply selected color to the whole container
        child: Column(
          crossAxisAlignment: widget.isMyMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    widget.isMyMessage ? Color(0xFFFFE7F5) : Color(0xFFF2F2F2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: widget.isMyMessage
                      ? Radius.circular(15)
                      : Radius.circular(0),
                  bottomRight: widget.isMyMessage
                      ? Radius.circular(0)
                      : Radius.circular(15),
                ),
              ),
              child: Text(
                widget.message,
                style: TextStyle(
                  color: widget.isMyMessage ? Colors.black : Colors.black,
                ),
              ),
            ),
            if (widget.attachment.isNotEmpty)
              Container(
                width: 203.0,
                height: 203.0,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey, // Set your desired background color here
                  borderRadius: BorderRadius.circular(18),
                ),
                child: widget.attachment.endsWith('pdf')
                    ? GestureDetector(
                        onTap: () {
                          _downloadAndDisplayPdf(context,
                              '${imagespath.baseUrl}${widget.attachment}');
                        },
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/ChatRoom/pdf.png',
                                  width: 203.0,
                                  height: 203.0,
                                  fit: BoxFit
                                      .cover, // You can choose between BoxFit.cover and BoxFit.contain
                                ),
                              ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          '${imagespath.baseUrl}${widget.attachment}',
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit
                              .cover, // You can choose between BoxFit.cover and BoxFit.contain
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class SelectedMediaWidget extends StatelessWidget {
  final File? image;
  final List<PlatformFile> files;

  SelectedMediaWidget({this.image, this.files = const []});

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Image.file(image!); // Display the selected image
    } else if (files.isNotEmpty) {
      // Display the selected documents
      return ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(files[index].name),
          );
        },
      );
    } else {
      return Container(); // Display an empty container if no media is selected
    }
  }
}
