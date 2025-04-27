class DownloadProgress {
  final double progress;
  final double estimatedTimeRemaining;
  final String status;

  DownloadProgress({
    required this.progress,
    required this.estimatedTimeRemaining,
    required this.status,
  });
}
