# YouTube Video Downloader

A Flutter package for downloading YouTube videos with quality selection, supporting custom storage paths and permissions handling.

## Features

- Download YouTube videos with quality selection
- Support for custom download paths
- Automatic permission handling
- Progress tracking
- Fallback to app's private storage
- Support for Android and iOS

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  youtube_video_downloader: ^0.0.1
```

## Usage

```dart
import 'package:youtube_video_downloader/youtube_video_downloader.dart';

// Initialize downloader
final downloader = YoutubeDownloader();

// Download with custom path
try {
  await downloader.downloadVideo(
    VideoQuality.high,
    'https://youtube.com/watch?v=...',
    customOutputPath: '/storage/emulated/0/Downloads/YouTube'
  );
} catch (e) {
  print('Error: $e');
}

// Download to app's private storage
await downloader.downloadVideo(
  VideoQuality.medium,
  'https://youtube.com/watch?v=...',
);
```

## Additional Information

For more examples and usage, please refer to the example app in the `/example` directory.

## License

[Add your license here]
