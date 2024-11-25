import 'package:shared_preferences/shared_preferences.dart';


Future<void> storeLocation(double latitude, double longitude) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setDouble('latitude', latitude);
  await prefs.setDouble('longitude', longitude);
}

Future<Map<String, double>> getLocation() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  double latitude = prefs.getDouble('latitude') ?? 0.0; // 0.0 is a default value if the data is not found
  double longitude = prefs.getDouble('longitude') ?? 0.0;

  return {'latitude': latitude, 'longitude': longitude};
}
