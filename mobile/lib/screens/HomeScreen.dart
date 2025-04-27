import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:omahe/controllers/HomeScreenController.dart';
import 'package:omahe/utils/AppAssets.dart';
import 'package:omahe/utils/AppSpaces.dart';
import 'package:omahe/widgets/buttons/ImageButton.dart';
import 'RoomScreen.dart';

class HomeScreen extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final String deviceId;
  final String deviceName;
  final int deviceRssi;

  const HomeScreen({super.key, required this.flutterReactiveBle, required this.deviceId, required this.deviceName, required this.deviceRssi});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    // Register the controller with Get.put
    Get.put(HomeScreenController(flutterReactiveBle: widget.flutterReactiveBle));

    // Fetch lamp status only once when the screen is first built
    Get.find<HomeScreenController>().getLampStatus(widget.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rooms = [
      {'icon': AppAssets.bedroom, 'title': 'Bedroom', 'id': 'bedroom'},
      {'icon': AppAssets.kitchen, 'title': 'Dining Room', 'id': 'diningroom'},
      {'icon': AppAssets.livingRoom, 'title': 'Living Room', 'id': 'living'},
      {'icon': AppAssets.garden, 'title': 'Garden', 'id': 'garden'},
      {'icon': AppAssets.front, 'title': 'Front', 'id': 'front'},
      {'icon': AppAssets.back, 'title': 'Back', 'id': 'back'},
    ];

    return GetBuilder<HomeScreenController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Get.theme.primaryColor.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Get.theme.primaryColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bluetooth Name: ${widget.deviceName}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Device ID: ${widget.deviceId}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              AppSpaces.vertical20,
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final roomStatus = controller.roomStatuses[room['id']]!;
                    return ImageButton(
                      image: room['icon'],
                      text: room['title'],
                      isOn: roomStatus['status'], // Use the status (on/off)
                      brightness: roomStatus['brightness'], // Use the brightness value
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomScreen(
                              flutterReactiveBle: widget.flutterReactiveBle,
                              deviceId: widget.deviceId,
                              title: room['title'],
                              lampId: room['id'],
                              isOn: roomStatus['status'], // Use the status (on/off)
                              brightness: roomStatus['brightness'], // Use the brightness value
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
