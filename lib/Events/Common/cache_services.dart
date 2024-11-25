import 'package:shared_preferences/shared_preferences.dart';

const String USERID = "userId";

class CacheService {
  setCache(String key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is String) {
      prefs.setString(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    }
  }

  getCache(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }


  setUserId(String userId) {
    setCache(USERID, userId);
  }


  Future<String?> getUserId() async {
    return "655f4800b2d441cce6602d6b";
    final userId = await getCache(USERID);
    if (userId == null || userId =="") return null;
    return "$userId";
  }

  removeAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
