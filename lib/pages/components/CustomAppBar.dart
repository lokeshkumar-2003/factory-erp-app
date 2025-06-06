import 'package:cd_automation/State/notification_provider.dart';
import 'package:cd_automation/pages/Notification/NotificationPage.dart';
// <- make sure this import is correct
import 'package:cd_automation/util/Localstorage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({super.key, required this.scaffoldKey});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? userType;
  String? username;

  @override
  void initState() {
    super.initState();
    loadUserType();
  }

  Future<void> loadUserType() async {
    String? fetchedUserType = await LocalStorage().getUserTypeData();
    String? fetchedUsername = await LocalStorage().getUserNameData();
    if (mounted) {
      setState(() {
        userType = fetchedUserType;
        username = fetchedUsername;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notificationCount = notificationProvider.notificationCount;
    final notifications = notificationProvider.notifications;
    return AppBar(
      backgroundColor: const Color(0xFF00536E),
      automaticallyImplyLeading: false,
      leading: userType == "admin_users"
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                widget.scaffoldKey.currentState?.openDrawer();
              },
            )
          : null,
      title: const Text(
        "CD Automation",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        // User Name and Icon
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {
                  // Handle profile button functionality
                },
              ),
              Text(
                username ?? "User",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        Stack(
          children: [
            IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {
                  if (notifications.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationListScreen(
                            notifications: notifications),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No notifications available"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }),
            if (notificationCount >= 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 7,
                  child: Text(
                    notificationCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
