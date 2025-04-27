import 'package:flutter/material.dart';
import 'package:flutter_erfan_youtube_muxer_2025/flutter_erfan_youtube_muxer_2025.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final downloader = YoutubeDownloader();
  String status = 'Ready to test';
  bool isLoading = false;

  Future<void> testDownload() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      status = 'Starting test...';
    });

    try {
      // Test video (shorter video for testing)
      const testUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      
      debugPrint('Fetching video qualities...');
      setState(() => status = 'Fetching video qualities...');
      final qualities = await downloader.getQualities(testUrl);
      
      debugPrint('Found ${qualities.length} qualities');
      setState(() => status = 'Found ${qualities.length} qualities available');
      
      if (qualities.isNotEmpty) {
        debugPrint('Selected quality: ${qualities.first.quality}');
        setState(() => status = 'Starting download with ${qualities.first.quality}...');
        
        await for (final progress in downloader.downloadVideo(
          qualities.first,
          testUrl,
        )) {
          debugPrint('Download progress: ${progress.progress}, Status: ${progress.status}');
          setState(() {
            status = 'Progress: ${(progress.progress * 100).toStringAsFixed(2)}%\n'
                    'Status: ${progress.status}';
          });
        }
        
        setState(() => status = 'Download complete! 🎉');
      } else {
        setState(() => status = 'No qualities found 😕');
      }
    } catch (e, stackTrace) {
      debugPrint('Download error: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() => status = 'Error occurred: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Downloader Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🎬 YouTube Downloader Test',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : testDownload,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(isLoading ? 'Testing...' : 'Start Test Download'),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}




