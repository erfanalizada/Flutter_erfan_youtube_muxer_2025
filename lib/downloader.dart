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
  static const platform = MethodChannel('com.example.downloader/mux');

  final YoutubeExplode _yt = YoutubeExplode();
  late Directory _downloadDirectory;
  bool _isInitialized = false;

  Downloader();

  Future<void> init() async {
    _downloadDirectory = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    _isInitialized = true;
  }

  Future<List<VideoOnlyStreamInfo>> getCompatibleVideoStreams(String url) async {
    final videoId = VideoId.parseVideoId(url);
    if (videoId == null) throw Exception('Invalid YouTube URL');

    final manifest = await _yt.videos.streamsClient.getManifest(videoId);

    return manifest.videoOnly
        .where((v) => 
            v.container.name == 'mp4' && 
            v.videoCodec.toLowerCase().contains('avc') &&  // Ensure H.264/AVC codec
            !v.videoCodec.toLowerCase().contains('av1'))
        .toList();
  }

  Future<List<AudioOnlyStreamInfo>> getCompatibleAudioStreams(String url) async {
    final videoId = VideoId.parseVideoId(url);
    if (videoId == null) throw Exception('Invalid YouTube URL');

    final manifest = await _yt.videos.streamsClient.getManifest(videoId);

    return manifest.audioOnly
        .where((a) => a.codec.mimeType.contains('audio/mp4'))
        .toList();
  }

  Future<DownloadItem> downloadAudioStream(
    AudioOnlyStreamInfo audioStream, 
    String title,
    {String? customOutputPath}
  ) async {
    if (!_isInitialized) await init();

    final safeTitle = _sanitize(title);
    
    String outputPath;
    if (customOutputPath != null) {
      final directory = Directory(customOutputPath);
      if (await directory.exists()) {
        outputPath = '$customOutputPath/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.m4a';
      } else {
        try {
          await directory.create(recursive: true);
          outputPath = '$customOutputPath/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.m4a';
        } catch (e) {
          outputPath = '${_downloadDirectory.path}/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.m4a';
        }
      }
    } else {
      outputPath = '${_downloadDirectory.path}/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.m4a';
    }

    final file = File(outputPath);
    final output = file.openWrite();

    final stream = _yt.videos.streamsClient.get(audioStream);
    await for (final data in stream) {
      output.add(data);
    }
    await output.close();

    return DownloadItem(title: title, path: outputPath, isAudio: true);
  }

  Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) { // Android 13 and above
        return await Permission.photos.isGranted && 
               await Permission.videos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted &&
             await Permission.mediaLibrary.isGranted;
    }
    return false;
  }

  Future<DownloadItem> downloadVideoAndMuxAudio({
    required VideoOnlyStreamInfo videoStream,
    required AudioOnlyStreamInfo audioStream,
    required String title,
    required void Function(double progress, String status) onProgress,
    String? customOutputPath,
  }) async {
    if (!_isInitialized) await init();

    final safeTitle = _sanitize(title);
    final tempVideoFile = File('${_downloadDirectory.path}/temp_video.mp4');
    final tempAudioFile = File('${_downloadDirectory.path}/temp_audio.m4a');
    
    String outputPath;
    if (customOutputPath != null && customOutputPath.trim().isNotEmpty) {
      // Check permissions if custom path is provided
      final hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission is required to save to custom location. Please grant the permission and try again.');
      }

      final directory = Directory(customOutputPath);
      if (await directory.exists()) {
        outputPath = '$customOutputPath/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.mp4';
      } else {
        try {
          await directory.create(recursive: true);
          outputPath = '$customOutputPath/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.mp4';
        } catch (e) {
          outputPath = '${_downloadDirectory.path}/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.mp4';
        }
      }
    } else {
      outputPath = '${_downloadDirectory.path}/$safeTitle-${DateTime.now().millisecondsSinceEpoch}.mp4';
    }

    try {
      // Download video
      onProgress(0.0, 'Downloading video...');
      final videoOutput = tempVideoFile.openWrite();
      var totalVideoBytes = videoStream.size.totalBytes;
      var downloadedVideoBytes = 0;

      await for (final data in _yt.videos.streamsClient.get(videoStream)) {
        videoOutput.add(data);
        downloadedVideoBytes += data.length;
        final progress = downloadedVideoBytes / (totalVideoBytes * 2); // Half of total progress
        onProgress(progress, 'Downloading video: ${(progress * 200).toStringAsFixed(1)}%');
      }
      await videoOutput.close();

      // Download audio
      onProgress(0.5, 'Downloading audio...');
      final audioOutput = tempAudioFile.openWrite();
      var totalAudioBytes = audioStream.size.totalBytes;
      var downloadedAudioBytes = 0;

      await for (final data in _yt.videos.streamsClient.get(audioStream)) {
        audioOutput.add(data);
        downloadedAudioBytes += data.length;
        final progress = 0.5 + (downloadedAudioBytes / (totalAudioBytes * 2)); // Second half of progress
        onProgress(progress, 'Downloading audio: ${(progress * 100).toStringAsFixed(1)}%');
      }
      await audioOutput.close();

      // Mux video and audio
      onProgress(0.95, 'Muxing video and audio...');
      final success = await platform.invokeMethod<bool>('muxVideoAndAudio', {
        'videoPath': tempVideoFile.path,
        'audioPath': tempAudioFile.path,
        'outputPath': outputPath,
      });

      if (success != true) {
        throw Exception('Muxing failed');
      }

      onProgress(1.0, 'Download complete');
      return DownloadItem(title: title, path: outputPath, isAudio: false);
    } finally {
      // Cleanup temp files
      try {
        if (await tempVideoFile.exists()) await tempVideoFile.delete();
        if (await tempAudioFile.exists()) await tempAudioFile.delete();
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  }

  String _sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
  }

  void dispose() {
    _yt.close();
  }
}
