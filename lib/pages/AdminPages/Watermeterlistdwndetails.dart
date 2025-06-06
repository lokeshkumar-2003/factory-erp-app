import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/AdminPages/DownloadReport.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:cd_automation/pages/components/Downloadreportfrompicker.dart';
import 'package:cd_automation/util/Filestorage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Watermeterlistdwndetails extends StatefulWidget {
  final String meter;
  final DateTime? fromdate;
  final DateTime? todate;
  final String? metertype;

  const Watermeterlistdwndetails(
      {super.key,
      required this.meter,
      this.fromdate,
      this.todate,
      this.metertype});

  @override
  State<Watermeterlistdwndetails> createState() =>
      _WatermeterlistdwndetailsState();
}

class _WatermeterlistdwndetailsState extends State<Watermeterlistdwndetails> {
  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  String? formatDateTimeToString(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  Future<void> downloadReport(
    BuildContext context,
    String fromDate,
    String toDate,
    String meterName,
  ) async {
    PermissionStatus status;

    if (Platform.isAndroid && (await _getAndroidSDKVersion()) >= 30) {
      status = await Permission.manageExternalStorage.status;
    } else {
      status = await Permission.storage.status;
    }

    if (status.isDenied || status.isRestricted) {
      if (Platform.isAndroid && (await _getAndroidSDKVersion()) >= 30) {
        bool granted =
            await Permission.manageExternalStorage.request().isGranted;
        if (!granted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to save the report. Please enable "All Files Access" in app settings.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          openAppSettings();
          return;
        }
      } else {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Storage permission is required to save the report.'),
              backgroundColor: Colors.red,
            ),
          );
          openAppSettings();
          return;
        }
      }
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

        final file = await FileStorage.writeBinaryFile(
          response.bodyBytes,
          fileName,
        );

        if (!mounted) return;
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
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request timed out. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please check your network.'),
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
      key: scaffoldKey,
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
                Text(
                  widget.metertype != "Power Meter"
                      ? "Water Meter"
                      : "Power Meter",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue[100],
                ),
                child: Center(
                  child: Text(
                    widget.meter,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 70),
            // (Optional) Additional Widgets can go here
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // From Date Button
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF387589),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Downloadreportfrompicker(
                            category: "Water meter",
                            meter: widget.meter,
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
                        color: Colors.white,
                      ),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 150),
            Opacity(
              opacity: (widget.fromdate != null && widget.todate != null)
                  ? 1.0
                  : 0.9, // 👈 reduced opacity when disabled
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00536E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: (widget.fromdate != null && widget.todate != null)
                    ? () {
                        String? fromDate =
                            formatDateTimeToString(widget.fromdate);
                        String? toDate = formatDateTimeToString(widget.todate);
                        downloadReport(
                            context, fromDate!, toDate!, widget.meter);
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
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 20),
                    Icon(
                      Icons.cloud_download,
                      size: 25,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
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
                              meter: widget.meter,
                              fromdate: widget.fromdate,
                              todate: widget.todate,
                            ),
                          ),
                        );
                      }
                    : null, // disables the button if either date is null
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
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 25,
                      color: Color(0xFF00536E),
                    ),
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
