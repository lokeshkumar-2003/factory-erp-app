import 'package:cd_automation/State/notification_provider.dart';
import 'package:cd_automation/pages/AdminPages/Powermeterlistdwnrpt.dart';
import 'package:flutter/material.dart';
import 'package:cd_automation/pages/AdminPages/PowerMeterListDashPage.dart';
import 'package:cd_automation/pages/AdminPages/PowerMeterReadingPage.dart';
import 'package:cd_automation/pages/AdminPages/WaterMeterListDash.dart';
import 'package:cd_automation/pages/AdminPages/WaterMeterReadingPage.dart';
import 'package:cd_automation/pages/AdminPages/Watermeterlistdwnrpt.dart';
import 'package:cd_automation/pages/DeviceUUIDPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cd_automation/pages/AdminLoginPage.dart';
import 'package:cd_automation/pages/AdminPages/PowerMeterList.dart';
import 'package:cd_automation/pages/AdminPages/WaterMeterList.dart';
import 'package:cd_automation/pages/AdminPages/AddAdminPage.dart';
import 'package:cd_automation/pages/AdminPages/AddRegularUserPage.dart';
import 'package:cd_automation/pages/AdminPages/AdminUserListPage.dart';
import 'package:cd_automation/pages/AdminPages/RegularUserListPage.dart';
import 'package:cd_automation/pages/AdminPages/UserListPage.dart';
import 'package:cd_automation/pages/DashboardPage.dart';
import 'package:cd_automation/pages/HomePage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cd_automation/util/Notification/Notificationhandling.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      NotificationHandling handler = NotificationHandling(context);
      await handler.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CD Automation",
      initialRoute: "/",
      routes: {
        "/": (context) => GetStartedPage(),
        "/device_uuid": (context) => DeviceUUIDPage(),
        "/auth/login": (context) => LoginPage(),
        "/dashboard": (context) => DashboardPage(),
        "/admin/userlist": (context) => UserListPage(),
        "/admin/adminlist": (context) => AdminUserListPage(),
        "/admin/regularlist": (context) => RegularUserListPage(),
        "/admin/add/adminUser": (context) => AddAdminPage(),
        "/admin/add/regularUser": (context) => AddRegularUserPage(),
        "/admin/waterMeterList": (context) =>
            WaterMeterList(scaffoldKey: GlobalKey<ScaffoldState>()),
        "/admin/powerMeterList": (context) =>
            PowerMeterList(scaffoldKey: GlobalKey<ScaffoldState>()),
        "/admin/reading/powermeter": (context) =>
            PowerMeterReadingPage(scaffoldKey: GlobalKey<ScaffoldState>()),
        "/admin/reading/watermeter": (context) =>
            WaterMeterReadingPage(scaffoldKey: GlobalKey<ScaffoldState>()),
        "/admin/dashboard/watermeterlist": (context) => Watermeterlistdash(),
        "/admin/dashboard/powermeterlist": (context) =>
            Powermeterlistdashpage(),
        "/admin/download/report/watermeter/list": (context) =>
            Watermeterlistdwnrpt(),
        "/admin/download/report/powermeter/list": (context) =>
            Powermeterlistdwnrpt(),
      },
    );
  }
}
