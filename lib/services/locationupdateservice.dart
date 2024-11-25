import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Shepower/common/cache.service.dart';
import 'package:Shepower/service.dart';

import '../common/api.service.dart';

class LocationUpdate {
  final storage = FlutterSecureStorage();
  Future<bool?> locationUpdate(
      String _id, String latitude, String longitude) async {
    try {
      String? _id = await CacheService.getUserId();
      if (_id == null || _id == "") return null;
      Map<String, dynamic> body = {
        "_ids": _id,
        "latitude": latitude,
        "longitude": longitude,
      };

      await storage.write(key: 'latitude', value: latitude);
      await storage.write(key: 'longitude', value: longitude);

      String url = "${ApiConfig.baseUrl}locationUpdate";
      var response = await ApiService().post(url, body);

      print(response);

      // Check the response and return a result accordingly
      if (response.statusCode == 200) {
        print("newLocationUpdated");

        // Successful update
        return true;
      } else {
        // Handle any other response codes or errors
        return false;
      }
    } catch (e) {
      // Handle exceptions here
      print('Error updating location: $e');
      return false;
    }
  }
}
