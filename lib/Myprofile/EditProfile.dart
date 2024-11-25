import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shepower/Events/createeven.services.dart';
import 'package:Shepower/Events/place.model.dart';
import 'package:Shepower/Myprofile/apiconprofile.dart';
import 'package:Shepower/common/cache.service.dart';
import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_borders/input_borders/gradient_outline_input_border.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class Al1category {
  final String category;

  Al1category({
    required this.category,
  });
}

class Al1subcategory {
  final String subcategory;

  Al1subcategory({
    required this.subcategory,
  });
}

class editprofile extends StatefulWidget {
  const editprofile({Key? key});

  @override
  State<editprofile> createState() => _profileState();
}

class _profileState extends State<editprofile> {
  List<List<String>> selectedCategoriesList = [
    [],
    [],
    [],
    [],
    [],
    [],
    [],
  ];
  List<Al1category?> Allcategories = [];
  List<Al1subcategory?> Al1Movies = [];
  List<Al1subcategory?> Al1music = [];
  List<Al1subcategory?> Al1books = [];
  List<Al1subcategory?> Al1dance = [];
  List<Al1subcategory?> Al1sports = [];
  List<Al1subcategory?> Al1others = [];

  final secureStorage = const FlutterSecureStorage();
  List<String> languagesList = [];
  String? selectedLanguage;
  String? responseData;
  DateTime? selectedDate;
  String profileID = '';
  String profileImg = '';
  File? PickimagePath;
  String location = '';
  String myId = '';
  String Name = "";
  int? Phone;
  String Mail = "";
  String birth = "";
  String Eduction = "";
  String Profession = "";
  String city = "";
  String FamilyMemebers = "";
  String language = "";
  List<String> movies = [];
  List<String> music = [];
  List<String> books = [];
  List<String> dance = [];
  List<String> sports = [];
  List<String> otherintrests = [];
  List<String> category = [];
  String mobile = "";
  String? categoryarray1 = "";
  String? categoryarray2 = "";
  String? categoryarray3 = "";
  String? categoryarray4 = "";
  String? categoryarray5 = "";
  String? categoryarray6 = "";

  String privacySetting = '';
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController professionController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController familyMembersController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController moviesController = TextEditingController();
  TextEditingController musicController = TextEditingController();
  TextEditingController danceController = TextEditingController();
  TextEditingController sportsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileID();
    subcategories1();
    category1();
    fetchLanguages();

    const fiveMinutes = Duration(minutes: 1);
    Timer.periodic(fiveMinutes, (Timer timer) {
      category1();
      subcategories1();
      fetchLanguages();
    });
  }

  void setPrivacySetting(String setting) {
    setState(() {
      privacySetting = setting;
    });

    print('setting===>>>$setting');
    if (setting == 'public') {
      ApiprofileService.visibleprofiledata();
    } else if (setting == 'private') {
      ApiprofileService.Hideprofiledata();
    } else if (setting == 'connected') {
      ApiprofileService.connectedprofiledata();
    }
  }

  void setPrivacySetting1(String setting) {
    setState(() {
      privacySetting = setting;
    });

    print('setting===>>>$setting');
    if (setting == 'public') {
      ApiprofileService.visibleprofiledata1();
    } else if (setting == 'private') {
      ApiprofileService.Hideprofiledata1();
    } else if (setting == 'connected') {
      ApiprofileService.connectedprofiledata1();
    }
  }

  void setPrivacySetting2(String setting) {
    setState(() {
      privacySetting = setting;
    });

    print('setting===>>>$setting');
    if (setting == 'public') {
      ApiprofileService.visibleprofiledata2();
    } else if (setting == 'private') {
      ApiprofileService.Hideprofiledata2();
    } else if (setting == 'connected') {
      ApiprofileService.connectedprofiledata2();
    }
  }

  void setPrivacySetting3(String setting) {
    setState(() {
      privacySetting = setting;
    });

    print('setting===>>>$setting');
    if (setting == 'public') {
      ApiprofileService.visibleprofiledata3();
    } else if (setting == 'private') {
      ApiprofileService.Hideprofiledata3();
    } else if (setting == 'connected') {
      ApiprofileService.connectedprofiledata3();
    }
  }

  void setPrivacySetting4(String setting) {
    setState(() {
      privacySetting = setting;
    });

    print('setting===>>>$setting');
    if (setting == 'public') {
      ApiprofileService.visibleprofiledata4();
    } else if (setting == 'private') {
      ApiprofileService.Hideprofiledata4();
    } else if (setting == 'connected') {
      ApiprofileService.connectedprofiledata4();
    }
  }

  void setPrivacySetting5(String setting) {
    setState(() {
      privacySetting = setting;
    });

    print('setting===>>>$setting');
    if (setting == 'public') {
      ApiprofileService.visibleprofiledata5();
    } else if (setting == 'private') {
      ApiprofileService.Hideprofiledata5();
    } else if (setting == 'connected') {
      ApiprofileService.connectedprofiledata5();
    }
  }

  void educationView() async {
    await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 350, 16, 100),
      items: [
        PopupMenuItem(
          child: const Text('Public'),
          onTap: () {
            setPrivacySetting('public');
          },
        ),
        PopupMenuItem(
          child: const Text('Private'),
          onTap: () {
            print('private1==');
            setPrivacySetting('private');
            print('private==');
          },
        ),
        PopupMenuItem(
          child: const Text('Connected'),
          onTap: () {
            setPrivacySetting('connected');
          },
        ),
      ],
    );
  }

  void dobView() async {
    await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 350, 16, 100),
      items: [
        PopupMenuItem(
          child: const Text('Public'),
          onTap: () {
            setPrivacySetting1('public');
          },
        ),
        PopupMenuItem(
          child: const Text('Private'),
          onTap: () {
            setPrivacySetting1('private');
          },
        ),
        PopupMenuItem(
          child: const Text('Connected'),
          onTap: () {
            setPrivacySetting1('connected');
          },
        ),
      ],
    );
  }

  void professionView() async {
    await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 350, 16, 100),
      items: [
        PopupMenuItem(
          child: const Text('Public'),
          onTap: () {
            setPrivacySetting2('public');
          },
        ),
        PopupMenuItem(
          child: const Text('Private'),
          onTap: () {
            setPrivacySetting2('private');
          },
        ),
        PopupMenuItem(
          child: const Text('Connected'),
          onTap: () {
            setPrivacySetting2('connected');
          },
        ),
      ],
    );
  }

  void cityView() async {
    await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 350, 16, 100),
      items: [
        PopupMenuItem(
          child: const Text('Public'),
          onTap: () {
            setPrivacySetting3('public');
          },
        ),
        PopupMenuItem(
          child: const Text('Private'),
          onTap: () {
            setPrivacySetting3('private');
          },
        ),
        PopupMenuItem(
          child: const Text('Connected'),
          onTap: () {
            setPrivacySetting3('connected');
          },
        ),
      ],
    );
  }

  void familymembersView() async {
    await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 350, 16, 100),
      items: [
        PopupMenuItem(
          child: const Text('Public'),
          onTap: () {
            setPrivacySetting4('public');
          },
        ),
        PopupMenuItem(
          child: const Text('Private'),
          onTap: () {
            setPrivacySetting4('private');
          },
        ),
        PopupMenuItem(
          child: const Text('Connected'),
          onTap: () {
            setPrivacySetting4('connected');
          },
        ),
      ],
    );
  }

  void languagesView() async {
    await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 350, 16, 100),
      items: [
        PopupMenuItem(
          child: const Text('Public'),
          onTap: () {
            setPrivacySetting5('public');
          },
        ),
        PopupMenuItem(
          child: const Text('Private'),
          onTap: () {
            setPrivacySetting5('private');
          },
        ),
        PopupMenuItem(
          child: const Text('Connected'),
          onTap: () {
            setPrivacySetting5('connected');
          },
        ),
      ],
    );
  }

  Future<void> _loadProfileID() async {
    final profileData = await GetProfileProfile();
    if (mounted) {
      setState(() {
        profileImg = profileData['profileImg'];
        profileID = profileData['profileID'];
        location = profileData['location'];
        myId = profileData['myId'];
        Name = profileData['name'];
        Mail = profileData['email'];
        birth = profileData['dob'];
        Eduction = profileData['education'];
        Profession = profileData['profession'];
        city = profileData['location'];
        FamilyMemebers = profileData['Fmily'];
        selectedLanguage = profileData['languages'];
        movies = profileData['movies'];
        music = profileData['music'];
        books = profileData['books'];
        dance = profileData['dance'];
        sports = profileData['sports'];
        mobile = profileData['mobile'];
        otherintrests = profileData['otherintrests'];
      });
    }
    String dateTimeString = birth;
    DateTime dateTime = DateTime.parse(dateTimeString);
    print('dateTimedateTime$dateTime');

    firstNameController.text = Name;
    emailController.text = Mail;
    dobController.text = DateFormat('yyyy-MM-dd').format(dateTime);
    educationController.text = Eduction;
    cityController.text = city;
    professionController.text = Profession;
    familyMembersController.text = FamilyMemebers;
    languageController.text = language;
    selectedCategoriesList[0] = movies;
    selectedCategoriesList[1] = music;
    selectedCategoriesList[2] = books;
    selectedCategoriesList[3] = dance;
    selectedCategoriesList[4] = sports;
    selectedCategoriesList[5] = otherintrests;
    mobileNumberController.text = mobile;
  }

  Future<Map<String, dynamic>> GetProfileProfile() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request =
        http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getMyprofile/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      String profileID = data['result']['profileID'];
      String profileImg = data['result']['profile_img'];
      String location = data['result']['location'];
      String myId = data['result']['_id'];
      String name = data['result']['firstname'];
      String email = data['result']['email'];
      String dobString = data['result']['dob'];
      String mobile = data['result']['mobilenumber'].toString();
      String education = data['result']['education'];
      String profession = data['result']['proffession'];
      String family = data['result']['familymembers'].join(', ');
      String languages = data['result']['languages'].join(', ');
      List<String> movies =
          List<String>.from(data['result']['areaofintrest']['movies']);
      List<String> music =
          List<String>.from(data['result']['areaofintrest']['music']);

      List<String> books =
          List<String>.from(data['result']['areaofintrest']['books']);

      List<String> dance =
          List<String>.from(data['result']['areaofintrest']['dance']);

      List<String> sports =
          List<String>.from(data['result']['areaofintrest']['sports']);

      List<String> otherintrests =
          List<String>.from(data['result']['areaofintrest']['otherintrests']);

      return {
        'profileID': profileID,
        'profileImg': profileImg,
        'myId': myId,
        'name': name,
        "email": email,
        "dob": dobString,
        "education": education,
        "profession": profession,
        "location": location,
        "Fmily": family,
        "languages": languages,
        "movies": movies,
        "music": music,
        "books": books,
        "dance": dance,
        "sports": sports,
        "otherintrests": otherintrests,
        "mobile": mobile
      };
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  void toggleCategory(int index, String category) {
    setState(() {
      if (selectedCategoriesList[index].contains(category)) {
        selectedCategoriesList[index].remove(category);
      } else {
        selectedCategoriesList[index].add(category);
      }
    });
  }

  Future<void> fetchLanguages() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request =
          http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getLanguages'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        Map<String, dynamic> data = json.decode(responseBody);

        if (data['result'] is List) {
          var languages = (data['result'] as List);
          languages.forEach((lang) {
            setState(() {
              languagesList.add(lang['languages']);
            });
            print('Language: ${lang['languages']}');
          });
        } else {
          print(response.reasonPhrase);
          throw Exception('Failed to fetch data');
        }
      } else {
        print(response.reasonPhrase);
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> UpdateCitizenProfile() async {
    print("firstNameController${firstNameController.text}");

    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String email = emailController.text;
    String profession = professionController.text;
    String city = cityController.text;
    String education = educationController.text;
    String dateOfBirth = dobController.text;
    List<String> languages =
        languageController.text.split(',').map((e) => e.trim()).toList();
    List<String> familyMembers =
        familyMembersController.text.split(',').map((e) => e.trim()).toList();

    final selectedInterests = {
      'movies': selectedCategoriesList[0],
      'music': selectedCategoriesList[1],
      'books': selectedCategoriesList[2],
      'dance': selectedCategoriesList[3],
      'sports': selectedCategoriesList[4],
      'otherintrests': selectedCategoriesList[5],
    };

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'PUT', Uri.parse('${ApiConfig.baseUrl}updateProfileCitizen'));

    request.body = json.encode({
      "_id": id,
      "lastname": lastName,
      "firstname": firstName,
      "email": email,
      "dob": dateOfBirth,
      "education": education,
      "proffession": profession,
      "familymembers": familyMembers,
      "languages": languages,
      "movies": selectedInterests['movies'],
      "music": selectedInterests['music'],
      "books": selectedInterests['books'],
      "dance": selectedInterests['dance'],
      "sports": selectedInterests['sports'],
      "otherintrests": selectedInterests['otherintrests'],
      "location": city
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      updateProfileImage(profileImg);
      showSuccessDialog();
    } else {
      print(response.reasonPhrase);
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.pink[300],
                strokeWidth: 2,
              ),
            );
          } else {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD80683),
                          Color(0xFF630772),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: const Icon(
                      Icons.done,
                      size: 48.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  const Center(
                    child: Text(
                      "Profile Updated Successfully",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD80683),
                            Color(0xFF630772),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Ok',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> UpdateLeaderProfile() async {
    print('commin g upto here');
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String email = emailController.text;
    String profession = professionController.text;
    String city = cityController.text;
    String education = educationController.text;
    String dateOfBirth = dobController.text;
    List<String> languages =
        languageController.text.split(',').map((e) => e.trim()).toList();
    List<String> familyMembers =
        familyMembersController.text.split(',').map((e) => e.trim()).toList();

    final selectedInterests = {
      'movies': selectedCategoriesList[0],
      'music': selectedCategoriesList[1],
      'books': selectedCategoriesList[2],
      'dance': selectedCategoriesList[3],
      'sports': selectedCategoriesList[4],
      'otherintrests': selectedCategoriesList[5],
    };

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request(
        'PUT', Uri.parse('${ApiConfig.baseUrl}updateProfileLeader'));

    request.body = json.encode({
      "_id": id,
      "lastname": lastName,
      "firstname": firstName,
      "email": email,
      "dob": dateOfBirth,
      "education": education,
      "proffession": profession,
      "familymembers": familyMembers,
      "languages": languages,
      "movies": selectedInterests['movies'],
      "music": selectedInterests['music'],
      "books": selectedInterests['books'],
      "dance": selectedInterests['dance'],
      "sports": selectedInterests['sports'],
      "otherintrests": selectedInterests['otherintrests'],
      "location": city
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      updateProfileImage(profileImg);
      showSuccessDialog();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      profileImg = pickedFile.path;
      PickimagePath = File(pickedFile.path);
    });

    if (profileID.startsWith('citizen')) {
      await updateImage(profileImg);
    } else {
      await createProfileleaderImage(File(pickedFile.path));
    }
  }

  void clearImageCache() {
    PaintingBinding.instance?.imageCache?.clear();
    PaintingBinding.instance?.imageCache?.clearLiveImages();
  }

  Future<void> updateImage(String profileimg) async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    String url = profileID.startsWith('citizen')
        ? '${ApiConfig.baseUrl}updateProfileCitizenimg'
        : '${ApiConfig.baseUrl}updateProfileLeaderimg';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.MultipartRequest('PUT', Uri.parse(url));
    request.fields.addAll({
      '_id': id!,
    });
    request.files
        .add(await http.MultipartFile.fromPath('profile_img', profileimg));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
    } else {
      print(response.reasonPhrase);
    }
  }

  updateProfileImage(String profileImg) async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    try {
      final myId = await CacheService.getUserId();
      if (myId == null || myId == "") return;
      bool isCitizen = profileID.startsWith('citizen');
      String url = isCitizen
          ? '${ApiConfig.baseUrl}updateProfileCitizenimg'
          : '${ApiConfig.baseUrl}updateProfileLeaderimg';

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };

      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.fields['_id'] = '$id';
      request.files.add(await http.MultipartFile.fromPath(
          'profile_img', profileImg,
          contentType: MediaType('image', 'png')));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseData = json.decode(await response.stream.bytesToString());
      if (response.statusCode == 200) {
        clearImageCache();
        setState(() {
          profileImg = profileImg;
        });
      } else {
        print('HTTP Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error updating profile image: $e");
    }
  }

  Future<void> category1() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getCategory'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      List<dynamic> responseList = data['intrest'];

      categoryarray1 = Allcategories[0]?.category;
      categoryarray2 = Allcategories[1]?.category;
      categoryarray3 = Allcategories[2]?.category;
      categoryarray4 = Allcategories[3]?.category;
      categoryarray5 = Allcategories[4]?.category;
      categoryarray6 = Allcategories[5]?.category;

      setState(() {
        Allcategories = responseList
            .map((item) => Al1category(
                  category: item['name'] as String,
                ))
            .toList();
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> subcategories1() async {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request =
        http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getSubCategory'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      print('data===>>$data');
      int categoryIndex = 0;
      List<dynamic> responseList =
          data['categoryList'][categoryIndex]['subcategories'];
      print('responseList$responseList');
      setState(() {
        Al1Movies = responseList
            .map((item) => Al1subcategory(
                  subcategory: item['name'] as String,
                ))
            .toList();
      });

      List<dynamic> responseList1 = data['categoryList'][1]['subcategories'];

      setState(() {
        Al1music = responseList1
            .map((item) => Al1subcategory(
                  subcategory: item['name'] as String,
                ))
            .toList();
      });

      List<dynamic> responseList2 = data['categoryList'][2]['subcategories'];

      setState(() {
        Al1books = responseList2
            .map((item) => Al1subcategory(
                  subcategory: item['name'] as String,
                ))
            .toList();
      });

      List<dynamic> responseList3 = data['categoryList'][3]['subcategories'];

      setState(() {
        Al1dance = responseList3
            .map((item) => Al1subcategory(
                  subcategory: item['name'] as String,
                ))
            .toList();
      });
      List<dynamic> responseList4 = data['categoryList'][4]['subcategories'];

      setState(() {
        Al1sports = responseList4
            .map((item) => Al1subcategory(
                  subcategory: item['name'] as String,
                ))
            .toList();
      });

      List<dynamic> responseList5 = data['categoryList'][5]['subcategories'];

      setState(() {
        Al1others = responseList5
            .map((item) => Al1subcategory(
                  subcategory: item['name'] as String,
                ))
            .toList();
      });
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> createProfileleaderImage(File pickedFile) async {
    try {
      const storage = FlutterSecureStorage();
      String? id = await storage.read(key: '_id');
      String? accesstoken = await storage.read(key: 'accessToken');

      if (id == null) {
        print('ID and/or Authorization not found in secure storage.');
        return;
      }

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}createProfileLeaderimg'),
      );

      request.fields['user_id'] = id;

      request.files.add(
          await http.MultipartFile.fromPath('profile_img', pickedFile.path));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        updateProfileImage(profileImg);
      } else {}
    } catch (e) {
      print("Error creating profile image: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: SizedBox(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    SizedBox(
                      height: 54.h,
                      width: 364.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100,
                            height: 60,
                            child: Image.asset("assets/Splash/shepower.png"),
                          ),
                          SizedBox(
                            width: 100.w,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 30.w,
                                height: 30.h,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: GradientBoxBorder(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color.fromRGBO(99, 7, 114, 1),
                                          Color.fromRGBO(216, 6, 131, 1)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      width: 1.5.w),
                                ),
                                child: const Icon(Icons.close_rounded,
                                    color: Color.fromRGBO(216, 6, 131, 1)),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Stack(
                        children: [
                          PickimagePath != null
                              ? Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 4,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            offset: const Offset(0, 10))
                                      ],
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                            File(profileImg),
                                          ))),
                                )
                              : Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 4,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            offset: const Offset(0, 10))
                                      ],
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            '${imagespath.baseUrl}$profileImg',
                                          ))),
                                ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  pickImage();
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 4,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    color: Color.fromRGBO(216, 6, 131, 1),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Name'.tr(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.sp, 0.sp, 11.sp, 15.sp),
                      child: Container(
                        height: 45.h,
                        width: 326.w,
                        decoration: BoxDecoration(
                            border: GradientBoxBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1)
                              ]),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.sp)),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter Your Name ',
                            hintStyle: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(116, 118, 136, 1),
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(left: 20),
                          ),
                          controller: firstNameController,
                          keyboardType: TextInputType.text,
                          cursorColor: const Color.fromARGB(162, 0, 0, 0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Phone Number'.tr(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.sp, 0.sp, 11.sp, 15.sp),
                      child: Container(
                        height: 45.h,
                        width: 326.w,
                        decoration: BoxDecoration(
                            border: GradientBoxBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1)
                              ]),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.sp)),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter Your Mobile Number ',
                            hintStyle: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(116, 118, 136, 1),
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 20.sp),
                          ),
                          controller:
                              mobileNumberController, // Add a controller here
                          keyboardType: TextInputType.number,
                          cursorColor: const Color.fromARGB(116, 118, 136, 1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Mail ID'.tr(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.sp, 0.sp, 11.sp, 15.sp),
                      child: Container(
                        height: 45.h,
                        width: 326.w,
                        decoration: BoxDecoration(
                            border: GradientBoxBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1)
                              ]),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.sp)),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter Your Email ID ',
                            hintStyle: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(116, 118, 136, 1),
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(left: 20),
                          ),
                          controller: emailController, // Add a controller here
                          keyboardType: TextInputType.text,
                          cursorColor: const Color.fromARGB(116, 118, 136, 1),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Date Of Birth'.tr(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 150.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            dobView();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.visibility,
                              size: 22.sp,
                              color: const Color.fromRGBO(216, 6, 131, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.sp, 0.sp, 11.sp, 15.sp),
                      child: Container(
                        height: 45.h,
                        width: 326.w,
                        decoration: BoxDecoration(
                          border: GradientBoxBorder(
                            gradient: const LinearGradient(colors: [
                              Color.fromRGBO(216, 6, 131, 1),
                              Color.fromRGBO(99, 7, 114, 1)
                            ]),
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter Your Date of Birth',
                                  hintStyle: GoogleFonts.nunitoSans(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                    color:
                                        const Color.fromRGBO(116, 118, 136, 1),
                                  ),
                                  counterText: '',
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                ),
                                controller: dobController,
                                keyboardType: TextInputType.text,
                                cursorColor:
                                    const Color.fromARGB(116, 118, 136, 1),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: 10.w), // Adjust the value as needed
                                child: const Icon(
                                  Icons.edit_calendar,
                                  color: Color.fromRGBO(116, 118, 136, 1),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Education'.tr(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            educationView();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.visibility,
                              size: 22.sp,
                              color: const Color.fromRGBO(216, 6, 131, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.sp, 0.sp, 11.sp, 15.sp),
                      child: Container(
                        height: 45.h,
                        width: 326.w,
                        decoration: BoxDecoration(
                            border: GradientBoxBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1)
                              ]),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.sp)),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter Your Education ',
                            hintStyle: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(116, 118, 136, 1),
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(left: 20),
                          ),
                          controller:
                              educationController, // Add a controller here
                          keyboardType: TextInputType.text,
                          cursorColor: const Color.fromARGB(116, 118, 136, 1),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Profession'.tr(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            professionView();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.visibility,
                              size: 22.sp,
                              color: const Color.fromRGBO(216, 6, 131, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.sp, 0.sp, 11.sp, 15.sp),
                      child: Container(
                        height: 45.h,
                        width: 326.w,
                        decoration: BoxDecoration(
                            border: GradientBoxBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1)
                              ]),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.sp)),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter Your Profession ',
                            hintStyle: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(116, 118, 136, 1),
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(left: 20),
                          ),
                          controller:
                              professionController, // Add a controller here
                          keyboardType: TextInputType.text,
                          cursorColor: const Color.fromARGB(116, 118, 136, 1),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'City'.tr(),
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            cityView();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                              right: 10,
                            ),
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.visibility,
                              size: 22.sp,
                              color: const Color.fromRGBO(216, 6, 131, 1),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: SizedBox(
                            height: 45.h,
                            width: 326.w,
                            child: TypeAheadField<Predictions>(
                              textFieldConfiguration: TextFieldConfiguration(
                                decoration: InputDecoration(
                                  hintText: 'City you live in',
                                  hintStyle: GoogleFonts.nunitoSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  counterText: '',
                                  border: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1.w,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  focusedBorder: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1.w,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                ),
                                controller: cityController,
                                keyboardType: TextInputType.text,
                                cursorColor: const Color.fromRGBO(0, 0, 0, 1),
                              ),
                              suggestionsCallback: (pattern) async {
                                // Fetch auto-suggestions based on the user's input (pattern)
                                return await EventService().getPlaces(pattern);
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion.description ?? "-"),
                                );
                              },
                              onSuggestionSelected: (suggestion) {
                                setState(() {
                                  cityController.text =
                                      suggestion.description ?? "";
                                  print(cityController
                                      .text); // Print the selected value for debugging
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Family Members'.tr(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 130.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            familymembersView();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.visibility,
                              size: 22.sp,
                              color: const Color.fromRGBO(216, 6, 131, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.sp, 0.sp, 11.sp, 15.sp),
                      child: Container(
                        height: 45.h,
                        width: 326.w,
                        decoration: BoxDecoration(
                            border: GradientBoxBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1)
                              ]),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.sp)),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'add  family members',
                            hintStyle: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(116, 118, 136, 1),
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(left: 20),
                          ),
                          controller:
                              familyMembersController, // Add a controller here

                          keyboardType: TextInputType.text,
                          cursorColor: const Color.fromARGB(116, 118, 136, 1),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('App Languages'.tr(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            languagesView();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.visibility,
                              size: 22.sp,
                              color: const Color.fromRGBO(216, 6, 131, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        _openModalDialog(context);
                      },
                      child: Row(
                        children: [
                          Container(
                            height: 45.h,
                            width: 323.w,
                            padding: EdgeInsets.only(left: 10.w, top: 10.h),
                            decoration: BoxDecoration(
                              border: GradientBoxBorder(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromRGBO(216, 6, 131, 1),
                                    Color.fromRGBO(99, 7, 114, 1),
                                  ],
                                ),
                                width: 1.w,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                selectedLanguage ?? 'Select Language',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 10.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 15.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Areas of Interests'.tr(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 7.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(categoryarray1.toString(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    for (int i = 0; i < Al1Movies.length; i += 3)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int j = i;
                                  j < i + 3 && j < Al1Movies.length;
                                  j++)
                                if (Al1Movies[j]?.subcategory != null)
                                  buildCategoryContainer(
                                      0, Al1Movies[j]!.subcategory),
                            ],
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(categoryarray2.toString(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    // Music Contents
                    SizedBox(height: 16.h),
                    for (int i = 0; i < Al1music.length; i += 3)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int j = i;
                                  j < i + 3 && j < Al1music.length;
                                  j++)
                                if (Al1music[j]?.subcategory != null)
                                  buildCategoryContainer(
                                      1, Al1music[j]!.subcategory),
                              SizedBox(height: 10.h),
                            ],
                          ),
                          SizedBox(
                            height: 10.h,
                          )
                        ],
                      ),

                    // Book Contents
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(categoryarray3.toString(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    for (int i = 0; i < Al1books.length; i += 3)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int j = i;
                                  j < i + 3 && j < Al1dance.length;
                                  j++)
                                if (Al1books[j]?.subcategory != null)
                                  buildCategoryContainer(
                                      2, Al1books[j]!.subcategory),
                              SizedBox(height: 10.h),
                            ],
                          ),
                          SizedBox(height: 10.h)
                        ],
                      ),
                    // Dance Contents
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(categoryarray4.toString(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    for (int i = 0; i < Al1dance.length; i += 3)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int j = i;
                                  j < i + 3 && j < Al1dance.length;
                                  j++)
                                if (Al1dance[j]?.subcategory != null)
                                  buildCategoryContainer(
                                      3, Al1dance[j]!.subcategory),
                              SizedBox(height: 10.h),
                            ],
                          ),
                          SizedBox(height: 10.h)
                        ],
                      ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(categoryarray5.toString(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    for (int i = 0; i < Al1sports.length; i += 3)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int j = i;
                                  j < i + 3 && j < Al1sports.length;
                                  j++)
                                if (Al1sports[j]?.subcategory != null)
                                  buildCategoryContainer(
                                      4, Al1sports[j]!.subcategory),
                              SizedBox(height: 10.h),
                            ],
                          ),
                          SizedBox(height: 10.h)
                        ],
                      ),

                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(categoryarray6.toString(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    SizedBox(height: 10.h),
                    for (int i = 0; i < Al1others.length; i += 3)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int j = i;
                                  j < i + 3 && j < Al1others.length;
                                  j++)
                                if (Al1others[j]?.subcategory != null)
                                  buildCategoryContainer(
                                      5, Al1others[j]!.subcategory),
                              SizedBox(height: 10.h),
                            ],
                          ),
                          SizedBox(height: 10.h)
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(17, 0, 17, 20),
          child: SizedBox(
            width: 327.w,
            height: 48.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(216, 6, 131, 1),
                    Color.fromRGBO(99, 7, 114, 1)
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (profileID.startsWith('citizen')) {
                    await UpdateCitizenProfile();
                  } else {
                    await UpdateLeaderProfile();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Submit',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w800,
                          fontSize: 21.sp,
                          color: const Color.fromRGBO(255, 255, 255, 1),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryContainer(int index, String category) {
    final isSelected = selectedCategoriesList[index].contains(category);

    return GestureDetector(
      onTap: () => toggleCategory(index, category),
      child: Container(
          width: 82.73.w,
          height: 24.58.h,
          padding: const EdgeInsets.symmetric(horizontal: 3.75),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.73.r),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      Color.fromRGBO(216, 6, 131, 1),
                      Color.fromRGBO(99, 7, 114, 1),
                    ],
                  )
                : null,
            color: isSelected ? null : const Color.fromRGBO(237, 242, 247, 1),
          ),
          child: Center(
            child: Text(category,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 11.36.sp,
                  color: isSelected
                      ? const Color.fromRGBO(255, 255, 255, 1)
                      : const Color.fromRGBO(61, 66, 96, 1),
                )),
          )),
    );
  }

  Map<String, String> languageCodeMapping = {
    'Arabic': 'ar',
    'Bengali': 'bn',
    'Belarusian': 'be',
    'Gujarati': 'gu',
    'Kannada': 'kn',
    'Maithili': 'mai',
    'Odia': 'or',
    'Meitei': 'mni',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Marathi': 'mr',
    'Hindi': 'hi',
    'Assamese': 'as',
    'Malayalam': 'ml',
    'English': 'en',
    'Tibetic': 'bo'
  };

  void _openModalDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Choose the App Language',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: languagesList.map((String languageName) {
                          return ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(languageName),
                            subtitle: Text(languageName),
                            onTap: () {
                              String? languageCode =
                                  languageCodeMapping[languageName];
                              print('languageName: $languageName');
                              print('languageCode: $languageCode');

                              if (languageCode != null) {
                                context.setLocale(Locale(languageCode));
                                setState(() {
                                  selectedLanguage = languageName;
                                  languageController.text = languageName;
                                });
                              } else {
                                print(
                                    'Language code not found for $languageName');
                              }

                              Navigator.of(context).pop();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Colors.grey),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
