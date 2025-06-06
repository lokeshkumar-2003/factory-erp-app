import 'dart:async';

import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/AdminPages/DownloadReport.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/Downloadreportfrompicker.dart';
import 'package:cd_automation/util/Filestorage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Powermeterlistdetailsdwn extends StatefulWidget {
  final String metername;
  final String categoryName;
  final DateTime? fromdate;
  final DateTime? todate;

  const Powermeterlistdetailsdwn({
    super.key,
    required this.metername,
    required this.categoryName,
    this.fromdate,
    this.todate,
  });

  @override
  State<Powermeterlistdetailsdwn> createState() =>
      _PowermeterlistdetailsdwnState();
}

class _PowermeterlistdetailsdwnState extends State<Powermeterlistdetailsdwn> {
  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');

  String? formatDateTimeToString(DateTime? dateTime) {
    if (dateTime == null) return null;
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  Future<void> downloadReport(
    BuildContext context,
    String fromDate,
    String toDate,
    String meterName,
  ) async {
    PermissionStatus status;

    Future<bool> checkAndRequestStoragePermission() async {
      if (Platform.isAndroid && (await _getAndroidSDKVersion()) >= 30) {
        status = await Permission.manageExternalStorage.status;
        if (status.isDenied || status.isRestricted) {
          final granted =
              await Permission.manageExternalStorage.request().isGranted;
          return granted;
        }
        return status.isGranted;
      } else {
        status = await Permission.storage.status;
        if (status.isDenied || status.isRestricted) {
          final granted = await Permission.storage.request().isGranted;
          return granted;
        }
        return status.isGranted;
      }
    }

    final hasPermission = await checkAndRequestStoragePermission();

    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        Platform.isAndroid && (await _getAndroidSDKVersion()) >= 30
            ? const SnackBar(
                content: Text(
                    'Storage permission is required to save the report. Please enable "All Files Access" in app settings.'),
                backgroundColor: Colors.red,
              )
            : const SnackBar(
                content:
                    Text('Storage permission is required to save the report.'),
                backgroundColor: Colors.red,
              ),
      );
      openAppSettings();
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse('${Apivariables.download_reports}/$meterName'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "from_date": fromDate,
              "to_date": toDate,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final fileName = '$meterName-$fromDate-to-$toDate.pdf';

        // Assuming FileStorage.writeBinaryFile writes bytes and returns File
        final file = await FileStorage.writeBinaryFile(
          response.bodyBytes,
          fileName,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved as ${file.path.split('/').last}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate the report from the server.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on SocketException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error occurred while downloading the report.'),
          backgroundColor: Colors.red,
        ),
      );
    } on TimeoutException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download timed out. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('Error saving report: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while saving the report.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<int> _getAndroidSDKVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FlyoutBar(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00536E),
        title:
            const Text('CD Automation', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
          Stack(
            children: [
              IconButton(
                  icon: const Icon(Icons.notifications_none), onPressed: () {}),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('3',
                      style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text('Power Meter',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Text('>',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(widget.categoryName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
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
                  widget.metername,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF387589),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Downloadreportfrompicker(
                            meter: widget.metername,
                            category: "Power meter",
                          ),
                        ),
                      );
                    },
                    child: Text(
                      widget.fromdate != null
                          ? dateFormatter.format(widget.fromdate!)
                          : 'From Date',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF387589),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: Text(
                      widget.todate != null
                          ? dateFormatter.format(widget.todate!)
                          : 'To Date',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Opacity(
              opacity: (widget.fromdate != null && widget.todate != null)
                  ? 1.0
                  : 0.5,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFF00536E), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: (widget.fromdate != null && widget.todate != null)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Downloadreport(
                              meter: widget.metername,
                              fromdate: widget.fromdate!,
                              todate: widget.todate!,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'View Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00536E),
                      ),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.remove_red_eye,
                        size: 25, color: Color(0xFF00536E)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔽 Download Report Button
            Opacity(
              opacity: (widget.fromdate != null && widget.todate != null)
                  ? 1.0
                  : 0.9,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00536E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: (widget.fromdate != null && widget.todate != null)
                    ? () {
                        String? fromDate =
                            formatDateTimeToString(widget.fromdate);
                        String? toDate = formatDateTimeToString(widget.todate);
                        downloadReport(
                            context, fromDate!, toDate!, widget.metername);
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Download Report',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.cloud_download, size: 25, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
