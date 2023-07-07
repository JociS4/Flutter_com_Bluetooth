import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Devices',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothDeviceListScreen(),
    );
  }
}

class BluetoothDeviceListScreen extends StatefulWidget {
  @override
  _BluetoothDeviceListScreenState createState() =>
      _BluetoothDeviceListScreenState();
}

class _BluetoothDeviceListScreenState extends State<BluetoothDeviceListScreen> {
  FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> devices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    startScan();
    Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (!isScanning) {
        startScan();
      }
    });
  }

  void startScan() async {
    setState(() {
      isScanning = true;
    });

    devices.clear();

    flutterBluetoothSerial
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices.addAll(bondedDevices);
      });
    });

    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aparelhos Bluetooth'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceInfoScreen(device: device),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(device.name ?? 'Unknown Device'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: startScan,
      ),
    );
  }
}

class DeviceInfoScreen extends StatelessWidget {
  final BluetoothDevice device;

  DeviceInfoScreen({required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informações do Dispositivo'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Nome: ${device.name ?? 'Unknown Device'}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Endereço: ${device.address}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tipo de Dispositivo: ${device.type.toString()}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Estado de conexão: ${device.isConnected}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Estado do Vinculo: ${device.bondState.toString()}',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}