import 'package:flutter/material.dart';
import 'package:flutter_erfan_youtube_muxer_2025/flutter_erfan_youtube_muxer_2025.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const YouTubeDownloaderScreen(),
    );
  }
}

class YouTubeDownloaderScreen extends StatefulWidget {
  const YouTubeDownloaderScreen({super.key});

  @override
  State<YouTubeDownloaderScreen> createState() => _YouTubeDownloaderScreenState();
}

class _YouTubeDownloaderScreenState extends State<YouTubeDownloaderScreen> {
  final _urlController = TextEditingController();
  final _downloader = YoutubeDownloader();
  List<VideoQuality> _qualities = [];
  String _status = '';
  bool _isLoading = false;
  double _progress = 0.0;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return;
    }
    // For Android 13 and above
    await Permission.photos.request();
    await Permission.videos.request();
    await Permission.audio.request();
  }

  Future<void> _getQualities() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a YouTube URL')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Fetching available qualities...';
      _qualities.clear();
    });

    try {
      final qualities = await _downloader.getQualities(_urlController.text);
      setState(() {
        _qualities = qualities;
        _status = 'Found ${qualities.length} qualities';
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadVideo(VideoQuality quality) async {
    await _requestPermissions();

    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _status = 'Starting download...';
    });

    try {
      await for (final progress in _downloader.downloadVideo(
        quality,
        _urlController.text,
      )) {
        setState(() {
          _progress = progress.progress;
          _status = progress.status;
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download completed successfully!')),
      );
    } catch (e) {
      setState(() => _status = 'Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Downloader'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://youtube.com/watch?v=...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _urlController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _getQualities,
              child: const Text('Get Available Qualities'),
            ),
            const SizedBox(height: 16),
            if (_isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
            ],
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (_progress > 0) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _qualities.length,
                itemBuilder: (context, index) {
                  final quality = _qualities[index];
                  return Card(
                    child: ListTile(
                      title: Text(quality.quality),
                      subtitle: Text(
                        'Size: ${(quality.size / 1024 / 1024).toStringAsFixed(2)} MB\n'
                        'Codec: ${quality.codec}',
                      ),
                      isThreeLine: true,
                      trailing: ElevatedButton(
                        onPressed: _isLoading ? null : () => _downloadVideo(quality),
                        child: const Text('Download'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
