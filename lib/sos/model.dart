class CommentSosModel {
  String? leaderId;
  String? citizenId;
  String? sosId;
  String? commentSos;
  int? ratingsCount;
  int? ratings;
  String? reviews;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  CommentSosModel(
      {this.leaderId,
      this.citizenId,
      this.sosId,
      this.commentSos,
      this.ratingsCount,
      this.ratings,
      this.reviews,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  CommentSosModel.fromJson(Map<String, dynamic> json) {
    leaderId = json['leader_id'];
    citizenId = json['citizen_id'];
    sosId = json['sosId'];
    commentSos = json['commentSos'];
    ratingsCount = json['ratingsCount'];
    ratings = json['ratings'];
    reviews = json['reviews'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['leader_id'] = this.leaderId;
    data['citizen_id'] = this.citizenId;
    data['sosId'] = this.sosId;
    data['commentSos'] = this.commentSos;
    data['ratingsCount'] = this.ratingsCount;
    data['ratings'] = this.ratings;
    data['reviews'] = this.reviews;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
