import 'package:cd_automation/State/notification_provider.dart';
import 'package:cd_automation/util/Notification/NotificationService.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cd_automation/util/Localstorage.dart';
import 'package:provider/provider.dart';

class NotificationHandling {
  final BuildContext context;
  late NotificationProvider provider;
  String? masterAdminName;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationHandling(this.context);

  Future<void> init() async {
    await _initFirebase();
    await _initLocalNotification();

    provider = Provider.of<NotificationProvider>(context, listen: false);
    masterAdminName = await LocalStorage().getUserNameData();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showNotification(message);

      if (masterAdminName != null) {
        await NotificationService()
            .fetchAndSetNotifications(masterAdminName!, provider);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification opened: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint("Firebase init error: $e");
    }
  }

  Future<void> _initLocalNotification() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        notification.body ?? '',
        contentTitle: notification.title,
        summaryText: notification.body,
      ),
      icon: 'industries',
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title ?? 'No Title',
      notification.body ?? 'No Body',
      platformDetails,
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📦 Background message received: ${message.messageId}');
}
