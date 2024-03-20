import 'package:flutter/material.dart';
import 'main.dart'; // Importing CircleTick widget from main.dart

class DispenserControl extends StatefulWidget {
  final Function(String) sendData;

  DispenserControl({required this.sendData});

  @override
  _DispenserControlState createState() => _DispenserControlState();
}

class _DispenserControlState extends State<DispenserControl> {
  String dispenserId = "6746179";
  double currentScaleReading = 50.0; // Liters
  String enteredVolume = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text("Dispenser Control"),
          ),
      body: Center(
        child: SingleChildScrollView(
          // Wrap your Column with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20), // Add space above the "CONNECTED" text
              Text(
                "CONNECTED",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 100), // Add space below the "CONNECTED" text
              Text(
                "Dispenser ID:\n$dispenserId", // Use '\n' to create a line break
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center, // Align the text to the center
              ),
              SizedBox(height: 20),
              Text(
                "SCALE: \nLiters",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(100),
                child: TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Enter Volume (Liters)",
                  ),
                  onChanged: (value) {
                    setState(() {
                      enteredVolume = value;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement logic to send the entered volume to the dispenser (replace with your specific logic)
                  print("Dispensing $enteredVolume liters...");
                  // Clear the entered volume after sending
                  widget.sendData(enteredVolume);

                  setState(() {
                    enteredVolume = "";
                  });
                },
                child: Text("Proceed"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
