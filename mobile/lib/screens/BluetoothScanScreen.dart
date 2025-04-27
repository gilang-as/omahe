import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomNavigationScreen.dart';

final flutterReactiveBle = FlutterReactiveBle();

class BluetoothScanScreen extends StatefulWidget {

  final FlutterReactiveBle flutterReactiveBle;

  const BluetoothScanScreen({super.key, required this.flutterReactiveBle});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  late Stream<DiscoveredDevice> scanStream;
  StreamSubscription<DiscoveredDevice>? scanSubscription; // <-- Tambah ini
  List<DiscoveredDevice> devices = [];
  bool isScanning = false;
  String? savedDeviceId;

  @override
  void initState() {
    super.initState();
    checkSavedDevice();
  }

  Future<void> checkSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    savedDeviceId = prefs.getString('saved_device_id');

    if (savedDeviceId != null) {
      try {
        final connection = flutterReactiveBle.connectToDevice(id: savedDeviceId!);
        connection.listen((connectionState) {
          if (connectionState.connectionState == DeviceConnectionState.connected) {
            stopScan(); // Stop scan setelah auto-connect

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavigationScreen(
                  flutterReactiveBle: widget.flutterReactiveBle,
                  deviceId: savedDeviceId!,
                  deviceName: '',
                  deviceRssi: 0,
                ),
              ),
            );
          } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
            startScan();
          }
        }, onError: (e) {
          print('Error auto connect: $e');
          startScan();
        });
      } catch (e) {
        print('Exception auto connect: $e');
        startScan();
      }
    } else {
      startScan();
    }
  }

  void startScan() {
    devices.clear();
    scanSubscription?.cancel(); // pastikan stop dulu kalau ada scanning aktif

    scanSubscription = flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      if (device.name.isNotEmpty && !devices.any((d) => d.id == device.id)) {
        setState(() {
          devices.add(device);
        });
      }
    }, onError: (e) {
      print("Scan error: $e");
    });

    setState(() {
      isScanning = true;
    });
  }

  void stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;

    setState(() {
      isScanning = false;
    });
  }

  void connectToDevice(DiscoveredDevice device) async {
    try {
      final connection = flutterReactiveBle.connectToDevice(id: device.id);
      connection.listen((connectionState) async {
        if (connectionState.connectionState == DeviceConnectionState.connected) {
          stopScan(); // Stop scan setelah sukses connect

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_device_id', device.id);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(
                flutterReactiveBle: widget.flutterReactiveBle,
                deviceId: device.id,
                deviceName: device.name,
                deviceRssi: device.rssi,
              ),
            ),
          );
        } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
          startScan(); // Kalau disconnect, mulai scan lagi
        }
      }, onError: (e) {
        print('Connection error: $e');
        startScan();
      });
    } catch (e) {
      print('Error connecting: $e');
    }
  }

  @override
  void dispose() {
    scanSubscription?.cancel(); // jangan lupa cancel scan waktu keluar screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Bluetooth Devices'),
        centerTitle: true,
      ),
      body: isScanning
          ? RefreshIndicator(
        onRefresh: () async {
          stopScan(); // stop scan dulu biar bersih
          await Future.delayed(const Duration(milliseconds: 500));
          startScan(); // mulai scan lagi
        },
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return ListTile(
              title: Text(device.name),
              subtitle: Text(device.id),
              onTap: () => connectToDevice(device),
            );
          },
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

}
