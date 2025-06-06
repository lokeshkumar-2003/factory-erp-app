import 'dart:convert';

import 'package:cd_automation/Apivariables.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cd_automation/pages/AdminPages/ScannerViewPage.dart';
import 'package:http/http.dart' as http;

class MeterScannerPage extends StatefulWidget {
  final String metertype;
  const MeterScannerPage({super.key, required this.metertype});

  @override
  _MeterScannerPageState createState() => _MeterScannerPageState();
}

class _MeterScannerPageState extends State<MeterScannerPage> {
  bool textAvailable = false;
  String barcodeText = '';

  late final String meterTypeDisplay;

  @override
  void initState() {
    super.initState();
    meterTypeDisplay =
        widget.metertype == "PowerMeter" ? "Power Meter" : "Water Meter";
  }

  Future<bool> checkMeter(BuildContext context, String meterName) async {
    final url =
        Uri.parse('${Apivariables.check_meter}/$meterName/${widget.metertype}');

    try {
      final response = await http.get(url);

      if (!context.mounted) return false; // Make sure context is valid

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Meter is inactive or invalid';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$message'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      } else if (response.statusCode == 404) {
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Meter not found';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$message'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cd Automation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00536E),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Please scan the $meterTypeDisplay",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  fit: BoxFit.cover,
                  onDetect: (BarcodeCapture capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        setState(() {
                          textAvailable = true;
                          barcodeText = barcode.rawValue!;
                        });
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (textAvailable)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Scanned Barcode: $barcodeText',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: textAvailable
                  ? () async {
                      bool isValid = await checkMeter(context, barcodeText);
                      if (isValid) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scannerviewpage(
                              metername: barcodeText,
                              metertype: widget.metertype,
                            ),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    textAvailable ? const Color(0xFF00536E) : Colors.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                "Click camera to capture",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: const BorderSide(color: Color(0xFF00536E)),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16, color: Color(0xFF00536E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
