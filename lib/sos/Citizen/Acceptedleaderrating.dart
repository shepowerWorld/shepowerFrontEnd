import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:Shepower/sos/Citizen/CitiGetsos.dart';
import 'package:Shepower/sos/Citizen/sos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stylish_dialog/stylish_dialog.dart';

class AcceptLeaderScreen extends StatefulWidget {
  final List<Leader> accptedleadeLeaders;
  final String usersosid;

  const AcceptLeaderScreen(
      {Key? key, required this.accptedleadeLeaders, required this.usersosid})
      : super(key: key);

  @override
  State<AcceptLeaderScreen> createState() => _AcceptLeaderScreenState();
}

class _AcceptLeaderScreenState extends State<AcceptLeaderScreen> {
  List<TextEditingController> descriptionControllers = [];

  List<int> trustworthyRatings = List.filled(5, 0);
  List<int> knowledgeableRatings = List.filled(5, 0);
  List<int> helpfulRatings = List.filled(5, 0);
  List<int> availableRatings = List.filled(5, 0);
  List<int> courageousRatings = List.filled(5, 0);
  List<int> efficientRatings = List.filled(5, 0);

  @override
  void initState() {
    super.initState();
    descriptionControllers =
        List.generate(widget.accptedleadeLeaders.length, (_) {
      return TextEditingController();
    });
  }

  @override
  void dispose() {
    // Dispose descriptionControllers
    descriptionControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color.fromRGBO(99, 7, 114, 0.8),
                  Color.fromRGBO(228, 65, 163, 0.849),
                ],
              ).createShader(bounds);
            },
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1,
                  color: const Color.fromRGBO(99, 1, 114, 0.8),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(
                Icons.navigate_before,
                color: Colors.black,
              ),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Add Ratings',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.accptedleadeLeaders.length,
              itemBuilder: (context, index) {
                final leader = widget.accptedleadeLeaders[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.all(10),
                        title: Text(
                          leader.firstname,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Mobile: ${leader.mobilenumber}'),
                        leading: CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                              '${imagespath.baseUrl}${leader.profileImg}'),
                        ),
                        onTap: () {},
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRatingCategory(
                              "Trustworthy", trustworthyRatings, index),
                          _buildRatingCategory(
                              "Knowledgeable", knowledgeableRatings, index),
                          _buildRatingCategory(
                              "Helpful", helpfulRatings, index),
                          _buildRatingCategory(
                              "Available", availableRatings, index),
                          _buildRatingCategory(
                              "Courageous", courageousRatings, index),
                          _buildRatingCategory(
                              "Efficient", efficientRatings, index),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descriptionControllers[index],
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Enter description...',
                              hintMaxLines: 10,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            width: 340, // Set the width of the button
            height: 60, // Set the height of the button
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(216, 6, 131, 1),
                  Color.fromRGBO(99, 7, 114, 1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(
                  18), // Adjust the border radius as needed
            ),
            child: ElevatedButton(
              onPressed: () {
                _submitAllRatings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Submit Ratings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAllRatings() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
        String? accesstoken = await storage.read(key: 'accessToken');


    List<Map<String, dynamic>> allRatings = [];

    for (int i = 0; i < widget.accptedleadeLeaders.length; i++) {
      final leader = widget.accptedleadeLeaders[i];

      allRatings.add({
        "leader_id": leader.id,
        "citizen_id": id,
        "sosId": widget.usersosid,
        "trustWorthy": trustworthyRatings[i],
        "knowledgeable": knowledgeableRatings[i],
        "helpful": helpfulRatings[i],
        "available": availableRatings[i],
        "courageous": courageousRatings[i],
        "efficient": efficientRatings[i],
        "reviews": descriptionControllers[i].text,
      });
    }


    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}addratingandreview'));
    request.body = json.encode(allRatings);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      showSuccessDialog(context);
    } else {
      print(response.reasonPhrase);
    }
  }

  void showSuccessDialog(BuildContext context) {
    StylishDialog(
      context: context,
      alertType: StylishDialogType.SUCCESS,
      content: Column(
        children: [
          Text('SOS Created successfully'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Emergencysos()),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    ).show();
  }

  Widget _buildRatingCategory(String category, List<int> ratings, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              category,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    ratings[index] = i + 1;
                  });
                },
                child: Icon(
                  i < ratings[index] ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
