import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:cd_automation/Apivariables.dart';

class Reading {
  final DateTime date;
  final double value;

  Reading({required this.date, required this.value});
}

class Watermeterfinalreportdashpage extends StatefulWidget {
  final String meterName;
  final DateTime fromDate;
  final DateTime toDate;

  const Watermeterfinalreportdashpage({
    super.key,
    required this.meterName,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<Watermeterfinalreportdashpage> createState() =>
      _WatermeterfinalreportdashpageState();
}

class _WatermeterfinalreportdashpageState
    extends State<Watermeterfinalreportdashpage> {
  List<Reading> readings = [];

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchReadingData();
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> fetchReadingData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final uri = Uri.parse(
          "${Apivariables.view_dashboard_reports}/${widget.meterName}");

      final formattedFromDate =
          DateFormat('yyyy-MM-dd').format(widget.fromDate);
      final formattedToDate = DateFormat('yyyy-MM-dd').format(widget.toDate);

      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(
                {"from_date": formattedFromDate, "to_date": formattedToDate}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List readingsData = data['readings'] ?? [];

        List<Reading> tempReadings = [];

        for (var reading in readingsData) {
          final dateStr = reading['reading_date'];
          final valueStr = reading['reading_value'];

          final parsedDate = _parseDate(dateStr);
          final value = double.tryParse(valueStr.toString());

          if (parsedDate != null && value != null) {
            tempReadings.add(Reading(date: parsedDate, value: value));
          }
        }

        tempReadings.sort((a, b) => a.date.compareTo(b.date));

        setState(() {
          readings = tempReadings;
          isLoading = false;
        });
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = (readings.length * 60).clamp(300, 800).toDouble();
    final chartHeight = 120.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Water Report")),
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
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  'Daily ${widget.meterName} Consumption from ${widget.fromDate.toString().replaceAll("00:00:00.000", "")} to ${widget.toDate.toString().replaceAll("00:00:00.000", "")}',
                                  style: TextStyle(
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
                                                      fontSize: 10,
                                                    ),
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
                                              interval: (readings.isEmpty)
                                                  ? 100
                                                  : _calculateInterval(),
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
                                        maxY: (readings.isEmpty)
                                            ? 1000
                                            : _calculateMaxY(),
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
                                                readings[index]
                                                    .value
                                                    .toDouble(),
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
    final maxVal = readings.map((e) => e.value).fold<double>(
        0,
        (previousValue, element) =>
            element > previousValue ? element : previousValue);
    return (maxVal * 1.2).ceilToDouble();
  }

  double _calculateInterval() {
    final maxY = _calculateMaxY();
    return maxY / 5;
  }
}
