import 'package:flutter/material.dart';

class FlyoutBar extends StatelessWidget {
  const FlyoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF00536E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _DrawerHeaderSection(),
            _buildExpandableSection(context, Icons.person, "Users", [
              _buildDrawerSubItem(
                  context, "Add Regular User", "/admin/add/regularUser"),
              _buildDrawerSubItem(
                  context, "Add Admin User", "/admin/add/adminUser"),
              _buildDrawerSubItem(context, "User List", "/admin/userlist"),
            ]),
            _buildExpandableSection(context, Icons.speed, "Meter", [
              _buildDrawerSubItem(
                  context, "Water Meter", "/admin/waterMeterList"),
              _buildDrawerSubItem(
                  context, "Power Meter", "/admin/powerMeterList"),
            ]),
            _buildExpandableSection(context, Icons.dashboard, "Dashboard", [
              _buildDrawerSubItem(
                  context, "Water Meter", "/admin/dashboard/watermeterlist"),
              _buildDrawerSubItem(
                  context, "Power Meter", "/admin/dashboard/powermeterlist"),
            ]),
            _buildExpandableSection(
                context, Icons.download, "Download Reports", [
              _buildDrawerSubItem(context, "Water Meter",
                  "/admin/download/report/watermeter/list"),
              _buildDrawerSubItem(context, "Power Meter",
                  "/admin/download/report/powermeter/list"),
            ]),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text("Log out", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeaderSection extends StatelessWidget {
  const _DrawerHeaderSection();

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: const Color(0xFF00536E)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.account_circle, size: 60, color: Colors.white),
          SizedBox(height: 10),
          Text("CD Automation",
              style: TextStyle(fontSize: 20, color: Colors.white)),
        ],
      ),
    );
  }
}

Widget _buildExpandableSection(
    BuildContext context, IconData icon, String title, List<Widget> children) {
  return Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      children: children,
    ),
  );
}

Widget _buildDrawerSubItem(BuildContext context, String title, String route) {
  return ListTile(
    title: Text(title, style: const TextStyle(color: Colors.white)),
    trailing: const Icon(Icons.chevron_right, color: Colors.white70),
    onTap: () {
      Navigator.pop(context); // Close the drawer before navigating
      Navigator.pushNamed(context, route);
    },
  );
}
