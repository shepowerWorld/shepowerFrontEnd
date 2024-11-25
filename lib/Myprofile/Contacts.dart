import 'dart:convert';
import 'dart:math';

import 'package:Shepower/service.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<Contact> contacts = [];
  bool isLoading = true;
  List<Contact> filteredContacts = [];
  TextEditingController searchController = TextEditingController();
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    getContactPermission();
  }

  launchMessageApp(phoneNumber, msg) async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {
        'body': msg,
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch messaging app');
      // Handle the error as needed.
    }
  }

  void openMessagingApp(String link) async {
    String msg = 'Check out ShePower app: $link';
    // launchMessageApp(phoneNumber, msg);
    launchWhatsapp(phoneNumber, msg);
  }

  Future<void> generteLink() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}deeplink'));
    request.body =
        json.encode({"link": "https://shepower.page.link", "_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseJson = json.decode(await response.stream.bytesToString());
      print('responseJson...$responseJson');
      if (responseJson['shortLink'] != null) {
        openMessagingApp(responseJson['shortLink']);
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  void getContactPermission() async {
    try {
      if (await Permission.contacts.isGranted) {
        fetchContacts();
      } else {
        await Permission.contacts.request();
      }
    } catch (e) {
      print("Error getting contact permission: $e");
      // Handle the error as needed.
    }
  }

  void launchWhatsapp(
    String phone,
    String message,
  ) async {
    final url = 'https://wa.me/$phone?text=$message';

    await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  void fetchContacts() async {
    Iterable<Contact> contactsIterable = await ContactsService.getContacts();
    setState(() {
      contacts = contactsIterable.toList();
      isLoading = false;
    });
  }

  bool get isSearching => searchController.text.isNotEmpty;

  void filterContacts(String query) {
    print("Query: $query");
    List<Contact> list = [];
    list = contacts.where((contact) {
      String queryString = query.toLowerCase().trim();
      List<String> queryWords = queryString.split(' ');

      String givenName = contact.givenName?.toLowerCase() ?? "";
      String displayName = contact.displayName?.toLowerCase() ?? "";

      return queryWords.every(
          (word) => givenName.contains(word) || displayName.contains(word));
    }).toList();
    setState(() {
      filteredContacts = list;
    });
    print("Filtered Contacts: ${filteredContacts.length}");
  }

  Widget buildContactButton(Contact contact) {
    return ElevatedButton(
      onPressed: () {
        // Add your button click logic here
        print('Button clicked for ${contact.givenName}');
        if (contact.phones?.isNotEmpty == true) {
          generteLink();
          setState(() {
            phoneNumber = contact.phones![0].value ?? '';
          });
        } else {
          print('No phone number available for ${contact.givenName}');
        }
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_add,
            color: Colors.black,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            'Invite',
            style: TextStyle(
              color: Colors.pink,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color.fromRGBO(216, 6, 163, 1),
                  Color.fromRGBO(99, 7, 114, 1),
                ],
              ).createShader(bounds);
            },
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1.5.w,
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
          'Contacts'.tr(),
          style: GoogleFonts.montserrat(
            color: const Color.fromRGBO(25, 41, 92, 1),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: filterContacts,
                        decoration: InputDecoration(
                          labelText: 'Search by Name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Add spacing
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3366FF),
                              Color(0xFF00CCFF)
                            ], // Replace with your desired colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the border radius as needed
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount:
                        isSearching ? filteredContacts.length : contacts.length,
                    itemBuilder: (context, index) {
                      Contact contact = isSearching
                          ? filteredContacts[index]
                          : contacts[index];

                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 45,
                              width: 45,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 7,
                                    color: Colors.pink.withOpacity(0.1),
                                    offset: Offset(-3, -3),
                                  ),
                                  BoxShadow(
                                    blurRadius: 7,
                                    color: Colors.pink.withOpacity(0.1),
                                    offset: Offset(-3, -3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.yellow,
                              ),
                              child: Text(
                                contact.givenName?.isNotEmpty == true
                                    ? contact.givenName![0]
                                    : '',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          contact.givenName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: "poppins",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          contact.phones?.isNotEmpty == true
                              ? contact.phones![0].value ?? ''
                              : '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                            fontFamily: "poppins",
                          ),
                        ),
                        horizontalTitleGap: 12,
                        trailing: buildContactButton(
                            contact), // Add Invite button here
                      );
                    },
                  ),
                ),
                // Button Column
              ],
            ),
    );
  }
}
