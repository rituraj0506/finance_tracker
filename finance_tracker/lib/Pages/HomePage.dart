// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:finance_tracker/Pages/FormPage.dart';
import 'package:flutter/material.dart';
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
  double totalExpense = 0.0;
  bool isMonthSelected = false;
  bool isYearSelected = false;

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
          totalIncome += double.tryParse(value['amount']) ?? 0.0;
        } else {
          // totalExpense += double.tryParse(value['amount']) ?? 0.0;
          totalIncome -= double.tryParse(value['amount']) ?? 0.0;
        }
      });

      setState(() {
        income = totalIncome;
        expense = totalExpense;
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
                                  padding: const EdgeInsets.only(left: 83.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.currency_rupee_outlined,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "1000000",
                                        style: TextStyle(
                                            fontSize: 27, color: Colors.white),
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
