// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:finance_tracker/Pages/FormPage.dart';
import 'package:finance_tracker/Pages/IncomePage.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/piedata.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  Homepage({
    super.key,
  });

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late TabController _tabController;
  double income = 0.0;
  double expense = 0.0;

  double totalIncome = 0.0;
  double totalBalance = 0.0;
  double totalExpense = 0.0;
  bool isMonthSelected = false;
  bool isYearSelected = false;

  List<PieChartSectionData> getSections() => PieData.data
      .asMap()
      .map<int, PieChartSectionData>((index, data) {
        final value = PieChartSectionData(
          radius: 42, // set radius according to use
          color: data.color,
          value: data.percent,
          title: '${data.percent}',
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
        );

        return MapEntry(index, value);
      })
      .values
      .toList();

  void resetSelectd() {
    isMonthSelected = false;
    isYearSelected = false;
  }

  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://financetracker-b215b-default-rtdb.firebaseio.com/finance-data.json');

    try {
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);

      data.forEach((key, value) {
        if (value['selectedCategory'] == 'Income') {
          // totalIncome += double.tryParse(value['amount']) ?? 0.0;
          totalBalance += double.tryParse(value['amount']) ?? 0.0;
        } else {
          // totalExpense += double.tryParse(value['amount']) ?? 0.0;
          //totalIncome -= double.tryParse(value['amount']) ?? 0.0;
          totalBalance -= double.tryParse(value['amount']) ?? 0.0;
        }
      });

      setState(() {
        income = totalIncome;
        expense = totalExpense;
        PieData.updateData(income, expense, totalIncome);
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Start off-screen
      end: Offset.zero, // End on-screen
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: SlideTransition(
                        position: _offsetAnimation,
                        child: Container(
                          width: screenWidth * 0.9,
                          height: 250,
                          // decoration: BoxDecoration(
                          //   color: Color(0xFF3C3F41),
                          //   borderRadius: BorderRadius.circular(12),
                          // ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6A11CB),
                                Color(0xFF2575FC)
                              ], // Attractive blue to purple gradient
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: Column(
                              children: [
                                Text(
                                  'Hello',
                                  style: TextStyle(
                                      fontSize: 27, color: Colors.white),
                                ),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(left: 100.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.currency_rupee_outlined,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "₹${totalBalance.toStringAsFixed(2)}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 40),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            "Income",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "₹${income.toStringAsFixed(2)}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Expense",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "10,000",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Incomepage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Show All Transction",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: 200,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center, // Center the text
                        children: [
                          PieChart(
                            PieChartData(
                              sections: getSections(),
                              centerSpaceRadius: 42,
                              startDegreeOffset:
                                  90, // Rotate the chart to position the colors as needed
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black26,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '230',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF6200EA),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Formpage()),
                    );
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
