import 'package:cd_automation/pages/AdminPages/PowerMeterFinalReportDashPage.dart';
import 'package:cd_automation/pages/AdminPages/WaterMeterFinalReportDashPage.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:cd_automation/pages/components/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ToDatePicker extends StatefulWidget {
  final String meterName;
  final DateTime selectedFromDate;
  final String categoryName;

  const ToDatePicker({
    super.key,
    required this.meterName,
    required this.selectedFromDate,
    required this.categoryName,
  });

  @override
  _ToDatePickerState createState() => _ToDatePickerState();
}

class _ToDatePickerState extends State<ToDatePicker> {
  DateTime _selectedDate = DateTime.now();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const FlyoutBar(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title
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
                  widget.categoryName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Meter name box
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue[100],
              ),
              child: Center(
                child: Text(
                  widget.meterName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Select a Date', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),

            // "To Date" button
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

            // Calendar
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
                    focusedDay: _selectedDate,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
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

            // Cancel and OK buttons
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
                      if (widget.categoryName == "Water Meter") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Watermeterfinalreportdashpage(
                              meterName: widget.meterName,
                              fromDate: widget.selectedFromDate,
                              toDate: _selectedDate,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Powermeterfinalreportdashpage(
                              categoryName: widget.categoryName,
                              metername: widget.meterName,
                              fromDate: widget.selectedFromDate,
                              toDate: _selectedDate,
                            ),
                          ),
                        );
                      }
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
