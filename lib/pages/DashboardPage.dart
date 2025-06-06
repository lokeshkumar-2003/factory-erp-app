import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cd_automation/util/Notification/NotificationService.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:cd_automation/util/Localstorage.dart';
import 'package:cd_automation/util/Notification/FirebaseApi.dart';
import 'package:cd_automation/State/notification_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeFun(); // ✅ Call it without `await`
  }

  Future<void> initializeFun() async {
    try {
      await FirebaseApi().initNotifications();

      final fetchedUsername = await LocalStorage().getUserNameData();
      if (!mounted) return;

      final provider =
          Provider.of<NotificationProvider>(context, listen: false);

      if (fetchedUsername != null) {
        setState(() {
          username = fetchedUsername;
        });

        await NotificationService()
            .fetchAndSetNotifications(fetchedUsername, provider);
      }
    } catch (e) {
      debugPrint("Notification init error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: const FlyoutBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      MeterCard(
                        route: "/admin/reading/watermeter",
                        imagePath: "assets/images/watermeter.png",
                        title: "Water meter",
                      ),
                      SizedBox(width: 20),
                      MeterCard(
                        route: "/admin/reading/powermeter",
                        imagePath: "assets/images/powermeter.png",
                        title: "Power meter",
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class MeterCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String route;

  const MeterCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 150,
        height: 170,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 90, height: 80, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
