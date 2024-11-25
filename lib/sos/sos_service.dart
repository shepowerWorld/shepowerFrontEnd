import 'package:Shepower/common/cache.service.dart';
import 'package:Shepower/common/url.dart';
import 'package:Shepower/sos/model.dart';

import '../common/api.service.dart';

class SosService {
  Future<CommentSosModel?> addSosComment(String leaderId, String citizenId,
      String sosId, String commentSos) async {
    try {
      String? myId = await CacheService.getUserId();
      if (myId == null || myId == "") return null;
      String url = Url.addComment;
      Map<String, dynamic> body = {
        "leader_id": leaderId,
        "citizen_id": citizenId,
        "sosId": sosId,
        "commentSos": commentSos
      };
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        CommentSosModel comment = CommentSosModel.fromJson(response['data']);
        return comment;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<CommentSosModel>?> getSosComments(String sosId) async {
    try {
      String url = Url.allCommentsSos;
      Map<String, dynamic> body = {'sosId': sosId};
      final response = await ApiService().get(url, body);
      if (response['Status'] == true) {
        List<CommentSosModel> list = response['result']
            .map<CommentSosModel>((json) => CommentSosModel.fromJson(json))
            .toList();

        return list;
      }
    } catch (e) {
      return null;
    }
  }

  Future<CommentSosModel?> ratingsReviews(String leaderId, String citizenId,
      String sosId, String ratings, String reviews) async {
    try {
      String? myId = await CacheService.getUserId();
      if (myId == null || myId == "") return null;
      String url = Url.addComment;
      Map<String, dynamic> body = {
        "leader_id": leaderId,
        "citizen_id": citizenId,
        "sosId": sosId,
        "ratings": ratings,
        "reviews": reviews,
      };
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        CommentSosModel comment = CommentSosModel.fromJson(response['data']);
        return comment;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<CommentSosModel>?> getratingsReview(String leaderId) async {
    try {
      String url = Url.getRatingsReview;
      Map<String, dynamic> body = {'leader_id': leaderId};
      final response = await ApiService().get(url, body);
      if (response['Status'] == true) {
        List<CommentSosModel> list = response['result']
            .map<CommentSosModel>((json) => CommentSosModel.fromJson(json))
            .toList();

        return list;
      }
    } catch (e) {
      return null;
    }
  }
}
