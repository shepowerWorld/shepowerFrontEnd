import 'dart:io';

import 'package:Shepower/service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late List<CameraDescription> cameras;
  late final CameraController cameraController;
  late VideoPlayerController _videoController;
  String? recordedVideoPath;

  int direction = 0;
  bool isRecording = false;
  bool isPlaying = false;
  bool showPlayButton = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    cameraController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void initializeCamera() async {
    cameras = await availableCameras();

    cameraController = CameraController(
      cameras[direction],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await cameraController.initialize();
      if (mounted) {
        setState(() {}); // To refresh widget
      }
    } catch (e) {
      print("shows the error $e");
    }
  }

  void toggleRecording() async {
    if (!isRecording) {
      try {
        await cameraController.startVideoRecording();
        setState(() {
          isRecording = true;
          showPlayButton = false;
        });
      } catch (e) {
        print(e);
      }
    } else {
      try {
        XFile videoFile = await cameraController.stopVideoRecording();
        recordedVideoPath = videoFile.path;
        initializeVideoPlayer(File(videoFile.path));
        setState(() {
          isRecording = false;
          showPlayButton = true;
        });
        print("Video saved to ${videoFile.path}");
      } catch (e) {
        print(e);
      }
    }
  }

  void initializeVideoPlayer(File videoFile) {
    _videoController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    print('VIDEO PLAY====');
  }

  Future<void> sendRequest1() async {
    setState(() {
      isLoading = true;
    });
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiConfig.baseUrl}CreateSos'));
      request.fields.addAll({
        'citizen_id': id ?? '',
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'text': 'gghhh' // Text field
      });
      request.files.add(
        await http.MultipartFile.fromPath(
          'attachment',
          recordedVideoPath!,
          contentType: MediaType('video', 'mp4'),
        ),
      );
      request.headers.addAll(headers);

      print('ATTACHMENT$recordedVideoPath');

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        print('Partner Location Data Fetched Successfull===>with attach');
        print('main====${await response.stream.bytesToString()}');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return IconOverlay();
          },
        );
      } else {
        print(response.reasonPhrase);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Partner Location Data Fetched Successfull===>with direct');
      print('Error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController.value.isInitialized) {
      return Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  if (!isPlaying) CameraPreview(cameraController),
                  // if (!isPlaying)
                  //   GestureDetector(
                  //     onTap: () {
                  //       showMediaPickerDialog();
                  //     },
                  //     child: _buildButton(Icons.photo, Alignment.bottomLeft),
                  //   ),
                  if (!showPlayButton) // Show recording button
                    GestureDetector(
                      onTap: () {
                        if (!isRecording) {
                          toggleRecording();
                        } else {
                          // If recording is in progress, stop recording and show the share overlay
                          toggleRecording();
                        }
                      },
                      child: Stack(
                        children: [
                          _buildButton(
                            isRecording ? Icons.stop : Icons.videocam,
                            Alignment.bottomCenter,
                          ),
                        ],
                      ),
                    ),
                  if (!isPlaying)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          direction = direction == 0 ? 1 : 0;
                          initializeCamera();
                        });
                      },
                      child: _buildButton(
                        direction == 1
                            ? Icons.flip_camera_ios_outlined // Back camera icon
                            : Icons.flip_camera_ios, // Front camera icon
                        Alignment.bottomRight,
                      ),
                    ),
                  if (showPlayButton) // Show play button
                    GestureDetector(
                      onTap: () {
                        if (isPlaying) {
                          _videoController.pause(); // Pause the video
                        } else {
                          _videoController.play(); // Play the video
                        }
                        setState(() {
                          isPlaying = !isPlaying; // Toggle the isPlaying state
                        });
                      },
                      child: _buildButton(
                        isPlaying
                            ? Icons.pause
                            : Icons
                                .play_arrow, // Swap icons based on isPlaying state
                        Alignment.bottomCenter,
                      ),
                    ),
                  if (isPlaying)
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Container(
                        height: 750,
                        width: 400,
                        child: Center(
                          child: _videoController.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _videoController.value.aspectRatio,
                                  child: VideoPlayer(_videoController),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  Visibility(
                    visible: isPlaying,
                    child: GestureDetector(
                      onTap: () {
                        sendRequest1();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: _buildButton(Icons.check, Alignment.bottomRight),
                      ), // Add the share icon/button
                    ),
                  ),
                  Visibility(
                    visible: isPlaying,
                    child: GestureDetector(
                      onTap: () {
                        if (!isRecording) {
                          toggleRecording();
                        } else {
                          // If recording is in progress, stop recording and show the share overlay
                          toggleRecording();
                        }
                        //
                        // _videoController.pause(); // Pause the video
                        setState(() {
                          isPlaying = false; // Set playing to false
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: _buildButton(Icons.replay, Alignment.bottomLeft),
                      ), // Add the share icon/button
                    ),
                  ),
                ],
              ),
      );
    } else {
      return SizedBox(
        height: 20,
      );
    }
  }

  Widget _buildButton(IconData icon, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
          margin: const EdgeInsets.only(
            right: 20,
            bottom: 10,
          ),
          height: 40,
          width: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color.fromRGBO(216, 6, 131, 1),
                  Color.fromRGBO(99, 7, 114, 1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Center(
              child: Icon(
                icon,
                color:
                    Colors.white, // This color will be masked by the gradient
                size: 40,
              ),
            ),
          )),
    );
  }
}

class IconOverlay extends StatelessWidget {
  final Function()? onPressed;

  IconOverlay({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(216, 6, 131, 1),
                      Color.fromRGBO(99, 7, 114, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(216, 6, 131, 1),
                      Color.fromRGBO(99, 7, 114, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sent to Nearby Leaders',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
