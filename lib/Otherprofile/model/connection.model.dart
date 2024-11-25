class Connection {
  String? Id;
  String? firstname;
  String? profileImg;

  Connection({this.Id, this.firstname, this.profileImg});

  Connection.fromJson(Map<String, dynamic> json) {
    Id = json['_id'];
    firstname = json['firstname'];
    profileImg = json['profile_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.Id;
    data['firstname'] = this.firstname;
    data['profile_img'] = this.profileImg;
    return data;
  }
}
