import 'package:Shepower/Events/createeven.services.dart';
import 'package:Shepower/Events/place.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/input_borders/gradient_outline_input_border.dart';

import '../common/cache.service.dart';

class locationPick extends StatefulWidget {
  const locationPick({Key? key}) : super(key: key);

  @override
  State<locationPick> createState() => _locationPickState();
}

class _locationPickState extends State<locationPick> {
  TextEditingController cityController = TextEditingController();

  void _shareAudioFile() {
    if (cityController != null) {
      Navigator.of(context).pop(cityController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick your location'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'City',
                    style: GoogleFonts.montserrat(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromRGBO(24, 25, 31, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
                child: SizedBox(
                  height: 45.h,
                  width: 323.w,
                  child: TypeAheadField<Predictions>(
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(
                        hintText: 'City you live in',
                        hintStyle: GoogleFonts.nunitoSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        border: GradientOutlineInputBorder(
                          gradient: const LinearGradient(colors: [
                            Color.fromRGBO(216, 6, 131, 1),
                            Color.fromRGBO(99, 7, 114, 1),
                          ]),
                          width: 1.w,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        focusedBorder: GradientOutlineInputBorder(
                          gradient: const LinearGradient(colors: [
                            Color.fromRGBO(216, 6, 131, 1),
                            Color.fromRGBO(99, 7, 114, 1),
                          ]),
                          width: 1.w,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: const EdgeInsets.only(left: 20),
                      ),
                      controller: cityController,
                      keyboardType: TextInputType.text,
                      cursorColor: const Color.fromRGBO(0, 0, 0, 1),
                    ),
                    suggestionsCallback: (pattern) async {
                      return await EventService().getPlaces(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.description ?? "-"),
                      );
                    },
                    onSuggestionSelected: (suggestion) async {
                      final selectedCity = suggestion.description ?? "";
                      double latitude = 0.0;
                      double longitude = 0.0;

                      try {
                        List<Location> locations = await locationFromAddress(selectedCity);

                        if (locations.isNotEmpty) {
                          latitude = locations[0].latitude;
                          longitude = locations[0].longitude;

                          print('Selected City: $selectedCity');
                          print('Latitude: $latitude, Longitude: $longitude');
                        } else {
                          print('Coordinates not found for $selectedCity');
                        }
                      } catch (e) {
                        print('Error fetching coordinates: $e');
                      }

                      setState(() {
                        cityController.text = selectedCity;
                      });

                      // Retrieve the user's ID using CacheService or your method
                      String? _id = await CacheService.getUserId();
                         print('paaavi: $_id');

                      // Check if _id is not null
                      // if (_id != null) {
                      //   // Create an instance of LocationUpdate and call locationUpdate method
                      //   LocationUpdate().locationUpdate(_id, latitude.toString(), longitude.toString());
                     
                      // } else {
                      //   print('User ID is null. Unable to update location.');
                      // }

                      void _shareLocation() {
                        if (selectedCity.isNotEmpty) {
                          Navigator.of(context).pop({
                            'selectedCity': selectedCity,
                            'latitude': latitude,
                            'longitude': longitude,
                          });
                        }
                      }

                      _shareLocation();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}