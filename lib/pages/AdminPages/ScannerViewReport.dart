import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:cd_automation/Apivariables.dart'; // Ensure this has view_recent_30_days_readings

class Reading {
  final DateTime date;
  final double value;

  Reading({required this.date, required this.value});

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      date: DateTime.parse(json['reading_date']),
      value: double.tryParse(json['reading_value'].toString()) ?? 0.0,
    );
  }
}

class Scannerviewreport extends StatefulWidget {
  final String meterName;

  const Scannerviewreport({
    super.key,
    required this.meterName,
  });

  @override
  State<Scannerviewreport> createState() => _Scannerviewreport();
}

class _Scannerviewreport extends State<Scannerviewreport> {
  List<Reading> readings = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchReadings();
  }

  Future<void> fetchReadings() async {
    try {
      final uri = Uri.parse(
          "${Apivariables.view_recent_30_days_readings}/${widget.meterName}");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final readingList = data['readings'] as List;

        setState(() {
          readings = readingList
              .map((e) => Reading.fromJson(e))
              .toList()
              .reversed
              .toList(); // Chronological order
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = (readings.length * 60).clamp(300, 800).toDouble();
    final chartHeight = 120.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Readings Report")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error loading data"))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.95),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  'Daily ${widget.meterName} Consumption over Last 30 Days (kL)',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: chartWidth,
                                    height: chartHeight,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(show: true),
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                final index = value.toInt();
                                                if (index < 0 ||
                                                    index >= readings.length) {
                                                  return const SizedBox();
                                                }
                                                final date =
                                                    readings[index].date;
                                                return Transform.rotate(
                                                  angle: -0.5,
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    DateFormat('MM/dd')
                                                        .format(date),
                                                    style: const TextStyle(
                                                        fontSize: 10),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            axisNameWidget: const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 16.0),
                                              child: Text(
                                                'Consumption',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            axisNameSize: 32,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 50,
                                              interval: _calculateInterval(),
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  NumberFormat.compact()
                                                      .format(value),
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: true),
                                        minY: 0,
                                        maxY: _calculateMaxY(),
                                        lineBarsData: [
                                          LineChartBarData(
                                            isCurved: true,
                                            barWidth: 3,
                                            dotData: FlDotData(show: true),
                                            color: Colors.blue,
                                            spots: List.generate(
                                              readings.length,
                                              (index) => FlSpot(
                                                index.toDouble(),
                                                readings[index].value,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  double _calculateMaxY() {
    if (readings.isEmpty) return 1000;
    final maxVal = readings.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return (maxVal * 1.2).ceilToDouble();
  }

  double _calculateInterval() {
    final maxY = _calculateMaxY();
    return (maxY / 5).ceilToDouble();
  }
}
