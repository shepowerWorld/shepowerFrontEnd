class AllgroupsModel {
  String? sId;
  List<JoiningGroup>? joiningGroup;
  String? roomId;
  JoiningGroup? adminId;
  String? groupProfileImg;
  String? groupabout;
  int? totalParticepants;
  int? totalrequestcount;
  List<TotalRequests>? totalrequests;
  bool? adminBlock;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? groupName;

  AllgroupsModel(
      {this.sId,
      this.joiningGroup,
      this.roomId,
      this.adminId,
      this.groupProfileImg,
      this.groupabout,
      this.totalParticepants,
      this.totalrequestcount,
      this.totalrequests,
      this.adminBlock,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.groupName});

  AllgroupsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['joining_group'] != null) {
      joiningGroup = <JoiningGroup>[];
      json['joining_group'].forEach((v) {
        joiningGroup!.add(new JoiningGroup.fromJson(v));
      });
    }
    roomId = json['room_id'];
    adminId = json['admin_id'] != null
        ? new JoiningGroup.fromJson(json['admin_id'])
        : null;
    groupProfileImg = json['group_profile_img'];
    groupabout = json['Groupabout'];
    totalParticepants = json['totalParticepants'];
    totalrequestcount = json['totalrequestcount'];
    if (json['totalrequest'] != null) {
      totalrequests = <TotalRequests>[];
      json['totalrequest'].forEach((v) {
        totalrequests!.add(new TotalRequests.fromJson(v));
      });
    }
    adminBlock = json['adminBlock'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    groupName = json['groupName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.joiningGroup != null) {
      data['joining_group'] =
          this.joiningGroup!.map((v) => v.toJson()).toList();
    }
    data['room_id'] = this.roomId;
    if (this.adminId != null) {
      data['admin_id'] = this.adminId!.toJson();
    }
    data['group_profile_img'] = this.groupProfileImg;
    data['Groupabout'] = this.groupabout;
    data['totalParticepants'] = this.totalParticepants;
    data['adminBlock'] = this.adminBlock;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['groupName'] = this.groupName;
    return data;
  }
}

class JoiningGroup {
  String? sId;
  String? firstname;
  int? mobilenumber;
  String? profileImg;

  JoiningGroup({this.sId, this.firstname, this.mobilenumber, this.profileImg});

  JoiningGroup.fromJson(Map<String, dynamic> json) {
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

class TotalRequests {
  String? sId;
  String? firstname;
  int? mobilenumber;
  String? profileImg;

  TotalRequests({this.sId, this.firstname, this.mobilenumber, this.profileImg});

  TotalRequests.fromJson(Map<String, dynamic> json) {
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
