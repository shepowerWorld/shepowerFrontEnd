import 'dart:convert';

import 'package:Shepower/Chatroom/Models/all_groups.model.dart';
import 'package:Shepower/Chatroom/Models/create_group.model.dart';
import 'package:Shepower/Chatroom/Models/send_request.dart';
import 'package:Shepower/common/api.service.dart';
import 'package:Shepower/common/cache.service.dart';
import 'package:Shepower/common/url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ChatService {
  Future<void> createGroup(String selectedIds) async {
    try {
      final storage = FlutterSecureStorage();
      String? accesstoken = await storage.read(key: 'accessToken');
      String? userId = await CacheService.getUserId();
      if (userId == null || userId.isEmpty) return;

      String url = Url.createGroup;
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var body = {
        "user_id": userId,
        "joining_group": [selectedIds]
      };

      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      final data = json.decode(response.body);
      print('createGroup: $data');

      if (response.statusCode == 200) {
        if (data['status'] == 'Success') {
          print('Group created successfully');
          // Add any further logic here
        } else {
          print('API Message: ${data['message']}');
        }
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<List<AllgroupsModel>?> getAllGroups() async {
    try {
      final storage = FlutterSecureStorage();
      String? userId = await storage.read(key: '_id');
      if (userId == null || userId.isEmpty) return null;

      String url = Url.getAllGroups;
      var body = {"user_id": userId};

      var response = await ApiService().post(url, body);
      List<AllgroupsModel> list = response["result"]
          .map<AllgroupsModel>((json) => AllgroupsModel.fromJson(json))
          .toList();

      return list;
    } catch (e) {
      print('Error in getAllGroups: $e');
      return null;
    }
  }

  Future<List<AllgroupsModel>?> joinGroup(
      String? groupId, String? adminId) async {
    try {
      final storage = FlutterSecureStorage();
      String? userId = await storage.read(key: '_id');
      if (userId == null || userId.isEmpty) return null;

      String url = Url.joinGroups;
      var body = {
        "_id": groupId,
        "admin_id": adminId,
        "joining_group": [userId]
      };

      var response = await ApiService().put(url, body);
      List<AllgroupsModel> list = response["result"]
          .map<AllgroupsModel>((json) => AllgroupsModel.fromJson(json))
          .toList();

      return list;
    } catch (e) {
      print('Error in joinGroup: $e');
      rethrow;
    }
  }

  Future<bool?> deletePerson(
      String? groupId, String? userId, String? adminId) async {
    try {
      var body = {"_id": groupId, "other_id": userId, "admin_id": adminId};

      String url = Url.deletePerson;
      var response = await ApiService().delete(url, body);

      return response['status'] == true;
    } catch (e) {
      print('Error in deletePerson: $e');
      rethrow;
    }
  }

  Future<bool> deleteRoom(String? adminId) async {
    try {
      var body = {"admin_id": adminId};

      String url = Url.deleteRoom;
      var response = await ApiService().delete(url, body);

      return response['status'] == true;
    } catch (e) {
      print('Error in deleteRoom: $e');
      rethrow;
    }
  }

  Future<bool> exitGroup(String? otherId, String? groupId) async {
    try {
      String url = Url.exitGroup + "/${groupId}";
      var body = {"other_id": otherId};
      final response = await ApiService().put(url, body);
      print("dddddddd  $response");
      return response['status'] == true;
    } catch (e) {
      print("$e");
      return false;
    }
  }

  Future<CreateGroupModel?> viewGroupInfo(String? groupId) async {
    try {
      print("hhhh--${groupId}");
      Map<String, dynamic> body = {
        "_id": groupId,
      };
      String url = Url.viewGroupInfo;
      final response = await ApiService().post(url, body);
      print("view--------${response}");
      if (response['status'] == true) {
        CreateGroupModel viewGroup =
            CreateGroupModel.fromJson(response['response']);

        print("ssssss------${viewGroup.groupProfileImg}");
        return viewGroup;
      }
      return null;
    } catch (e) {
      print(e);

      return null;
    }
  }

  Future<CreateGroupModel?> updateProfilegroup(
      String groupId, String groupName) async {
    try {
      String url = Url.updateProfileGroup + "/${groupId}";
      Map<String, dynamic> body = {
        "groupName": groupName,
      };
      final response = await ApiService().put(url, body);
      if (response['status'] == true) {
        CreateGroupModel updateprofilegroup =
            CreateGroupModel.fromJson(response['response']);
        return updateprofilegroup;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<CreateGroupModel?> updateGroup(String imagePath, String groupName,
      String groupId, String groupAbout) async {
    try {
      String url = Url.updateGroupImage;
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.fields.addAll({
        'groupName': groupName,
        '_id': groupId,
        'Groupabout': groupAbout,
      });
      request.files
          .add(await http.MultipartFile.fromPath('profile_img', imagePath));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var resbody = await response.stream.bytesToString();
        var data = jsonDecode(resbody);

        if (data['status'] == "Success") {
          CreateGroupModel updateImg =
              CreateGroupModel.fromJson(data['result']);
          return updateImg;
        }
      } else {
        print('Failed to update group: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<SendRequest?> sendReuest(String groupId) async {
    try {
      final storage = FlutterSecureStorage();
      String? userId = await storage.read(key: '_id');
      if (userId == null || userId.isEmpty) return null;
      print("sendRequestGroup--------$userId...$groupId");
      String url = Url.sendRequestGroup;
      Map<String, dynamic> body = {
        "fromUser": userId,
        "group_id": groupId,
      };
      final response = await ApiService().put(url, body);
      print("sendRequestGroup--------$response");
      if (response['Status'] == true) {
        SendRequest requestgroup = SendRequest.fromJson(response['response']);
        return requestgroup;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<CreateGroupModel?> acceptGroupRequest(
      String userId, String groupId) async {
    try {
      String url = Url.acceptGroupRequest;
      Map<String, dynamic> body = {
        "fromUser": userId,
        "group_id": groupId,
      };
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        CreateGroupModel acceptgroup =
            CreateGroupModel.fromJson(response['result']);
        return acceptgroup;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
