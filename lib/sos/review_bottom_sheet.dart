import 'dart:math';

import 'package:flutter/material.dart';

class ReviewBottomModel extends StatefulWidget {
  const ReviewBottomModel({super.key});

  @override
  State<ReviewBottomModel> createState() => _ReviewBottomModelState();
}

class _ReviewBottomModelState extends State<ReviewBottomModel> {
  var _ratingPageController = PageController();

  var _rating = 0;
  List<int> _ratings = List.filled(5, 0); // Initialize ratings for 5 options

  // var _startController
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // List of options
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 25, bottom: 20),
                      child: Text(
                        _getRatingText(index),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              // List of star ratings
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: List.generate(
                          5,
                          (starIndex) => InkWell(
                            onTap: () {
                              setState(() {
                                _ratings[index] = starIndex + 1;
                              });
                            },
                            child: Icon(
                              starIndex < _ratings[index]
                                  ? Icons.star
                                  : Icons.star_border,
                              color: starIndex < _ratings[index]
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            _description(),
            SizedBox(
                height:
                    250), // Adding some space between description and submit button
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 22, right: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        8), // Adjust border radius as needed
                    // border: Border.all(
                    //   color: Colors.pink, // Adjust border color
                    //   width: 2, // Adjust border width
                    // ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(99, 7, 114, 0.8),
                            Color.fromRGBO(228, 65, 163, 0.849),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 300,
                          minHeight: 50,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Submit Review',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _handleSubmit() {
    // Implement your submit logic here
  }

  Widget _description() {
    return Column(
      children: [
        Text(
          "Description",
          style: TextStyle(
            color: Colors.pink,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Container(
            width: 300, // Adjust width as needed
            padding: EdgeInsets.only(right: 10, top: 0),
            margin: EdgeInsets.only(right: 10, top: 0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.pink),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter description...',
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.start,
                  maxLines: 2, // Allow multiple lines
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _causeRatings() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // List of options
        SizedBox(
          height: 60,
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 6,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Text(
                    _getRatingText(index),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              );
            },
          ),
        ),

        // List of star ratings
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 4), // Adjust as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (starIndex) => InkWell(
                      onTap: () {
                        // setState(() {
                        //   _selectedChipIndex = index;
                        //   _rating = starIndex + 1;
                        // });
                      },
                      child: Icon(
                        starIndex < _rating ? Icons.star : Icons.star_border,
                        color: starIndex < _rating ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getRatingText(int index) {
    switch (index) {
      case 0:
        return "Trustworthy";
      case 1:
        return "Knowledgeable";
      case 2:
        return "Helpful";
      case 3:
        return "Available";
      case 4:
        return "Courageous";
      case 5:
        return "Efficient";
      default:
        return "gggg";
    }
  }
}
