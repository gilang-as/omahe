import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class HomeScreenController extends GetxController {
  final FlutterReactiveBle flutterReactiveBle;
  HomeScreenController({required this.flutterReactiveBle});

  Map<String, Map<String, dynamic>> roomStatuses = {
    'bedroom': {'status': false, 'brightness': 0.0},
    'diningroom': {'status': false, 'brightness': 0.0},
    'living': {'status': false, 'brightness': 0.0},
    'garden': {'status': false, 'brightness': 0.0},
    'front': {'status': false, 'brightness': 0.0},
    'back': {'status': false, 'brightness': 0.0},
  };

  // UUID of the service and characteristic
  final String serviceUuid = '12345678-1234-1234-1234-1234567890ab';
  final String characteristicUuid = 'abcd1234-ab12-cd34-ef56-1234567890ab';

  // Method to read the lamp status from the device
  Future<void> getLampStatus(String deviceId) async {
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(characteristicUuid),
        deviceId: deviceId,
      );

      // Reading the characteristic value
      final result = await flutterReactiveBle.readCharacteristic(characteristic);
      final statusString = String.fromCharCodes(result);

      print(statusString);

      // Split the status string by line breaks
      final statusList = statusString.split('\n');

      // Parse each room's status
      for (var status in statusList) {
        final parts = status.split(':');
        if (parts.length == 3) {
          final room = parts[0];
          final roomStatus = parts[1] == '1'; // Convert '0' or '1' to boolean
          final brightness = double.tryParse(parts[2]) ?? 0.0;

          // Update room status
          if (roomStatuses.containsKey(room)) {
            roomStatuses[room] = {
              'status': roomStatus,
              'brightness': brightness,
            };
          }
        }
      }

      update(); // Update the UI
    } catch (e) {
      print("Failed to read lamp status: $e");
    }
  }
}
