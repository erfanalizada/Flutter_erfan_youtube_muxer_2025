import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'models/video_quality.dart';
import 'models/download_progress.dart';
import 'permission_checker.dart';

class YoutubeDownloader {
  static const platform = MethodChannel('com.erfan.flutter_erfan_youtube_muxer_2025/mux');
  final _yt = yt.YoutubeExplode();
  
  /// Checks if a video stream is compatible with Android MediaMuxer
  bool _isCompatibleVideoStream(yt.VideoStreamInfo stream) {
    final codec = stream.videoCodec.toLowerCase();
    final container = stream.container.name.toLowerCase();
    
    // Must be MP4 container with H.264/AVC codec
    return container == 'mp4' && 
           codec.contains('avc') &&
           !codec.contains('av1') &&
           !codec.contains('vp8') &&
           !codec.contains('vp9');
  }

  /// Checks if an audio stream is compatible with Android MediaMuxer
  bool _isCompatibleAudioStream(yt.AudioStreamInfo stream) {
    return stream.codec.mimeType.contains('audio/mp4');
  }

  /// Get available qualities for a YouTube video
  Future<List<VideoQuality>> getQualities(String videoUrl) async {
    try {
      final video = await _yt.videos.get(videoUrl);
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);
      
      // Filter for compatible video streams only
      final videoStreams = manifest.videoOnly
          .where(_isCompatibleVideoStream)
          .toList();

      // Also check if we have at least one compatible audio stream
      final hasCompatibleAudio = manifest.audioOnly
          .any(_isCompatibleAudioStream);

      if (!hasCompatibleAudio) {
        throw Exception('No compatible audio stream found for this video');
      }

      final qualities = videoStreams.map((stream) => VideoQuality(
        quality: stream.qualityLabel,
        url: stream.url.toString(),
        size: stream.size.totalBytes,
        container: stream.container.name,
        codec: stream.videoCodec,
        bitrate: stream.bitrate.bitsPerSecond,
        fps: stream.framerate.framesPerSecond.toInt(),
      )).toList();
      
      // Sort by resolution (highest to lowest)
      qualities.sort((a, b) {
        final aHeight = int.tryParse(a.quality.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bHeight = int.tryParse(b.quality.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return bHeight.compareTo(aHeight);
      });
      
      return qualities;
    } catch (e) {
      throw Exception('Failed to get video qualities: $e');
    }
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
      
      // Get compatible video stream
      final videoStream = manifest.videoOnly.firstWhere(
        (s) => s.qualityLabel == quality.quality && _isCompatibleVideoStream(s),
        orElse: () => throw Exception('Selected quality no longer available'),
      );

      // Get compatible audio stream (highest bitrate)
      final audioStream = manifest.audioOnly
          .where(_isCompatibleAudioStream)
          .reduce((a, b) => a.bitrate.bitsPerSecond > b.bitrate.bitsPerSecond ? a : b);

      final dir = await getApplicationDocumentsDirectory();
      final tempVideoPath = '${dir.path}/temp_video.mp4';
      final tempAudioPath = '${dir.path}/temp_audio.m4a';
      
      String outputPath;
      if (customOutputPath != null && customOutputPath.trim().isNotEmpty) {
        final hasPermission = await PermissionChecker.hasStoragePermission();
        if (!hasPermission) {
          throw Exception('Required storage permissions are not granted');
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
        'audioConfig': {
          'sampleRate': audioStream.bitrate.bitsPerSecond,
          'channelCount': 2,
          'channelMask': 3,
        }
      });

      if (success != true) {
        throw Exception('Muxing failed');
      }

      yield DownloadProgress(
        progress: 1.0,
        estimatedTimeRemaining: 0,
        status: 'Download completed',
      );
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  String _sanitize(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }
}

















