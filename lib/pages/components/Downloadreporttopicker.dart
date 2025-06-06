// import 'package:cd_mill_automation/download_report/water_meter/dwd_wm_download_page.dart';
import 'package:cd_automation/pages/AdminPages/Powermeterlistdetailsdwn.dart';
import 'package:cd_automation/pages/AdminPages/Watermeterlistdwndetails.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Downloadreporttopicker extends StatefulWidget {
  final String meter;
  final DateTime fromDate;
  final String category;

  const Downloadreporttopicker(
      {super.key,
      required this.meter,
      required this.fromDate,
      required this.category});

  @override
  _DownloadreporttopickerState createState() => _DownloadreporttopickerState();
}

class _DownloadreporttopickerState extends State<Downloadreporttopicker> {
  DateTime todate = DateTime.now();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
                  widget.meter, // ✅ Fixed reference
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    onPressed: () {},
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
            const SizedBox(height: 20),
            Center(
              child: Container(
                height: 350,
                width: 450,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 128, 168, 180),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: todate,
                    selectedDayPredicate: (day) => isSameDay(todate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        todate = selectedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue[500],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      defaultDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 216, 218, 217),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      weekendDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 216, 218, 217),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 182, 197, 202),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
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
                      backgroundColor: const Color(0xFF00536E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      widget.category == "Water meter"
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Watermeterlistdwndetails(
                                  meter: widget.meter,
                                  fromdate: widget.fromDate,
                                  todate: todate,
                                ), // ✅ Fixed
                              ),
                            )
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Powermeterlistdetailsdwn(
                                  metername: widget.meter,
                                  categoryName: "Power meter",
                                  fromdate: widget.fromDate,
                                  todate: todate,
                                ), // ✅ Fixed
                              ),
                            );
                    },
                    child: const Text(
                      'Ok',
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
    );
  }
}
