import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/model/NotificationItem.dart';
import 'package:cd_automation/State/notification_provider.dart';

class NotificationService {
  Future<void> fetchAndSetNotifications(
      String username, NotificationProvider provider) async {
    final url = Uri.parse("${Apivariables.get_notification_data}$username");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> rawList = body['notifications'] ?? [];

        final List<NotificationItem> notifications = rawList
            .map((item) =>
                NotificationItem.fromMap(item as Map<String, dynamic>))
            .toList();

        provider.setNotifications(notifications);
        provider.setNotificationCount(notifications.length);
      } else {
        throw Exception(
            "Failed to fetch notifications: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching notifications: $e");
    }
  }
}
