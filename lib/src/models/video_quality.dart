class VideoQuality {
  final String quality;
  final String url;
  final int size;
  final String container;
  final String codec;
  final int bitrate;
  final int fps;

  VideoQuality({
    required this.quality,
    required this.url,
    required this.size,
    required this.container,
    required this.codec,
    required this.bitrate,
    required this.fps,
  });

  @override
  String toString() {
    return 'VideoQuality('
        'quality: $quality, '
        'codec: $codec, '
        'fps: ${fps}fps, '
        'size: ${(size / 1024 / 1024).toStringAsFixed(2)}MB)';
  }
}


