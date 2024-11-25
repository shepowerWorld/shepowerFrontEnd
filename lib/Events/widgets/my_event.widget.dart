import 'package:Shepower/Events/models/event.model.dart';
import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class EventItem extends StatelessWidget {
  final EventModel item;

  const EventItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace this with the actual URL you get from your API
    String imageUrl =
        "${imagespath.baseUrl}${item.eventimage}";

    // Replace this with the actual Google Meet link for the event
    String googleMeetLink = item.eventlink ?? "";

    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        elevation: 10, // Set the elevation to give it a shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Align the content to the left
        child: Container(
          width: 180,
          height: 300,
          margin: const EdgeInsets.all(9.07),
          decoration: BoxDecoration(
            color: Colors.white, // Set the background color to white
            border: Border.all(
              color: Colors.white, // Set the border color
              width: 2.0, //
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0), // Set the border radius
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    10), // Adjust the corner radius as needed
                child: Image.network(
                  imageUrl,
                  width: 150, // Adjust the width of the image as needed
                  height: 110, // Adjust the height of the image as needed
                  fit: BoxFit
                      .cover, // You can choose how the image should be fitted
                ),
              ),
              SizedBox(height: 10), // Add some space between image and text
              Text(
                item.eventname ?? "-",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  // Adjust the font size
                  fontWeight: FontWeight.bold, // Make the text bold
                  color: Color.fromARGB(255, 0, 0, 0), // Adjust the text color
                  letterSpacing: 1.5,
                  // Add letter spacing for space between characters
                ),
              ),
              const SizedBox(
                  height:
                      10), // Add some space between event name and icon/text row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFD80683), // Double color for text
                  ),
                  SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      // Check if the Google Meet link is not empty, and then launch it
                      if (googleMeetLink.isNotEmpty) {
                        launch(googleMeetLink);
                      }
                    },
                    child: const Text(
                      "Google Meet", // Replace with your desired text
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16, // Adjust the font size
                        color: Color(0xFFD80683), // Double color for text
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
