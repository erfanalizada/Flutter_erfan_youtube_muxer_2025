import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:flutter_erfan_youtube_muxer_2025/src/youtube_downloader.dart';
import 'package:flutter_erfan_youtube_muxer_2025/src/models/video_quality.dart';
import 'package:flutter_erfan_youtube_muxer_2025/src/models/download_progress.dart';
import 'package:flutter_erfan_youtube_muxer_2025/src/permission_checker.dart';
import 'test_helpers.dart';
import 'youtube_downloader_test.mocks.dart';

@GenerateMocks([yt.YoutubeExplode, PermissionChecker])
void main() {
  group('YoutubeDownloader Tests', () {
    late YoutubeDownloader downloader;
    late yt.YoutubeExplode mockYoutubeExplode;

    setUp(() {
      mockYoutubeExplode = MockYoutubeExplode();
      downloader = YoutubeDownloader();
    });

    test('getAvailableQualities returns correct quality list', () async {
      const videoUrl = 'https://www.youtube.com/watch?v=test123';
      // Mock video metadata and manifest
      final mockVideo = MockVideo();
      final mockManifest = MockVideoManifest();
      when(mockYoutubeExplode.videos.get(videoUrl)).thenAnswer((_) async => mockVideo);
      when(mockYoutubeExplode.videos.streamsClient.getManifest(any)).thenAnswer((_) async => mockManifest);
      
      final qualities = await downloader.getQualities(videoUrl);
      expect(qualities, isNotEmpty);
      expect(qualities.first, isA<VideoQuality>());
    });

    test('downloadVideo emits progress updates', () async {
      const videoUrl = 'https://www.youtube.com/watch?v=test123';
      final quality = VideoQuality(
        quality: "720p",
        url: "",
        size: 0,
        container: "mp4"
      );
      // Mock video metadata
      final mockVideo = MockVideo();
      final mockManifest = MockVideoManifest();
      when(mockYoutubeExplode.videos.get(videoUrl)).thenAnswer((_) async => mockVideo);
      when(mockYoutubeExplode.videos.streamsClient.getManifest(any)).thenAnswer((_) async => mockManifest);
      
      expect(
        downloader.downloadVideo(quality, videoUrl),
        emitsInOrder([
          isA<DownloadProgress>(),
          // Add more expected emissions
        ]),
      );
    });

    test('downloadVideo throws exception when permissions not granted', () async {
      const videoUrl = 'https://www.youtube.com/watch?v=test123';
      final quality = VideoQuality(
        quality: "720p",
        url: "",
        size: 0,
        container: "mp4"
      );
      when(PermissionChecker.hasStoragePermission()).thenAnswer((_) async => false);
      
      expect(
        () => downloader.downloadVideo(quality, videoUrl, customOutputPath: '/test/path'),
        throwsException,
      );
    });
  });
}




