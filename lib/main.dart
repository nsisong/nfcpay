import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';
import 'dart:async';
import 'my_home_page.dart'; // Importing MyHomePage widget
import 'screen3.dart';
import 'package:permission_handler/permission_handler.dart';

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
  NFCReaderPageState createState() => NFCReaderPageState();
}

class NFCReaderPageState extends State<NFCReaderPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;

  @override
  void initState() {
    super.initState();
    _initNFC();
    // scanForDevices();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    final bluetoothPermission = await Permission.bluetooth.request();
    if (bluetoothPermission.isGranted) {
      print('Bluetooth permission granted');
      final scanPermission = await Permission.bluetoothScan.request();
      if (scanPermission.isGranted) {
        print('Bluetooth scan permission granted');
        final connectPermission = await Permission.bluetoothConnect.request();
        if (connectPermission.isGranted) {
          print('Bluetooth connect permission granted');
          // You can start scanning for devices or establish connections here.
        } else {
          print('Bluetooth connect permission denied');
        }
      } else {
        print('Bluetooth scan permission denied');
      }
    } else {
      print('Bluetooth permission denied');
    }
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
                    startReadingBluetoothData().listen((data) {
                      print('dat: $data');
                    });
                  }
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DispenserControl(
                    sendData: sendData,
                    receivedData:
                        startReadingBluetoothData(), // Call startReadingBluetoothData to get the stream
                  ),
                ),
              );
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

  Stream<String> startReadingBluetoothData() {
    StreamController<String> controller = StreamController<String>();

    if (_readCharacteristic != null) {
      _readCharacteristic!.setNotifyValue(true).then((_) {
        _readCharacteristic!.value.listen((List<int>? value) {
          if (value != null) {
            String receivedData = utf8.decode(value);
            // print('main : $receivedData');
            controller.add(receivedData);
          }
        });
      }).catchError((error) {
        print('Error setting notify value: $error');
        controller.addError(error); // Add error to the stream if encountered
      });
    }

    return controller.stream;
  }

  void sendData(String data) {
    if (_writeCharacteristic != null) {
      List<int> bytes =
          utf8.encode(data + '\r\n'); // Encoding the string to bytes
      _writeCharacteristic!.write(bytes); // Writing bytes to the characteristic
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
