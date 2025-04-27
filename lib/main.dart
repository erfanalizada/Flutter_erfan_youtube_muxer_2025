import 'package:flutter/material.dart';
import 'package:flutter_erfan_youtube_muxer_2025/download_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(const MyApp());
}

Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    if (androidInfo.version.sdkInt >= 33) {
      // Android 13 and above
      await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
        Permission.notification,
      ].request();
    } else {
      // Android 12 and below
      await Permission.storage.request();
    }
  } else if (Platform.isIOS) {
    await [
      Permission.photos,
      Permission.mediaLibrary,
    ].request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Downloader',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const DownloadScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
