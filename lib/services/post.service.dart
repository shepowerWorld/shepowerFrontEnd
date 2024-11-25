import 'dart:convert';

import 'package:Shepower/Dashboard/models/post.model.dart';
import 'package:Shepower/Events/Common/apiservice.dart';
import 'package:Shepower/common/url.dart';
import 'package:Shepower/screens/post/models/comment.model.dart';
import 'package:Shepower/screens/post/models/post_like.model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../Events/Common/cache_services.dart';

class PostService {
  Future<List<Feed>> getPosts() async {
    final storage = const FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken == null) {
      // Handle case when access token is not available
      return [];
    }

    try {
      String? userId = await CacheService().getUserId();
      if (userId == null || userId.isEmpty) {
        return [];
      }

      String url = Url.getPostAll;
      Map<String, dynamic> body = {"user_id": userId};

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        List<PostModel> list = jsonDecode(response.body)['UsersWithPosts']
            .map<PostModel>((json) => PostModel.fromJson(json))
            .toList();

        List<Feed> feeds = [];
        for (PostModel post in list) {
          for (Feed feed in post.feed ?? []) {
            feed.isPostLiked = feed.likedpeopledata
                ?.any((likedPeople) => likedPeople.sId == userId);
            feed.userName = post.firstname;
            feed.userProfileImg = post.profileImg;
            feed.profileID = post.profileID;
          }
          feeds.addAll((post.feed ?? []).reversed);
        }
        return feeds;
      } else {
        print('Failed to load posts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("Error in get Post : $e");
      return [];
    }
  }

  Future<List<PostModel>?> createPost(
      String imagePath, String? postDescription) async {
    try {
      final storage = const FlutterSecureStorage();
      String? accessToken = await storage.read(key: 'accessToken');

      if (accessToken == null) {
        // Handle case when access token is not available
        return null;
      }

      String? userId = await CacheService().getUserId();
      if (userId == null || userId == "") return null;
      String url = Url.createPost;
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      request.headers.addAll(headers);

      request.fields.addAll(
          {'user_id': userId, 'Post_discription': postDescription ?? ""});
      request.files.add(await http.MultipartFile.fromPath('post', imagePath));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var resbody = await response.stream.bytesToString();
        var data = jsonDecode(resbody);
        if (data['message'] == "post created successfully") {
          List<PostModel> list = data['response']
              .map<PostModel>((json) => PostModel.fromJson(json))
              .toList();
          return list;
        }
        return null;
      } else {
        print(response.reasonPhrase);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<PostModel>?> editPostDetails(
      String postId, String postDescription) async {
    try {
      Map<String, dynamic> body = {
        "post_id": postId,
        "Post_discription": postDescription,
      };
      String url = Url.editPostDetails;
      final response = await ApiService().post(url, body);
      if (response['message'] == "Post edited Successfully") {
        List<PostModel> list = response['response']
            .map<PostModel>((json) => PostModel.fromJson(json))
            .toList();
        return list;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<PostLikeModel?> likePost(String postId) async {
    try {
      String? myId = await CacheService().getUserId();
      if (myId == null || myId == "") return null;

      Map<String, dynamic> body =
          PostLikeModel(postId: postId, likerId: myId).toJson();
      String url = Url.likePost;
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        PostLikeModel model = PostLikeModel.fromJson(response['result']);
        model.isPostLiked = response['message'] == "liked your post";
        return model;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<PostLikeModel?> getLikesOfPost(String postId) async {
    try {
      Map<String, dynamic> body =
          PostLikeModel(postId: postId).toGetLikeOfPostMap();
      String url = Url.getLikesOfPost;
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        PostLikeModel model = PostLikeModel.fromJson(response['response']);
        String? myId = await CacheService().getUserId();
        if (myId == null || myId == "") return null;
        model.likesofposts?.forEach((item) {
          if (item.sId == myId) {
            model.isPostLiked = true;
          }
        });
        return model;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Comment>?> getComments(String postId) async {
    try {
      String url = Url.getComment;
      Map<String, dynamic> body = {'post_id': postId};
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        List<Comment> list = response['response']
            .map<Comment>((json) => Comment.fromJson(json))
            .toList();
        String? myId = await CacheService().getUserId();
        if (myId == null || myId == "") return null;
        for (Comment comment in list) {
          //  comment.isLiked = false;
          comment.isLiked = comment.commentlikerDetails
                  ?.any((likedPeople) => likedPeople.sId == myId) ??
              false;
          //  for(CommentlikerDetails commentLiker in  comment.commentlikerDetails ?? []){
          //     if(myId == commentLiker.sId)  comment.isLiked = true;
          //  }
          for (CommentReply reply in comment.replies ?? []) {
            //  reply.isLiked = false;
            //  for(CommentlikerDetails commentLiker in  reply.commentlikerDetails ?? []){
            //   if(myId == commentLiker.sId)  reply.isLiked = true;
            // }
            reply.isLiked = reply.commentlikerDetails
                    ?.any((likedPeople) => likedPeople.sId == myId) ??
                false;
          }
        }

        return list;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Comment?> addComment(String postId, String commentText) async {
    try {
      String? myId = await CacheService().getUserId();
      if (myId == null || myId == "") return null;
      String url = Url.addComment;
      Map<String, dynamic> body = {
        "post_id": postId,
        "commenter_id": myId,
        "text": commentText
      };
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        Comment comment = Comment.fromJson(response['response']);
        return comment;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<CommentReply?> addReplyComment(
      String postId, String commentId, String text) async {
    try {
      String? myId = await CacheService().getUserId();
      if (myId == null || myId == "") return null;
      String url = Url.addReplyComment;
      Map<String, dynamic> body = {
        "post_id": postId,
        "comment_id": commentId,
        "commenter_id": myId,
        "text": text
      };
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        CommentReply reply = CommentReply.fromJson(response['response']);
        return reply;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Comment?> likeComment(String postId, String commentId) async {
    try {
      String? myId = await CacheService().getUserId();
      if (myId == null || myId == "") return null;
      String url = Url.likeComment;
      Map<String, dynamic> body = {
        "post_id": postId,
        "comment_id": commentId,
        "liker_id": myId
      };
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        Comment comment = Comment.fromJson(response['result']);
        comment.isLiked = response['message'] == 'liked your Comment';
        return comment;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Feed>?> getAllPostOfMe() async {
    try {
      String? myId = await CacheService().getUserId();
      if (myId == null || myId == "") return null;

      String url = Url.getAllPostsOfMe;
      Map<String, dynamic> body = {"user_id": myId};
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        if (response['results'] != null && response['results'].isNotEmpty) {
          final posts = response['results'][0]['posts'] ?? [];
          if (posts.isNotEmpty) {
            List<Feed> list =
                posts.map<Feed>((json) => Feed.fromJson(json)).toList();
            for (Feed feed in list) {
              feed.isPostLiked = false;
              for (Likesofposts likedPeople in feed.likedpeopledata ?? []) {
                if (likedPeople.sId == myId) {
                  feed.isPostLiked = true;
                }
              }
            }
            return list;
          }
          return [];
        }
        return [];
      }
      return [];
    } catch (e) {
      return null;
    }
  }

  Future<CommentReply?> replyCommentLike(
      String postId, String commentId, String replyCommentId) async {
    try {
      String? myId = await CacheService().getUserId();
      if (myId == null || myId == "") return null;

      String url = Url.replyCommentLike;
      Map<String, dynamic> body = {
        "post_id": postId,
        "comment_id": commentId,
        "replycomment_id": replyCommentId,
        "liker_id": myId
      };
      final response = await ApiService().post(url, body);
      if (response['Status'] == true) {
        CommentReply reply = CommentReply.fromJson(response['result']);
        reply.isLiked = response['message'] == 'liked your Comment';
        return reply;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      String url = Url.deletePost;
      Map<String, dynamic> body = {"_id": postId};
      final response = await ApiService().delete(url, body);
      return response['Status'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      String? myId = await CacheService().getUserId();
      if (myId == null || myId == "") return false;
      String url = Url.deleteComment;
      Map<String, dynamic> body = {"comment_id": commentId, "deleter_id": myId};
      final response = await ApiService().delete(url, body);
      return response['Status'] == true;
    } catch (e) {
      return false;
    }
  }
}
