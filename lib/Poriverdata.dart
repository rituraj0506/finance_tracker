import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/piedata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier{
  double LastIncome = 0.0;
  double totalBalance = 0.0;
  double LastExpense = 0.0;

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

      totalBalance = tempTotalBalance;
      LastIncome = tempLastIncome;
      LastExpense = tempLastExpense;
      PieData.updateData(LastIncome, LastExpense, totalBalance);

      notifyListeners();
      print(
          'Updated LastIncome: $LastIncome, LastExpense: $LastExpense, TotalBalance: $totalBalance');
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

}