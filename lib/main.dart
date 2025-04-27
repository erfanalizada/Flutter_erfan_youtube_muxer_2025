import 'package:flutter/material.dart';
import 'package:flutter_erfan_youtube_muxer_2025/download_screen.dart';

void main() {
  runApp(const MyApp());
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
      home: const DownloadScreen(), // <-- this points to your screen file
      debugShowCheckedModeBanner: false,
    );
  }
}
