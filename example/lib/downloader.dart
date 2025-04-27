// lib/downloader.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
  Directory? _downloadDirectory;

  Downloader({YoutubeExplode? yt, MethodChannel? platform, Directory? overrideDirectory})
      : _yt = yt ?? YoutubeExplode(),
        _platform = platform ?? const MethodChannel('com.erfan.flutter_erfan_youtube_muxer_2025/mux'),
        _overrideDirectory = overrideDirectory;

  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return await Permission.photos.isGranted &&
            await Permission.videos.isGranted &&
            await Permission.audio.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted &&
          await Permission.mediaLibrary.isGranted;
    }
    return false;
  }

  Future<Directory> get _directory async {
    if (_downloadDirectory != null) return _downloadDirectory!;
    _downloadDirectory = _overrideDirectory ?? await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    return _downloadDirectory!;
  }

  Future<List<VideoOnlyStreamInfo>> getCompatibleVideoStreams(String url) async {
    if (!await checkPermissions()) {
      throw Exception('Required permissions not granted');
    }
    final videoId = VideoId.parseVideoId(url) ?? (throw Exception('Invalid YouTube URL'));
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    return manifest.videoOnly
        .where((v) =>
            v.container.name == 'mp4' &&
            v.videoCodec.toLowerCase().contains('avc') &&
            !v.videoCodec.toLowerCase().contains('av1'))
        .toList();
  }

  Future<List<AudioOnlyStreamInfo>> getCompatibleAudioStreams(String url) async {
    if (!await checkPermissions()) {
      throw Exception('Required permissions not granted');
    }
    final videoId = VideoId.parseVideoId(url) ?? (throw Exception('Invalid YouTube URL'));
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    return manifest.audioOnly.where((a) => a.codec.mimeType.contains('audio/mp4')).toList();
  }

  Future<DownloadItem> downloadAudioStream(AudioOnlyStreamInfo streamInfo, String title, {String? customOutputPath}) async {
    if (!await checkPermissions()) {
      throw Exception('Required permissions not granted');
    }
    final dir = customOutputPath ?? (await _directory).path;
    final filePath = '$dir/${sanitize(title)}-${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _downloadStream(streamInfo, filePath);
    return DownloadItem(title: title, path: filePath, isAudio: true);
  }

  Future<DownloadItem> downloadVideoAndMuxAudio({
    required VideoOnlyStreamInfo videoStream,
    required AudioOnlyStreamInfo audioStream,
    required String title,
    required void Function(double progress, String status) onProgress,
    String? customOutputPath,
  }) async {
    if (!await checkPermissions()) {
      throw Exception('Required permissions not granted');
    }
    final dir = customOutputPath ?? (await _directory).path;
    final safeTitle = sanitize(title);

    final tempVideoPath = '$dir/temp_video.mp4';
    final tempAudioPath = '$dir/temp_audio.m4a';
    final outputPath = '$dir/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      onProgress(0.0, 'Downloading video...');
      await _downloadStream(videoStream, tempVideoPath);

      onProgress(0.5, 'Downloading audio...');
      await _downloadStream(audioStream, tempAudioPath);

      onProgress(0.9, 'Muxing...');
      final success = await _platform.invokeMethod<bool>('muxVideoAndAudio', {
        'videoPath': tempVideoPath,
        'audioPath': tempAudioPath,
        'outputPath': outputPath,
        'audioConfig': {
          'sampleRate': audioStream.bitrate.bitsPerSecond,
          'channelCount': 2, // Force stereo output
          'channelMask': 3, // CHANNEL_OUT_STEREO
        }
      });

      if (success != true) {
        throw Exception('Muxing failed via platform channel.');
      }

      onProgress(1.0, 'Completed');
      return DownloadItem(title: title, path: outputPath, isAudio: false);
    } finally {
      await _cleanup([tempVideoPath, tempAudioPath]);
    }
  }

  Future<void> _downloadStream(StreamInfo streamInfo, String savePath) async {
    final file = File(savePath);
    final output = file.openWrite();
    await for (final data in _yt.videos.streamsClient.get(streamInfo)) {
      output.add(data);
    }
    await output.close();
  }

  Future<void> _cleanup(List<String> paths) async {
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  String sanitize(String input) => input.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');

  Future<Video> getVideoInfo(String videoId) async {
    return await _yt.videos.get(videoId);
  }

  void dispose() {
    _yt.close();
  }
}
