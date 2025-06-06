import 'package:cd_automation/State/notification_provider.dart';
import 'package:cd_automation/util/Notification/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/model/NotificationItem.dart';
import 'package:cd_automation/util/Localstorage.dart';
import 'package:provider/provider.dart';
import 'NotificationCard.dart';

class NotificationListScreen extends StatefulWidget {
  final List<NotificationItem> notifications;

  const NotificationListScreen({super.key, required this.notifications});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late List<NotificationItem> _notifications;
  late NotificationProvider provider;
  String? username;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.notifications);
    provider = Provider.of<NotificationProvider>(context, listen: false);
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    username = await LocalStorage().getUserNameData();
  }

  Future<bool> markNotificationAsRead(
      String username, int notificationId) async {
    final url = Uri.parse(
        '${Apivariables.mark_notification}/$username/$notificationId');
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        debugPrint("✅ Notification marked as read.");
        return true;
      } else {
        debugPrint("⚠️ Failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      return false;
    }
  }

  void handleClose(int index) async {
    final item = _notifications[index];

    if (username != null) {
      final success = await markNotificationAsRead(username!, item.id);
      if (success) {
        setState(() {
          _notifications.removeAt(index);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Notifications", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00536E),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (username != null) {
              await NotificationService()
                  .fetchAndSetNotifications(username!, provider);
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text("No notifications available"))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return NotificationCard(
                  item: _notifications[index],
                  onClose: () => handleClose(index),
                );
              },
            ),
    );
  }
}
