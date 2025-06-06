import 'package:cd_automation/pages/AdminPages/WaterMeterFinalReportDashPage.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/PopupComponents/FromDatePicker.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class Powermeterdetailsdashpage extends StatefulWidget {
  final String categoryName;
  final String powerMeterName;

  const Powermeterdetailsdashpage({
    super.key,
    required this.powerMeterName,
    required this.categoryName,
  });

  @override
  State<Powermeterdetailsdashpage> createState() =>
      _PowermeterdetailsdashpageState();
}

class _PowermeterdetailsdashpageState extends State<Powermeterdetailsdashpage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> items = [
    'Past 1 Month',
    'Past 2 Month',
    'Past 3 Month',
    'Past 4 Month',
    'Past 5 Month',
    'Past 6 Month',
    'Past 7 Month',
    'Past 8 Month',
    'Past 9 Month',
    'Past 10 Month',
    'Past 11 Month',
    'Past 12 Month',
  ];
  String? selectedValue;
  DateTime? fromDate;
  DateTime? toDate;

  // Convert selected month range string into actual DateTime range
  Map<String, DateTime> convertMonthIntoFromAndEndDate(String? months) {
    final currentDatetime = DateTime.now();
    final DateTime endDate = DateTime(currentDatetime.year,
        currentDatetime.month, currentDatetime.day); // strip time from now
    DateTime fromDate;

    final match = RegExp(r'Past (\d+) Month').firstMatch(months ?? '');
    if (match != null) {
      int monthsAgo = int.parse(match.group(1)!);
      final tempDate = DateTime(currentDatetime.year,
          currentDatetime.month - monthsAgo, currentDatetime.day);
      fromDate =
          DateTime(tempDate.year, tempDate.month, tempDate.day); // strip time
    } else {
      final tempDate = DateTime(
          currentDatetime.year - 1, currentDatetime.month, currentDatetime.day);
      fromDate =
          DateTime(tempDate.year, tempDate.month, tempDate.day); // strip time
    }

    return {"fromDate": fromDate, "toDate": endDate};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Power Meter',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '>',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.categoryName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                            widget.powerMeterName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select a Date',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF387589),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FromDatePicker(
                                      meterName: widget.powerMeterName,
                                      categoryname: "Water Meter",
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'From Date',
                                style: TextStyle(
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                // Implement To Date picker if needed
                              },
                              child: const Text(
                                'To Date',
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
                      const SizedBox(height: 40),
                      DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        hint: const Text(
                          'Select a particular month range',
                          style: TextStyle(fontSize: 14),
                        ),
                        items: items
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ))
                            .toList(),
                        value: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                            final dateRange =
                                convertMonthIntoFromAndEndDate(value);
                            fromDate = dateRange['fromDate'];
                            toDate = dateRange['toDate'];
                          });
                        },
                        onSaved: (value) {
                          selectedValue = value.toString();
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.only(right: 8),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 24,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Fixed Show Report Button at bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (fromDate == null || toDate == null)
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Watermeterfinalreportdashpage(
                                meterName: widget.powerMeterName,
                                fromDate: fromDate!,
                                toDate: toDate!,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (fromDate == null || toDate == null)
                        ? Colors.grey
                        : const Color(0xFF387589),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Show Report',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
