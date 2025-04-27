# 🎬 Flutter YouTube Video Downloader & Muxer 2025 | flutter_erfan_youtube_muxer_2025

A powerful Flutter plugin to download YouTube videos in different qualities, mux audio and video together into a single .mp4 file, and track download progress — all with easy-to-use APIs.

## Supports Android and iOS coming soon!
Ideal for apps needing offline YouTube video support or media processing.
Uses Android 

## ✨ Features

Fetch available video qualities and audio streams from YouTube videos
Download selected streams
Mux (merge) video and audio files automatically
Real-time download progress updates
Auto permission handling (storage & media access checks)
Currently support for Android 12/13+ 

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
 dependencies:
  flutter_erfan_youtube_muxer_2025: ^1.0.0

```
Then run:

```bash
flutter pub get
```

## 🛠️ Platform Setup

Android
Add required permissions to your android/app/src/main/AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

```
For Android 13+ (SDK 33), media permissions like READ_MEDIA_VIDEO are automatically handled.
## Usage

```dart
import 'package:flutter_erfan_youtube_muxer_2025/youtube_video_downloader.dart';

void main() async {
  final downloader = YoutubeDownloader();
  
  try {
    // Get available qualities
    final qualities = await downloader.getQualities('https://youtube.com/watch?v=YOUR_VIDEO_ID');
    
    final selectedQuality = qualities.first;
    
    // Start downloading
    await for (final progress in downloader.downloadVideo(
      selectedQuality,
      'https://youtube.com/watch?v=YOUR_VIDEO_ID',
    )) {
      print('Progress: ${(progress.progress * 100).toStringAsFixed(2)}%');
      print('Status: ${progress.status}');
    }
    
  } catch (e) {
    print('Error: $e');
  }
}

```
## 📋 Project Overview

Class	Description

YoutubeDownloader	Main class to handle YouTube download and muxing.
VideoQuality	Represents a video quality stream option.
DownloadProgress	Emits current download/muxing progress and status.
PermissionChecker	Handles runtime permission checking.


## 🧹File Output

Downloads are stored by default in the app's documents directory (getApplicationDocumentsDirectory()).
For this no system permissions are required.

You can also specify a customOutputPath when downloading.
For this, you need to ensure the app has the necessary storage permissions since this package does not handle permissions automatically but only checks if the permission is granted.

Example:

```dart
await downloader.downloadVideo(
  selectedQuality,
  'https://youtube.com/watch?v=...',
  customOutputPath: '/storage/emulated/0/Download/MyVideos/',
);

```

## ⚙️ Customizations
Customize how streams are selected (e.g., select best quality, lowest size).
Customize output file names.
Build your own UI on top of the download streams (progress bar, etc).


## 📢 Notes

This plugin does not bypass YouTube terms of service.
Use responsibly. Downloading copyrighted content without permission is illegal in many jurisdictions.
YouTube frequently updates their platform; if you notice issues, check for youtube_explode_dart updates.
This project is built upon the youtube_explode_dart library for fetching video and audio information while muxing is handled natively.

## 🤝 Contributions
Pull requests, issues, and feature suggestions are welcome!
Please open a GitHub Issue if you encounter bugs or want improvements.


## 📝 License
This project is licensed under the MIT License.
See the LICENSE file for details.

## 🌟 Thanks for using Flutter_erfan_youtube_muxer_2025!
Happy Coding! 🚀

## Additional Information

Github source code is available in the `https://github.com/erfanalizada/Flutter_erfan_youtube_muxer_2025`.

