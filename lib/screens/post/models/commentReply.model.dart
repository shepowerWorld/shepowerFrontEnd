class CommentReplyModel {
  String? postId;
  String? commentId;
  String? text;
  Commentdetails? commentdetails;
  List<Commentdetails>? commentlikerDetails;
  String? sId;

  CommentReplyModel(
      {this.postId,
      this.commentId,
      this.text,
      this.commentdetails,
      this.commentlikerDetails,
      this.sId});

  CommentReplyModel.fromJson(Map<String, dynamic> json) {
    postId = json['post_id'];
    commentId = json['comment_id'];
    text = json['text'];
    commentdetails = json['commentdetails'] != null
        ? Commentdetails.fromJson(json['commentdetails'])
        : null;
    if (json['commentlikerDetails'] != null) {
      commentlikerDetails = <Commentdetails>[];
      json['commentlikerDetails'].forEach((v) {
        commentlikerDetails!.add(Commentdetails.fromJson(v));
      });
    }
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    data['_id'] = sId;
    return data;
  }
}

class Commentdetails {
  String? sId;
  String? firstname;
  String? profileImage;
  String? token;

  Commentdetails({this.sId, this.firstname, this.profileImage, this.token});

  Commentdetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstname = json['firstname'];
    profileImage = json['profile_img'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId; 
    data['firstname'] = firstname;
    data['profile_img'] = profileImage;
    data['token'] = token;
    print('dataaaa $data');
    return data;
  }
}

