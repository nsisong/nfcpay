import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Bluetooth Connection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NFCBluetoothConnectionPage(),
    );
  }
}

class NFCBluetoothConnectionPage extends StatefulWidget {
  @override
  _NFCBluetoothConnectionPageState createState() =>
      _NFCBluetoothConnectionPageState();
}

class _NFCBluetoothConnectionPageState
    extends State<NFCBluetoothConnectionPage> {
  bool _isNFCEnabled = false;
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];

  @override
  void initState() {
    super.initState();
    _initNFC();
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
          _startScanning();
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
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        // Handle NFC tag discovery here
        // Filter out the desired Bluetooth device by name based on tag info
        List<ScanResult> filteredResults = _scanResults
            .where((result) => result.device.name == 'NFC_UART')
            .toList();

        if (filteredResults.isNotEmpty) {
          BluetoothDevice device = filteredResults.first.device;
          // Connect to the Bluetooth device
          await _connectToDevice(device);
        } else {
          print('NFC_UART device not found');
        }
      });
      setState(() {
        _isNFCEnabled = true;
      });
    } catch (e) {
      print('Error initializing NFC: $e');
    }
  }

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
    });
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      setState(() {
        _scanResults = results;
      });
    });
    flutterBlue.startScan();
  }

  Future<void> _stopScanning() async {
    setState(() {
      _isScanning = false;
    });
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Bluetooth Connection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('NFC Enabled: $_isNFCEnabled'),
            SizedBox(height: 20),
            _isScanning
                ? CircularProgressIndicator()
                : Text('Scanning for NFC_UART device...'),
            SizedBox(height: 20),
            _buildScanResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanResults() {
    if (_scanResults.isEmpty) {
      return Text('No Bluetooth devices found');
    } else {
      return Column(
        children: _scanResults.map((result) {
          return ListTile(
            title: Text(result.device.name ?? 'Unknown Device'),
            subtitle: Text(result.device.id.toString()),
            onTap: () {
              _connectToDevice(result.device);
            },
          );
        }).toList(),
      );
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // Stop scanning before connecting
      await _stopScanning();

      // Connect to the selected Bluetooth device
      await device.connect();

      // Discover services and characteristics
      List<BluetoothService> services = await device.discoverServices();

      // Iterate through services and characteristics
      services.forEach((service) {
        service.characteristics.forEach((characteristic) {
          // Set up notifications for all characteristics
          characteristic.setNotifyValue(true);

          // Send "HLO SN" to the device (optional)
          characteristic.write(utf8.encode('HLO SN'));

          // Listen for incoming messages
          characteristic.value.listen((List<int> value) {
            String incomingMessage = utf8.decode(value);
            print('Incoming message: $incomingMessage');
            // You can further process the incoming message here
            // For example, parse the data based on a specific format
            // or update the UI to display the received message.
          });
        });
      });

      // Display a snackbar indicating successful connection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name}'),
        ),
      );
    } catch (e) {
      // Handle connection errors
      print('Error connecting to device: $e');
      // You may want to display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to ${device.name}'),
        ),
      );
    }
  }

  // Future<void> receive_Data() async {
  //   if (targetCharacteristic != null) {
  //     List<int> value = await targetCharacteristic!.read();
  //     String receivedData = utf8.decode(value);
  //     print('Received data: $receivedData');
  //   }
  // }
}
