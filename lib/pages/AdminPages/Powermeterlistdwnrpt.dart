import 'dart:async';
import 'dart:io';

import 'package:cd_automation/pages/AdminPages/Powersubmeterlist.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cd_automation/Apivariables.dart';
import 'package:http/http.dart' as http;

class Powermeterlistdwnrpt extends StatefulWidget {
  const Powermeterlistdwnrpt({super.key});

  @override
  _PowermeterlistdwnrptState createState() => _PowermeterlistdwnrptState();
}

class _PowermeterlistdwnrptState extends State<Powermeterlistdwnrpt> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> meterlist = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getMeterList(); // Fetch meter list when the screen is loaded
  }

  Future<void> getMeterList() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('${Apivariables.get_meter_list}/Power Meter');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData["data"] != null && decodedData["data"] is List) {
          setState(() {
            meterlist = List<Map<String, dynamic>>.from(decodedData["data"]);
          });
          print(meterlist);
        }
      } else {
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
          content: Text("Request timed out. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Internet connection. Please check your network."),
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
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                    'Power Meter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoading) Center(child: CircularProgressIndicator()),
              if (!_isLoading && meterlist.isNotEmpty)
                ...meterlist.map((meter) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Powersubmeterlist(
                                powerMeterSection: meter['MeterName'],
                              ),
                            ),
                          );
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
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            meter['MeterName'] ??
                                'Unknown Meter', // Display the name of the meter
                            style: const TextStyle(color: Color(0xFF00536E)),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              // If no meters are found
              if (!_isLoading && meterlist.isEmpty)
                Center(child: Text('No meters available')),
            ],
          ),
        ),
      ),
    );
  }
}
