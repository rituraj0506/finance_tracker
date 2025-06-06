// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/Pages/FormPage.dart';
import 'package:finance_tracker/Pages/IncomePage.dart';
import 'package:finance_tracker/Poriverdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/piedata.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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


  @override
  void initState() {
    super.initState();
    // fetchData();
    Provider.of<DataProvider>(context,listen: false).fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final dataProvider = Provider.of<DataProvider>(context);


    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue[800],
        body: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout_sharp, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Body content
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: screenWidth,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                    child: Column(
                      children: [
                        // Total Balance Card
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            width: screenWidth * 0.9,
                            height: screenHeight * 0.35,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[900]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Total Balance',
                                  style: TextStyle(fontSize: 27, color: Colors.white),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  "₹${dataProvider.totalBalance.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white, fontSize: 25),
                                ),
                                const SizedBox(height: 40),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            "Income",
                                            style: TextStyle(color: Colors.white, fontSize: 15),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "₹${dataProvider.LastIncome.toStringAsFixed(2)}",
                                            style: const TextStyle(color: Colors.white, fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "Expense",
                                            style: TextStyle(color: Colors.white, fontSize: 15),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "₹${dataProvider.LastExpense.toStringAsFixed(2)}",
                                            style: const TextStyle(color: Colors.white, fontSize: 15),
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

                        const SizedBox(height: 40),

                        // Pie chart and indicators
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
                                  offset: const Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Pie chart
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
                                          borderData: FlBorderData(show: false),
                                        ),
                                        swapAnimationDuration: const Duration(milliseconds: 800),
                                        swapAnimationCurve: Curves.easeOutExpo,
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Total Balance',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "₹${dataProvider.totalBalance.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Color indicators
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: PieData.data.map((data) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: 20,
                                                color: data.color,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                               data.name,
                                                style: const TextStyle(fontSize: 16, color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom buttons
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Incomepage()),
                                  );
                                },
                                child: Container(
                                  width: 200,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade600, Colors.blue.shade900],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      const BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(2, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
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
                                foregroundColor: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Formpage()),
                                  );
                                },
                                child: const Icon(Icons.add),
                              )
                            ],
                          ),
                        ),
                      ],
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
