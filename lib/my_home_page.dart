import 'package:flutter/material.dart';
import 'main.dart'; // Importing CircleTick widget from main.dart

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //   // title: Text('Pay for Fuel'),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // SizedBox(height: 100),
        children: [
          Center(
            child: CircleTick(size: 100, color: Colors.green),
          ),
          SizedBox(height: 200),
          Text(
            'Place Phone close to NFC Reader',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
