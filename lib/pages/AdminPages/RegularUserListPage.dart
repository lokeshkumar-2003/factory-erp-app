import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/AdminPages/DetailsPage.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegularUserListPage extends StatefulWidget {
  const RegularUserListPage({super.key});

  @override
  State<RegularUserListPage> createState() => _RegularUserListPageState();
}

class _RegularUserListPageState extends State<RegularUserListPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> regularUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getLoadUserListData();
  }

  Future<void> getLoadUserListData() async {
    const url = '${Apivariables.get_user_list}/regular_users';

    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          regularUsers =
              data.map((user) => Map<String, dynamic>.from(user)).toList();
          isLoading = false;
        });
      } else {
        print("Failed to load users. Status code: ${response.statusCode}");
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load users (Status: ${response.statusCode})')),
        );
      }
    } on SocketException catch (e) {
      if (!mounted) return;
      print("Network error: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error while fetching users')),
      );
    } on TimeoutException catch (e) {
      if (!mounted) return;
      print("Request timed out: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out while fetching users')),
      );
    } catch (e) {
      if (!mounted) return;
      print("Unexpected error: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    }

    print(regularUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text('User List',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 80),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Regular User',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00536E)),
              ),
            ),
            const SizedBox(height: 50),

            // Loading or content
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (regularUsers.isEmpty)
              const Center(child: Text('No users found.'))
            else
              Expanded(
                child: ListView(
                  children: regularUsers.map((user) {
                    String status = (user['IsDeviceActive'] == true)
                        ? "Active"
                        : "Inactive";

                    Color statusColor = status.toLowerCase() == "active"
                        ? Colors.green
                        : Colors.red;

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
                                  userId: user['userId'],
                                  userName: user['Name'],
                                  userType: "regular_users",
                                ),
                              ),
                            );

                            if (result == true) {
                              getLoadUserListData();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8F9FA),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            side: const BorderSide(color: Color(0xFF00536E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user['Name'] ?? "Unnamed",
                                  style:
                                      const TextStyle(color: Color(0xFF00536E)),
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
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
