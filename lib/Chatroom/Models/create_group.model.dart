
import 'package:Shepower/Chatroom/Models/user.model.dart';

class CreateGroupModel {
  String? sId;
  List<UserModel>? joiningGroup;
  String? roomId;
  UserModel? adminId;
  String? groupProfileImg;
  String? groupabout;
  String? groupName;
  List<UserModel>? totalrequest;
  int? totalParticepants;
  int? totalrequestcount;
  bool? adminBlock;
  String? createdAt;
  String? updatedAt;
  int? iV;

  CreateGroupModel(
      {this.sId,
      this.joiningGroup,
      this.roomId,
      this.adminId,
      this.groupProfileImg,
      this.groupabout,
      this.totalrequest,
      this.totalParticepants,
      this.totalrequestcount,
      this.adminBlock,
      this.groupName,
      this.createdAt,
      this.updatedAt,
      this.iV});

  CreateGroupModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['joining_group'] != null) {
      joiningGroup = <UserModel>[];
      json['joining_group'].forEach((v) {
        joiningGroup!.add(new UserModel.fromJson(v));
      });
    }
    roomId = json['room_id'];
    adminId = json['admin_id'] != null
        ? UserModel.fromJson(json['admin_id'])
        : null;
    groupProfileImg = json['group_profile_img'];
    groupName = json['groupName'];
    groupabout = json['Groupabout'];
    if (json['totalrequest'] != null) {
      totalrequest = <UserModel>[];
      json['totalrequest'].forEach((v) {
        totalrequest!.add(new UserModel.fromJson(v));
      });
    }
    totalParticepants = json['totalParticepants'];
    totalrequestcount = json['totalrequestcount'];
    adminBlock = json['adminBlock'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
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
    data['groupName'] = this.groupName;
    data['Groupabout'] = this.groupabout;
    if (this.totalrequest != null) {
      data['totalrequest'] = this.totalrequest!.map((v) => v.toJson()).toList();
    }
    data['totalParticepants'] = this.totalParticepants;
    data['totalrequestcount'] = this.totalrequestcount;
    data['adminBlock'] = this.adminBlock;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

