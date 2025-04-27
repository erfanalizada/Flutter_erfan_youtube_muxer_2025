import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'downloader.dart';
import 'video_player_screen.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final TextEditingController _controller = TextEditingController();
  final Downloader _downloader = Downloader();

  bool _isDownloading = false;
  String _message = '';
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    try {
      final hasPermissions = await _downloader.checkPermissions();
      setState(() {
        _hasPermissions = hasPermissions;
      });
    } catch (e) {
      setState(() {
        _message = 'Error checking permissions: $e';
      });
    }
  }

  Future<void> _startDownload({required bool isAudioOnly}) async {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      _showMessage('Please enter a YouTube URL');
      return;
    }
    if (!_hasPermissions) {
      _showMessage('Please grant required permissions first');
      return;
    }

    setState(() {
      _isDownloading = true;
      _message = '';
    });

    try {
      final videoId = VideoId.parseVideoId(url) ?? (throw Exception('Invalid YouTube URL'));
      final video = await _downloader.getVideoInfo(videoId);

      if (isAudioOnly) {
        final audios = await _downloader.getCompatibleAudioStreams(url);
        if (audios.isEmpty) throw Exception('No audio streams found');

        final selected = await _selectStreamDialog(audios.map((a) => '${a.bitrate.kiloBitsPerSecond ~/ 1000} kbps').toList());
        if (selected == null) return _cancelDownload();

        await _downloader.downloadAudioStream(audios[selected], video.title);
        _showMessage('Audio downloaded successfully!');
      } else {
        final videos = await _downloader.getCompatibleVideoStreams(url);
        final audios = await _downloader.getCompatibleAudioStreams(url);

        if (videos.isEmpty) throw Exception('No compatible video streams found.');
        if (audios.isEmpty) throw Exception('No compatible audio streams found.');

        final selected = await _selectStreamDialog(
          videos.map((v) => '${v.videoQualityLabel} (${v.bitrate.kiloBitsPerSecond ~/ 1000} kbps)').toList(),
        );
        if (selected == null) return _cancelDownload();

        final result = await _downloader.downloadVideoAndMuxAudio(
          videoStream: videos[selected],
          audioStream: audios.first,
          title: video.title,
          onProgress: (progress, status) => setState(() => _message = status),
        );

        _showMessage('Video downloaded successfully!');
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(filePath: result.path),
            ),
          );
        }
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<int?> _selectStreamDialog(List<String> options) {
    return showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Quality'),
        children: options
            .asMap()
            .entries
            .map((entry) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, entry.key),
                  child: Text(entry.value),
                ))
            .toList(),
      ),
    );
  }

  void _showMessage(String text) {
    if (mounted) {
      setState(() => _message = text);
    }
  }

  void _cancelDownload() {
    _showMessage('Download canceled');
    setState(() => _isDownloading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'YouTube Link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (!_hasPermissions)
              ElevatedButton.icon(
                onPressed: _checkAndRequestPermissions,
                icon: const Icon(Icons.security),
                label: const Text('Grant Permissions'),
              ),
            if (_hasPermissions)
              _isDownloading
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _startDownload(isAudioOnly: true),
                          icon: const Icon(Icons.audiotrack),
                          label: const Text('Audio'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _startDownload(isAudioOnly: false),
                          icon: const Icon(Icons.video_library),
                          label: const Text('Video'),
                        ),
                      ],
                    ),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _message.startsWith('Error') ? Colors.red[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_message),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
