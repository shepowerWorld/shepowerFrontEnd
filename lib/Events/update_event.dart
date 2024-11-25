import 'dart:io'; // Add this import for File class

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:Shepower/Events/createeven.services.dart';
import 'package:Shepower/Events/meet_service.dart';
import 'package:Shepower/Events/place.model.dart';

class UpdateScreen extends StatefulWidget {
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  TextEditingController eventNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController meetIdController = TextEditingController();
  TextEditingController eventDateController = TextEditingController();
  TextEditingController eventTimeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TimeOfDay? endTime;

  File? _image;
  List<Predictions> predictions = [];

  String formatDate(DateTime date) => DateFormat("MMM-dd-yyyy").format(date);

  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) {
      // User canceled the operation
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Screen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Event Name",
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold, // Set the font weight here
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: eventNameController,
                decoration: InputDecoration(
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Enter Event Description",
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Event Image",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: Stack(
                  alignment:
                      Alignment.center, // Align the children to the center
                  children: [
                    if (_image != null) // Show the image when it's available
                      ClipOval(
                        child: Image.file(
                          _image!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Positioned(
                      bottom: -10,
                      left:
                          7, // Adjust this value to position the icon as needed
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.camera),
                                    title: Text('Camera'),
                                    onTap: () {
                                      Navigator.pop(
                                          context); // Close the bottom sheet
                                      _getImageFromCamera();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.image),
                                    title: Text('Gallery'),
                                    onTap: () {
                                      Navigator.pop(
                                          context); // Close the bottom sheet
                                      _getImageFromGallery();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(
                          Icons.edit, // Use "edit" instead of "pencil"
                          size: 40,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          readOnly: true,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2023, 1, 1),
                              lastDate: DateTime(2100, 12, 31),
                            );
                            if (pickedDate != null &&
                                pickedDate != selectedDate) {
                              setState(() {
                                selectedDate = pickedDate;
                                eventDateController.text =
                                    formatDate(pickedDate);
                              });
                            }
                          },
                          controller: eventDateController,
                          decoration: InputDecoration(
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            hintText: "Select Time",
                            suffixIcon: Icon(
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
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Location",
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TypeAheadField<Predictions>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: locationController,
                      autofocus: true,
                      decoration: InputDecoration(
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
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: meetIdController,
                      enabled: true,
                      decoration: InputDecoration(
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
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: 200, // Make the button take the full width
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20.0), // Rounded border
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFD80683),
                            Color(0xFF630772),
                          ], // Double-color gradient
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: () {},
                        // Call createEvent function when button is pressed
                        child: Text(
                          "Update Event",
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16.0, // Text size
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
