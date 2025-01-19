import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl package for date parsing
import 'package:finance_tracker/dummy_data.dart';

class Incomepage extends StatefulWidget {
  const Incomepage({super.key});

  @override
  State<Incomepage> createState() => _IncomepageState();
}

class _IncomepageState extends State<Incomepage> {
  bool isMonthSelected = false;
  bool isYearSelected = false;
  bool isProgrssIndicator = false;

  void resetSelected() {
    isMonthSelected = false;
    isYearSelected = false;
  }

  double incomeval = 0.0;
  double expenseval = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List<FinanceData> financedata = [];

  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://financetracker-b215b-default-rtdb.firebaseio.com/finance-data.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsondata = jsonDecode(response.body);

        setState(() {
          financedata = jsondata.entries.map((entry) {
            return FinanceData.fromJson(entry.value, entry.key);
          }).toList();
          isProgrssIndicator = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Get current month and year for filtering
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // Filter the data based on the selected category and last 3 months
    List<FinanceData> filteredData = financedata.where((data) {
      DateTime transactionDate =
          parseDate(data.date); // Parsing the date properly

      bool isWithinCurrentMonth = transactionDate.month == currentMonth &&
          transactionDate.year == currentYear;

      bool isWithinLastThreeMonths =
          DateTime.now().difference(transactionDate).inDays <= 90;

      if (isMonthSelected && isWithinLastThreeMonths) {
        return data.selectedCategory == 'Income'; // Show only income category
      } else if (isYearSelected && isWithinLastThreeMonths) {
        return data.selectedCategory == 'Expense'; // Show only expense category
      }
      return isWithinLastThreeMonths || isWithinCurrentMonth;
    }).toList();

    // Calculate total income and expense for the current month
    double totalIncomeThisMonth = 0.0;
    double totalExpenseThisMonth = 0.0;

    for (var data in filteredData) {
      // Parse the amount as a double safely
      double amount = double.tryParse(data.amount.toString()) ?? 0.0;

      if (data.selectedCategory == 'Income' &&
          parseDate(data.date).month == currentMonth &&
          parseDate(data.date).year == currentYear) {
        totalIncomeThisMonth += amount;
      } else if (data.selectedCategory == 'Expense' &&
          parseDate(data.date).month == currentMonth &&
          parseDate(data.date).year == currentYear) {
        totalExpenseThisMonth += amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Transaction History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      resetSelected();
                      isMonthSelected = true;
                    });
                  },
                  child: Text("Income"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isMonthSelected ? Colors.blue : Colors.black38,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      resetSelected();
                      isYearSelected = true;
                    });
                  },
                  child: Text("Expense"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isYearSelected ? Colors.blue : Colors.black38,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Display total income and expense for the current month based on the selected category
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isMonthSelected) ...[
                    Column(
                      children: [
                        Text(
                          "Total Income This Month",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "₹${totalIncomeThisMonth.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 18, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  if (isYearSelected) ...[
                    Column(
                      children: [
                        Text(
                          "Total Expense This Month",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "₹${totalExpenseThisMonth.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            Expanded(
              child: filteredData.isEmpty && !isProgrssIndicator
                  ? Center(
                      child: Image.asset('asset/no_data_found.png'),
                    )
                  : isProgrssIndicator
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            Color containerColor =
                                filteredData[index].selectedCategory == 'Income'
                                    ? Colors.green.shade200
                                    : Colors.red.shade200;

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: containerColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Amount: \₹${filteredData[index].amount}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: filteredData[index]
                                                  .selectedCategory ==
                                              'Income'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Date: ${filteredData[index].date}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Category: ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        filteredData[index].selectedCategory,
                                        style: TextStyle(
                                          color: filteredData[index]
                                                      .selectedCategory ==
                                                  'Income'
                                              ? Colors.green
                                              : filteredData[index]
                                                          .selectedCategory ==
                                                      'Expense'
                                                  ? Colors.red
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Description: ${filteredData[index].description}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to parse dates (custom format)
  DateTime parseDate(String dateStr) {
    try {
      // Using DateFormat to parse date in dd/MM/yyyy format
      final format = DateFormat('dd/MM/yyyy'); // Adjust format if needed
      return format.parse(dateStr);
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now(); // Return current date if parsing fails
    }
  }
}

