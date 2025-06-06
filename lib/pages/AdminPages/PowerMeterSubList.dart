import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/AdminPages/AddNewWaterMeter.dart';
import 'package:cd_automation/pages/AdminPages/WaterMeterEditOptionPage.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';

class PowerMeterSubList extends StatefulWidget {
  final String powerMeterSection;
  const PowerMeterSubList({super.key, required this.powerMeterSection});

  @override
  _PowerMeterSubListState createState() => _PowerMeterSubListState();
}

class _PowerMeterSubListState extends State<PowerMeterSubList> {
  List<Map<String, dynamic>> chosenMeterList = [];
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getMeterList();
  }

  Future<void> getMeterList() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        '${Apivariables.get_submeterlist}/${widget.powerMeterSection.trim()}',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData["data"] != null && decodedData["data"] is List) {
          final List<Map<String, dynamic>> updatedList =
              List<Map<String, dynamic>>.from(
            decodedData["data"].map((e) => {
                  "MeterName": e["MeterName"].toString(),
                  "MeterID": e["MeterID"],
                  "Status": e["MeterStatus"] ?? "Inactive",
                }),
          );
          if (mounted) {
            setState(() {
              chosenMeterList = updatedList;
            });
          }
        }
      } else {
        _showSnackBar("Failed to load meter list");
      }
    } on SocketException {
      _showSnackBar('Network error while loading meter list');
    } on TimeoutException {
      _showSnackBar('Request timed out while loading meter list');
    } catch (e) {
      _showSnackBar("Something went wrong: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: SingleChildScrollView(
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
                  'Meter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 50,
              width: 500,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.table_chart),
                  const SizedBox(width: 5),
                  Text(
                    widget.powerMeterSection,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00536E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: chosenMeterList.map((meter) {
                      final meterName = meter["MeterName"];
                      final meterId = meter["MeterID"];
                      final status = meter["Status"];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WaterMeterEditOption(
                                    meterType: "Power Meter",
                                    waterMeterName: meterName,
                                    meterId: meterId,
                                    subMeterName: widget.powerMeterSection,
                                  ),
                                ),
                              );
                              if (result == true) {
                                getMeterList();
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  meterName,
                                  style: const TextStyle(
                                    color: Color(0xFF00536E),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: status == "Active"
                                            ? Colors.green
                                            : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        color: status == "Active"
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00536E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddNewWaterMeter(
                      metertype: "Power Meter",
                      submetername: widget.powerMeterSection,
                    ),
                  ),
                );
                if (result == true) {
                  getMeterList();
                }
              },
              child: const Text(
                'Add a new meter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
