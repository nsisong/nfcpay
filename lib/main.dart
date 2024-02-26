import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class CircleTick extends StatelessWidget {
  final double size;
  final Color color;

  const CircleTick({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Add decoration for the border
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.green, width: 2), // Adjust width as needed
      ),
      child: Stack(
        children: [
          // Make the inside white
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: size / 2,
          ),
          Positioned(
            top: size * 0.25,
            left: size * 0.25,
            child: Icon(
              Icons.check,
              color: Colors.green,
              size: size * 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Add variables and functions here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay for Fuel'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute evenly
        children: [
          Center(
            child: CircleTick(size: 100, color: Colors.green),
          ),
          Text(
            'Place Phone close to NFC Reader ..',
            style: TextStyle(fontSize: 16), // Adjust font size as needed
          ),
        ],
      ),
    );
  }
}
