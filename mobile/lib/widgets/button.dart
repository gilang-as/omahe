import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omahe/utils/AppAssets.dart';
import 'package:omahe/utils/AppSpaces.dart';
import 'package:omahe/utils/Others.dart';

class TopSelectButton extends StatelessWidget {
  const TopSelectButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: const [
        DropdownMenuItem<String>(
          value: 'All Rooms',
          child: Text('All Rooms'),
        ),
        DropdownMenuItem<String>(
          value: 'Living Room',
          child: Text('Living Room'),
        ),
      ],
      hint: const Text(
        'Living Room',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
      ),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black),
      icon: const Padding(padding: EdgeInsets.only(left: 5), child: Icon(CupertinoIcons.chevron_down)),
      iconSize: 20,
      iconEnabledColor: Colors.black,
      underline: const SizedBox.shrink(),
      onChanged: (value) {},
    );
  }
}

class HomeButton extends StatelessWidget {
  const HomeButton({
    Key? key,
    required this.image,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.fontSize = 18,
    this.unSelectedImageColor,
  }) : super(key: key);
  final String image;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? unSelectedImageColor;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: isSelected ? appGradient : null,
            // color: !isSelected ? Get.theme.backgroundColor : null,
          ),
          child: Column(children: [
            AppSpaces.vertical15,
            Expanded(
              child: Center(
                child: SizedBox(
                  width: Get.width / 5,
                  height: Get.height / 10,
                  child: Image.asset(
                    image,
                    color: isSelected ? Colors.white : (unSelectedImageColor ?? Get.theme.primaryColor),
                  ),
                ),
              ),
            ),
            AppSpaces.vertical15,
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: fontSize,
              ),
            ),
            AppSpaces.vertical15,
          ]),
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  const CircleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: appGradient,
        ),
        padding: const EdgeInsets.all(9.0),
        child: Image.asset(
          AppAssets.onOff,
          width: 25,
          height: 25,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: appGradient,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 45, vertical: 10),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
      ),
    );
  }
}



class NeumorphicButton extends StatefulWidget {
  final String assetPath;
  final String title;
  final VoidCallback onTap;

  const NeumorphicButton({
    Key? key,
    required this.assetPath,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  double _scale = 1.0;
  Duration _duration = Duration(milliseconds: 100);

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: _duration,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: Offset(-6, -6),
                blurRadius: 10,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(6, 6),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                widget.assetPath,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}