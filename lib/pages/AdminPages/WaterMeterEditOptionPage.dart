import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/AdminPages/EditMeter.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/PopupComponents/SuccessDialog.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:cd_automation/util/Filestorage.dart';
import 'package:cd_automation/util/Localstorage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WaterMeterEditOption extends StatefulWidget {
  final String waterMeterName;
  final String meterType;
  final int meterId;
  final String? subMeterName;

  const WaterMeterEditOption(
      {super.key,
      this.subMeterName,
      required this.waterMeterName,
      required this.meterId,
      required this.meterType});

  @override
  State<WaterMeterEditOption> createState() => _WaterMeterEditOptionState();
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class _WaterMeterEditOptionState extends State<WaterMeterEditOption> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController metername = TextEditingController();

  @override
  void initState() {
    super.initState();
    metername.text = widget.waterMeterName;
  }

  Future<void> showConfirmMeterStatusDialog(
    BuildContext context,
    int meterId,
    String meterType,
    String status,
  ) async {
    bool confirmed = false;
    final isActivation = status.toLowerCase() == "activation";

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          isActivation ? "Confirm Activation" : "Confirm Deactivation",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: Text(
          isActivation
              ? "Are you sure you want to activate this meter?"
              : "Are you sure you want to deactivate this meter?",
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black87),
            ),
            onPressed: () {
              confirmed = false;
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00536E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isActivation ? "Activate" : "Deactivate",
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              confirmed = true;
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );

    if (confirmed) {
      if (meterType == "Water Meter") {
        await meterStatusChanges(context, meterId, meterType, status);
      } else {
        await subMeterStatusChanges(
            context, meterId, widget.subMeterName, status);
      }
    }
  }

  Future<void> saveMeterQrFile(BuildContext context, String meterName) async {
    try {
      final response = await http
          .post(
            Uri.parse(Apivariables.qr_code_converter),
            headers: {'Content-Type': 'application/json'},
            body: '{"meter_name":"$meterName"}',
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        await FileStorage.writeBinaryFile(response.bodyBytes, '$meterName.png');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code saved to Downloads as $meterName.png'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate QR code from server.'),
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
          content: Text('No internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('Error saving QR file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while saving the QR file.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> meterStatusChanges(
    BuildContext context,
    int meterId,
    String meterType,
    String status,
  ) async {
    try {
      final uri =
          Uri.parse("${Apivariables.meter_status}/$meterType/$meterId/$status");

      final response = await http.put(uri).timeout(const Duration(seconds: 10));

      if (!mounted) return; // <-- check mounted after await

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        String? masterUserName = await LocalStorage().getUserNameData();
        final notifyUri = Uri.parse(
          '${Apivariables.notification_user}/$masterUserName/${widget.subMeterName}/${widget.meterType}/Update',
        );

        await http.get(notifyUri).timeout(const Duration(seconds: 10));

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => SuccessDialog(
            message: body["message"],
            isButton: false,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update meter status.'),
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
          content: Text('No internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> subMeterStatusChanges(
    BuildContext context,
    int meterId,
    String? subMetername,
    String status,
  ) async {
    try {
      final uri = Uri.parse(
          "${Apivariables.sub_meter_status}/$subMetername/$meterId/$status");

      final response = await http.put(uri).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        String? masterUserName = await LocalStorage().getUserNameData();
        final notifyUri = Uri.parse(
          '${Apivariables.notification_user}/$masterUserName/${widget.subMeterName}/${widget.meterType}/Update',
        );
        await http.get(notifyUri).timeout(const Duration(seconds: 10));

        if (!mounted) return;

        final body = jsonDecode(response.body);
        debugPrint("Success: $body");

        showDialog(
          context: context,
          builder: (context) => SuccessDialog(
            message: body["message"],
            isButton: false,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update meter status.'),
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
          content: Text('No internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context) async {
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Delete Meter",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: const Text(
          "Are you sure you want to delete this water meter?",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
            onPressed: () {
              confirmed = true;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

    if (confirmed) {
      if (widget.meterType == "Water Meter") {
        await deleteMeter(context);
      } else {
        await deleteSubMeter(context);
      }
    }
  }

  Future<void> deleteMeter(BuildContext context) async {
    try {
      final uri = Uri.parse(
          "${Apivariables.delete_meter}/Water Meter/${widget.meterId}");
      final response =
          await http.delete(uri).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        debugPrint("Deleted: $body");
        String? masterUserName = await LocalStorage().getUserNameData();
        final notifyUri = Uri.parse(
          '${Apivariables.notification_user}/$masterUserName/${widget.subMeterName}/${widget.meterType}/Delete;',
        );

        await http.get(notifyUri).timeout(const Duration(seconds: 10));

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => SuccessDialog(
            message: body["message"] ?? "Meter deleted successfully.",
            isButton: false,
          ),
        ).then((_) {
          if (!mounted) return;
          Future.delayed(const Duration(seconds: 0), () {
            Navigator.pop(context, true);
          });
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete the meter.'),
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
          content: Text('No internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("Delete error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while deleting.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteSubMeter(BuildContext context) async {
    try {
      final uri = Uri.parse(
          "${Apivariables.delete_sub_meter_status}/${widget.meterId}");
      final response =
          await http.delete(uri).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        debugPrint("Deleted: $body");
        String? masterUserName = await LocalStorage().getUserNameData();
        final notifyUri = Uri.parse(
          '${Apivariables.notification_user}/$masterUserName/${widget.subMeterName}/${widget.meterType}/Delete',
        );
        await http.get(notifyUri).timeout(const Duration(seconds: 10));

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => SuccessDialog(
            message: body["message"] ?? "Meter deleted successfully.",
            isButton: false,
          ),
        ).then((_) {
          if (!mounted) return;
          Future.delayed(const Duration(seconds: 0), () {
            Navigator.pop(context, true);
          });
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete the meter.'),
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
          content: Text('No internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("Delete error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while deleting.'),
          backgroundColor: Colors.red,
        ),
      );
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
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.meterType,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade100,
              ),
              child: TextField(
                controller: metername,
                enabled: false,
                focusNode: AlwaysDisabledFocusNode(),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00536E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditWaterMeter(
                      metername: widget.waterMeterName,
                      metertype: widget.meterType,
                    ),
                  ),
                );
              },
              child: const Text(
                'Edit',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00536E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (widget.meterType == "Water Meter") {
                  showConfirmMeterStatusDialog(
                    context,
                    widget.meterId,
                    "Water Meter",
                    "Deactivation",
                  );
                } else {
                  showConfirmMeterStatusDialog(
                    context,
                    widget.meterId,
                    "Power Meter",
                    "Deactivation",
                  );
                }
              },
              child: const Text(
                'Deactivate',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00536E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (widget.meterType == "Water Meter") {
                  showConfirmMeterStatusDialog(
                    context,
                    widget.meterId,
                    "Water Meter",
                    "Activation",
                  );
                } else {
                  showConfirmMeterStatusDialog(
                    context,
                    widget.meterId,
                    "Power Meter",
                    "Activation",
                  );
                }
              },
              child: const Text(
                'Activate',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00536E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                saveMeterQrFile(context, widget.waterMeterName);
              },
              child: const Text(
                'Download Qr',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => showDeleteConfirmationDialog(context),
              child: const Text(
                'Delete',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
