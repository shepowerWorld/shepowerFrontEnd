import 'dart:convert';
import 'dart:io';

import 'package:Shepower/OnBoarding/Leader/CreateProfile.dart';
import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:gradient_borders/input_borders/gradient_outline_input_border.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../leneargradinent.dart';

class Facescan extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Facescan> {
  final secureStorage = FlutterSecureStorage();

  bool isLoading = false;
  bool loading = true;
  File? _image;
  List<dynamic>? _output;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        loading = false;
      });
      pickImageCamera();
    });
  }

  Future<Map<String, String?>> getStoredParameters() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');

    return {
      'id': id,
    };
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model_gender.tflite',
        labels: 'assets/labels.txt',
      );
      print("loading model Successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> pickImageCamera() async {
    try {
      var image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }

      setState(() {
        _image = File(image.path);
      });

      // Create an ImageCropper instance
      var imageCropper = ImageCropper();

      // Crop the image
      var cropped = await imageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
      );

      if (cropped == null) {
        return;
      }
      var croppedFile = File(cropped.path);

      setState(() {
        _image = croppedFile;
      });

      await _detectFaces(_image!);
    } catch (e) {
      print("Error picking image from camera: $e");
    }
  }

  Future<void> _detectFaces(image) async {
    print('i received image from camera$image');
    setState(() {
      isLoading = true;
    });
    if (image == null) {
      return;
    }
    final inputImage = InputImage.fromFile(image);
    final faceDetector = GoogleMlKit.vision.faceDetector();
    final faces = await faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      print("Number of detected faces: ${faces.length}");

      for (var face in faces) {
        final boundingBox = face.boundingBox;
        final headEulerAngleY = face.headEulerAngleY;
        final headEulerAngleZ = face.headEulerAngleZ;

        print("Face Bounding Box: $boundingBox");
        print("Head Euler Angle Y: $headEulerAngleY");
        print("Head Euler Angle Z: $headEulerAngleZ");
      }

      detectGender(image); // Use the parameter here
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoFaceDetectScreen()),
      );
    }
  }

  Future<void> detectGender(File image) async {
    print('i received image from detectFaces$image');
    try {
      var headers = {'token': genderdetection.token};
      var request = http.MultipartRequest(
          'POST', Uri.parse(genderdetection.detectAPIUrl));
      request.files.add(await http.MultipartFile.fromPath('photo', image.path));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseJson = json.decode(await response.stream.bytesToString());
        print('photo/detect...${responseJson[0]['gender']['value']}');
        if (responseJson.toString().isNotEmpty) {
          if (responseJson[0]['gender']['value'] == "Male") {
            setState(() {
              isLoading = false;
            });
            print('Navigating to MaleScreen');
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MaleScreen()),
            );
          } else if (responseJson[0]['gender']['value'] == "Female") {
            showVerificationOverlay();
            await createProfileImage(image);
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        print(response.reasonPhrase);
        setState(() {
          isLoading = false;
        });
        showError();
      }
    } catch (e) {
      print("Error detecting image: $e");
      setState(() {
        isLoading = false;
      });
      showError();
    }
  }

  Future<void> createProfileImage(File image) async {
    try {
      final storage = FlutterSecureStorage();
      String? id = await storage.read(key: '_id');

      String? accesstoken = await storage.read(key: 'accessToken');

      print('accesstoken$accesstoken');

      if (id == null) {
        print('ID and/or Authorization not found in secure storage.');
        return;
      }

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };

      var request = http.MultipartRequest(
          'PUT', Uri.parse('${ApiConfig.baseUrl}createProfileLeaderimg'));
      request.fields.addAll({
        '_id': id,
      });

      request.files
          .add(await http.MultipartFile.fromPath('profile_img', image.path));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateProfile()),
        );
      } else {
        print('HTTP Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error creating profile image: $e");
    }
  }

  Future<void> showError() async {
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
                  "Please take a clear picture!",
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
              InkWell(
                onTap: () {
                  // Handle Accept button tap
                  Navigator.of(context).pop();
                  pickImageCamera(); // You can pass any value you need
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
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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

  Future<void> showVerificationOverlay() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context); // Dismiss the overlay when tapped
          },
          child: Container(
            height: 190.h,
            width: 255.w,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/face/verified.png',
                    width: 190.w,
                    height: 190.h,
                  ),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [
                          Color.fromRGBO(216, 6, 131, 1),
                          Color.fromRGBO(99, 7, 114, 1),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ).createShader(bounds);
                    },
                    child: Text("Verified",
                        style: GoogleFonts.montserrat(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(255, 255, 255, 1))),
                  ),
                  Image.asset(
                    'assets/face/dots.png',
                    width: 100.w,
                    height: 100.h,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SizedBox(
              height: 471.h,
              width: 319.65.w,
              child: Column(
                children: [
                  !loading && _output != null && _image != null
                      ? SizedBox(
                          height: 471.h,
                          width: 319.65.w,
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Visibility(
                          visible: !isLoading,
                          child: Container(
                            margin: EdgeInsets.only(left: 30, top: 100),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 50,
                                ),
                                const SizedBox(height: 50.0),
                                const Center(
                                  child: Text(
                                    'Please take a picture to verify!',
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
                                InkWell(
                                  onTap: () {
                                    // Handle Accept button tap
                                    pickImageCamera();
                                    // You can pass any value you need
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Ok',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ))
                ],
              ),
            ),
    );
  }
}

//male screen

class MaleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        leading: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Color.fromRGBO(216, 6, 163, 1),
                Color.fromRGBO(99, 7, 114, 1),
              ],
            ).createShader(bounds);
          },
          child: IconButton(
            icon: SizedBox(
              height: 30.h,
              width: 30.w,
              child: Stack(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      border: GradientOutlineInputBorder(
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(216, 6, 163, 1),
                          Color.fromRGBO(99, 7, 114, 1),
                        ]),
                        width: 1.5,
                      ),
                      focusedBorder: GradientOutlineInputBorder(
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(216, 6, 163, 1),
                          Color.fromRGBO(99, 7, 114, 1),
                        ]),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [
                            Color.fromRGBO(216, 6, 163, 1),
                            Color.fromRGBO(99, 7, 114, 1),
                          ],
                        ).createShader(bounds);
                      },
                      child: const Icon(
                        Icons.navigate_before_rounded,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              // Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Facescan(),
                ),
              );
            },
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
            Text(
              'Sorry Men !\nYou can’t continue.',
              style: GoogleFonts.montserrat(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(216, 30, 30, 1)),
              textAlign: TextAlign.start,
            ),

            Image.asset(
              'assets/face/male.png',
              width: 214.w,
              height: 295.h,
            ), // Replace with your image asset
            SizedBox(
              height: 20.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Text(
                'Since we are ‘only women’ platform we request you to sit out from this ...',
                style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(35, 31, 32, 1),
                    height: 1.9.h),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(72, 0, 72, 30),
          child: SizedBox(
            width: 215.9.w, // Set your desired width
            height: 40.13.h, // Set your desired height
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10.56.r),
              ),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Facescan()),
                    );
                    // Navigation logic here
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.56.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Got it !",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w800,
                            color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                    ],
                  )),
            ),
          )),
    );
  }
}

// no face detected  class

class NoFaceDetectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 35.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(top: 50.h)),
            Text(
              'Sorry No face Detected!\nPlease  try Again',
              style: GoogleFonts.montserrat(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(216, 30, 30, 1)),
              textAlign: TextAlign.start,
            ),

            Image.asset(
              'assets/face/nofaces.jpg',
              width: 214.w,
              height: 295.h,
            ), // Replace with your image asset
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(72, 0, 72, 30),
          child: SizedBox(
            width: 215.9.w, // Set your desired width
            height: 40.13.h, // Set your desired height
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10.56.r),
              ),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Facescan()),
                    );
                    // Navigation logic here
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.56.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Scan Again !",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w800,
                            color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                    ],
                  )),
            ),
          )),
    );
  }
}
