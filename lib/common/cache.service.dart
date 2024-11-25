import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String USERID = "_id";


class CacheService {
 static const storage = FlutterSecureStorage();
  
  static setCache(String key, value) async {
     await storage.write(key: key, value: value);
  }

  static  getCache(String key) async {
    return await storage.read(key: key);
  }

  static setUserId(String userId) {
    setCache(USERID, userId);
  }


  static Future<String?> getUserId() async {
    final userId = await getCache(USERID);
    if (userId == null || userId =="") return null;
    return "$userId";
  }

  static removeAll() async {
    await storage.deleteAll();
  }

  static remove(String key)async{
    await storage.delete(key:key);
  }
}
