// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:finance_tracker/Pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomePage after a delay
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Homepage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/splash_screen.jpg'),
            fit: BoxFit.cover, // Ensures the image covers the whole container
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, // Align to the bottom
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wallet_membership, // Finance-related icon
                  color: Colors.white,
                  size: 30.0,
                ),
                SizedBox(width: 10), // Space between icon and text
                Text(
                  'Welcome to Finance Tracker',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Space from the bottom
          ],
        ),
      ),
    );
  }
}
