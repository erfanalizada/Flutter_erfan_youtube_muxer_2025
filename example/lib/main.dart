import 'package:youtube_video_downloader/youtube_video_downloader.dart';

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
      print('Progress: ${(progress.progress * 100).toStringAsFixed(2)}%');
      print('Status: ${progress.status}');
      print('Time remaining: ${progress.estimatedTimeRemaining} seconds');
    }
    
  } catch (e) {
    print('Error: $e');
  }
}


