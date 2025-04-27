import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omahe/screens/BluetoothScanScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';


final flutterReactiveBle = FlutterReactiveBle();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Omahe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xff867cef),
        // backgroundColor: Color(0xfff0f0f0),
        disabledColor: const Color(0xffededed),
        colorScheme: ColorScheme.fromSwatch(accentColor: const Color(0xffaf92ea)),
        textTheme: GoogleFonts.openSansTextTheme(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BluetoothAppLifecycleManager(),
    );
  }
}


class BluetoothAppLifecycleManager extends StatefulWidget {
  const BluetoothAppLifecycleManager({super.key});

  @override
  State<BluetoothAppLifecycleManager> createState() =>
      _BluetoothAppLifecycleManagerState();
}

class _BluetoothAppLifecycleManagerState extends State<BluetoothAppLifecycleManager> with WidgetsBindingObserver {
  late Stream<BleStatus> _bleStatusStream;
  BleStatus _bleStatus = BleStatus.unknown;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bleStatusStream = flutterReactiveBle.statusStream;
    _bleStatusStream.listen((status) {
      setState(() => _bleStatus = status);

      if (status == BleStatus.poweredOff && !_dialogShown) {
        _dialogShown = true;
        _showBluetoothRequiredDialog();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle saat app keluar
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      debugPrint('App closing. Disconnecting and clearing saved device.');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_device_id');
      await flutterReactiveBle.deinitialize();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> _showBluetoothRequiredDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bluetooth Required'),
          content: const Text(
              'Bluetooth is turned off. Please enable it to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _dialogShown = false;
                  });
                });
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text('Exit App'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BluetoothScanScreen(flutterReactiveBle: flutterReactiveBle);
  }
}
