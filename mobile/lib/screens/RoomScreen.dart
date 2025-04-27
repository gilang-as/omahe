import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:omahe/controllers/LightsController.dart';
import 'package:omahe/utils/AppAssets.dart';
import 'package:omahe/utils/AppSpaces.dart';
import 'package:omahe/utils/Others.dart';

import '../controllers/HomeScreenController.dart';


class RoomScreen extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final String deviceId;
  final String title;
  final String lampId;
  final bool? isOn;
  final double? brightness;

  const RoomScreen({super.key, required this.flutterReactiveBle, required this.deviceId, required this.title, required this.lampId, this.isOn, this.brightness});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  Timer? _debounce;

  late QualifiedCharacteristic lampCharacteristic;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
      // Register the controller with Get.put
      Get.put(HomeScreenController(flutterReactiveBle: widget.flutterReactiveBle));

    // Setup QualifiedCharacteristic
    lampCharacteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse('12345678-1234-1234-1234-1234567890ab'),
      characteristicId: Uuid.parse('abcd1234-ab12-cd34-ef56-1234567890ab'),
      deviceId: widget.deviceId,
    );

  }

  @override
  Widget build(BuildContext context) {


    return GetBuilder<LightsController>(
      init: LightsController(),
      builder: (controller) {
        controller.switchData.value = widget.isOn ?? false;
        controller.sliderData.value = widget.brightness!;

        Future<void> toggleLamp() async {
          final brightnessValue = (controller.sliderData.value).toInt();
          final status = controller.switchData.value ? 1 : 0;

          // Membuat string dalam format "id:status:brightness"
          final commandJson = '${widget.lampId}:${status}:${brightnessValue}';

          try {
            // Kirim data dengan format string langsung
            await widget.flutterReactiveBle.writeCharacteristicWithResponse(
              lampCharacteristic,
              value: commandJson.codeUnits, // Mengirim sebagai kode unit byte
            );
            debugPrint('Sent command: $commandJson');
          } catch (e) {
            debugPrint('Error sending command: $e');
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(widget.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            backgroundColor: Colors.white, // Background app bar
            elevation: 0, // Menghilangkan shadow
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.black), // Ikon custom untuk back
              onPressed: () {
                Navigator.pop(context);
                // Fetch lamp status only once when the screen is first built
                Get.find<HomeScreenController>().getLampStatus(widget.deviceId);
              },
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(children: [
              AppSpaces.vertical30,
              AppSpaces.vertical30,
              Image.asset(
                AppAssets.sun,
                height: 40,
              ),
              AppSpaces.vertical20,
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Obx(() {
                    final isSwitchOn = controller.switchData.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            disabledActiveTrackColor: Colors.grey.shade400,
                            activeTrackColor: Get.theme.primaryColor,
                            inactiveTrackColor: Get.theme.disabledColor,
                            thumbColor: Colors.transparent,
                            overlayColor: Colors.transparent,
                            thumbSelector: (textDirection, values, tapValue,
                                    thumbSize, trackSize, dx) =>
                                Thumb.start,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 1,
                              elevation: 0.0,
                            ),
                            overlayShape:
                                const RoundSliderOverlayShape(overlayRadius: 1),
                            trackHeight: Get.width / 3,
                            trackShape: const CustomRoundedRectSliderTrackShape(
                                Radius.circular(12)),
                          ),
                          child: Slider(
                            onChanged: isSwitchOn
                                ? (value) {
                              controller.sliderData.value = value;
                              if (_debounce?.isActive ?? false) _debounce!.cancel();
                              _debounce = Timer(const Duration(milliseconds: 500), () async {
                                final brightnessValue = value.toInt();
                                final status = 1; // Status lampu aktif (1)

                                // Menggunakan format custom "id:status:brightness"
                                final commandJson = '${widget.lampId}:${status}:${brightnessValue}';

                                try {
                                  await widget.flutterReactiveBle.writeCharacteristicWithResponse(
                                    lampCharacteristic,
                                    value: commandJson.codeUnits, // Kirim dalam format byte array
                                  );
                                  debugPrint('Sent brightness command: $commandJson');
                                } catch (e) {
                                  debugPrint('Error sending brightness command: $e');
                                }
                              });
                            }
                                : null,
                            min: 0,
                            max: 100,
                            value: controller.sliderData.value,
                          ),
                        ),
                        if (!isSwitchOn)
                          const Text(
                            'OFF',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              AppSpaces.vertical30,
              Obx(() => InkWell(
                    onTap: () {
                      controller.switchData.value = !controller.switchData.value;
                      toggleLamp();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Cek aktif / tidak aktif
                        gradient: controller.switchData.value
                            ? appGradient // Aktif: pakai gradient aktif
                            : const LinearGradient(
                                // Tidak aktif: pakai warna abu2
                                colors: [Colors.grey, Colors.grey],
                              ),
                      ),
                      padding: const EdgeInsets.all(9.0),
                      child: Image.asset(
                        AppAssets.onOff,
                        width: 25,
                        height: 25,
                        color: Colors.white,
                      ),
                    ),
                  )),
              AppSpaces.vertical10,
              // If the switch is on, show a text Click to turn off
              // If the switch is off, show a text Click to turn on
              Obx(() => Text(
                    controller.switchData.value
                        ? 'Click to turn off'
                        : 'Click to turn on',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                    ),
                  )),
              AppSpaces.vertical30,
            ]),
          ),
        );
      },
    );
  }
}

class CustomRoundedRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  final Radius trackRadius;
  const CustomRoundedRectSliderTrackShape(this.trackRadius);

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint leftTrackPaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint rightTrackPaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    var activeRect = RRect.fromLTRBAndCorners(
      trackRect.left,
      trackRect.top - (additionalActiveTrackHeight / 2),
      thumbCenter.dx,
      trackRect.bottom + (additionalActiveTrackHeight / 2),
      topLeft: trackRadius,
      bottomLeft: trackRadius,
    );
    var inActiveRect = RRect.fromLTRBAndCorners(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
      topRight: trackRadius,
      bottomRight: trackRadius,
    );
    var percent =
        ((activeRect.width / (activeRect.width + inActiveRect.width)) * 100)
            .toInt();
    if (percent > 99) {
      activeRect = RRect.fromLTRBAndCorners(
        trackRect.left,
        trackRect.top - (additionalActiveTrackHeight / 2),
        thumbCenter.dx,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
        topLeft: trackRadius,
        bottomLeft: trackRadius,
        bottomRight: trackRadius,
        topRight: trackRadius,
      );
    }

    if (percent < 1) {
      inActiveRect = RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
        topRight: trackRadius,
        bottomRight: trackRadius,
        bottomLeft: trackRadius,
        topLeft: trackRadius,
      );
    }
    context.canvas.drawRRect(
      activeRect,
      leftTrackPaint,
    );

    context.canvas.drawRRect(
      inActiveRect,
      rightTrackPaint,
    );

    drawText(context.canvas, '%$percent', activeRect.center.dx,
        activeRect.center.dy, pi * 0.5, activeRect.width);
  }

  void drawText(Canvas context, String name, double x, double y,
      double angleRotationInRadians, double height) {
    context.save();
    var span = TextSpan(
        style: TextStyle(
            color: Colors.white, fontSize: height >= 24.0 ? 24.0 : height),
        text: name);
    var tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    context.translate((x + (tp.height * 0.5)), (y - (tp.width * 0.5)));
    context.rotate(angleRotationInRadians);
    tp.layout();
    tp.paint(context, const Offset(0.0, 0.0));
    context.restore();
  }
}
