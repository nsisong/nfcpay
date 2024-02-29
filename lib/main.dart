import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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

  const CircleTick({Key? key, required this.size, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Stack(
        children: [
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
  const MyHomePage({Key? key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _tagData = 'Place Phone close to NFC Reader ..';

  @override
  void initState() {
    super.initState();
    _initNFC();
  }

  Future<void> _initNFC() async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          setState(() {
            _tagData = tag.data.toString();
          });
        },
      );
    } catch (e) {
      print('Error initializing NFC: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay for Fuel'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Center(
            child: CircleTick(size: 100, color: Colors.green),
          ),
          Text(
            _tagData,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
}
