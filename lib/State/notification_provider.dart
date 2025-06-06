import 'package:flutter/foundation.dart';
import 'package:cd_automation/model/NotificationItem.dart';

class NotificationProvider with ChangeNotifier {
  int _notificationCount = 0;
  List<NotificationItem> _notifications = [];

  int get notificationCount => _notificationCount;
  List<NotificationItem> get notifications => _notifications;

  void setNotificationCount(int count) {
    _notificationCount = count;
    notifyListeners();
  }

  void setNotifications(List<NotificationItem> notifications) {
    _notifications = notifications;
    notifyListeners();
  }
}
