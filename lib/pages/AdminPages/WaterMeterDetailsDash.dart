import 'package:cd_automation/pages/AdminPages/WaterMeterFinalReportDashPage.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/PopupComponents/FromDatePicker.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class Watermeterdetailsdash extends StatefulWidget {
  final String watermetername;

  const Watermeterdetailsdash({super.key, required this.watermetername});

  @override
  State<Watermeterdetailsdash> createState() => _WatermeterdetailsdashState();
}

class _WatermeterdetailsdashState extends State<Watermeterdetailsdash> {
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

  Map<String, DateTime> convertMonthIntoFromAndEndDate(String? months) {
    final currentDatetime = DateTime.now();
    final DateTime endDate = DateTime(currentDatetime.year,
        currentDatetime.month, currentDatetime.day); // removes time
    DateTime fromDate;

    final match = RegExp(r'Past (\d+) Month').firstMatch(months ?? '');
    if (match != null) {
      int monthsAgo = int.parse(match.group(1)!);
      final tempDate = DateTime(currentDatetime.year,
          currentDatetime.month - monthsAgo, currentDatetime.day);
      fromDate =
          DateTime(tempDate.year, tempDate.month, tempDate.day); // removes time
    } else {
      final tempDate = DateTime(
          currentDatetime.year - 1, currentDatetime.month, currentDatetime.day);
      fromDate =
          DateTime(tempDate.year, tempDate.month, tempDate.day); // removes time
    }

    return {"fromDate": fromDate, "toDate": endDate};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FlyoutBar(),
      key: scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
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
                          'Water Meter',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                          widget.watermetername,
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FromDatePicker(
                                    meterName: widget.watermetername,
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              // Optional: Implement ToDatePicker
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
                    const SizedBox(height: 70),
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
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (fromDate == null || toDate == null)
                      ? null // Disable the button
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Watermeterfinalreportdashpage(
                                meterName: widget.watermetername,
                                fromDate: fromDate!, // assert non-null
                                toDate: toDate!, // assert non-null
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF387589),
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
            ),
          ],
        ),
      ),
    );
  }
}
