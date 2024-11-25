class UserModel {
  String? sId;
  String? firstname;
  int? mobilenumber;
  String? profileImg;
  String? token;

  UserModel(
      {this.sId,
      this.firstname,
      this.mobilenumber,
      this.profileImg,
      this.token});

  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstname = json['firstname'];
    mobilenumber = json['mobilenumber'];
    profileImg = json['profile_img'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['firstname'] = this.firstname;
    data['mobilenumber'] = this.mobilenumber;
    data['profile_img'] = this.profileImg;
    data['token'] = this.token;
    return data;
  }
}