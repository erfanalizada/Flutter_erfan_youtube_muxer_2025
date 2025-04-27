import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'models/video_quality.dart';
import 'models/download_progress.dart';
import 'models/download_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class YoutubeDownloader {
  static const platform = MethodChannel('com.example.downloader/mux');
  final _yt = yt.YoutubeExplode();
  
  /// Get available qualities for a YouTube video
  Future<List<VideoQuality>> getQualities(String videoUrl) async {
    try {
      final video = await _yt.videos.get(videoUrl);
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);
      
      final videoStreams = manifest.videoOnly;
      final qualities = videoStreams.map((stream) => VideoQuality(
        quality: stream.qualityLabel,
        url: stream.url.toString(),
        size: stream.size.totalBytes,
        container: stream.container.name,
      )).toList();
      
      return qualities;
    } catch (e) {
      throw Exception('Failed to get video qualities: $e');
    }
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

  /// Download video with progress updates
  Stream<DownloadProgress> downloadVideo(
    VideoQuality quality,
    String videoUrl,
    {String? customOutputPath}
  ) async* {
    try {
      final video = await _yt.videos.get(videoUrl);
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);
      
      final videoStream = manifest.videoOnly.firstWhere(
        (s) => s.qualityLabel == quality.quality
      );
      final audioStream = manifest.audioOnly.first;

      final dir = await getApplicationDocumentsDirectory();
      final tempVideoPath = '${dir.path}/temp_video.mp4';
      final tempAudioPath = '${dir.path}/temp_audio.m4a';
      
      String outputPath;
      if (customOutputPath != null && customOutputPath.trim().isNotEmpty) {
        // Check permissions if custom path is provided
        final hasPermission = await _checkStoragePermission();
        if (!hasPermission) {
          throw Exception('Storage permission is required to save to custom location. Please grant the permission and try again.');
        }

        final directory = Directory(customOutputPath);
        if (await directory.exists()) {
          outputPath = '$customOutputPath/${_sanitize(video.title)}.mp4';
        } else {
          try {
            await directory.create(recursive: true);
            outputPath = '$customOutputPath/${_sanitize(video.title)}.mp4';
          } catch (e) {
            outputPath = '${dir.path}/${_sanitize(video.title)}.mp4';
          }
        }
      } else {
        outputPath = '${dir.path}/${_sanitize(video.title)}.mp4';
      }

      // Download video
      yield DownloadProgress(
        progress: 0,
        estimatedTimeRemaining: 0,
        status: 'Downloading video...',
      );
      
      await _yt.videos.streamsClient.get(videoStream).pipe(
        File(tempVideoPath).openWrite()
      );

      // Download audio
      yield DownloadProgress(
        progress: 0.5,
        estimatedTimeRemaining: 0,
        status: 'Downloading audio...',
      );
      
      await _yt.videos.streamsClient.get(audioStream).pipe(
        File(tempAudioPath).openWrite()
      );

      // Mux files
      yield DownloadProgress(
        progress: 0.9,
        estimatedTimeRemaining: 0,
        status: 'Muxing files...',
      );

      final success = await platform.invokeMethod<bool>('muxVideoAndAudio', {
        'videoPath': tempVideoPath,
        'audioPath': tempAudioPath,
        'outputPath': outputPath,
      });

      if (success == true) {
        yield DownloadProgress(
          progress: 1.0,
          estimatedTimeRemaining: 0,
          status: 'Complete',
        );
      } else {
        throw Exception('Muxing failed');
      }

    } catch (e) {
      throw Exception('Download failed: $e');
    } finally {
      _yt.close();
    }
  }

  String _sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
  }
}







