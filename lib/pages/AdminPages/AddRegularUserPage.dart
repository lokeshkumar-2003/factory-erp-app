import 'dart:async';
import 'dart:io';

import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/util/Localstorage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';

class AddRegularUserPage extends StatefulWidget {
  const AddRegularUserPage({super.key});

  @override
  State<AddRegularUserPage> createState() => _AddRegularUserPageState();
}

class _AddRegularUserPageState extends State<AddRegularUserPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController uuidController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final Uuid uuid = Uuid();

  void createUniqueDeviceId(TextEditingController controller) {
    String deviceId = uuid.v4();
    controller.text = deviceId;
  }

  Widget customTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isOptional = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF00536E)),
            ),
            if (isOptional)
              const Text(
                ' (optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF00536E),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00536E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00536E)),
            ),
          ),
          validator: (value) {
            if (!isOptional && (value == null || value.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> addUser() async {
    if (!mounted) return;
    String? masterUserName = await LocalStorage().getUserNameData();

    final url = Uri.parse('${Apivariables.add_user}/regular_users');

    setState(() {
      isLoading = true;
    });

    final Map<String, dynamic> body = {
      "Name": nameController.text.trim(),
      "Username": usernameController.text.trim(),
      "Phoneno": mobileController.text.trim(),
      "UserdeviceId": uuidController.text.trim(),
      "IsDeviceActive": false,
      "EmailId": emailController.text.trim(),
      "Password": passwordController.text.trim(),
    };

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final Map<String, dynamic> res = jsonDecode(response.body);
      final String message = res['message'] ?? 'Something went wrong';

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final uri = Uri.parse(
          '${Apivariables.notification_user}/$masterUserName/${usernameController.text.trim()}/Regular%20User/Add',
        );

        await http.get(uri);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Regular user added successfully",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);

        nameController.clear();
        usernameController.clear();
        mobileController.clear();
        uuidController.clear();
        emailController.clear();
        passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on SocketException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No internet connection",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request timed out",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Internal server error",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/industries.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'CD Technotex',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00536E),
                    ),
                  ),
                  const Text(
                    'Add your Regular user account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00536E),
                    ),
                  ),
                  const SizedBox(height: 40),
                  customTextField(
                    label: 'Name',
                    hint: 'kavin',
                    controller: nameController,
                  ),
                  customTextField(
                    label: 'Username*',
                    hint: 'Mr.kavin123',
                    controller: usernameController,
                  ),
                  customTextField(
                    label: 'Password*',
                    hint: 'kavin123',
                    controller: passwordController,
                  ),
                  customTextField(
                    label: 'Email*',
                    hint: 'user@gmail.com',
                    controller: emailController,
                    inputType: TextInputType.emailAddress,
                  ),
                  Row(
                    children: [
                      // UUID TextField
                      Expanded(
                        child: TextFormField(
                          controller: uuidController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Device UUID*',
                            hintText: 'Tap the icon to generate',
                            labelStyle: TextStyle(
                                color: Color(0xFF00536E), // Label color
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF387589), width: 1.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF387589), width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 8),

                      // IconButton styled to match other inputs
                      Container(
                        height: 58,
                        width: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFF387589),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.auto_fix_high, color: Colors.white),
                          onPressed: () {
                            createUniqueDeviceId(uuidController);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  customTextField(
                    label: 'Mobile number*',
                    hint: '6345 8475 89',
                    controller: mobileController,
                    inputType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF387589),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00536E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    addUser();
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
