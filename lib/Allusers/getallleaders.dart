import 'dart:convert';

import 'package:Shepower/Allusers/allusermodel.dart';
import 'package:Shepower/common/api.service.dart';
import 'package:Shepower/common/cache.service.dart';
import 'package:Shepower/core/app_export.dart';
import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class getallusers extends StatefulWidget {
  @override
  _HotelBookingPageState createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends State<getallusers> {
  final _refreshController = RefreshController();
  List<Leader> leaderData = [];
  List<Leader>? filteredLeaderData;

  var storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchNearbyLeaders();
  }

  Future<void> fetchNearbyLeaders() async {
    String? _id = await CacheService.getUserId();
    String? accessToken = await storage.read(key: 'accessToken');

    if (_id == null || _id.isEmpty) return;

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      var request = http.Request(
          'POST', Uri.parse('${ApiConfig.baseUrl}getAllLeadersapp'));
      request.body = json.encode({"_id": _id});

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      print('jsonResponse$jsonResponse');

      List<Leader> leaders = [];

      if (jsonResponse['status'] == true) {
        final leaderList = jsonResponse['leadersWithConnectionsAndRequests'];
        for (var leaderJson in leaderList) {
          leaders.add(Leader.fromJson(leaderJson));
        }
      }

      setState(() {
        leaderData = leaders;
        filteredLeaderData = leaderData;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void filterData(String query) {
    setState(() {
      if (leaderData.isNotEmpty) {
        filteredLeaderData = leaderData
            .where((leader) =>
                leader.firstname.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        onRefresh: () async {
          await fetchNearbyLeaders();
          _refreshController.refreshCompleted();
        },
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
              child: Container(
                height: 50.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEDEE),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 10.0),
                        blurRadius: 10.0)
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Icon(
                        Icons.search,
                        size: 30.0,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: filterData,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search ....',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.0,
                            color: Colors.grey.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (filteredLeaderData != null)
                      FutureBuilder(
                        future: Future.delayed(Duration(seconds: 2), () {}),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildSkeletonLoadingView();
                          } else {
                            if (filteredLeaderData!.isEmpty) {
                              return const Center(
                                child: Text("No Leaders available"),
                              );
                            } else {
                              return _userListView(filteredLeaderData!);
                            }
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoadingView() {
    return ListView.builder(
      itemCount: 10, // Number of skeleton items
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            height: 130,
            width: 110,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                color: Colors.grey[300]),
          ),
          title: Container(
            margin: EdgeInsets.all(5),
            height: 20,
            width: 60,
            decoration: BoxDecoration(color: Colors.grey[300]),
          ),
          subtitle: Container(
            margin: EdgeInsets.all(5),
            height: 20,
            width: 60,
            decoration: BoxDecoration(color: Colors.grey[300]),
          ),
        );
      },
    );
  }

  Widget _userListView(List<Leader> leaderData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: leaderData.length,
      itemBuilder: (BuildContext context, index) {
        final userdata = leaderData[index];
        final username = userdata.firstname;
        final mobilenumber = userdata.mobilenumber;
        final profileImageUrl = userdata.profileImg;
        final Review = userdata.overallAverageRating != null
            ? userdata.overallAverageRating!.toDouble()
            : 0.0;
        final isconnected = userdata.isConnected;
        final requestExists = userdata.requestExists;

        print("profileImageUrl$Review");

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 4.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: profileImageUrl.isNotEmpty &&
                          profileImageUrl != " " &&
                          profileImageUrl != null
                      ? Container(
                          height: 130,
                          width: 110,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                  '${imagespath.baseUrl}$profileImageUrl'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          height: 130,
                          width: 110,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(216, 6, 131, 1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                          ),
                          child: Image.asset(ImageConstant.imgImage20331x235,fit: BoxFit.fill,)),
                ),
                Positioned(
                  top: 15,
                  left: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 120, // Set a width to constrain the text
                        child: Text(
                          username,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        mobilenumber.toString(),
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      _buildRatings(Review)
                    ],
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        String result =
                            await ApiService.sendRequest(userdata.id);
                        if (result == 'success') {
                          fetchNearbyLeaders();
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                          color: Color.fromRGBO(216, 6, 131, 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15.0,
                              offset: Offset(2.0, 4.4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              (isconnected == true && requestExists == false)
                                  ? "Following"
                                  : (isconnected == true &&
                                          requestExists == true)
                                      ? "Connected"
                                      : "Connect",
                              style: const TextStyle(
                                  fontSize: 13.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: .1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildRatings(double user) {
  double rating = user;

  int filledStars = rating.floor();
  double fractionalPart = rating - filledStars;

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      for (int i = 0; i < filledStars; i++)
        const Icon(
          Icons.star,
          color: Colors.orange,
          size: 20,
        ),
      if (fractionalPart > 0)
        const Icon(
          Icons.star_half,
          color: Colors.orange,
          size: 20,
        ),
      for (int i = 0; i < 5 - rating.ceil(); i++)
        const Icon(
          Icons.star_border,
          color: Colors.orange,
          size: 20,
        ),
    ],
  );
}
