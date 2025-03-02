// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/Pages/FormPage.dart';
import 'package:finance_tracker/Pages/IncomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/piedata.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  double LastIncome = 0.0;
  double totalBalance = 0.0;
  double LastExpense = 0.0;
  bool isMonthSelected = false;
  bool isYearSelected = false;

  List<PieChartSectionData> getSections() {
    double total = LastIncome + LastExpense + totalBalance;

    if (total == 0) total = 1; // Prevent division by zero

    return [
      PieChartSectionData(
        value: (LastIncome == 0)
            ? 1
            : LastIncome / total * 100, // Ensure visibility
        color: Colors.green,
        title: '',
        titleStyle: TextStyle(fontSize: 0),
        radius: 40,
      ),
      PieChartSectionData(
        value: (LastExpense == 0) ? 1 : LastExpense / total * 100,
        color: Colors.red,
        title: '',
        titleStyle: TextStyle(fontSize: 0),
        radius: 40,
      ),
      PieChartSectionData(
        value: (totalBalance == 0) ? 1 : totalBalance / total * 100,
        color: Colors.blue,
        title: '',
        titleStyle: TextStyle(fontSize: 0),
        radius: 40,
      ),
    ];
  }

  Future<void> fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in.");
        return;
      }

      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .get();

      double tempTotalBalance = 0.0;
      double tempLastIncome = 0.0; // Accumulate income
      double tempLastExpense = 0.0; // Accumulate expenses

      for (var doc in transactionsSnapshot.docs) {
        var data = doc.data();
        double amount = (data['amount'] is String)
            ? double.tryParse(data['amount']) ?? 0.0
            : (data['amount'] ?? 0.0);

        if (data['selectedCategory'] == 'Income') {
          tempTotalBalance += amount;
          tempLastIncome += amount; 
        } else {
          tempTotalBalance -= amount;
          tempLastExpense += amount; 
        }
      }

      setState(() {
        totalBalance = tempTotalBalance;
        LastIncome = tempLastIncome;
        LastExpense = tempLastExpense; 
        PieData.updateData(LastIncome, LastExpense, totalBalance);
      });

      print(
          'Updated LastIncome: $LastIncome, LastExpense: $LastExpense, TotalBalance: $totalBalance');
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue[800],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    " Welcome!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      icon: Icon(Icons.logout_sharp)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    Container(
                      width: screenWidth,
                      height: screenHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  width: screenWidth * 0.8,
                                  height: screenHeight * 0.35,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue[900]!,
                                        Colors.blue[600]!
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 1.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Total Balance',
                                            style: TextStyle(
                                                fontSize: 27,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(height: 30),
                                          const SizedBox(width: 10),
                                          Text(
                                            "₹${totalBalance.toStringAsFixed(2)}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 25),
                                          ),
                                          SizedBox(height: 40),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      "₹${LastIncome.toStringAsFixed(2)}",
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
                                                      "₹${LastExpense.toStringAsFixed(2)}",
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
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: screenWidth * 0.95,
                              height: screenHeight * 0.35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey.shade200],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: Offset(4, 4), // Soft shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  
                                  Flexible(
                                    flex:
                                        2, 
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        PieChart(
                                          PieChartData(
                                            sections: getSections(),
                                            centerSpaceRadius: 80,
                                            startDegreeOffset: 270,
                                            sectionsSpace: 3,
                                            borderData:
                                                FlBorderData(show: false),
                                          ),
                                          swapAnimationDuration:
                                              Duration(milliseconds: 800),
                                          swapAnimationCurve:
                                              Curves.easeOutExpo,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Total Balance',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "₹${totalBalance.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right side color indication column
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 90.0),
                                  //   child: Flexible(
                                  //     flex:
                                  //         1, // Adjusts the color indicators to take 1/4th of the row space
                                  //     child: Column(
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.start,
                                  //       children: PieData.data.map((data) {
                                  //         return Row(
                                  //           children: [
                                  //             Container(
                                  //               width: 20,
                                  //               height: 20,
                                  //               color: data.color,
                                  //             ),
                                  //             const SizedBox(width: 10),
                                  //             Text(
                                  //               '${data.name}',
                                  //               style: TextStyle(
                                  //                   fontSize: 16,
                                  //                   color: Colors.black),
                                  //             ),
                                  //           ],
                                  //         );
                                  //       }).toList(),
                                  //     ),
                                  //   ),
                                  // ),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            PieChart(
                                              PieChartData(
                                                sections: getSections(),
                                                centerSpaceRadius: 80,
                                                startDegreeOffset: 270,
                                                sectionsSpace: 3,
                                                borderData:
                                                    FlBorderData(show: false),
                                              ),
                                              swapAnimationDuration:
                                                  Duration(milliseconds: 800),
                                              swapAnimationCurve:
                                                  Curves.easeOutExpo,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Total Balance',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black54),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "₹${totalBalance.toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        // Instead of Padding -> Flexible
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: PieData.data.map((data) {
                                            return Row(
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  color: data.color,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  '${data.name}',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Incomepage()), // Navigate to Incomepage
                                    );
                                  },
                                  child: Container(
                                    width: 200,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade600,
                                          Colors.blue.shade900
                                        ], // Smooth gradient
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          12), // Rounded corners
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(2, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Show All Transactions",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                FloatingActionButton(
                                  backgroundColor: Colors.blue.shade800,
                                  foregroundColor: Colors.black,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Formpage()),
                                    );
                                  },
                                  child: Icon(Icons.add),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
