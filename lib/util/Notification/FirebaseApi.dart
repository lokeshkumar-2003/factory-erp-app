import 'dart:convert';
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/util/Localstorage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      await _firebaseMessaging.requestPermission();

      final username = await LocalStorage().getUserNameData();

      if (username!.isEmpty) {
        print("Username not found in local storage");
        return;
      }

      await handleFcmToken(username);
    } catch (e) {
      print("Error requesting notification permission: $e");
    }
  }

  Future<void> handleFcmToken(String username) async {
    try {
      final fcmtoken = await _firebaseMessaging.getToken();

      if (fcmtoken == null) {
        print("FCM token is null");
        return;
      }

      final url = Uri.parse('${Apivariables.fcm_token}$username');
      final body = jsonEncode({"fcm_token": fcmtoken});
      print("${Apivariables.fcm_token}$username");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        String? dbToken = responseData["fcmtoken"];
        String? localToken = await LocalStorage().getFcmToken();

        print("🔍 DB Token: $dbToken");
        print("📱 Local Token: $localToken");

        if (dbToken != localToken) {
          await LocalStorage().setFcmToken(fcmtoken);
          print("✅ Local token updated to match DB.");
        } else {
          print("ℹ️ Local token already matches DB.");
        }
      } else {
        print("❌ Failed to sync FCM token. Status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (err) {
      print("🚨 Exception in handleFcmToken: $err");
    }
  }
}
