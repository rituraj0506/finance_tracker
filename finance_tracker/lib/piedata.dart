import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Piechar extends StatefulWidget {
  const Piechar({super.key});

  @override
  State<Piechar> createState() => _PiecharState();
}

class _PiecharState extends State<Piechar> {
  double income = 0.0;
  double expense = 0.0;

  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
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
          totalExpense += double.tryParse(value['amount']) ?? 0.0;
        }
      });

      setState(() {
        income = totalIncome;
        expense = totalExpense;
        // Update PieData here with fetched values
        PieData.updateData(income, expense, totalIncome);
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class PieData {
  static List<Data> data = [];

  static void updateData(double income, double expense, double totalIncome) {
    data = [
      Data(name: 'Blue', percent: income, color: const Color(0xFF007DBB)),
      Data(
          name: 'Light Pink', percent: expense, color: const Color(0xFFFFA8A7)),
      Data(
          name: 'Orange', percent: totalIncome, color: const Color(0xFFFF914D)),
      Data(
          name: 'Violet',
          percent: 24.0,
          color: const Color(0xFF9C90FF)), // Example fixed data
    ];
  }
}

class Data {
  final String name;
  final double percent;
  final Color color;

  Data({required this.name, required this.percent, required this.color});
}