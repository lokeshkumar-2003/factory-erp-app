import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cd_automation/Apivariables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:intl/intl.dart';

class Downloadreport extends StatefulWidget {
  final String meter;
  final DateTime? fromdate;
  final DateTime? todate;

  const Downloadreport(
      {super.key, required this.meter, this.fromdate, this.todate});

  @override
  State<Downloadreport> createState() => _DownloadreportState();
}

class _DownloadreportState extends State<Downloadreport> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  List<dynamic> meterReadings = [];

  @override
  void initState() {
    super.initState();
    fetchMeterReadings();
  }

  Future<void> fetchMeterReadings() async {
    final String apiUrl = Apivariables.view_report;

    final String? formattedFromDate = widget.fromdate != null
        ? DateFormat('yyyy-MM-dd').format(widget.fromdate!)
        : null;

    final String? formattedToDate = widget.todate != null
        ? DateFormat('yyyy-MM-dd').format(widget.todate!)
        : null;

    final Map<String, dynamic> requestData = {
      'meterName': widget.meter,
      'fromdate': formattedFromDate,
      'todate': formattedToDate,
    };

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestData),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          meterReadings = data;
        });
      } else {
        throw Exception("Failed to load readings: ${response.statusCode}");
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
            "Error fetching meter readings: $e",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue[100],
              ),
              child: Center(
                child: Text(
                  widget.meter,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Loader or Table
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : meterReadings.isEmpty
                      ? const Center(child: Text("No readings found."))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowColor:
                                  WidgetStateProperty.all(Colors.blue[50]),
                              border: TableBorder.all(color: Colors.black26),
                              columns: const [
                                DataColumn(label: Text('S.No')),
                                DataColumn(
                                    label: Center(child: Text('Date Time'))),
                                DataColumn(
                                    label: Center(child: Text('Meter ID'))),
                                DataColumn(label: Text('Reading Value')),
                                DataColumn(label: Text('User Name')),
                              ],
                              rows: List<DataRow>.generate(
                                meterReadings.length,
                                (index) {
                                  final item = meterReadings[index];
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(Text(item['reading_date']
                                              .toString()
                                              .replaceAll("00:00:00 GMT", "") ??
                                          '')),
                                      DataCell(
                                          Text(item['meter_id'].toString())),
                                      DataCell(Text(
                                          item['reading_value'].toString())),
                                      DataCell(Text(item['username'] ?? '')),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
