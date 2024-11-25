

class PostLikeModel {
  String? sId;
  String? postId;
  List<Likesofposts>? likesofposts;
  int? totallikesofpost;
  String? likerId;
  bool? isPostLiked;

  PostLikeModel({this.sId, this.postId, this.likesofposts, this.totallikesofpost,this.likerId,this.isPostLiked});

  PostLikeModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    postId = json['post_id'];
    if (json['likesofposts'] != null) {
      likesofposts = <Likesofposts>[];
      json['likesofposts'].forEach((v) {
        likesofposts!.add(Likesofposts.fromJson(v));
      });
    }
    totallikesofpost = json['totallikesofpost'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['liker_id'] = likerId;
    data['post_id'] = postId;
    return data;
  }
  
  Map<String, dynamic> toGetLikeOfPostMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['post_id'] = postId;
    return data;
  }
}

class Likesofposts {
  String? sId;
  String? firstname;
  String? profileImg;
  String? token;

  Likesofposts({this.sId, this.firstname, this.profileImg, this.token});

  Likesofposts.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstname = json['firstname'];
    profileImg = json['profile_img'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['firstname'] = firstname;
    data['profile_img'] = profileImg;
    data['token'] = token;
    return data;
  }
}
