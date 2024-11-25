import 'dart:convert';
import 'dart:io';

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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
    final storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');
    try {
      final response = await http.delete(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken'
          });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data as Map<String, dynamic>;
      } else {
        throw const HttpException("Something went wrong!");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future put(String url, Map<String, dynamic>? body) async {
    final storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');
    try {
      final response = await http.put(Uri.parse(url),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accesstoken'
          });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        return data;
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
    final storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data as Map<String, dynamic>;
      } else {
        throw const HttpException("Something went wrong!");
      }
    } catch (e) {
      rethrow;
    }
  }
}
