#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <EEPROM.h>
#include <ArduinoJson.h>

#define DEVICE_NAME "omahe"
#define SERVICE_UUID "12345678-1234-1234-1234-1234567890ab"
#define CHARACTERISTIC_UUID "abcd1234-ab12-cd34-ef56-1234567890ab"

#define BLUETOOTH_CONNECTED_LED_PIN 2

// Room names
const char* roomNames[] = {"bedroom", "diningroom", "living", "garden", "front", "back"};
const int roomPins[] = {4, 16, 17, 5, 18, 19}; // Lamp pins
int roomBrightness[6] = {50, 50, 50, 50, 50, 50}; // Default 50% brightness

BLECharacteristic *pCharacteristic;
bool deviceConnected = false;

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    Serial.println("Bluetooth device connected");
    deviceConnected = true;
    digitalWrite(BLUETOOTH_CONNECTED_LED_PIN, HIGH);
  }

  void onDisconnect(BLEServer* pServer) override {
    Serial.println("Bluetooth device disconnected");
    deviceConnected = false;
    digitalWrite(BLUETOOTH_CONNECTED_LED_PIN, LOW);
    BLEDevice::getAdvertising()->start();
    Serial.println("Advertising again...");
  }
};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) override {
    String value = pCharacteristic->getValue().c_str();
    Serial.print("Received value: ");
    Serial.println(value);

    // Menggunakan format "room:status:brightness"
    int firstColon = value.indexOf(':');
    int secondColon = value.indexOf(':', firstColon + 1);

    if (firstColon == -1 || secondColon == -1) {
      Serial.println("Invalid input format");
      return;
    }

    String room = value.substring(0, firstColon);
    String statusStr = value.substring(firstColon + 1, secondColon);
    String brightnessStr = value.substring(secondColon + 1);

    bool state = (statusStr == "1"); // Jika statusnya '1', lampu nyala
    int brightness = brightnessStr.toInt();

    brightness = constrain(brightness, 1, 100);
    int pwm = map(brightness, 0, 100, 0, 255);

    // Find room index
    for (int i = 0; i < 6; i++) {
      if (room.equals(roomNames[i])) {
        if (state) {
          analogWrite(roomPins[i], pwm);
          roomBrightness[i] = brightness;
          Serial.printf("%s ON, brightness %d%%\n", roomNames[i], brightness);
        } else {
          analogWrite(roomPins[i], 0);
          roomBrightness[i] = 0;
          Serial.printf("%s OFF\n", roomNames[i]);
        }
        EEPROM.write(i, roomBrightness[i]);
        EEPROM.commit();
        break;
      }
    }
  }
  void onRead(BLECharacteristic *pCharacteristic) override {
  String output = "";
  
  for (int i = 0; i < 6; i++) {
    // Menggunakan roomBrightness untuk menentukan apakah lampu menyala (lebih dari 0 berarti ON)
    String roomStatus = String(roomNames[i]) + ":" + 
                        (roomBrightness[i] > 0 ? "1" : "0") + ":" + 
                        String(roomBrightness[i]);
    output += roomStatus + "\n";
  }

  pCharacteristic->setValue(output.c_str());
  pCharacteristic->notify();
  Serial.println("Status sent to client: ");
  Serial.println(output);
}
};

void setup() {
  Serial.begin(115200);

  EEPROM.begin(512);
  for (int i = 0; i < 6; i++) {
    roomBrightness[i] = EEPROM.read(i);
    if (roomBrightness[i] > 100) roomBrightness[i] = 50; // Safety fallback
  }

  pinMode(BLUETOOTH_CONNECTED_LED_PIN, OUTPUT);
  for (int i = 0; i < 6; i++) {
    pinMode(roomPins[i], OUTPUT);
    int pwm = map(roomBrightness[i], 0, 100, 0, 255);
    analogWrite(roomPins[i], pwm);
  }

  BLEDevice::init(DEVICE_NAME);
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_READ
  );
  pCharacteristic->setCallbacks(new MyCallbacks());

  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->start();

  Serial.println("BLE device is now advertising...");
}

void loop() {
  // Kosongin aja
}
