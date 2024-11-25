import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shepower/Dashboard/Bottomnav.dart';
import 'package:Shepower/common/common_dialog.dart';
import 'package:Shepower/leneargradinent.dart';
import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CreatePostScreen extends StatefulWidget {
  final bool postData;

  const CreatePostScreen({super.key, required this.postData});

  @override
  // ignore: library_private_types_in_public_api
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _postTextController = TextEditingController();
  File? _selectedMedia;
  String profileID = '';
  String profileImg = '';
  String location = '';
  String myId = '';
  String firstname = '';
  String lastname = '';
  String postid = '';
  bool isLoading = false;
  String? isnavigation;
  bool? navigate;
  String postText = '';
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _loadProfileID();

    const fiveMinutes = const Duration(minutes: 5);
    Timer.periodic(fiveMinutes, (Timer timer) {
      _loadProfileID();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadProfileID() async {
    storage.read(key: "postnavigation").then((values) {
      setState(() {
        isnavigation = values;
      });
    });
    final profileData = await getProfile();
    setState(() {
      profileImg = profileData['profileImg'];
      profileID = profileData['profileID'];
      location = profileData['location'];
      myId = profileData['myId'];
      firstname = profileData['firstname'];
      lastname = profileData['lastname'];
    });
  }

  Future<Map<String, dynamic>> getProfile() async {
    const storage = FlutterSecureStorage();
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
      String profileID = data['result']['profileID'];
      String profileImg = data['result']['profile_img'];
      String location = data['result']['location'];
      String myId = data['result']['_id'];
      String firstname = data['result']['firstname'];
      String lastname = data['result']['lastname'];
      String connection = data['Connection'].toString();
      String weShare = data['weShare'].toString();

      return {
        'profileID': profileID,
        'profileImg': profileImg,
        'location': location,
        'myId': myId,
        'firstname': firstname,
        'lastname': lastname,
        'connection': connection,
        'weShare': weShare,
      };
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<void> _showMediaOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Pick Image'),
              onTap: () {
                pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Pick Video'),
              onTap: () {
                pickMedia(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Capture from Camera'),
              onTap: () {
                pickMedia(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedImage = await picker.pickImage(
        source: source,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedMedia = File(pickedImage.path);
        });
        print('_selectedimage$_selectedMedia');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> pickMedia(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 10),
      );

      if (pickedFile != null) {
        File mediaFile = File(pickedFile.path);

        int fileSizeInBytes = await mediaFile.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        if (fileSizeInMB <= 10) {
          setState(() {
            _selectedMedia = mediaFile;
            if (pickedFile.path.endsWith('.mp4')) {
              _videoController = VideoPlayerController.file(_selectedMedia!)
                ..initialize().then((_) {
                  setState(() {});
                });
            } else {}
          });
        } else {
          showErrorDialog(context,
              "Selected video exceeds the maximum allowed size of 10MB.");
        }
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  Future<void> createPost() async {
    if (_selectedMedia == null || isLoading) {
      showErrorDialog(context, "Please select an image");
      return;
    }

    String postText = _postTextController.text;

    setState(() {
      isLoading = true;
    });

    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accessToken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}createPost'),
    );
    request.headers.addAll(headers);

    if (id != null) {
      request.fields.addAll({'user_id': id});
    }

    String mediaType =
        _selectedMedia!.path.endsWith('.mp4') ? 'video' : 'image';
    print('mediaTypemediaType$mediaType');

    String fileName = _selectedMedia!.path.split('/').last;
    request.files.add(
      await http.MultipartFile.fromPath(
        'post',
        _selectedMedia!.path,
        contentType: MediaType(mediaType, fileName),
      ),
    );

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });

        final responseJson = await response.stream.bytesToString();
        print('responseJson$responseJson');
        final decodedJson = json.decode(responseJson);

        final postId = decodedJson['response'][0]['_id'];

        if (postText.isNotEmpty) {
          await discription(
            postId,
          );
        }

        showSuccessDialog(
          context,
          "post Created Successfully",
        );
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> discription(String postid) async {
    String postText = _postTextController.text;

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}editPostDetails'));
    request.body = json.encode({
      "post_id": postid,
      "Post_discription": postText,
    });
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to show a simple error dialog
  void showErrorDialog(BuildContext context, String message) {
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          BasicDialogAction(
            title: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void showSuccessDialog(BuildContext context, String message) {
    CommonDialog.showSuccessDialog(context, message, handleOkPressed);
  }

  void handleOkPressed() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const Bottomnavscreen()));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar:_appbarbuild(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                '${imagespath.baseUrl}$profileImg', // Use the URL from the imagespath class
                              ),
                              radius: 20.r,
                            ),
                          ),
                          SizedBox(
                            width: 12.w,
                          ),
                          Text(firstname,
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.05.sp,
                                  color: Color.fromRGBO(25, 41, 92, 1))),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    SizedBox(
                      width: 294.w,
                      height: 78.43.h,
                      child: TextField(
                        controller: _postTextController,
                        maxLines: 7,
                        decoration: InputDecoration(
                            hintText:
                                "share_thought".tr(),
                            hintStyle: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w400,
                                fontSize: 15.sp,
                                color: Color.fromRGBO(153, 161, 190, 1))),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    _selectedMedia != null
                        ? _selectedMedia!.path.endsWith('.mp4')
                            ? Container(
                                child: VideoPlayerWidget(
                                    file: File(_selectedMedia!.path)),
                              )
                            : (_selectedMedia!.path.endsWith('.jpg') ||
                                    _selectedMedia!.path.endsWith('.webp') ||
                                    _selectedMedia!.path.endsWith('.png'))
                                ? Image.file(
                                    File(_selectedMedia!.path),
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox()
                        : const SizedBox(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showMediaOptions();
                          },
                          child: Container(
                            height: 35.43.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromRGBO(241, 244, 245, 1),
                                  width: 1),
                              color: const Color(0xFFF1F4F5),
                              borderRadius: BorderRadius.circular(9.21.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_alt,
                                  color: Colors.pink,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Choose_media'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.46,
                                    color: Color.fromRGBO(83, 87, 103, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: SizedBox(
          width: 215.9.w,
          height: 40.13.h,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.56.r),
              gradient: isLoading ? null : gradient,
            ),
            child: ElevatedButton(
              onPressed: () {
                createPost();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.56.r),
                ),
              ),
              child: Text(
                "share_post".tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w800,
                  fontSize: 21.sp,
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _appbarbuild() {
    return AppBar(
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
      title: Text('create_post'.tr(),
          textAlign: TextAlign.start,
          style: GoogleFonts.montserrat(
              color: const Color.fromRGBO(25, 41, 92, 1),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600)),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File file;

  const VideoPlayerWidget({required this.file});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(_controller),
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    backgroundColor: Colors.white,
                    bufferedColor: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                      // Text(
                      //   '${_controller.value.position}/${_controller.value.duration}',
                      //   style: TextStyle(color: Colors.white),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
