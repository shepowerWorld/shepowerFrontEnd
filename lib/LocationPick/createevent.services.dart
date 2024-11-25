import 'package:Shepower/Events/place.model.dart';

import '../Events/Common/apiservice.dart';
import '../Events/Common/cache_services.dart';

class EventService {
  CacheService cache = CacheService();
  static const String API_KEY = "AIzaSyCaUi9Ulf6xNfeYw4DAQ1oj3rSESj-wBKc";

  Future<List<Predictions>> getPlaces(String query) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$API_KEY&types=geocode";
    var response = await ApiService().get(url);
    Place place = Place.fromJson(response);

    return place.predictions ?? [];
  }
}
