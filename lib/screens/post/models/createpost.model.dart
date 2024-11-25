import 'post_like.model.dart';

class CreatePostModel {
  String? userId;
  String? post;
  String? postDiscription;
  int? totallikesofpost;
  List<Likesofposts>? likedpeopledata;
  String? sId;
  int? iV;
  String? createdAt;
  String? updatedAt;

  CreatePostModel(
      {this.userId,
      this.post,
      this.postDiscription,
      this.totallikesofpost,
      this.likedpeopledata,
      this.sId,
      this.iV,
      this.createdAt,
      this.updatedAt});

  CreatePostModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    post = json['Post'];
    postDiscription = json['Post_discription'];
    totallikesofpost = json['totallikesofpost'];
    if (json['likedpeopledata'] != null) {
      likedpeopledata = <Likesofposts>[];
      json['likedpeopledata'].forEach((v) {
        likedpeopledata!.add(Likesofposts.fromJson(v));
      });
    }
    sId = json['_id'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['Post'] = post;
    data['Post_discription'] = postDiscription;
    data['totallikesofpost'] = totallikesofpost;
    if (likedpeopledata != null) {
      data['likedpeopledata'] =
          likedpeopledata!.map((v) => v.toJson()).toList();
    }
    data['_id'] = sId;
    data['__v'] = iV;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
