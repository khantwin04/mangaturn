import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {

  static Future<void> saveReadChapterId(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt('$id', id);
  }

  static Future<int?> getReadChapterId(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt('$id');
  }

    static Future<void> saveRepliedCmt(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt('$id', id);
  }

  static Future<int?> getRepliedCmt(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt('$id');
  }

  static Future<void> saveMangaShowLimit(bool? data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('show', data ?? true);
  }

  static Future<bool?> getMangaShowLimit() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool('show');
  }
}
