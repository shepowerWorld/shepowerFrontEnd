import 'package:flutter/material.dart';

class AppConstants {
  static const double defaultIconSize = 24;
  static const TextStyle defaultButtonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static InputDecoration defaultInputDecoration = InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    fillColor: Colors.grey.shade100,
  );
}
