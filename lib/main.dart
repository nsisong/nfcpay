import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';
import 'my_home_page.dart'; // Importing MyHomePage widget
import 'screen3.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Tag Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NFCReaderPage(),
    );
  }
}

class NFCReaderPage extends StatefulWidget {
  @override
  _NFCReaderPageState createState() => _NFCReaderPageState();
}

class _NFCReaderPageState extends State<NFCReaderPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;

  @override
  void initState() {
    super.initState();
    _initNFC();
    // scanForDevices();
  }

  Future<void> _initNFC() async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          String? bluetoothName = getBluetoothNameFromNfcTag(tag.data);
          if (bluetoothName != null) {
            await connectToBluetoothDevice(bluetoothName);
          }
          print('Bluetooth Name: $bluetoothName');
        },
      );
    } catch (e) {
      print('Error initializing NFC: $e');
    }
  }

  String? getBluetoothNameFromNfcTag(Map<String, dynamic> tagData) {
    List<int> payload =
        tagData['ndef']['cachedMessage']['records'][0]['payload'];
    List<int> last15Numbers = payload.sublist(payload.length - 15);

    String resultString = "";

    for (int byte in last15Numbers) {
      int asciiCode = byte;
      String asciiChar = String.fromCharCode(asciiCode);

      if (asciiCode >= 65 && asciiCode <= 122) {
        resultString += asciiChar;
      }
    }

    return resultString.isNotEmpty ? resultString : null;
  }

  Future<void> connectToBluetoothDevice(String bluetoothName) async {
    try {
      // Start scanning for devices
      flutterBlue.startScan(timeout: Duration(seconds: 5));

      // Listen to the scan results stream
      flutterBlue.scanResults.listen((List<ScanResult> scanResults) {
        for (ScanResult result in scanResults) {
          if (result.device.name == bluetoothName) {
            // Stop scanning once the device is found
            flutterBlue.stopScan();
            _connectedDevice = result.device;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DispenserControl(sendData: sendData)));
            result.device.connect().then((_) async {
              // Once connected, discover services and characteristics
              List<BluetoothService> services =
                  await result.device.discoverServices();
              for (BluetoothService service in services) {
                for (BluetoothCharacteristic characteristic
                    in service.characteristics) {
                  if (characteristic.properties.write) {
                    _writeCharacteristic = characteristic;
                    // break;
                  } else if (characteristic.properties.notify) {
                    _readCharacteristic = characteristic;
                    _readCharacteristic!.setNotifyValue(true).then((_) {
                      // Listen to incoming notifications
                      _readCharacteristic!.value.listen((value) {
                        // Handle incoming data here
                        print('Received data: ${utf8.decode(value)}');
                      });
                    });
                  }
                }
              }
            }).catchError((error) {
              print('Failed to connect to device: $error');
            });
            break;
          }
        }
      });
    } catch (error) {
      print('Error scanning for devices: $error');
    }
  }

  void sendData(String data) {
    if (_writeCharacteristic != null) {
      List<int> bytes = utf8.encode(data + '\n');
      _writeCharacteristic!.write(bytes);
    }
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay for fuel'),
      ),
      body: MyHomePage(), // Navigate to MyHomePage
    );
  }
}

class CircleTick extends StatelessWidget {
  final double size;
  final Color color;

  const CircleTick({required this.size, required this.color});

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
