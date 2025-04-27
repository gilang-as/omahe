import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:omahe/controllers/BottomNavigationController.dart';
import 'package:omahe/screens/HomeScreen.dart';
import 'package:omahe/screens/TempatureScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BluetoothScanScreen.dart';

class BottomNavigationScreen extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final String deviceId;
  final String deviceName;
  final int deviceRssi;

  const BottomNavigationScreen({super.key, required this.flutterReactiveBle, required this.deviceId, required this.deviceName, required this.deviceRssi});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  Future<void> disconnectAndRestart(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_device_id');

    await flutterReactiveBle.deinitialize();
    await Future.delayed(const Duration(milliseconds: 300));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BluetoothScanScreen(flutterReactiveBle: widget.flutterReactiveBle,)),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomNavigationController>(
        init: BottomNavigationController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Devices",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
              backgroundColor: Colors.white, // Background app bar
              elevation: 0, // Menghilangkan shadow
              leading: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black), // Ikon custom untuk back
                onPressed: () => disconnectAndRestart(context),
              ),
              centerTitle: true,
            ),
              body: IndexedStack(
                index: 0,
                children: [
                  [
                    HomeScreen( flutterReactiveBle: widget.flutterReactiveBle, deviceId: widget.deviceId, deviceName: widget.deviceName, deviceRssi: widget.deviceRssi,),
                    const TempatureScreen(),
                    const TempatureScreen(),
                  ][controller.index]
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: controller.index,
                onTap: controller.setIndex,
                selectedLabelStyle: const TextStyle(fontSize: 1),
                selectedItemColor: Get.theme.primaryColor,
                unselectedItemColor: Colors.grey,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.verified_user),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: '',
                  ),
                ],
              ),
            );
        });
  }
}