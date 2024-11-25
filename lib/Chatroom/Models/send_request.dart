class SendRequest {
  String? fromUser;
  String? groupId;
  bool? requestPending;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  SendRequest(
      {this.fromUser,
      this.groupId,
      this.requestPending,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  SendRequest.fromJson(Map<String, dynamic> json) {
    fromUser = json['fromUser'];
    groupId = json['group_id'];
    requestPending = json['requestPending'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fromUser'] = this.fromUser;
    data['group_id'] = this.groupId;
    data['requestPending'] = this.requestPending;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
