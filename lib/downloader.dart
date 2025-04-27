import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http_parser/http_parser.dart';

class DownloadItem {
  final String title;
  final String path;
  final bool isAudio;

  DownloadItem({required this.title, required this.path, required this.isAudio});
}

class Downloader {
  final YoutubeExplode _yt;
  final MethodChannel _platform;
  final Directory? _overrideDirectory;
  late Directory _downloadDirectory;
  bool _isInitialized = false;

  Downloader({YoutubeExplode? yt, MethodChannel? platform, Directory? overrideDirectory})
      : _yt = yt ?? YoutubeExplode(),
        _platform = platform ?? const MethodChannel('com.example.downloader/mux'),
        _overrideDirectory = overrideDirectory;

  Future<void> init() async {
    if (_overrideDirectory != null) {
      _downloadDirectory = _overrideDirectory!;
    } else {
      _downloadDirectory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    }
    _isInitialized = true;
  }

  Future<List<VideoOnlyStreamInfo>> getCompatibleVideoStreams(String url) async {
    final videoId = VideoId.parseVideoId(url);
    if (videoId == null) throw Exception('Invalid YouTube URL');

    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    return manifest.videoOnly.where((v) =>
        v.container.name == 'mp4' &&
        v.videoCodec.toLowerCase().contains('avc') &&
        !v.videoCodec.toLowerCase().contains('av1')).toList();
  }

  Future<List<AudioOnlyStreamInfo>> getCompatibleAudioStreams(String url) async {
    final videoId = VideoId.parseVideoId(url);
    if (videoId == null) throw Exception('Invalid YouTube URL');

    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    return manifest.audioOnly.where((a) => a.codec.mimeType.contains('audio/mp4')).toList();
  }

  Future<DownloadItem> downloadAudioStream(
    AudioOnlyStreamInfo streamInfo,
    String title, {
    String? customOutputPath,
  }) async {
    if (!_isInitialized) await init();

    final path = customOutputPath ?? _downloadDirectory.path;
    final safeTitle = _sanitize(title);
    final filePath = '$path/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.m4a';
    final file = File(filePath);
    final output = file.openWrite();

    final stream = _yt.videos.streamsClient.get(streamInfo);
    await for (final data in stream) {
      output.add(data);
    }
    await output.close();

    return DownloadItem(title: title, path: filePath, isAudio: true);
  }

  Future<DownloadItem> downloadVideoAndMuxAudio({
    required VideoOnlyStreamInfo videoStream,
    required AudioOnlyStreamInfo audioStream,
    required String title,
    required void Function(double progress, String status) onProgress,
    String? customOutputPath,
  }) async {
    if (!_isInitialized) await init();

    final path = customOutputPath ?? _downloadDirectory.path;
    final safeTitle = _sanitize(title);

    final tempVideoFile = File('$path/temp_video.mp4');
    final tempAudioFile = File('$path/temp_audio.m4a');
    final outputPath = '$path/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      // Download video
      onProgress(0.0, 'Downloading video...');
      final videoOutput = tempVideoFile.openWrite();
      await for (final data in _yt.videos.streamsClient.get(videoStream)) {
        videoOutput.add(data);
      }
      await videoOutput.close();

      // Download audio
      onProgress(0.5, 'Downloading audio...');
      final audioOutput = tempAudioFile.openWrite();
      await for (final data in _yt.videos.streamsClient.get(audioStream)) {
        audioOutput.add(data);
      }
      await audioOutput.close();

      // Mux
      onProgress(0.9, 'Muxing video and audio...');
      final success = await _platform.invokeMethod<bool>('muxVideoAndAudio', {
        'videoPath': tempVideoFile.path,
        'audioPath': tempAudioFile.path,
        'outputPath': outputPath,
      });

      if (success != true) {
        throw Exception('Muxing failed');
      }

      onProgress(1.0, 'Completed');
      return DownloadItem(title: title, path: outputPath, isAudio: false);
    } finally {
      if (await tempVideoFile.exists()) await tempVideoFile.delete();
      if (await tempAudioFile.exists()) await tempAudioFile.delete();
    }
  }

  String _sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
  }

  void dispose() {
    _yt.close();
  }
}
