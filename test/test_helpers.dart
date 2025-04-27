import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'dart:collection';

class MockVideoStreamInfo extends Mock implements yt.VideoStreamInfo {
  @override
  yt.FileSize get size => const yt.FileSize(1000000);
  
  @override
  Uri get url => Uri.parse('https://test.com/video.mp4');
}

@GenerateMocks([])
class MockVideoManifest extends Mock implements yt.StreamManifest {
  @override
  UnmodifiableListView<yt.StreamInfo> get streams => 
      UnmodifiableListView<yt.StreamInfo>([MockVideoStreamInfo()]);
}

class MockVideo extends Mock implements yt.Video {
  @override
  String get title => 'Test Video';
}

// Add more mock classes as needed

