// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:Shepower/Allusers/allusermodel.dart';
import 'package:Shepower/common/api.service.dart';
import 'package:Shepower/core/utils/image_constant.dart';
import 'package:Shepower/service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: camel_case_types
class getallCitizenusers extends StatefulWidget {
  const getallCitizenusers({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HotelBookingPageState createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends State<getallCitizenusers> {
  final _refreshController = RefreshController();
  var storage = const FlutterSecureStorage();

  List<Citizen> citizendata = [];
  List<Citizen>? filteredCitizenData;

  @override
  void initState() {
    super.initState();
    fetchCitizens();
  }

  Future<void> fetchCitizens() async {
    String? id = await storage.read(key: '_id');
    String? accessToken = await storage.read(key: 'accessToken');

    if (id == null || id.isEmpty) return;

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      var request = http.Request(
          'POST', Uri.parse('${ApiConfig.baseUrl}getAllCitizensapp'));
      request.body = json.encode({"_id": id});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        List<Citizen> citizens = [];

        if (jsonResponse['status'] == true) {
          final citizenList =
              jsonResponse['citizensWithConnectionsAndRequests'];
          for (var citizenJson in citizenList) {
            citizens.add(Citizen.fromJson(citizenJson));
          }
        }

        setState(() {
          citizendata = citizens;
          filteredCitizenData = citizens;
        });
      } else {
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  void filterData(String query) {
    setState(() {
      if (citizendata.isNotEmpty) {
        filteredCitizenData = citizendata
            .where((citizen) =>
                citizen.firstname.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        onRefresh: () async {
          await fetchCitizens();
          _refreshController.refreshCompleted();
        },
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        child: Column(
          children: <Widget>[
            const SizedBox(
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
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (filteredCitizenData != null)
                      FutureBuilder(
                        future:
                            Future.delayed(const Duration(seconds: 1), () {}),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildSkeletonLoadingView();
                          } else {
                            if (filteredCitizenData!.isEmpty) {
                              return const Center(
                                child: Text("No Citizens available"),
                              );
                            } else {
                              return _userListView(filteredCitizenData!);
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
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
            margin: const EdgeInsets.all(5),
            height: 20,
            width: 60,
            decoration: BoxDecoration(color: Colors.grey[300]),
          ),
          subtitle: Container(
            margin: const EdgeInsets.all(5),
            height: 20,
            width: 60,
            decoration: BoxDecoration(color: Colors.grey[300]),
          ),
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget _userListView(List<Citizen> Citizendata) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Citizendata.length,
      itemBuilder: (BuildContext context, index) {
        final userdata = Citizendata[index];
        final username = userdata.firstname;
        final mobilenumber = userdata.mobilenumber;
        final profileImageUrl = userdata.profileImg;
        final isconnected = userdata.isConnected;
        final requestExists = userdata.requestExists;
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
                          child: Image.asset(
                            ImageConstant.imgImage20331x235,
                            fit: BoxFit.fill,
                          )),
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
                          fetchCitizens();
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

// ignore: unused_element
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
