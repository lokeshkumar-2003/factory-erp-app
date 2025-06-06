import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/AdminPages/PowerMeterDetailsDashPage.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';

class Powermeterlistdashpage extends StatefulWidget {
  const Powermeterlistdashpage({super.key});

  @override
  State<Powermeterlistdashpage> createState() => _PowermeterlistdashpageState();
}

class _PowermeterlistdashpageState extends State<Powermeterlistdashpage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, List<dynamic>> groupedMeters = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPowerMeterCategories();
  }

  Future<void> fetchPowerMeterCategories() async {
    try {
      final response = await http
          .get(Uri.parse(Apivariables.get_sub_meter_list))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Map<String, List<dynamic>> data =
            (jsonData["data"] as Map<String, dynamic>).map((key, value) =>
                MapEntry(key, List<Map<String, dynamic>>.from(value)));

        if (mounted) {
          setState(() {
            groupedMeters = data;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load data (${response.statusCode})");
      }
    } on TimeoutException {
      setState(() => isLoading = false);
      _showError("Request timed out");
    } on SocketException {
      setState(() => isLoading = false);
      _showError("No internet connection");
    } catch (e) {
      setState(() => isLoading = false);
      _showError("Error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedMeters.isEmpty
              ? const Center(child: Text("No data available"))
              : SingleChildScrollView(
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
                          const Text(
                            'Power Meter',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...groupedMeters.entries.map((entry) {
                        final sectionName = entry.key;
                        final meters = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sectionName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...meters.map((meter) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              Powermeterdetailsdashpage(
                                            categoryName: sectionName,
                                            powerMeterName: meter["MeterName"],
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 16,
                                      ),
                                      side: const BorderSide(
                                          color: Color(0xFF00536E)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          meter["MeterName"] ?? "",
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const Icon(Icons.chevron_right),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
