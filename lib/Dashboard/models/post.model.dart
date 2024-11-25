import 'package:Shepower/screens/post/models/post_like.model.dart';

class PostModel {
  String? sId;
  String? firstname;
  String? profileImg;
  String? profileID;
  List<Feed>? feed;

  PostModel(
      {this.sId, this.firstname, this.profileImg, this.profileID, this.feed});

  PostModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstname = json['firstname'];
    profileImg = json['profile_img'];
    profileID = json['profileID'];
    if (json['feed'] != null) {
      feed = <Feed>[];
      json['feed'].forEach((v) {
        feed!.add(Feed.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['firstname'] = firstname;
    data['profile_img'] = profileImg;
    data['profileID'] = profileID;
    if (feed != null) {
      data['feed'] = feed!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Feed {
  String? sId;
  String? userId;
  String? post;
  String? postDiscription;
  int? totallikesofpost;
  int? totalComments;
  List<Likesofposts>? likedpeopledata;
  String? createdAt;
  bool? isPostLiked;
  String? userName;
  String? userProfileImg;
  String? profileID;

  Feed(
      {this.sId,
      this.userId,
      this.post,
      this.postDiscription,
      this.totallikesofpost,
      this.likedpeopledata,
      this.totalComments,
      this.isPostLiked,
      this.createdAt,
      this.userName,
      this.userProfileImg,
      this.profileID});

  Feed.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['user_id'];
    post = json['Post'];
    postDiscription = json['Post_discription'];
    totallikesofpost = json['totallikesofpost'];
    totalComments = json['totalcomments'];
    if (json['likedpeopledata'] != null) {
      likedpeopledata = <Likesofposts>[];
      json['likedpeopledata'].forEach((v) {
        likedpeopledata!.add(Likesofposts.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user_id'] = userId;
    data['Post'] = post;
    data['Post_discription'] = postDiscription;
    data['totallikesofpost'] = totallikesofpost;
    if (likedpeopledata != null) {
      data['likedpeopledata'] =
          likedpeopledata!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    return data;
  }
}
