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
  flutter_erfan_youtube_muxer_2025: ^1.0.1
```

Then run:

```bash
flutter pub get
```

## 🛠️ Platform Setup

### Android
Add required permissions to your android/app/src/main/AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

## 📱 Usage

Here's a complete example of how to implement the YouTube downloader:

```dart
import 'package:flutter_erfan_youtube_muxer_2025/flutter_erfan_youtube_muxer_2025.dart';

// Initialize the downloader
final downloader = YoutubeDownloader();

// Get available qualities
final qualities = await downloader.getQualities('https://www.youtube.com/watch?v=YOUR_VIDEO_ID');

// Download with selected quality
await for (final progress in downloader.downloadVideo(
  qualities.first,  // Select your preferred quality
  'https://www.youtube.com/watch?v=YOUR_VIDEO_ID',
)) {
  print('Progress: ${progress.progress * 100}%');
  print('Status: ${progress.status}');
}
```

### Complete Implementation Example

See the [example](example/lib/main.dart) folder for a full implementation with UI.

## ⚙️ Customizations

* Customize how streams are selected (e.g., select best quality, lowest size)
* Customize output file names
* Build your own UI on top of the download streams (progress bar, etc)

## 📢 Notes

* This plugin does not bypass YouTube terms of service
* Use responsibly. Downloading copyrighted content without permission is illegal in many jurisdictions
* YouTube frequently updates their platform; if you notice issues, check for youtube_explode_dart updates
* This project is built upon the youtube_explode_dart library for fetching video and audio information while muxing is handled natively

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

