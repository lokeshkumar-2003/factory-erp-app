import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/PopupComponents/SuccessDialog.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditWaterMeter extends StatefulWidget {
  const EditWaterMeter(
      {super.key, required this.metername, required this.metertype});

  final String metername;
  final String metertype;

  @override
  State<EditWaterMeter> createState() => _EditWaterMeterState();
}

class _EditWaterMeterState extends State<EditWaterMeter> {
  final TextEditingController currentnameController = TextEditingController();
  final TextEditingController newnameController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentnameController.text = widget.metername;
  }

  Future<void> editMeterName() async {
    if (!mounted) return;
    setState(() => isLoading = true); // Show loader

    try {
      Map<String, String> meterData = {
        "oldmetername": currentnameController.text.trim(),
        "newmetername": newnameController.text.trim(),
        "metertype": widget.metertype.trim(),
      };

      final response = await http.put(
        Uri.parse(Apivariables.edit_meter_name),
        body: jsonEncode(meterData),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
          context,
          responseData["message"] ?? "Successfully updated",
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context, true);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData["message"] ?? "Error occurred",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Request timed out", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    currentnameController.dispose();
    newnameController.dispose();
    super.dispose();
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          message: message,
          isButton: false,
        );
      },
    );
  }

  Widget customTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool disable,
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
                color: Color(0xFF00536E),
              ),
            ),
            if (isOptional)
              const Text(
                ' (optional)',
                style: TextStyle(fontSize: 14, color: Color(0xFF00536E)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        disable
            ? Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF00536E)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  controller.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              )
            : TextField(
                controller: controller,
                keyboardType: inputType,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
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

  @override
  Widget build(BuildContext context) {
    print(widget.metertype);
    return Scaffold(
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Water Meter',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Edit Meter Name',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00536E),
                          ),
                        ),
                        const SizedBox(height: 40),
                        customTextField(
                          label: 'Current Meter Name',
                          hint: 'Current name',
                          disable: true,
                          controller: currentnameController,
                        ),
                        customTextField(
                          label: 'New Name',
                          hint: 'Enter new name',
                          disable: false,
                          controller: newnameController,
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  minimumSize: const Size(double.infinity, 50),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: () {
                                  if (newnameController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please enter a new meter name.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    editMeterName();
                                  }
                                },
                                child: const Text(
                                  'Done',
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
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00536E),
              ),
            ),
        ],
      ),
    );
  }
}
