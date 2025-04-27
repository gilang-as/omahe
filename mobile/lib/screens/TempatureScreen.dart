import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:omahe/controllers/TempatureController.dart';
import 'package:omahe/utils/AppSpaces.dart';
import 'package:omahe/widgets/button.dart';

class TempatureScreen extends StatelessWidget {
  const TempatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TempatureController>(
      init: TempatureController(),
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(children: [
            const Text(
              'Today',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w200,
              ),
            ),
            AppSpaces.vertical30,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SleekCircularSlider(
                  appearance: CircularSliderAppearance(
                    customColors: CustomSliderColors(
                      trackColor: Get.theme.disabledColor,
                      dotColor: Get.theme.disabledColor,
                      progressBarColor: Get.theme.primaryColor,
                    ),
                    startAngle: 130.0,
                    angleRange: 280.0,
                    size: Get.mediaQuery.size.height,
                    customWidths: CustomSliderWidths(progressBarWidth: 5, handlerSize: 10),
                  ),
                  min: 13,
                  max: 25,
                  initialValue: controller.tempature.value,
                  onChangeEnd: (value) => controller.tempature.value = value,
                  innerWidget: (percentage) => Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Get.theme.primaryColor,
                                  width: 1,
                                ),
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Text(
                                  '${percentage.toStringAsFixed(0)}°C',
                                  style: TextStyle(
                                    fontSize: 15 + (22 * 683 / Get.mediaQuery.size.height),
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))),
                    ),
                  ),
                ),
              ),
            ),
            const CircleButton(),
            AppSpaces.vertical10,
            const Text('Click to turn off'),
            AppSpaces.vertical10,
          ]),
        );
      },
    );
  }
}