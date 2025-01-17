import 'package:flutter/material.dart';

class ExpenseData {
  final String amount;
  final String description;
  final String date;
  final String selectedCategory;
  ExpenseData({
    required this.amount,
    required this.description,
    required this.date,
    required this.selectedCategory,
  });
}

final List<ExpenseData> expensedata = [
  ExpenseData(
      amount: '10000',
      description: "salary",
      date: "01/01/2025",
      selectedCategory: "selectedCategory"),
];
