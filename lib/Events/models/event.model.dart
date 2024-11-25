// class EventModel {
//   String? id;
//   String? userId;
//   String? eventname;
//   String? eventdescription;
//   String? eventlocation;
//   String? eventimage;
//   String? eventtime;
//   String? eventlink;
//   String? createdAt;
//   String? updatedAt;
//   int? iV;

//   EventModel(
//       {this.id,
//       this.userId,
//       this.eventname,
//       this.eventdescription,
//       this.eventlocation,
//       this.eventimage,
//       this.eventtime,
//       this.eventlink,
//       this.createdAt,
//       this.updatedAt,
//       this.iV});

//   EventModel.fromJson(Map<String, dynamic> json) {
//     id = json['_id'];
//     userId = json['user_id'];
//     eventname = json['eventname'];
//     eventdescription = json['eventdescription'];
//     eventlocation = json['eventlocation'];
//     eventimage = json['eventimage'];
//     eventtime = json['eventtime'];
//     eventlink = json['eventlink'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     iV = json['__v'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  <String, dynamic>{};
//     data['_id'] = id;
//     data['user_id'] = userId;
//     data['eventname'] = eventname;
//     data['eventdescription'] = eventdescription;
//     data['eventlocation'] = eventlocation;
//     data['eventimage'] = eventimage;
//     data['eventtime'] = eventtime;
//     data['eventlink'] = eventlink;
//     data['createdAt'] = createdAt;
//     data['updatedAt'] = updatedAt;
//     data['__v'] = iV;
//     return data;
//   }
// }


class EventModel {
  String? Id;
  String? userId;
  String? eventname;
  String? eventdescription;
  String? eventlocation;
  String? eventimage;
  String? eventtime;
  String? eventlink;
  String? eventendtime;
  String? createdAt;
  String? updatedAt;
  int? iV;

  EventModel(
      {this.Id,
      this.userId,
      this.eventname,
      this.eventdescription,
      this.eventlocation,
      this.eventimage,
      this.eventtime,
      this.eventlink,
      this.eventendtime,
      this.createdAt,
      this.updatedAt,
      this.iV});

  EventModel.fromJson(Map<String, dynamic> json) {
    Id = json['_id'];
    userId = json['user_id'];
    eventname = json['eventname'];
    eventdescription = json['eventdescription'];
    eventlocation = json['eventlocation'];
    eventimage = json['eventimage'];
    eventtime = json['eventtime'];
    eventlink = json['eventlink'];
    eventendtime = json['eventendtime'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  String? get eventStartTime => null;

  get eventdate => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.Id;
    data['user_id'] = this.userId;
    data['eventname'] = this.eventname;
    data['eventdescription'] = this.eventdescription;
    data['eventlocation'] = this.eventlocation;
    data['eventimage'] = this.eventimage;
    data['eventtime'] = this.eventtime;
    data['eventlink'] = this.eventlink;
    data['eventendtime'] = this.eventendtime;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

