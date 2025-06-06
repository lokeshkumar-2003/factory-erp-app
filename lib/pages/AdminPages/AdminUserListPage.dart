import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cd_automation/pages/AdminPages/DetailsPage.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> adminUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAdminUsers();
  }

  Future<void> loadAdminUsers() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final String url = '${Apivariables.get_user_list}/admin_users';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          adminUsers =
              data.map((user) => Map<String, dynamic>.from(user)).toList();
          isLoading = false;
        });
      } else {
        debugPrint("Failed to load admin users: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } on SocketException {
      debugPrint("No internet connection.");
      setState(() {
        isLoading = false;
      });
    } on TimeoutException {
      debugPrint("Request to fetch admin users timed out.");
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching admin users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Admin List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Admin User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00536E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ...adminUsers.map((user) {
                    String userName = user['Name'] ?? 'Unnamed';
                    int userId = (user['userId'] is int) ? user['userId'] : 0;

                    bool isActive = user['IsDeviceActive'] == 1 ? true : false;
                    String status = isActive ? "Active" : "Inactive";
                    Color statusColor = isActive ? Colors.green : Colors.red;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminDetailPage(
                                  userName: userName,
                                  userId: userId.toString(),
                                  userType: "admin_users",
                                ),
                              ),
                            );

                            if (result == true) {
                              loadAdminUsers();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8F9FA),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 20,
                            ),
                            side: const BorderSide(color: Color(0xFF00536E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Color(0xFF00536E),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
