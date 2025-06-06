// import 'package:cd_mill_automation/water_meter_dashboard/from_page.dart';
// import 'package:cd_mill_automation/water_meter_dashboard/to_page.dart';
// import 'package:cd_mill_automation/water_meter_dashboard/water_meter_list.dart';
import 'package:cd_automation/pages/PopupComponents/FlyoutBar.dart';
import 'package:flutter/material.dart';

class Watermeterreportfinal extends StatelessWidget {
  final String userName;
  final DateTime fromDate;
  final DateTime toDate;
  const Watermeterreportfinal({
    super.key,
    required this.userName,
    required this.fromDate,
    required this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FlyoutBar(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00536E),
        title: const Text(
          'CD Automation',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Water Meter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 150, vertical: 12),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue[100],
                ),
                child: Text(
                  userName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Text(
                  'Select a Date',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150, // Set a fixed width
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF387589), // Dark Teal
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {},
                      child: Text(
                        "${fromDate.day}-${fromDate.month}-${fromDate.year}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 150, // Set a fixed width
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF387589), // Dark Teal
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => ToPage(
                        //       userName: userName,
                        //     ), // ✅ Pass individual user
                        //   ),
                        // );
                      },
                      child: Text(
                        "${toDate.day}-${toDate.month}-${toDate.year}",
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
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                Text(
                  'Drive Quarters', // Change text as per need: Edit / Delete / Submit
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Image.asset(
              '/images/wm_report.png',
              width: 500,
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 150),
              child: SizedBox(
                width: 150, // Set a fixed width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00536E), // Dark Teal
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Action
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) =>
                    //         D_WaterMeterList(), // ✅ Pass individual user
                    //   ),
                    // );
                  },
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
