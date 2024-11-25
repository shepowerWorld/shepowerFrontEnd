class DeletePerson {
  String? sId;
  String? roomId;
  AdminId? adminId;
  String? groupProfileImg;
  String? groupabout;
  int? totalParticepants;
  int? totalrequestcount;
  bool? adminBlock;
  String? createdAt;
  String? updatedAt;
  int? iV;

  DeletePerson(
      {this.sId,
      this.roomId,
      this.adminId,
      this.groupProfileImg,
      this.groupabout,
      this.totalParticepants,
      this.adminBlock,
      this.createdAt,
      this.updatedAt,
      this.iV});

  DeletePerson.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    roomId = json['room_id'];
    adminId = json['admin_id'] != null
        ? new AdminId.fromJson(json['admin_id'])
        : null;
    groupProfileImg = json['group_profile_img'];
    groupabout = json['Groupabout'];
    totalParticepants = json['totalParticepants'];
    adminBlock = json['adminBlock'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['room_id'] = this.roomId;
    if (this.adminId != null) {
      data['admin_id'] = this.adminId!.toJson();
    }
    data['group_profile_img'] = this.groupProfileImg;
    data['Groupabout'] = this.groupabout;
    data['totalParticepants'] = this.totalParticepants;
    data['totalrequestcount'] = this.totalrequestcount;
    data['adminBlock'] = this.adminBlock;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class AdminId {
  String? sId;
  String? firstname;
  int? mobilenumber;
  String? profileImg;

  AdminId({this.sId, this.firstname, this.mobilenumber, this.profileImg});

  AdminId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstname = json['firstname'];
    mobilenumber = json['mobilenumber'];
    profileImg = json['profile_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['firstname'] = this.firstname;
    data['mobilenumber'] = this.mobilenumber;
    data['profile_img'] = this.profileImg;
    return data;
  }
}
