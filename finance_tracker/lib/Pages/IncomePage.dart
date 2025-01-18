import 'dart:convert';
import 'package:finance_tracker/dummy_data.dart';
import 'package:finance_tracker/piedata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Incomepage extends StatefulWidget {
  const Incomepage({super.key});

  @override
  State<Incomepage> createState() => _IncomepageState();
}

class _IncomepageState extends State<Incomepage> {
  bool isMonthSelected = false;
  bool isYearSelected = false;

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
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Filter the data based on the selected category
    List<FinanceData> filteredData = financedata.where((data) {
      if (isMonthSelected) {
        return data.selectedCategory == 'Income'; // Show only income category
      } else if (isYearSelected) {
        return data.selectedCategory == 'Expense'; // Show only expense category
      }
      return true; // Default case if no filter is selected
    }).toList();

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
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
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
                                color: filteredData[index].selectedCategory ==
                                        'income'
                                    ? Colors.green
                                    : filteredData[index].selectedCategory ==
                                            'expense'
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
}

