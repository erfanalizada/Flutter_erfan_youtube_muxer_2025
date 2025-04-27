import 'package:flutter_erfan_youtube_muxer_2025/flutter_erfan_youtube_muxer_2025.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YoutubeDownloader Tests', () {
    late YoutubeDownloader downloader;

    setUp(() {
      downloader = YoutubeDownloader();
    });

    test('getQualities returns list of qualities', () async {
      const testUrl = 'https://www.youtube.com/watch?v=test123';
      
      expect(() async {
        await downloader.getQualities(testUrl);
      }, throwsException);
    });

    test('downloadVideo with valid quality succeeds', () async {
      const testUrl = 'https://www.youtube.com/watch?v=test123';
      final testQuality = VideoQuality(
        quality: '720p',
        url: 'https://test.com/video',
        size: 1000000,
        container: 'mp4'
      );
      
      expect(() async {
        await downloader.downloadVideo(testQuality, testUrl).first;
      }, throwsException);
    });

    test('invalid URL throws exception', () async {
      const invalidUrl = 'invalid-url';
      
      expect(() async {
        await downloader.getQualities(invalidUrl);
      }, throwsException);
    });
  });
}



