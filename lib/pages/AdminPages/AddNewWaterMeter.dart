import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/PopupComponents/SuccessDialog.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:cd_automation/util/Localstorage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddNewWaterMeter extends StatefulWidget {
  String? metertype;
  String? submetername;

  AddNewWaterMeter({super.key, required this.metertype, this.submetername});

  @override
  State<AddNewWaterMeter> createState() => _AddNewWaterMeterState();
}

class _AddNewWaterMeterState extends State<AddNewWaterMeter> {
  final TextEditingController meternameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String? meterType;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    meterType = widget.metertype;
  }

  Future<void> addNewMeter() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? query;
      if (widget.metertype == "Water Meter") {
        query = '${Apivariables.add_new_meter}/${widget.metertype}';
      } else {
        query = '${Apivariables.add_new_sub_meter}/${widget.submetername}';
      }

      Map<String, String> data = {
        "metername": meternameController.text.trim(),
      };

      final result = await http.post(
        Uri.parse(query),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10)); // timeout added

      if (result.statusCode == 201) {
        String? masterUserName = await LocalStorage().getUserNameData();
        final uri = Uri.parse(
          '${Apivariables.notification_user}/$masterUserName/${meternameController.text}/${widget.metertype}/Add',
        );

        await http.get(uri).timeout(const Duration(seconds: 5));

        final data = jsonDecode(result.body);
        if (mounted) {
          showSuccessDialog(context, data["message"] ?? "Added successfully");
          meternameController.clear();

          Future.delayed(const Duration(seconds: 0), () {
            if (mounted) {
              Navigator.pop(context);
              Navigator.pop(context, true);
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to add meter. Try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on SocketException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No Internet connection."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request timed out. Try again later."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    bool isOptional = false,
    TextInputType inputType = TextInputType.text,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF00536E),
              ),
            ),
            if (isOptional)
              Text(
                ' (optional)',
                style: TextStyle(fontSize: 14, color: Color(0xFF00536E)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFF00536E)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF00536E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Color(0xFF00536E)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF00536E)))
          : SingleChildScrollView(
              // Wrap the body in a SingleChildScrollView
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Meter',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          width: double.infinity, // Make the width flexible
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.table_chart),
                              SizedBox(width: 5),
                              Text(
                                meterType!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00536E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 130),
                        Container(
                          width: double.infinity, // Make the width flexible
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                customTextField(
                                  label: 'Add New Meter',
                                  hint: 'Meter Name',
                                  controller: meternameController,
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF387589),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14),
                                        ),
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                Navigator.pop(context);
                                              },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF00536E),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14),
                                        ),
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                if (meternameController
                                                    .text.isNotEmpty) {
                                                  addNewMeter();
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Please enter meter name"),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                        child: Text(
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
