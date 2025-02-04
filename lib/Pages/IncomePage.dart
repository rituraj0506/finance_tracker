import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import intl package for date parsing


class Incomepage extends StatefulWidget {
  const Incomepage({super.key});

  @override
  State<Incomepage> createState() => _IncomepageState();
}

class _IncomepageState extends State<Incomepage> {
  bool isMonthSelected = false;
  bool isYearSelected = false;
  bool isProgrssIndicator = false;

  double incomeval = 0.0;
  double expenseval = 0.0;

  List<DocumentSnapshot> transactionsSnapshot = []; // Store Firestore data

  void resetSelected() {
    setState(() {
      isMonthSelected = false;
      isYearSelected = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in.");
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .get();

      setState(() {
        transactionsSnapshot = snapshot.docs; // Store the documents
      });
    } catch (error) {
      print('Error fetching data: $error');
    }

  }

  DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      try {
        final format = DateFormat('dd/MM/yyyy');
        final parsedDate = format.parse(date);
        print("Parsed Date: $parsedDate"); // Debugging line
        return parsedDate;
      } catch (e) {
        print('Error parsing date: $e');
        return DateTime.now(); // Fallback if parsing fails
      }
    } else {
      // Handle case where date is neither Timestamp nor String
      print('Invalid date format');
      return DateTime.now();
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // Filter transactions based on conditions
    List<DocumentSnapshot> filteredData = transactionsSnapshot.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime transactionDate = parseDate(data['date']); // Fix date parsing

      bool isWithinCurrentMonth = transactionDate.month == currentMonth &&
          transactionDate.year == currentYear;

      bool isWithinLastThreeMonths =
          DateTime.now().difference(transactionDate).inDays <= 90;

      if (isMonthSelected && isWithinLastThreeMonths) {
        return data['selectedCategory'] == 'Income';
      } else if (isYearSelected && isWithinLastThreeMonths) {
        return data['selectedCategory'] == 'Expense';
      }
      return isWithinLastThreeMonths || isWithinCurrentMonth;
    }).toList();


    double totalIncomeThisMonth = 0.0;
    double totalExpenseThisMonth = 0.0;

for (var doc in filteredData) {
      var data = doc.data() as Map<String, dynamic>;

      double amount = double.tryParse(data['amount'].toString()) ?? 0.0;
      DateTime transactionDate = parseDate(data['date']);
      String category = data['selectedCategory'].toString().trim();

      print(
          'Checking transaction: ${data['amount']} | Date: ${data['date']} | Parsed: $transactionDate | Category: $category');

      if (category == 'Income' &&
          transactionDate.month == currentMonth &&
          transactionDate.year == currentYear) {
        print('✅ Adding to totalIncomeThisMonth: $amount');
        totalIncomeThisMonth += amount;
      }

      if (category == 'Expense' &&
          transactionDate.month == currentMonth &&
          transactionDate.year == currentYear) {
        print('✅ Adding to totalExpenseThisMonth: $amount');
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
            SizedBox(height: 20), // Spacing between buttons and stats
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
                            var data = filteredData[index].data()
                                as Map<String, dynamic>;
                            Color containerColor =
                                data['selectedCategory'] == 'Income'
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
                                    'Amount: \₹${data['amount']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          data['selectedCategory'] == 'Income'
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Date: ${data['date']}',
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
                                        data['selectedCategory'],
                                        style: TextStyle(
                                          color: data['selectedCategory'] ==
                                                  'Income'
                                              ? Colors.green
                                              : data['selectedCategory'] ==
                                                      'Expense'
                                                  ? Colors.red
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Description: ${data['description']}',
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
