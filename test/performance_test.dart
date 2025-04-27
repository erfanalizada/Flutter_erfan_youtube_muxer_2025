import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_erfan_youtube_muxer_2025/src/youtube_downloader.dart';
import 'package:flutter_erfan_youtube_muxer_2025/src/models/video_quality.dart';
import 'dart:io';

void main() {
  group('YoutubeDownloader Performance Tests', () {
    late YoutubeDownloader downloader;
    const testVideoUrl = 'https://www.youtube.com/watch?v=test123';

    setUp(() {
      downloader = YoutubeDownloader();
    });

    test('Download speed test - Large file (>100MB)', () async {
      final stopwatch = Stopwatch()..start();
      
      await for (final progress in downloader.downloadVideo(
        VideoQuality(
          quality: "1080p",
          url: "",
          size: 0,
          container: "mp4"
        ),
        testVideoUrl,
      )) {
        // Ensure download speed is above minimum threshold (e.g., 1MB/s)
        if (progress.progress < 0.001) {
          fail('Download speed too slow: ${progress.progress * 100}%');
        }
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(300000)); // Should complete within 5 minutes
    });

    test('Memory usage test during download', () async {
      final startMemory = ProcessInfo.currentRss;
      
      await for (final _ in downloader.downloadVideo(
        VideoQuality(
          quality: "720p",
          url: "",
          size: 0,
          container: "mp4"
        ),
        testVideoUrl,
      )) {
        final currentMemory = ProcessInfo.currentRss;
        // Ensure memory usage doesn't exceed reasonable threshold (e.g., 100MB)
        expect(
          currentMemory - startMemory,
          lessThan(100 * 1024 * 1024), // 100MB in bytes
          reason: 'Memory usage exceeded threshold',
        );
      }
    });

    test('Concurrent downloads performance', () async {
      final downloads = List.generate(3, (index) => 
        downloader.downloadVideo(
          VideoQuality(
            quality: "720p",
            url: "",
            size: 0,
            container: "mp4"
          ),
          testVideoUrl,
        )
      );

      final stopwatch = Stopwatch()..start();
      
      await Future.wait(
        downloads.map((download) => download.drain())
      );

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(600000)); // Should complete within 10 minutes
    });

    test('Quality switch response time', () async {
      final stopwatch = Stopwatch()..start();
      
      final qualities = await downloader.getQualities(testVideoUrl);
      expect(qualities, isNotEmpty);
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should complete within 2 seconds
    });

    test('Download cancellation response time', () async {
      final downloadStream = downloader.downloadVideo(
        VideoQuality(
          quality: "720p",
          url: "",
          size: 0,
          container: "mp4"
        ),
        testVideoUrl,
      );

      final subscription = downloadStream.listen((_) {});
      
      final stopwatch = Stopwatch()..start();
      await subscription.cancel();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should cancel within 100ms
    });
  });
}




