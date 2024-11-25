import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shepower/Dashboard/Bottomnav.dart';
import 'package:Shepower/Notification.dart';
import 'package:Shepower/notification_services.dart.dart';
import 'package:Shepower/service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

import 'WelCome1.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final NotificationServices1 notificationService = NotificationServices1();

  final IO.Socket socket = IO.io(
    '${ApiConfig.socket}',
    IO.OptionBuilder()
        .setTransports(['websocket']).setExtraHeaders({'foo': 'bar'}).build(),
  );

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? fcmToken;
  String profileID = '';
  String lastname = '';
  bool? profile;
  String profileImg = '';
  String location = '';
  String myId = '';
  Timer? locationUpdateTimer;
  String deviceid = '';
  bool isNotification = false;

  @override
  void initState() {
    super.initState();
    Future(() {
      fetchLocation();
    });
    callSplashScreenAPI();
    determinePosition();

    connectToServer();
    getDeviceId();
    getFCMToken().then((token) {
      setState(() {
        fcmToken = token;
        _storeFCMToken(token);
      });
    });

    _loadProfileID();

    locationUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchLocation();
    });

    notificationService.firebaseInit(context);
    // Request notification permission from the user
    notificationService.requestNotificationPermission();
    // Setup message handling when the app is in background or terminated
    notificationService.setupInteractMessage(context);
  }

  Future<void> callSplashScreenAPI() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    

    if (id != null) {
      try {
        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accesstoken'
        };
        var request =
            http.Request('POST', Uri.parse('${ApiConfig.baseUrl}SplashScreen'));
        request.body = json.encode({"_id": id});
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responseJson = json.decode(await response.stream.bytesToString());
        //print('SplashScreen...${responseJson}');

        if (responseJson['Status'] == 200) {
          // print('SplashScreen...${responseJson['response'][0]['adminBlock']}');
          // print('SplashScreen...${responseJson['response'][0]['checkout'][0]['newdevice_id']}');
          if (responseJson['response'][0]['adminBlock'] == true) {
            String msg = 'You have been blocked by ShePower Team';
            showdialogue(msg);
            await Future.delayed(const Duration(seconds: 3));
            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(builder: (context) => WelcomeScreen()),
            // );
          } else if (responseJson['response'][0]['checkout'][0]
                  ['newdevice_id'] !=
              deviceid) {
            String msg =
                'You have been logged out from this device because new Login detected on a new device';
            showdialogue(msg);
            await Future.delayed(const Duration(seconds: 3));
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          } else {
            delayedNavigation();
          }
        } else {
          delayedNavigation();
        }
      } catch (error) {
        // Handle error here
        print('Error: $error');
        delayedNavigation();
      }
    } else {
      delayedNavigation();
    }
  }

  void showdialogue(String message) {
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
                  message,
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
              Center(
                child: InkWell(
                  onTap: () {
                    // Handle Accept button tap
                    Navigator.of(context).pop();
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
                      mainAxisAlignment: MainAxisAlignment.center,
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

  Future<void> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceId;
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        // print('deviceId..$deviceId');
        setState(() {
          deviceid = androidInfo.id;
        });
        await _secureStorage.write(
            key: 'DeviceId',
            value: deviceId); // Use androidId for uniqueness on Android
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo
            .identifierForVendor; // Use identifierForVendor for uniqueness on iOS
        // print('deviceId..$deviceId');
        setState(() {
          deviceid = iosInfo.identifierForVendor!;
        });
        await _secureStorage.write(key: 'DeviceId', value: deviceId);
      }
    } catch (e) {
      print("Error getting device id: $e");
    }

    print("Device ID: $deviceId");
  }

  void _navigateToNotificationScreen(Map<String, dynamic> messageData) {
    print('messagedata===>>>$messageData');
    var message;
    if (message.data['title'] == 'ShePower') {
      setState(() {
        isNotification = true;
      });
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => NotificationScreen()));
    }
  }

  void connectToServer() {
    socket.onError((error) {
      print("Socket error: $error");
    });

    socket.onConnect((_) {
      print("Socket connected");
    });

    socket.onDisconnect((_) {
      print("Socket disconnected");
    });

    socket.on('messageSend', (data) {
      print("Received message: $data");
    });
  }

  Future<void> delayedNavigation() async {
    await Future.delayed(const Duration(seconds: 3));
    if (profile == true) {
      if (!isNotification) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Bottomnavscreen(),
          ),
        );
      }
    } else {
      if (!isNotification) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      }
    }
  }

  Future<Position?> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    } else {
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _loadProfileID() async {
    final profileData = await GetMyProfile();
    setState(() {
      lastname = profileData['lastname'];
      profile = profileData['profile'];
      profileID = profileData['profileID'];
    });

    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );
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
    var request =
        http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getMyprofile/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();

      Map<String, dynamic> data = json.decode(responseBody);

      String lastname = data['result']['lastname'];
      bool profile = data['result']['profile'];
      String profileID = data['result']['profileID'];

      return {'lastname': lastname, 'profile': profile, 'profileID': profileID};
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<String?> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    return await messaging.getToken();
  }

  Future<void> _storeFCMToken(String? token) async {
    if (token != null) {
      await _secureStorage.write(key: 'fcmToken', value: token);
    }
  }

  Future<void> fetchLocation() async {
    if (profile == true) {
      final storage = FlutterSecureStorage();
      String? id = await storage.read(key: '_id');
      String? accesstoken = await storage.read(key: 'accessToken');

      try {
        print('Fetching location...');
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        double latitude = position.latitude;
        double longitude = position.longitude;

        storage.write(key: "latitude", value: latitude.toString());
        storage.write(key: "longitude", value: longitude.toString());

        print('Location fetched: $latitude, $longitude');

        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accesstoken'
        };
        if (profileID.startsWith('Leader')) {
          var request = http.Request(
              'POST', Uri.parse('${ApiConfig.baseUrl}locationUpdate'));
          request.body = json.encode({
            "_ids": [id],
          });
          request.headers.addAll(headers);

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            print('Leader Location update successful');
            print(await response.stream.bytesToString());
          } else {
            print('Leader Location update failed: ${response.reasonPhrase}');
          }
        } else if (profileID.startsWith('citizen')) {
          var headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken'
          };
          var request = http.Request(
              'POST', Uri.parse('${ApiConfig.baseUrl}locationUpdatecitizen'));
          request.body = json.encode({
            "_ids": [id],
          });
          request.headers.addAll(headers);

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            print('Citizen Location update successful');
            print(await response.stream.bytesToString());
          } else {
            print('Citizen Location update failed: ${response.reasonPhrase}');
          }
        }
      } catch (e) {
        print('Error fetching or updating location: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = 0.15;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.9,
              height: screenWidth * 0.9,
              child: Image.asset('assets/Splash/shepower.png'),
            ),
          ],
        ),
      ),
    );
  }
}
