import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/AdminPages/AddNewWaterMeter.dart';
import 'package:cd_automation/pages/AdminPages/WaterMeterEditOptionPage.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WaterMeterList extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const WaterMeterList({super.key, required this.scaffoldKey});

  @override
  State<WaterMeterList> createState() => _WaterMeterListState();
}

class _WaterMeterListState extends State<WaterMeterList> {
  List<Map<String, dynamic>> meterlist = [];
  bool _isLoading = false;

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
      final url = Uri.parse('${Apivariables.get_meter_list}/Water Meter');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData["data"] != null && decodedData["data"] is List) {
          if (!mounted) return;
          setState(() {
            meterlist = List<Map<String, dynamic>>.from(decodedData["data"]);
          });
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load meter list"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request timed out. Please try again later."),
          backgroundColor: Colors.red,
        ),
      );
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection. Please check your network."),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: widget.scaffoldKey),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00536E),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Meter',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                        Icon(Icons.table_chart),
                        SizedBox(width: 5),
                        Text(
                          'Water Meter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00536E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...meterlist.map((watermeter) {
                    String status =
                        watermeter["MeterStatus"]?.toString() ?? "Inactive";

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
                                builder: (_) => WaterMeterEditOption(
                                  meterType: "Water Meter",
                                  waterMeterName:
                                      watermeter["MeterName"].toString(),
                                  meterId: watermeter["MeterID"],
                                ),
                              ),
                            );
                            if (result == true) {
                              getMeterList();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color(0xFFF8F9FA),
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
                                  watermeter["MeterName"],
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
                              SizedBox(width: 8),
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
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00536E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddNewWaterMeter(
                                    metertype: "Water Meter",
                                  )));
                      if (result == true) {
                        getMeterList();
                      }
                    },
                    child: Text(
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
