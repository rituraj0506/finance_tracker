import 'package:flutter/material.dart';

class Incomepage extends StatefulWidget {
  const Incomepage({super.key});

  @override
  State<Incomepage> createState() => _IncomepageState();
}

class _IncomepageState extends State<Incomepage> {
  bool isMonthSelected = false;
  bool isYearSelected = false;

  void resetSelectd() {
    isMonthSelected = false;
    isYearSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    resetSelectd();
                    isMonthSelected = true;
                  });
                },
                child: Text("Income"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black38,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    resetSelectd();
                    isYearSelected = true;
                  });
                },
                child: Text("Expense"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black38,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          if (isMonthSelected)
            Container(
              width: screenWidth,
              height: 600,
              color: Colors.blue,
            ),
          if (isYearSelected)
            Container(
              width: screenWidth,
              height: 600,
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}
