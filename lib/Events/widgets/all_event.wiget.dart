import 'package:Shepower/Events/EventDetails_screen.dart';
import 'package:Shepower/Events/models/event.model.dart';
import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class AllEventItem extends StatelessWidget {
  final EventModel item;

  const AllEventItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        "${imagespath.baseUrl}${item.eventimage}";
    String eventLocation = item.eventlocation ?? "Location";
    String eventTime = item.eventtime ?? "Event Time";

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(item: item),
          ),
        );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            margin: EdgeInsets.all(9.07),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        eventTime,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          textStyle: TextStyle(
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        item.eventname ?? "-",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          color: Color(0xFFD80683),
                          fontWeight: FontWeight.bold,
                          textStyle: TextStyle(
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Color(0xFFD80683),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              eventLocation,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFD80683),
                                fontFamily: 'Montserrat',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Share the event name and Google Meet link to WhatsApp and Instagram
                    String shareText =
                        "Event Name: ${item.eventname}\nGoogle Meet Link: ${item.eventlink}";
                    Share.share(shareText);
                  },
                  child: Icon(
                    Icons.share,
                    color: Color(0xFFD80683),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
