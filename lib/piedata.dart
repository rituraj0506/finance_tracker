
import 'package:flutter/material.dart';

class PieData {
  static List<Data> data = [];

  static void updateData(double income, double expense, double totalIncome) {
    data = [
      Data(name: 'Income', percent: income, color: Colors.green),
      Data(
        name: 'Expense',
        percent: expense,
        color: Colors.red,
      ),
      Data(
          name: 'Total', percent: totalIncome, color: Colors.blue),
    ];
  }
}




class Data {
  final String name;
  final double percent;
  final Color color;

  Data({required this.name, required this.percent, required this.color});
}
