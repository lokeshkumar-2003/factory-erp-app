import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<void> setUserTypeData(String usertype) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("usertype", usertype);
  }

  Future<String?> getUserTypeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString("usertype");
  }

  Future<void> setUserNameData(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
  }

  Future<String?> getUserNameData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString("username");
  }

  Future<String?> getFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("fcmtoken");
  }

  Future<void> delFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('fcmtoken');
  }

  Future<void> setFcmToken(String fcmtoken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("fcmtoken", fcmtoken);
  }
}
