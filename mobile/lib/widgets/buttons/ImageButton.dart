import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageButton extends StatelessWidget {
  const ImageButton({
    Key? key,
    required this.image,
    required this.text,
    required this.onTap,
    this.isOn = false,
    this.fontSize = 18,
    this.unSelectedImageColor,
    this.brightness = 50,
  }) : super(key: key);

  final String image;
  final String text;
  final VoidCallback onTap;
  final bool? isOn;
  final Color? unSelectedImageColor;
  final double fontSize;
  final double? brightness;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            const SizedBox(height: 10),
            // Tag ON/OFF
            if (isOn != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOn! ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isOn! ? 'ON' : 'OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  height: MediaQuery.of(context).size.height / 10,
                  child: Image.asset(
                    image,
                    color: Theme.of(context).primaryColor,
                    colorBlendMode: BlendMode.modulate,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: fontSize,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
