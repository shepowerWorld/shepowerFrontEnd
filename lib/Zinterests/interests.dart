import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Shepower/OnBoarding/Leader/location.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../service.dart';
import '../Myprofile/profile.dart';

class Interests extends StatefulWidget {
  final Map<String, dynamic> profileParameters;

  Interests({required this.profileParameters});

  @override
  _InterestsState createState() => _InterestsState();
}

class _InterestsState extends State<Interests> {
  List<List<String>> selectedCategoriesList = [
    [],
    [],
    [],
    [],
    [],
    [],
    [],
  ];

  late Map<String, dynamic> profileParameters;

  @override
  void initState() {
    super.initState();
    profileParameters = widget.profileParameters;
    // Now you can access profileParameters here and use it in the screen.
    // final firstName = profileParameters['firstName'];
    // final lastName = profileParameters['lastName'];
    // final email = profileParameters['email'];
    // final dateOfBirth = profileParameters['dateOfBirth'];
    // final education = profileParameters['education'];
    // final profession = profileParameters['profession'];
    // final city = profileParameters['city'];
    // final member = widget.profileParameters['member'];
    // final language = widget.profileParameters['language'];

    print('profileParameters$profileParameters');
  }

  final secureStorage = FlutterSecureStorage();

  Future<void> createProfile() async {
    try {
      final selectedInterests = {
        'movies': selectedCategoriesList[0],
        'music': selectedCategoriesList[1],
        'books': selectedCategoriesList[2],
        'dance': selectedCategoriesList[3],
        'sports': selectedCategoriesList[4],
        'otherintrests': selectedCategoriesList[5],
      };
      print('Selected Interests: $selectedInterests');
      final member = widget.profileParameters['member'];
      final language = widget.profileParameters['language'];

      final firstName = widget.profileParameters['firstName'];
      final lastName = widget.profileParameters['lastName'];
      final email = widget.profileParameters['email'];
      final dateOfBirth = widget.profileParameters['dateOfBirth'];
      final education = widget.profileParameters['education'];
      final profession = widget.profileParameters['profession'];
      final city = widget.profileParameters['city'];
      final List<String> languages = language.split(',');
      final List<String> familyMembers = member.split(',');

      final jsonData = {
        '_id': '64f77d2000b1224576087ce2',
        'Authorization':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjRmNzdkMjAwMGIxMjI0NTc2MDg3Y2UyIiwiaWF0IjoxNjkzOTQxMDI0fQ.TIA4-h4ahz6z0zYoqYEaJZXThH9ZsQzCXIwm8notLQA',
        'lastname': lastName,
        'firstname': firstName,
        'email': email,
        'dob': dateOfBirth,
        'education': education,
        'proffession': profession,
        'movies': selectedInterests['movies'],
        'music': selectedInterests['music'],
        'books': selectedInterests['books'],
        'dance': selectedInterests['dance'],
        'familymembers': familyMembers,
        'languages': languages,
        'sports': selectedInterests['sports'],
        'otherintrests': selectedInterests['otherintrests'],
        'location': city,
      };

      final headers = {'Content-Type': 'application/json'};

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}createProfileCitizen'),
        headers: headers,
        body: json.encode(jsonData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await secureStorage.write(
            key: 'profileResponseData', value: json.encode(responseData));
        print('Profile created successfully');
        print('Response Data: $responseData');

        //Navigate to the next screen or perform other actions
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Profile(),
          ),
        );
      } else {
        print('Failed to create profile: ${response.reasonPhrase}');
        print('Error Response: ${response.body}');
      }
    } catch (e) {
      print('Error during API request: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60.0),
            const Padding(
              padding: const EdgeInsets.only(left: 17),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Your Interests ',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF371212),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            const Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tell us about your interests, and we\nll customize your feed and connections. ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF371212),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5.0),
            const Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search interests....',
                  hintStyle: TextStyle(fontSize: 20),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Movies',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(0, 'Hollywood'),
                    buildCategoryContainer(0, 'Bollywood'),
                    buildCategoryContainer(0, 'Kollywood'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(0, 'Tollywood'),
                    buildCategoryContainer(0, 'Sandalwood'),
                    buildCategoryContainer(0, 'Pollywood'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            const Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Music',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
            // Music Contents
            SizedBox(height: 10.0),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(1, 'English'),
                    buildCategoryContainer(1, 'Hindi'),
                    buildCategoryContainer(1, 'Tamil'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(1, 'Telugu'),
                    buildCategoryContainer(1, 'Kannada'),
                    buildCategoryContainer(1, 'Malayalam'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(1, 'Urdu'),
                    buildCategoryContainer(1, 'Assamese'),
                    buildCategoryContainer(1, 'Tulu'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(1, 'Bangla'),
                    buildCategoryContainer(1, 'Oriya'),
                  ],
                ),
                // Add more rows as needed
              ],
            ),

            // Book Contents
            const SizedBox(height: 10.0),
            const Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Books',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(2, 'English'),
                    buildCategoryContainer(2, 'Hindi'),
                    buildCategoryContainer(2, 'Tamil'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(2, 'Telugu'),
                    buildCategoryContainer(2, 'Kannada'),
                    buildCategoryContainer(2, 'Malayalam'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(2, 'Urdu'),
                    buildCategoryContainer(2, 'Punchabi'),
                    buildCategoryContainer(2, 'Tulu'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(2, 'Bangla'),
                    buildCategoryContainer(2, 'Oriya'),
                  ],
                ),
                // Add more rows as needed
              ],
            ),

            // Dance Contents
            const SizedBox(height: 10.0),
            const Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(3, 'Bharatanatyam'),
                    buildCategoryContainer(3, 'Kathak'),
                    buildCategoryContainer(3, 'Kathakali'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(3, 'Modern dance'),
                    buildCategoryContainer(3, 'Sattriya'),
                    buildCategoryContainer(3, 'Westerns'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(3, 'Modern'),
                    buildCategoryContainer(3, 'Filmy'),
                    buildCategoryContainer(3, 'Odissi'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(3, 'Manipuri Raas Leela'),
                  ],
                ),
                // Add more rows as needed
              ],
            ),
            const SizedBox(height: 10.0),
            const Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(4, 'Cricket'),
                    buildCategoryContainer(4, ' Football'),
                    buildCategoryContainer(4, 'Tennis'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(4, ' Swimming'),
                    buildCategoryContainer(4, 'Handball'),
                    buildCategoryContainer(4, 'Kabbadi'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(4, 'Golf'),
                    buildCategoryContainer(4, 'Archery'),
                    buildCategoryContainer(4, 'Javelin'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(4, 'Hockey'),
                    buildCategoryContainer(4, 'Badminton'),
                  ],
                ),
                // Add more rows as needed
              ],
            ),

            const SizedBox(height: 10.0),
            const Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Other Interests',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(5, 'Cooking'),
                    buildCategoryContainer(5, 'Baking'),
                    buildCategoryContainer(5, 'Home Decor'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(5, 'Sports'),
                    buildCategoryContainer(5, 'Social Service'),
                    buildCategoryContainer(5, 'Spirituality'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(5, 'Children '),
                    buildCategoryContainer(5, 'Teaching'),
                    buildCategoryContainer(5, 'Yoga'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(5, 'Fitness'),
                    buildCategoryContainer(5, 'Traveling'),
                    buildCategoryContainer(5, 'Learning Languages'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(5, 'Meditating'),
                    buildCategoryContainer(5, 'Crafting'),
                    buildCategoryContainer(5, ' Politics'),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryContainer(5, ' Memes'),
                    buildCategoryContainer(5, 'fashion Designing'),
                  ],
                ),
                // Add more rows as needed
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: 200,
          height: 55,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD80683), Color(0xFF630772)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ElevatedButton(
              onPressed: () {
                createProfile();
              },
              style: ElevatedButton.styleFrom(
                                         foregroundColor: Colors.transparent, backgroundColor: Colors.transparent,

                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Confirm",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ],
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
        width: 125,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFD80683), Color(0xFF630772)],
                )
              : null,
          color: isSelected ? null : Colors.grey[200],
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.normal,
              fontFamily: 'Montserrat',
              color: isSelected ? Colors.white : Color(0xFF2C2C2C),
            ),
          ),
        ),
      ),
    );
  }
}

//wellcome screen    after profile creation

class welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage(''),
            //   fit: BoxFit.cover, // You can change the fit mode as needed
            // ),
            ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFFD80683),
                      Color(0xFF630772),
                    ],
                  ).createShader(bounds);
                },
                child: const Text(
                  "That's all",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFFD80683),
                      Color(0xFF630772),
                    ],
                  ).createShader(bounds);
                },
                child: const Text(
                  "you’re In...",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.0),
        child: Container(
          width: 200,
          height: 55,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFD80683),
                  Color(0xFF630772),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Leaderlocation()),
                );
                // Navigation logic here
              },
              style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.transparent, backgroundColor: Colors.transparent,

                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Start the adventure now",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                  Icon(
                    Icons.arrow_right,
                    size: 40,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}










  // Future<void> createProfile() async {
  //   final selectedInterests = {
  //     'movies': selectedCategoriesList[0],
  //     'music': selectedCategoriesList[1],
  //     'books': selectedCategoriesList[2],
  //     'dance': selectedCategoriesList[3],
  //     'sports': selectedCategoriesList[4],
  //     'otherintrests': selectedCategoriesList[5],
  //   };
  //   print('Selected Interests: $selectedInterests');
  //   final member = widget.profileParameters['member'];
  //   final language = widget.profileParameters['language'];

  //   final firstName = widget.profileParameters['firstName'];
  //   final lastName = widget.profileParameters['lastName'];
  //   final email = widget.profileParameters['email'];
  //   final dateOfBirth = widget.profileParameters['dateOfBirth'];
  //   final education = widget.profileParameters['education'];
  //   final profession = widget.profileParameters['profession'];
  //   final city = widget.profileParameters['city'];
  //   final List<String> languages = language.split(',');
  //   final List<String> familyMembers = member.split(',');

  //   var headers = {'Content-Type': 'application/json'};
  //   var request = http.Request(
  //       'PUT', Uri.parse('${ApiConfig.baseUrl}createProfileCitizen'));
  //   request.body = json.encode({
  //     "_id": "64f5e4228a6fa73c8a27f5c2",
  //     "Authorization":
  //         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjRmNWU0MjI4YTZmYTczYzhhMjdmNWMyIiwiaWF0IjoxNjkzODM2MzIyfQ.FfZ6jv_rBhMrF2p07j9u_cBR7kmpjQxzsJb95sOswH4",
  //     "lastname": lastName,
  //     "firstname": firstName,
  //     "email": email,
  //     "dob": dateOfBirth,
  //     "education": education,
  //     "proffession": profession,
  //     "familymembers": familyMembers,
  //     "languages": languages,
  //     "movies": selectedInterests['movies'],
  //     "music": selectedInterests['music'],
  //     "books": selectedInterests['books'],
  //     "dance": selectedInterests['dance'],
  //     "sports": selectedInterests['sports'],
  //     "otherintrests": selectedInterests['otherintrests'],
  //     "location": city
  //   });
  //   request.headers.addAll(headers);

  //   http.StreamedResponse response = await request.send();

  //   if (response.statusCode == 200) {
  //     print(await response.stream.bytesToString());
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }