import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Shepower/Events/Common/apiservice.dart';
import 'package:Shepower/Events/Common/cache_services.dart';
import 'package:Shepower/Events/models/event.model.dart';
import 'package:Shepower/Events/place.model.dart';
import 'package:Shepower/service.dart';

class EventService {
  CacheService cache = CacheService();
  static const String API_KEY = "AIzaSyCaUi9Ulf6xNfeYw4DAQ1oj3rSESj-wBKc";

  Future<List<Predictions>> getPlaces(String query) async {
    print('query$query');
    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$API_KEY&types=geocode";
    var response = await ApiService().get(url);
    Place place = Place.fromJson(response);
    print('prediction${place.predictions}');
    return place.predictions ?? [];
  }

  Future<List<EventModel>?> getMyEvents() async {
    try {
      const storage = FlutterSecureStorage();
      String? _id = await storage.read(key: '_id');
      if (_id == null || _id == "") return null;

      Map<String, dynamic> body = {
        "user_id": _id
        //  "user_id": "650d4976dbe78426bd36d2f6"
      };

      String url = "${ApiConfig.baseUrl}myEvents";
      var response = await ApiService().post(url, body);
      List<EventModel> list = response["response"]
          .map<EventModel>((json) => EventModel.fromJson(json))
          .toList();
      return list;
    } catch (e) {
      return null;
    }
  }

  Future<List<EventModel>?> getUpComingEvents() async {
    try {
      const storage = FlutterSecureStorage();
      String? _id = await storage.read(key: '_id');
      if (_id == null || _id == "") return null;

      Map<String, dynamic> body = {
        "user_id": _id
        //  "user_id": "650d4976dbe78426bd36d2f6"
      };

      String url = "${ApiConfig.baseUrl}upcomingEvent";
      var response = await ApiService().post(url, body);
      List<EventModel> list = response["response"]
          .map<EventModel>((json) => EventModel.fromJson(json))
          .toList();
      return list;
    } catch (e) {
      return null;
    }
  }

  Future<List<EventModel>?> getLiveEvents() async {
    try {
      const storage = FlutterSecureStorage();
      String? _id = await storage.read(key: '_id');
      if (_id == null || _id == "") return null;

      Map<String, dynamic> body = {
        "user_id": _id
        //  "user_id": "650d4976dbe78426bd36d2f6"
      };

      String url = "${ApiConfig.baseUrl}getLiveEvents";
      var response = await ApiService().post(url, body);
      List<EventModel> list = response["response"]
          .map<EventModel>((json) => EventModel.fromJson(json))
          .toList();
      return list;
    } catch (e) {
      return null;
    }
  }

  Future<List<EventModel>?> getAllEvents() async {
    try {
      const storage = FlutterSecureStorage();
      String? _id = await storage.read(key: '_id');
      if (_id == null || _id == "") return null;

      Map<String, dynamic> body = {
        "user_id": _id
        //  "user_id": "650d4976dbe78426bd36d2f6"
      };

      String url = "${ApiConfig.baseUrl}getAllEvents";
      var response = await ApiService().get(url, body);
      List<EventModel> list = response["response"]
          .map<EventModel>((json) => EventModel.fromJson(json))
          .toList();
      return list;
    } catch (e) {
      return null;
    }
  }

  Future<bool?> deleteEvent(String userId, String eventId) async {
    try {
      Map<String, dynamic> body = {"user_id": userId, "event_id": eventId};

      String url = "${ApiConfig.baseUrl}deleteEvent";
      var response = await ApiService().delete(url, body);
      if (response['status'] == true) return true;
      if (response['status'] == false)
        // throw response['message'];

        return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<EventModel?> getEvent(String eventId) async {
    try {
      String url = "${ApiConfig.baseUrl}getEvents/$eventId";
      var response = await ApiService().get(url);
      EventModel? event = EventModel.fromJson(response["user"]);
      return event;
    } catch (e) {
      return null;
    }
  }
}
