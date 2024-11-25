class Leader {
  final String id;
  final String firstname;
  final String lastname;
  final int mobilenumber;
  final String email;
  final String dob;
  final String education;
  final String profileImg;
  final String profession;
  final String location;
  final String profileID;
  final bool adminBlock;
  final bool isPublic;
  final bool isPrivate;
  final bool isConnected;
  final bool connected;
  final bool requestExists;
  final double? overallAverageRating;

  Leader({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.mobilenumber,
    required this.email,
    required this.dob,
    required this.education,
    required this.profileImg,
    required this.profession,
    required this.location,
    required this.profileID,
    required this.adminBlock,
    required this.isPublic,
    required this.isPrivate,
    required this.isConnected,
    required this.connected,
    required this.requestExists,
    this.overallAverageRating,
  });

  factory Leader.fromJson(Map<String, dynamic> json) {
    return Leader(
      id: json['_id'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      mobilenumber: json['mobilenumber'] ?? 0,
      email: json['email'] ?? '',
      dob: json['dob'] ?? '',
      education: json['education'] ?? '',
      profileImg: json['profile_img'] ?? '',
      profession: json['proffession'] ?? '',
      location: json['location'] ?? '',
      profileID: json['profileID'] ?? '',
      adminBlock: json['adminBlock'] ?? false,
      isPublic: json['public'] ?? false,
      isPrivate: json['private'] ?? false,
      connected: json['connected'] ?? false,
      isConnected: json['isConnected'] ?? false,
      requestExists: json['requestExists'] ?? false,
      overallAverageRating: json['overallAverageRating'] != null
          ? json['overallAverageRating'].toDouble()
          : null,
    );
  }
}

//citizen model
class Citizen {
  final String id;
  final String firstname;
  final String lastname;
  final int mobilenumber;
  final String email;
  final String dob;
  final String education;
  final String profileImg;
  final String profession;
  final String location;
  final String profileID;
  final bool adminBlock;
  final bool isPublic;
  final bool isPrivate;
  final bool isConnected;
  final bool connected;
  final bool requestExists;
  Citizen({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.mobilenumber,
    required this.email,
    required this.dob,
    required this.education,
    required this.profileImg,
    required this.profession,
    required this.location,
    required this.profileID,
    required this.adminBlock,
    required this.isPublic,
    required this.isPrivate,
    required this.isConnected,
    required this.connected,
    required this.requestExists,
  });

  factory Citizen.fromJson(Map<String, dynamic> json) {
    return Citizen(
      id: json['_id'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      mobilenumber: json['mobilenumber'] ?? 0,
      email: json['email'] ?? '',
      dob: json['dob'] ?? '',
      education: json['education'] ?? '',
      profileImg: json['profile_img'] ?? '',
      profession: json['proffession'] ?? '',
      location: json['location'] ?? '',
      profileID: json['profileID'] ?? '',
      adminBlock: json['adminBlock'] ?? false,
      isPublic: json['public'] ?? false,
      isPrivate: json['private'] ?? false,
      connected: json['connected'] ?? false,
      isConnected: json['isConnected'] ?? false,
      requestExists: json['requestExists'] ?? false,
    );
  }
}
