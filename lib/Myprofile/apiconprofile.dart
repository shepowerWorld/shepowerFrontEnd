import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiprofileService {
  static Future<void> visibleprofiledata() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "education", "public": "true"});
    request.headers.addAll(headers);

    print('request.body===>>${request.body}');

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print('pubilc');
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> visibleprofiledata1() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body = json.encode({"_id": id, "feild": "dob", "public": "true"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('pubilc');
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> visibleprofiledata2() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "proffession", "public": "true"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('pubilc');
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> visibleprofiledata3() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "location", "public": "true"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('pubilc');
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> visibleprofiledata4() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "familymembers", "public": "true"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('pubilc');
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> visibleprofiledata5() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "languages", "public": "true"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('pubilc');
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> Hideprofiledata() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "education", "private": "true"});
    request.headers.addAll(headers);

    print('Nandan==>>${request.body}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('succesfully');
      print(await response.stream.bytesToString());
    } else {
      print('Failure');
      print(response.reasonPhrase);
    }
  }

  static Future<void> Hideprofiledata1() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body = json.encode({"_id": id, "feild": "dob", "private": "true"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> Hideprofiledata2() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "proffession", "private": "true"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> Hideprofiledata3() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "location", "private": "true"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> Hideprofiledata4() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "familymembers", "private": "true"});
    request.headers.addAll(headers);

    print('Nandan==${request.body}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('Nandan');
      print(await response.stream.bytesToString());
    } else {
      print('nandan2');
      print(response.reasonPhrase);
    }
  }

  static Future<void> Hideprofiledata5() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "languages", "private": "true"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> connectedprofiledata() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "education", "connected": "true"});
    request.headers.addAll(headers);

    print('request.body${request.body}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> connectedprofiledata1() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "dob", "connected": "true"});
    request.headers.addAll(headers);

    print('request.body${request.body}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> connectedprofiledata2() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "proffession", "connected": "true"});
    request.headers.addAll(headers);

    print('request.body${request.body}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> connectedprofiledata3() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "location", "connected": "true"});
    request.headers.addAll(headers);

    print('request.body${request.body}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> connectedprofiledata4() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "familymembers", "connected": "true"});
    request.headers.addAll(headers);

    print('request.body${request.body}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> connectedprofiledata5() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}profileDataSetting'));
    request.body =
        json.encode({"_id": id, "feild": "languages", "connected": "true"});
    request.headers.addAll(headers);

    print('request.body${request.body}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static void showSuccessDialog(context) {
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
              Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD80683),
                      Color(0xFF630772),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.done,
                      size: 48.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Center(
                child: Text(
                  "Profile Updated Successfully",
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
                  Navigator.of(context).pop();
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
                            color: Colors.white, fontWeight: FontWeight.bold),
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
}
