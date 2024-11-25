import 'package:Shepower/common/url.dart';
import 'package:Shepower/service.dart';

import '../common/api.service.dart';
import '../common/cache.service.dart';
import '../screens/post/models/commentReply.model.dart';

class CommentReplyService {
// comment_reply.service.dart
  Future<CommentReplyModel?> addReplyComments(
      String postId, String commentId, String text) async {
    try {
      String? _id = await CacheService.getUserId();
      if (_id == null || _id == "") return null;

      Map<String, dynamic> body = {
        "post_id": postId,
        "comment_id": commentId,
        "commenter_id": _id,
        "text": text
      };
      print('body1111111$body');
      String url = Url.addReplyComment;

      var response = await ApiService().post(url, body);

      CommentReplyModel? result =
          CommentReplyModel.fromJson(response['response']);

      return result;
    } catch (e) {
      return null;
    }
  }

  Future<bool?> blockUser(
      String postId, String blockerId, String blockReason) async {
    try {
      String? _id = await CacheService.getUserId();
      if (_id == null || _id == "") return null;
      Map<String, dynamic> body = {
        // "user_id":userId,
        // "event_id":eventId
        "postId": postId,
        "blocker_id": _id,
        "blockReason": blockReason,
      };

      String url = "${ApiConfig.baseUrl}postBlock";
      var response = await ApiService().put(url, body);
      print(response);

      if (response['message'] == "Post blocked successfully") {
        return true;
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }
}
