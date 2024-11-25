import 'dart:io'; // Add this import for File class

import 'package:Shepower/Events/createeven.services.dart';
import 'package:Shepower/Events/meet_service.dart';
import 'package:Shepower/Events/place.model.dart';
import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../Dashboard/Bottomnav.dart';
import 'models/event.model.dart';

class CreateEventScreen extends StatefulWidget {
  final EventModel? item;

  const CreateEventScreen({Key? key, this.item}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  TextEditingController eventNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController meetIdController = TextEditingController();
  TextEditingController eventDateController = TextEditingController();
  TextEditingController eventTimeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TimeOfDay? endTime;
  bool isEdit = false;

  var _image;

  List<Predictions> predictions = [];

  String formatDate(DateTime date) => DateFormat("MMM-dd-yyyy").format(date);

  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _image = File(pickedImage.path);
    });
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) {
      // User canceled the operation
      return;
    }

    setState(() {
      _image = File(pickedImage.path);
    });
  }

  Future<void> createEvent() async {
    String eventname = eventNameController.text;
    String eventdescription = descriptionController.text;
    String eventlocation = locationController.text;
    String eventlink = meetIdController.text;

    if (eventname.isEmpty ||
        eventdescription.isEmpty ||
        eventlocation.isEmpty ||
        eventlink.isEmpty) {
      showSErrorDialog(context);
      return; // Exit the function without calling the API
    }

    if (isEdit) {
      updateEventData();
      return;
    }
    //create post

    const storage = FlutterSecureStorage();
    String? _id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');


    if (_id == null || _id == "") return;

    // Prepare the data to send to the API
    String apiUrl = '${ApiConfig.baseUrl}createEvent';

    final Map<String, String> data = {
      'eventname': eventNameController.text,
      'eventdescription': descriptionController.text,
      'eventlocation': locationController.text,
      'eventtime': selectedDate != null && selectedTime != null
          ? '${formatDate(selectedDate!)} ${selectedTime!.format(context)}'
          : '',
      // 'eventtime':eventTime.toUtc().toIso8601String(),
      'eventlink': meetIdController.text,
      'user_id': _id,
    };
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    // Create a multipart request
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll(headers);
    request.fields.addAll(data);

    print('Craeteevents api working or not $data');

    // Attach the image file if it exists
    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'event_img',
          _image!.path,
          contentType: MediaType('image', 'png'),
        ),
      );
    }

    // try {
      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        // Request was successful
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        showSuccessDialog(context,
            "Event created successfully!");
      } else {
        // Request failed
        print('Request failed with status: ${response.statusCode}');
        print(response.reasonPhrase);
        showErrorDialog(context,
            'Failed to create event. Please try again.'); // Show error dialog
      }
    // } catch (e) {
    //   print('Error sending request: $e');
    //   showErrorDialog(context,
    //       'An error occurred. Please try again later.'); // Show error dialog
    // }
  }

  //Updateevent

  Future<void> updateEventData() async {
    const storage = FlutterSecureStorage();
    String? _id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    String eventname = eventNameController.text;
    String eventdescription = descriptionController.text;
    String eventlocation = locationController.text;
    String eventlink = meetIdController.text;

    if (eventname.isEmpty ||
        eventdescription.isEmpty ||
        eventlocation.isEmpty ||
        eventlink.isEmpty) {
      showSErrorDialog(context);
      return; // Exit the function without calling the API
    }

    String apiUrl = '${ApiConfig.baseUrl}updateEvent';
    final Map<String, String> data = {
      'eventname': eventNameController.text,
      'eventdescription': descriptionController.text,
      'eventlocation': locationController.text,
      'eventtime': selectedDate != null && selectedTime != null
          ? '${formatDate(selectedDate!)} ${selectedTime!.format(context)}'
          : '',
      // 'eventtime':eventTime.toUtc().toIso8601String(),
      'eventlink': meetIdController.text,
      '_id': widget.item!.Id!,
      // 'user_id': "650af8657140194011119c2d",
    };

    // Create a multipart request
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    final request = http.MultipartRequest('PUT', Uri.parse(apiUrl));
    request.headers.addAll(headers);
    request.fields.addAll(data);

    // Attach the image file if it exists
    if (_image != null && _image is File) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'event_img',
          _image!.path,
          contentType: MediaType('image', 'png'),
        ),
      );
    }

    try {
      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        // Request was successful
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
        showSuccessDialog(context,
            "Event Update successfully!"); // or "Event updated successfully!"
        // Show success dialog
        // Handle the response here as needed
        // Handle the response here as needed

        // Add navigation to the home screen
      } else {
        // Request failed
        print('Request failed with status: ${response.statusCode}');
        print(response.reasonPhrase);
        showErrorDialog(context,
            'Failed to create event. Please try again.'); // or 'Failed to update event. Please try again.'
        // Show error dialog
        // Handle error response here
        // Handle error response here
      }
    } catch (e) {
      print('Error sending request: $e');
      showErrorDialog(context,
          'An error occurred. Please try again later.'); // Show error dialog
      // Handle any exceptions that may occur during the request
      // Handle any exceptions that may occur during the request
    }
  }

  void showSuccessDialog(BuildContext context, String message) {
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(150),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD80683), // Gradient color for the inner box
                    Color(0xFF630772), // Gradient color for the inner box
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.done,
                    size: 48.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              message,
              style: TextStyle(
                fontSize: 18.0,
                color: Color(0xFFD80683), // Text color
                fontWeight: FontWeight.bold, // Font weight
                fontFamily:
                    'Monstare', // Font family (replace with your desired font)
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Bottomnavscreen()),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD80683), // Gradient color for the button
                      Color(0xFF630772), // Gradient color for the button
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  void showErrorDialog(BuildContext context, String errorMessage) {
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            side: BorderSide(
              width: 2.0, // Border width
              color: Color(0xFFD80683), // Border color
            ),
          ),
          title: Text("Error",
              style: TextStyle(color: Color(0xFFD80683))), // Title text color
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD80683),
                  Color(0xFF630772),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.white), // Text color
              ),
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFD80683),
                    Color(0xFF630772),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSErrorDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: BasicDialogAlert(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      size: 48.0,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              const Center(
                child: Text(
                  "Please Fill All Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ok',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    isEdit = widget.item != null;
    Future.delayed(Duration.zero, () {
      if (isEdit) setData();
    });

    super.initState();
  }

  setData() {
    if (mounted) {
      setState(() {
        eventNameController.text = widget.item?.eventname ?? "";
        descriptionController.text = widget.item?.eventdescription ?? "";
        locationController.text = widget.item?.eventlocation ?? "";
        meetIdController.text = widget.item?.eventlink ?? "";
        _image = widget.item?.eventimage ?? "";

        if (widget.item?.eventtime != null && widget.item!.eventtime != "") {
          DateTime dateTime = DateTime.parse(widget.item!.eventtime!);
          selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
          eventDateController.text = formatDate(selectedDate!);
          selectedTime =
              TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
          endTime = TimeOfDay(
            hour: selectedTime!.hour + (selectedTime!.minute + 60) ~/ 60,
            minute: (selectedTime!.minute + 60) % 60,
          );
          eventTimeController.text =
              '${selectedTime!.format(context)} - ${endTime!.format(context)}';
        }
      });
    }
  }

  @override
  void dispose() {
    eventNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  String name = place?.predictions?.first?.description ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Update Event" : "Create Event",
          style: GoogleFonts.montserrat(
            // Apply Montserrat font
            color: Color(0xFFD80683), // Set text color to #D9D9D9
            fontWeight: FontWeight.bold, // Set font weight to bold
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme:const IconThemeData(
          color: Color(0xFFD80683), // Set icon color to black
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Event Name",
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: Color(0xFFD80683),
                fontWeight: FontWeight.bold, // Set the font weight here
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: eventNameController,
              autofocus: true, // Add this line to set autofocus to true
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD80683),
                    width: 2.0, // Set the border width when focused
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "Enter Event Name",
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Description",
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: Color(0xFFD80683),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFD80683),
                    width: 2.0, // Set the border width when focused
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "Enter Event Description",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Event Image",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFD80683),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black45, // Color of the circular border
                  width: 2.0, // Width of the circular border
                ),
              ),
              child: Stack(
                alignment: Alignment.center, // Align the children to the center
                children: [
                  if (isEdit && _image is String?)
                    ClipOval(
                      child: Image.network(
                        "${imagespath.baseUrl}" + (_image ?? ""),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (_image != null)
                    ClipOval(
                      child: Image.file(
                        _image,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    ClipOval(
                      child: Image.asset(
                        'assets/Splash/shepower.png', // Replace with the path to your default image
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Positioned(
                    top: -2,
                    right:
                        3, // Adjust this value to positiosn the icon as needed
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                "Select One",
                                style: TextStyle(
                                  color: Color(
                                      0xFFD80683), // Set the title color here
                                  fontFamily: 'Monstare',
                                  fontWeight: FontWeight
                                      .bold, // Bold font weight // Set the font family (replace with your desired font)
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                      _getImageFromCamera();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Rounded border box
                                        border: Border.all(
                                          color: Colors
                                              .pink, // Border color for the box
                                        ),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(
                                                0xFFD80683), // Gradient color for the button
                                            Color(
                                                0xFF630772), // Gradient color for the button
                                          ],
                                        ),
                                      ),
                                      padding: EdgeInsets.all(
                                          12.0), // Adjust padding as needed
                                      child: const Row(
                                        children: <Widget>[
                                          Icon(Icons.camera,
                                              color: Colors.white // Icon color
                                              ),
                                          SizedBox(width: 12.0),
                                          Text(
                                            'Camera',
                                            style: TextStyle(
                                              fontFamily:
                                                  'Monstare', // Set the font family (replace with your desired font)
                                              color: Colors.white, // Text color
                                              fontWeight: FontWeight
                                                  .bold, // Bold font weight
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12.0),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                      _getImageFromGallery();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Rounded border box
                                        border: Border.all(
                                          color: Colors
                                              .pink, // Border color for the box
                                        ),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(
                                                0xFFD80683), // Gradient color for the button
                                            Color(
                                                0xFF630772), // Gradient color for the button
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(
                                          12.0), // Adjust padding as needed
                                      child: const Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.image,
                                            color: Colors.white, // Icon color
                                          ),
                                          SizedBox(width: 12.0),
                                          Text(
                                            'Gallery',
                                            style: TextStyle(
                                              fontFamily:
                                                  'Monstare', // Set the font family (replace with your desired font)
                                              color: Colors.white, // Text color
                                              fontWeight: FontWeight
                                                  .bold, // Bold font weight
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Image.asset(
                        'assets/profile/edit.png', // Replace with the actual path to your image
                        width: 30,
                        height: 30,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date",
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          color: Color(0xFFD80683),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        readOnly: true,
                        onTap: () async {
                          final currentDate = DateTime.now();
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? currentDate,
                            firstDate: currentDate,
                            lastDate: DateTime(2100, 12, 31),
                          );
                          if (pickedDate != null &&
                              pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                              eventDateController.text = formatDate(pickedDate);
                            });
                          }
                        },
                        controller: eventDateController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD80683),
                              width: 2.0, // Set the border width when focused
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Select Date",
                          suffixIcon: const Icon(
                            Icons.edit_calendar_outlined,
                            color: Color(0xFF630772),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Time",
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          color: Color(0xFFD80683),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        readOnly: true,
                        onTap: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );
                          if (pickedTime != null &&
                              pickedTime != selectedTime) {
                            setState(() {
                              selectedTime = pickedTime;
                              // Calculate end time by adding 60 minutes to the selected time
                              endTime = TimeOfDay(
                                hour: selectedTime!.hour +
                                    (selectedTime!.minute + 60) ~/ 60,
                                minute: (selectedTime!.minute + 60) % 60,
                              );

                              eventTimeController.text =
                                  '${selectedTime!.format(context)} - ${endTime!.format(context)}';
                            });
                          }
                        },
                        controller: eventTimeController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD80683),
                              width: 2.0, // Set the border width when focused
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Select Time",
                          suffixIcon: const Icon(
                            Icons.access_time,
                            color: Color(0xFF630772),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Location",
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: Color(0xFFD80683),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: locationController.text.isEmpty ? 2 : null,
                  overflow:
                      TextOverflow.ellipsis, // Specify how to handle overflow
                ),
                const SizedBox(height: 20),
                TypeAheadField<Predictions>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: locationController,
                    autofocus: true,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFD80683),
                          width: 2.0, // Set the border width when focused
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: "Search Location",
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return await EventService().getPlaces(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.description ?? "-"),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      locationController.text = suggestion.description ?? "";
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Meet ID",
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: Color(0xFFD80683),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD80683),
                        Color(0xFF630772),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      DateTime start = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute);

                      DateTime end = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute + 30);

                      EventData data = EventData(
                          description: descriptionController.text,
                          summary: eventNameController.text,
                          startDateTime: start,
                          endDateTime: end);

                      String? link = await MeetService.getLink(data);
                      setState(() {
                        meetIdController.text = link ?? "";
                      });
                    },
                    child: const Text(
                      "Generate",
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 16.0, // Text size
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: meetIdController,
                    enabled: true,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:const BorderSide(
                          color: Color(0xFFD80683),
                          width: 2.0, // Set the border width when focused
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: "Generate Meet ID",
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the column vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the column horizontally
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: 200, // Make the button take the full width
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded border
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD80683),
                          Color(0xFF630772),
                        ], // Double-color gradient
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: MaterialButton(
                      onPressed: isEdit
                          ? updateEventData
                          : createEvent, // Call the appropriate function
                      child: Builder(
                        builder: (context) {
                          // Use a Builder widget to access the context
                          return Text(
                            isEdit
                                ? "Update Event"
                                : "Create Event", // Conditional text
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 16.0, // Text size
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
