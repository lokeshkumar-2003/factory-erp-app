import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cd_automation/pages/AdminPages/Watermeterlistdwndetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';

class Powersubmeterlist extends StatefulWidget {
  final String powerMeterSection;
  const Powersubmeterlist({super.key, required this.powerMeterSection});

  @override
  _PowersubmeterlistState createState() => _PowersubmeterlistState();
}

class _PowersubmeterlistState extends State<Powersubmeterlist> {
  List<Map<String, dynamic>> chosenMeterList = [];
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getMeterList();
  }

  Future<void> getMeterList() async {
    print(widget.powerMeterSection);
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        '${Apivariables.get_submeterlist}/${widget.powerMeterSection.trim()}',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData["data"] is List) {
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
        setState(() => _isLoading = false);
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
            // Back Button + Title
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

            // Section Display Container
            Container(
              height: 50,
              width: double.infinity, // Changed from fixed 500 width
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
            ),
            const SizedBox(height: 20),

            // Loader or Meter List
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: chosenMeterList.map((meter) {
                      final meterName = meter["MeterName"];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Watermeterlistdwndetails(
                                    meter: meter['MeterName'],
                                    metertype: "Power Meter",
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF8F9FA),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  meterName,
                                  style: const TextStyle(
                                    color: Color(0xFF00536E),
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Color(0xFF00536E)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
