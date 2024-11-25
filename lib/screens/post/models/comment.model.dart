class Comment {
  String? sId;
  String? postId;
  String? text;
  Commentdetails? commentdetails;
  List<CommentlikerDetails>? commentlikerDetails;
  int? totallikesofcomments;
  List<CommentReply>? replies;
  bool? isLiked;

  Comment(
      {this.sId,
      this.postId,
      this.text,
      this.commentdetails,
      this.commentlikerDetails,
      this.totallikesofcomments,
      this.replies,
      this.isLiked
      });

  Comment.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    postId = json['post_id'];
    text = json['text'];
    commentdetails = json['commentdetails'] != null
        ? Commentdetails.fromJson(json['commentdetails'])
        : null;
    if (json['commentlikerDetails'] != null) {
      commentlikerDetails = <CommentlikerDetails>[];
      json['commentlikerDetails'].forEach((v) {
        commentlikerDetails!.add(CommentlikerDetails.fromJson(v));
      });
    }
    totallikesofcomments = json['totallikesofcomments'];
    if (json['replies'] != null) {
      replies = <CommentReply>[];
      json['replies'].forEach((v) {
        replies!.add(CommentReply.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['post_id'] = postId;
    data['text'] = text;
    if (commentdetails != null) {
      data['commentdetails'] = commentdetails!.toJson();
    }
    if (commentlikerDetails != null) {
      data['commentlikerDetails'] =
          commentlikerDetails!.map((v) => v.toJson()).toList();
    }
    data['totallikesofcomments'] = totallikesofcomments;
    if (replies != null) {
      data['replies'] = replies!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Commentdetails {
  String? sId;
  String? firstname;
  String? profileImg;
  String? token;

  Commentdetails({this.sId, this.firstname, this.profileImg, this.token});

  Commentdetails.fromJson(Map<String, dynamic> json) {
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


class CommentlikerDetails {
  String? sId;
  String? firstname;
  String? profileImg;
  String? token;

  CommentlikerDetails({this.sId, this.firstname, this.profileImg, this.token});

  CommentlikerDetails.fromJson(Map<String, dynamic> json) {
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

class CommentReply {
  String? sId;
  String? postId;
  String? commentId;
  String? text;
  Commentdetails? commentdetails;
  List<CommentlikerDetails>? commentlikerDetails;
  int? totallikesofcomments;
  bool? isLiked;
  CommentReply(
      {this.sId,
      this.postId,
      this.commentId,
      this.text,
      this.commentdetails,
      this.commentlikerDetails,
      this.totallikesofcomments,
      this.isLiked
      });

  CommentReply.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    postId = json['post_id'];
    commentId = json['comment_id'];
    text = json['text'];
    commentdetails = json['commentdetails'] != null
        ? Commentdetails.fromJson(json['commentdetails'])
        : null;
    if (json['commentlikerDetails'] != null) {
      commentlikerDetails = <CommentlikerDetails>[];
      json['commentlikerDetails'].forEach((v) {
        commentlikerDetails!.add(CommentlikerDetails.fromJson(v));
      });
    }
    totallikesofcomments = json['totallikesofcomments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['post_id'] = postId;
    data['comment_id'] = commentId;
    data['text'] = text;
    if (commentdetails != null) {
      data['commentdetails'] = commentdetails!.toJson();
    }
    if (commentlikerDetails != null) {
      data['commentlikerDetails'] =
          commentlikerDetails!.map((v) => v.toJson()).toList();
    }
    data['totallikesofcomments'] = totallikesofcomments;
    return data;
  }
}
