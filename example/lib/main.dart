import 'dart:developer' show log;

import 'package:flutter_erfan_youtube_muxer_2025/flutter_erfan_youtube_muxer_2025.dart';

void main() async {
  final downloader = YoutubeDownloader();
  
  try {
    // Get available qualities
    final qualities = await downloader.getQualities('https://youtube.com/watch?v=...');
    
    // Select a quality (e.g., first available quality)
    final selectedQuality = qualities.first;
    
    // Start downloading with progress updates
    await for (final progress in downloader.downloadVideo(
      selectedQuality,
      'https://youtube.com/watch?v=...',
      customOutputPath: ''  // or null
    )) {
      log('Progress: ${(progress.progress * 100).toStringAsFixed(2)}%');
      log('Status: ${progress.status}');
      log('Time remaining: ${progress.estimatedTimeRemaining} seconds');
    }
    
  } catch (e) {
    log('Error: $e');
  }
}




