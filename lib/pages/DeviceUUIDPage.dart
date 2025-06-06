import 'dart:convert';
import 'package:cd_automation/Apivariables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeviceUUIDPage extends StatefulWidget {
  const DeviceUUIDPage({super.key});

  @override
  _DeviceUUIDPageState createState() => _DeviceUUIDPageState();
}

class _DeviceUUIDPageState extends State<DeviceUUIDPage> {
  final TextEditingController usernameController = TextEditingController();
  String? selectedUserType;
  bool isLoading = false;

  String mapUserType(String? input) {
    if (input == "Admin User") return "admin_users";
    if (input == "Regular User") return "regular_users";
    return "";
  }

  Future<void> fetchAndStoreDeviceUUID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = usernameController.text.trim();
    final usertype = mapUserType(selectedUserType);

    if (username.isEmpty || usertype.isEmpty) {
      _showSnackbar("Please enter a username and select a user type.",
          isSuccess: false);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(Apivariables.get_device_id),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Username": username,
          "Usertype": usertype,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isDeviceActive = data['IsDeviceActive'] == true;
        if (isDeviceActive) {
          _showSnackbar(
            "This account is already linked to another device. Access denied.",
            isSuccess: false,
          );
          return;
        }
        final deviceUUID = data['Device_uuid'];
        sharedPreferences.setString("device_uuid", deviceUUID.toString());
        _showSnackbar("Device linked successfully!", isSuccess: true);
        await http.put(Uri.parse(
            '${Apivariables.device_id_activate}/$usertype/$username'));
        Navigator.pushNamed(context, '/auth/login');
      } else {
        final data = jsonDecode(response.body);
        _showSnackbar(data['message'] ?? data['error'] ?? 'Unknown error',
            isSuccess: false);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackbar("Something went wrong. Please try again.\n$e",
          isSuccess: false);
    }
  }

  void _showSnackbar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Link and Secure Your Details',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 28),
              DropdownButtonFormField<String>(
                value: selectedUserType,
                decoration: InputDecoration(
                    labelText: "Select User",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00536E)),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )),
                items: ["Admin User", "Regular User"]
                    .map(
                      (user) => DropdownMenuItem(
                        value: user,
                        child: Text(user),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUserType = value;
                  });
                },
                isExpanded: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Username*',
                  hintText: 'Enter your username',
                  labelStyle: TextStyle(color: Colors.black),
                  hintStyle: TextStyle(color: Colors.black54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00536E)),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: isLoading ? null : fetchAndStoreDeviceUUID,
                icon: const Icon(Icons.auto_fix_high, color: Colors.white),
                label: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Link Device Id',
                        style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00536E),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
