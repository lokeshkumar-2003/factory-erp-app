import 'dart:async';
import 'dart:io';
import 'package:cd_automation/pages/AdminPages/ScannerViewReport.dart';
import 'package:cd_automation/util/Localstorage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:cd_automation/Apivariables.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/PopupComponents/SuccessDialog.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:image_picker/image_picker.dart';

class Scannerdetailspage extends StatefulWidget {
  final File capturedImage;
  final String metername;
  final String meterType;
  final String userType;

  const Scannerdetailspage({
    super.key,
    required this.capturedImage,
    required this.metername,
    required this.meterType,
    required this.userType,
  });

  @override
  State<Scannerdetailspage> createState() => _ScannerdetailspageState();
}

class _ScannerdetailspageState extends State<Scannerdetailspage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late File _currentImage;
  bool _isLoading = false;
  String _extractedDigits = '';
  bool _isEditing = false;
  final TextEditingController _editingController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentImage = widget.capturedImage;
    initFunctions();
  }

  void initFunctions() async {
    if (widget.meterType == "WaterMeter") {
      await _submitWaterReading();
    } else {
      await _submitPowerReading();
    }
  }

  Future<void> postReadingValue(String meterName, dynamic detectedValue) async {
    final cleanedMeterName = meterName.trim();
    String? username = await LocalStorage().getUserNameData();

    final url =
        Uri.parse('${Apivariables.add_water_meter_reading}/$cleanedMeterName');

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(
                {'readingValue': detectedValue, "username": username}),
          )
          .timeout(const Duration(seconds: 10));

      final responseJson = json.decode(response.body);
      final message = responseJson['message'] ?? 'Unknown error';

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reading successfully submitted'),
              backgroundColor: Colors.green),
        );
        showSuccessDialog(
            context, "Reading Extracted: $detectedValue", widget.metername);
        setState(() => _extractedDigits = detectedValue.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to submit: $message'),
              backgroundColor: Colors.red),
        );
      }
    } on SocketException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Network error while submitting reading."),
            backgroundColor: Colors.red),
      );
      print("SocketException: $e");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error submitting reading: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadFromLocalStorage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _currentImage = File(pickedFile.path);
        });

        if (widget.meterType == "WaterMeter") {
          await _submitWaterReading();
        } else {
          await _submitPowerReading();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitWaterReading() async {
    if (!_currentImage.existsSync()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No image captured or file missing'),
                backgroundColor: Colors.red),
          );
        }
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(Apivariables.extract_water_meter_reading);

      var request = http.MultipartRequest('POST', url)
        ..fields['meterName'] = widget.metername
        ..files
            .add(await http.MultipartFile.fromPath('file', _currentImage.path));

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));

      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        if (responseJson['status'] == 'success') {
          final detectedValue = responseJson['detected_values'];
          setState(() {
            _extractedDigits = detectedValue.toString();
            _editingController.text = _extractedDigits;
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Detection failed: ${responseJson['detected_values'] ?? 'Unknown error'}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Failed to upload image'),
                  backgroundColor: Colors.red),
            );
          }
        });
      }
    } on SocketException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network error during upload'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
      print("SocketException: $e");
    } catch (e) {
      print("Error uploading reading: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('An error occurred during upload'),
                backgroundColor: Colors.red),
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitPowerReading() async {
    if (!_currentImage.existsSync()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No image captured or file missing'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(Apivariables.power_meter_image);

      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          widget.capturedImage.path,
          contentType: MediaType('image', 'jpeg'),
        ));

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        final detectedDigits = responseJson['digits'];

        print("detected value $detectedDigits");

        if (detectedDigits != null && detectedDigits.isNotEmpty) {
          setState(() {
            _extractedDigits = detectedDigits;
            _editingController.text = _extractedDigits;
          });
          await postReadingValue(widget.metername, detectedDigits);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No digits detected from image'),
                backgroundColor: Colors.red),
          );
        }
      } else {
        print("Status: ${response.statusCode}, Body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to extract reading from image'),
              backgroundColor: Colors.red),
        );
      }
    } on SocketException catch (e) {
      if (!mounted) return;
      print("SocketException: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Network error during upload'),
            backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      print("Error uploading power meter reading: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred during upload'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void showSuccessDialog(
      BuildContext context, String message, String meterName) {
    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          message: message,
          isButton: true,
        );
      },
    ).then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scannerviewreport(
            meterName: meterName.trim(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Scanner',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.metername,
                      style: const TextStyle(
                          fontSize: 20, color: Color(0xFF00536E)),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _isEditing
                              ? SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: _editingController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00536E),
                                    ),
                                  ),
                                )
                              : Text(
                                  _extractedDigits.isNotEmpty
                                      ? _extractedDigits
                                      : "No Data",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00536E),
                                  ),
                                ),
                          Row(
                            children: [
                              if (widget.userType == "admin_users")
                                IconButton(
                                  icon: Icon(
                                    _isEditing ? Icons.save : Icons.edit_note,
                                    size: 32,
                                    color: const Color(0xFF00536E),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_isEditing) {
                                        _extractedDigits =
                                            _editingController.text;
                                      }
                                      _isEditing = !_isEditing;
                                    });
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    size: 32, color: Color(0xFF00536E)),
                                onPressed: () {},
                              ),
                              if (widget.userType == "admin_users")
                                IconButton(
                                    icon: const Icon(Icons.folder,
                                        size: 32, color: Color(0xFF00536E)),
                                    onPressed: _pickAndUploadFromLocalStorage),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_currentImage.existsSync())
                      Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF00536E)),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _currentImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      const Text(
                        "Image not found",
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: Color(0xFF00536E), width: 1),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00536E),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00536E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              final valueToSubmit = _isEditing
                                  ? _editingController.text
                                  : _extractedDigits;
                              postReadingValue(widget.metername, valueToSubmit);
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
