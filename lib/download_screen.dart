import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'downloader.dart';
import 'video_player_screen.dart'; // 👈 import this!

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isDownloading = false;
  String _message = '';
  bool _hasPermissions = false;
  Downloader? _downloader;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool hasPermissions = false;

    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        hasPermissions = await Permission.photos.isGranted &&
            await Permission.videos.isGranted &&
            await Permission.audio.isGranted &&
            await Permission.notification.isGranted;
      } else {
        hasPermissions = await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      hasPermissions = await Permission.photos.isGranted &&
          await Permission.mediaLibrary.isGranted;
    }

    setState(() {
      _hasPermissions = hasPermissions;
    });
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        if (await _isAndroid13OrHigher()) {
          await Permission.photos.request();
          await Permission.videos.request();
          await Permission.audio.request();
          await Permission.notification.request();
        } else {
          await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        await Permission.photos.request();
        await Permission.mediaLibrary.request();
      }

      await _checkPermissions();
    } catch (e) {
      setState(() {
        _message = 'Error requesting permissions: ${e.toString()}';
      });
    }
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  Future<void> _startDownload(bool isAudioOnly) async {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() {
        _message = 'Please enter a YouTube URL';
      });
      return;
    }

    if (!_hasPermissions) {
      setState(() {
        _message = 'Please grant required permissions first';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _message = '';
    });

    try {
      _downloader ??= Downloader();
      await _downloader!.init();

      final yt = YoutubeExplode();
      final videoId = VideoId.parseVideoId(url);
      if (videoId == null) throw Exception('Invalid YouTube URL');
      final video = await yt.videos.get(videoId);

      if (isAudioOnly) {
        final audioStreams = await _downloader!.getCompatibleAudioStreams(url);
        if (audioStreams.isEmpty) throw Exception('No audio streams found');

        final selectedIndex = await _showStreamSelectionDialog(
          audioStreams.map((a) => '${a.bitrate.kiloBitsPerSecond ~/ 1000} kbps').toList(),
        );

        if (selectedIndex == null) {
          setState(() {
            _message = 'Download canceled';
            _isDownloading = false;
          });
          return;
        }

        await _downloader!.downloadAudioStream(audioStreams[selectedIndex], video.title);

        setState(() {
          _message = 'Audio Downloaded Successfully!';
        });

      } else {
        final videoStreams = await _downloader!.getCompatibleVideoStreams(url);
        final audioStreams = await _downloader!.getCompatibleAudioStreams(url);

        if (videoStreams.isEmpty) {
          throw Exception('No compatible video streams found. Only H.264/AVC videos are supported.');
        }
        if (audioStreams.isEmpty) {
          throw Exception('No compatible audio streams found');
        }

        final selectedIndex = await _showStreamSelectionDialog(
          videoStreams.map((v) => '${v.videoQualityLabel} (${v.bitrate.kiloBitsPerSecond ~/ 1000} kbps)').toList(),
        );

        if (selectedIndex == null) {
          setState(() {
            _message = 'Download canceled';
            _isDownloading = false;
          });
          return;
        }

        final selectedVideo = videoStreams[selectedIndex];
        final bestAudio = audioStreams.first;

        final downloadResult = await _downloader!.downloadVideoAndMuxAudio(
          onProgress: (progress, status) {
            setState(() {
              _message = status;
            });
          },
          videoStream: selectedVideo,
          audioStream: bestAudio,
          title: video.title,
        );

        setState(() {
          _message = 'Video Downloaded Successfully!';
        });

        // 👇 Navigate to video player
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(filePath: downloadResult.path),
            ),
          );
        }
      }

    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<int?> _showStreamSelectionDialog(List<String> options) async {
    return await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Quality'),
          children: options.asMap().entries.map((entry) {
            final idx = entry.key;
            final val = entry.value;
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, idx),
              child: Text(val),
            );
          }).toList(),
        );
      },
    );
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
                onPressed: _requestPermissions,
                icon: const Icon(Icons.security),
                label: const Text('Grant Permissions'),
              ),
            if (_hasPermissions && _isDownloading)
              const CircularProgressIndicator(),
            if (_hasPermissions && !_isDownloading)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _startDownload(true),
                    icon: const Icon(Icons.audiotrack),
                    label: const Text('Download Audio'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _startDownload(false),
                    icon: const Icon(Icons.video_library),
                    label: const Text('Download Video'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _message.startsWith('Error')
                      ? Colors.red[100]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.startsWith('Error')
                        ? Colors.red[900]
                        : Colors.green[900],
                  ),
                ),
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
