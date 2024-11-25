import 'dart:convert';
import 'dart:io';

import 'package:Shepower/service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future post(String url, Map<String, dynamic> body) async {
    final storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');

    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken'
          });
      print("Apirespo --${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(url);
        print(jsonEncode(body));
        print('ApiService....$data');
        return data;
      } else {
        throw const HttpException("Something went wrong!");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(
      String url, Map<String, dynamic>? body) async {
    try {
      final storage = FlutterSecureStorage();
      String? accesstoken = await storage.read(key: 'accessToken');

      final response = await http.delete(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken'
          });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(url);
        print(jsonEncode(body));
        print(data);
        return data as Map<String, dynamic>;
      } else {
        throw const HttpException("Something went wrong!");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future put(String url, Map<String, dynamic>? body) async {
    try {
      final storage = FlutterSecureStorage();
      String? accesstoken = await storage.read(key: 'accessToken');
      final response = await http.put(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken'
          });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(url);
        print(jsonEncode(body));
        print(data);
        return data;
      } else if (response.statusCode == 401 || response.statusCode == 500) {
        final data = jsonDecode(response.body);
        throw HttpException(data['message']);
      } else {
        throw const HttpException("Something went wrong!");
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(String url,
      [Map<String, dynamic> body = const {}]) async {
    try {
      final storage = FlutterSecureStorage();
      String? accesstoken = await storage.read(key: 'accessToken');
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(url);
        print(jsonEncode(body));
        print(data);
        return data as Map<String, dynamic>;
      } else {
        throw const HttpException("Something went wrong!");
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<String> sendRequest(String userId) async {
    final storage = FlutterSecureStorage();
    String? storedId = await storage.read(key: '_id');
    String? accessToken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}sendRequestOrConnect'),
    );
    request.body = json.encode({"fromUser": storedId, "toUser": userId});
    print('sendRequestOrConnect ${request.body}');
    request.headers.addAll(headers);
    final response = await request.send();
    print('sendRequestOrConnect');
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      return 'success';
    } else {
      print(response.reasonPhrase);
      return 'failure';
    }
  }
}
