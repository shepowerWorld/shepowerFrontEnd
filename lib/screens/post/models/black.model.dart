class BlockModel {
  String? postId;
  String? blockerId;
  String? blockReason;
  String? sId;

  BlockModel({this.postId, this.blockerId, this.blockReason, this.sId});

  BlockModel.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    blockerId = json['blocker_id'];
    blockReason = json['blockReason'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['blocker_id'] = this.blockerId;
    data['blockReason'] = this.blockReason;
    data['_id'] = this.sId;
    return data;
  }
}
