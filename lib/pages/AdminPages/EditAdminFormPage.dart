import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:cd_automation/util/Localstorage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class EditAdminPage extends StatefulWidget {
  const EditAdminPage(
      {super.key, required this.userId, required this.usertype});
  final String userId;
  final String usertype;

  @override
  State<EditAdminPage> createState() => _EditAdminPageState();
}

class _EditAdminPageState extends State<EditAdminPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController deviceIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool? isDeviceActive;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  final Uuid uuid = Uuid();
  String? usertypetext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserDetails();
    });
    setState(() {
      usertypetext =
          widget.usertype == "admin_users" ? "Admin user" : "Regular user";
    });
  }

  Future<void> getUserDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    String url = '${Apivariables.get_user}/${widget.usertype}/${widget.userId}';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is List && decodedData.isNotEmpty) {
          final data = decodedData[0];

          setState(() {
            nameController.text = data['Name']?.toString() ?? '';
            usernameController.text = data['Username']?.toString() ?? '';
            mobileController.text = data['Phoneno']?.toString() ?? '';
            deviceIdController.text = data['Device_uuid']?.toString() ?? '';
            emailController.text = data['EmailId']?.toString() ?? '';
            passwordController.text = data['Password']?.toString() ?? '';
            isDeviceActive = data['IsDeviceActive'] == 1 ? true : false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user data found.',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user details: ${response.statusCode}',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Request timed out', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error fetching user details: $e',
      //         style: const TextStyle(color: Colors.white)),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateUserDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> userdata = {
        "Name": nameController.text.trim(),
        "Username": usernameController.text.trim(),
        "Phoneno": int.tryParse(mobileController.text.trim()) ?? 0,
        "EmailId": emailController.text.trim(),
        "Device_uuid": deviceIdController.text.trim(),
        "Password": passwordController.text.trim(),
        "IsDeviceActive": isDeviceActive,
      };

      String url =
          '${Apivariables.edit_user}/${widget.usertype}/${widget.userId}';

      final response = await http
          .put(
            Uri.parse(url),
            headers: {'Content-Type': "application/json"},
            body: jsonEncode(userdata),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final responsedata = jsonDecode(response.body);
      String message = responsedata['message'] ?? 'User updated successfully';

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? masterUserName = await LocalStorage().getUserNameData();
        final uri = Uri.parse(
          '${Apivariables.notification_user}/$masterUserName/${usernameController.text.trim()}/${widget.usertype}/Update',
        );

        await http.get(uri);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No internet connection",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Request timed out",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Internal server error: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void createUniqueDeviceId(
      BuildContext context, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Change Device ID?"),
          content: const Text(
            "If you change the device ID, the user will no longer be able to access the account on their previous device. "
            "Do you still want to proceed?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                String deviceId = const Uuid().v4();
                controller.text = deviceId;
                Navigator.of(ctx).pop();
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFF00536E)),
              child: const Text("Yes, Change",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget customTextField({
    required String label,
    required String hint,
    TextEditingController? controller,
    bool isOptional = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF00536E),
                ),
              ),
            ),
            if (isOptional)
              const Text(' (optional)',
                  style: TextStyle(fontSize: 14, color: Color(0xFF00536E))),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
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
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget customToggleField({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF00536E),
                ),
              ),
            ),
            if (isOptional)
              const Text(' (optional)',
                  style: TextStyle(fontSize: 14, color: Color(0xFF00536E))),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF00536E)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value ? "Active" : "Inactive",
                style: TextStyle(
                  fontSize: 16,
                  color: value ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    mobileController.dispose();
    deviceIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
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
                            Text(
                              "$usertypetext",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customTextField(
                                  label: 'Name',
                                  hint: 'Kavin',
                                  controller: nameController),
                              customTextField(
                                  label: 'Username',
                                  hint: 'Mr.kavin123',
                                  controller: usernameController),
                              customTextField(
                                  label: 'Password',
                                  hint: 'Secure!12345',
                                  controller: passwordController),
                              customTextField(
                                  label: 'Mobile Number',
                                  hint: '6345 8475 89',
                                  controller: mobileController),
                              customTextField(
                                  label: 'Email ID',
                                  hint: 'jhondoe@gmail.com',
                                  controller: emailController),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: deviceIdController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        labelText: 'Device UUID*',
                                        hintText: 'Tap the icon to generate',
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF00536E),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400]),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF00536E)),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.refresh,
                                              color: Color(0xFF00536E)),
                                          onPressed: () {
                                            createUniqueDeviceId(
                                                context, deviceIdController);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              customToggleField(
                                label: 'Device Active Status',
                                value: isDeviceActive ?? false,
                                onChanged: (bool newValue) {
                                  setState(() {
                                    isDeviceActive = newValue;
                                  });
                                },
                              ),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00536E),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    updateUserDetails();
                                  },
                                  child: const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
