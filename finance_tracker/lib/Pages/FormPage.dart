// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:finance_tracker/Pages/HomePage.dart';
import 'package:finance_tracker/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Formpage extends StatefulWidget {
  const Formpage({super.key});

  @override
  State<Formpage> createState() => _FormpageState();
}

class _FormpageState extends State<Formpage> {
  @override
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory = "Income";
  TextEditingController dateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  List<ExpenseData> expensedata = [];

  Future<void> onSave() async {
    if (_formKey.currentState!.validate()) {
      double parsedAmount = double.tryParse(amountController.text) ?? 0.0;
      String description = descriptionController.text;
      String date = dateController.text;
      final url = Uri.parse(
          'https://financetracker-b215b-default-rtdb.firebaseio.com/finance-data.json');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'amount': parsedAmount.toString(),
            'description': description,
            'date': date,
            'selectedCategory': selectedCategory!,
            '_totalBalance': _totalBalance,
          }),
        );

        if (response.statusCode == 200) {
          print('Data saved successfully!');
        } else {
          print('Failed to save data. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error saving data: $error');
      }

      amountController.clear();
      descriptionController.clear();
      dateController.clear();
      selectedCategory = null;

      //Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Homepage(),
        ),
      );
    } else {
      print('Form validation failed');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 177, 173, 223),
          ),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Text("Enter Amount"),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black), // Corrected usage
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue), // Example focused border
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height:
                            100, // This controls the height of the  TextFormField container
                        child: TextFormField(
                          maxLength: 60,
                          controller: descriptionController,
                          maxLines:
                              null, // Allows the  TextFormField to expand vertically
                          expands: true, // Fills the available height
                          decoration: InputDecoration(
                            label: Text("Enter Description"),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black), // Corrected usage
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue), // Example focused border
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description is required';
                            }

                            return null;
                          },
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: "Select Category",
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            value: selectedCategory,
                            items: [
                              DropdownMenuItem(
                                value: "Income",
                                child: Text("Income"),
                              ),
                              DropdownMenuItem(
                                value: "Expense",
                                child: Text("Expense"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Category is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: dateController,
                            decoration: InputDecoration(
                              labelText: "Enter Date",
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Date is required';
                              }
                              return null;
                            },
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                dateController.text =
                                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: onSave,
                      child: Container(
                        width: 200,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}