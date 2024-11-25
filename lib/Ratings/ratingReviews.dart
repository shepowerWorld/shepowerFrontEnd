import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RatingReview {
  final String id;
  final String leaderId;
  final String citizenId;
  final String sosId;
  final int trustWorthy;
  final int knowledgeable;
  final int helpful;
  final int available;
  final int courageous;
  final int efficient;
  final String reviews;
  final String createdAt;
  final String updatedAt;
  final List<UserDetails> userDetails;

  RatingReview({
    required this.id,
    required this.leaderId,
    required this.citizenId,
    required this.sosId,
    required this.trustWorthy,
    required this.knowledgeable,
    required this.helpful,
    required this.available,
    required this.courageous,
    required this.efficient,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt,
    required this.userDetails,
  });

  factory RatingReview.fromJson(Map<String, dynamic> json) {
    return RatingReview(
      id: json['_id'] ?? "",
      leaderId: json['leader_id'] ?? "",
      citizenId: json['citizen_id'] ?? "",
      sosId: json['sosId'] ?? "",
      trustWorthy: json['trustWorthy'] ?? 0,
      knowledgeable: json['knowledgeable'] ?? 0,
      helpful: json['helpful'] ?? 0,
      available: json['available'] ?? 0,
      courageous: json['courageous'] ?? 0,
      efficient: json['efficient'] ?? 0,
      reviews: json['reviews'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      userDetails: (json['userDeatils'] != null)
          ? List<UserDetails>.from(
              json['userDeatils'].map((x) => UserDetails.fromJson(x)))
          : [],
    );
  }
}

class UserDetails {
  final String id;
  final String firstname;
  final String profileImg;

  UserDetails({
    required this.id,
    required this.firstname,
    required this.profileImg,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['_id'] ?? "",
      firstname: json['firstname'] ?? "",
      profileImg: json['profile_img'] ?? "",
    );
  }
}

class GetRatingScreen extends StatefulWidget {
  final String userId;

  const GetRatingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _GetRatingScreenState createState() => _GetRatingScreenState();
}

class _GetRatingScreenState extends State<GetRatingScreen> {
  List<RatingReview> allReviews = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getRatings();
  }

  Future<void> getRatings() async {
    setState(() {
      isLoading = true;
    });
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getratingsReview'));
    request.body = json.encode({"leader_id": widget.userId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final reviewData = json.decode(responseBody);

      final reviews = reviewData['result'];

      setState(() {
        isLoading = false;
        allReviews = reviews
            .map<RatingReview>(
                (reviewJson) => RatingReview.fromJson(reviewJson))
            .toList();
      });
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoading = false;
      });
    }
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
        title: Text(
          'Reviews'.tr(),
          style: const TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : allReviews.isEmpty
              ? Center(
                  child: Text('No reviews found.'),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: allReviews.length,
                        itemBuilder: (BuildContext context, index) {
                          final review = allReviews[index];
                          String firstname = review.userDetails.isNotEmpty
                              ? review.userDetails[0].firstname
                              : 'Unknown';
                          String profileImg = review.userDetails.isNotEmpty
                              ? review.userDetails[0].profileImg
                              : '';

                          print(
                              'firstname: $firstname, profileImg: $profileImg');
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.all(10),
                                  title: Text(
                                    firstname,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Mobile: ${review.sosId}'),
                                  leading: CircleAvatar(
                                    radius: 35,
                                    backgroundImage: NetworkImage(
                                        '${imagespath.baseUrl}$profileImg'),
                                  ),
                                  onTap: () {},
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildRatingCategory(
                                        review.trustWorthy != null &&
                                                review.trustWorthy != 0
                                            ? "Trustworthy"
                                            : "",
                                        review.trustWorthy),
                                    _buildRatingCategory(
                                        review.knowledgeable != null &&
                                                review.knowledgeable != 0
                                            ? "Knowledgeable"
                                            : "",
                                        review.knowledgeable),
                                    _buildRatingCategory(
                                        review.helpful != null &&
                                                review.helpful != 0
                                            ? "Helpful"
                                            : "",
                                        review.helpful),
                                    _buildRatingCategory(
                                        review.available != null &&
                                                review.available != 0
                                            ? "Available"
                                            : "",
                                        review.available),
                                    _buildRatingCategory(
                                        review.courageous != null &&
                                                review.courageous != 0
                                            ? "Courageous"
                                            : "",
                                        review.courageous),
                                    _buildRatingCategory(
                                        review.efficient != null &&
                                                review.efficient != 0
                                            ? "Efficient"
                                            : "",
                                        review.efficient),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                            width: 1, color: Colors.pink),
                                      ),
                                      padding: EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Review:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            review.reviews,
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        ],
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
                  ],
                ),
    );
  }

  Widget _buildRatingCategory(String category, int index) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(index, (i) {
              return GestureDetector(
                child: const Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 20,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
