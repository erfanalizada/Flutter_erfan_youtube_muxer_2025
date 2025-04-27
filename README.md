# 🎬 Flutter YouTube Video Downloader & Muxer 2025 | flutter_erfan_youtube_muxer_2025

A powerful Flutter plugin to download YouTube videos in different qualities, mux audio and video together into a single .mp4 file, and track download progress — all with easy-to-use APIs.

## ⚠️ Important Usage Notes

- Only H.264/AVC codec in MP4 container format is supported
- VP9, AV1, and other codecs are not supported due to Android MediaMuxer limitations
- Not all YouTube videos have H.264/AVC versions available

## ✨ Features

- Fetch available video qualities (H.264/AVC only)
- Download selected streams
- Mux (merge) video and audio files automatically
- Real-time download progress updates
- Auto permission handling
- Currently supports Android 12/13+

## 📦 Installation

```yaml
dependencies:
  flutter_erfan_youtube_muxer_2025: ^1.0.2
```

## 🛠️ Platform Setup

### Android

1. Add required permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

2. Ensure your `android/app/build.gradle` has:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

## 📱 Usage

Here's a complete example showing proper error handling:

```dart
import 'package:flutter_erfan_youtube_muxer_2025/flutter_erfan_youtube_muxer_2025.dart';

Future<void> downloadYouTubeVideo() async {
  final downloader = YoutubeDownloader();
  
  try {
    // Get available qualities (H.264/AVC only)
    final qualities = await downloader.getQualities('YOUR_YOUTUBE_URL');
    
    if (qualities.isEmpty) {
      print('No compatible video qualities found (H.264/AVC required)');
      return;
    }
    
    // Download with selected quality
    await for (final progress in downloader.downloadVideo(
      qualities.first,
      'YOUR_YOUTUBE_URL',
    )) {
      print('Progress: ${progress.progress * 100}%');
      print('Status: ${progress.status}');
    }
  } catch (e) {
    print('Error: $e');
    // Handle error appropriately
  }
}
```

## 🔍 Troubleshooting

Common issues and solutions:

1. **No qualities available**: The video might not have H.264/AVC versions. Try another video.
2. **Muxing failed**: Make sure you're only using H.264/AVC videos in MP4 container.
3. **Permission denied**: Ensure all required permissions are properly set in AndroidManifest.xml.

## 📢 Notes

- This plugin does not bypass YouTube terms of service
- Use responsibly and respect copyright
- YouTube frequently updates their platform; check for updates if issues occur

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

