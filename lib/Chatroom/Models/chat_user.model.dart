class ChatUser {
  String? sId;
  String? senderId;
  String? otherId;
  String? roomId;
  bool? blocked;
  ChatData? otherData;

  ChatData? senderData;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<Data>? data;
  String? profileImg;
  String? GroupName;

  ChatUser(
      {this.sId,
      this.senderId,
      this.otherId,
      this.roomId,
      this.blocked,
      this.otherData,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.data,
      this.profileImg,
      this.GroupName});

  ChatUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['sender_id'];
    otherId = json['other_id'];
    roomId = json['room_id'];
    blocked = json['blocked'];
    profileImg =
        json['group_profile_img'] != null ? json['group_profile_img'] : null;
    otherData = json['other_idData'] != null
        ? new ChatData.fromJson(json['other_idData'])
        : null;
    senderData = json['sender_idData'] != null
        ? new ChatData.fromJson(json['sender_idData'])
        : null;

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    GroupName = json['groupName'];
    iV = json['__v'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['sender_id'] = this.senderId;
    data['other_id'] = this.otherId;
    data['room_id'] = this.roomId;
    data['blocked'] = this.blocked;
    if (this.otherData != null) {
      data['other_idData'] = this.otherData!.toJson();
    }

    if (this.senderData != null) {
      data['sender_idData'] = this.senderData!.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChatData {
  String? sId;
  String? firstname;
  String? profileImg;
  bool? public;
  bool? private;
  bool? connected;

  ChatData(
      {this.sId,
      this.firstname,
      this.profileImg,
      this.public,
      this.private,
      this.connected});

  ChatData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstname = json['firstname'];
    profileImg = json['profile_img'];
    public = json['public'];
    private = json['private'];
    connected = json['connected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['firstname'] = this.firstname;
    data['profile_img'] = this.profileImg;
    data['public'] = this.public;
    data['private'] = this.private;
    data['connected'] = this.connected;
    return data;
  }
}

class Data {
  String? sId;
  String? senderId;
  String? senderName;
  String? message;
  String? attachment;
  String? roomId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.senderId,
      this.senderName,
      this.message,
      this.attachment,
      this.roomId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['sender_id'];
    senderName = json['senderName'];
    message = json['message'];
    attachment = json['attachment'];
    roomId = json['room_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['sender_id'] = this.senderId;
    data['senderName'] = this.senderName;
    data['message'] = this.message;
    data['attachment'] = this.attachment;
    data['room_id'] = this.roomId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
