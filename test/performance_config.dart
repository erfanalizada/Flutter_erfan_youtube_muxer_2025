class PerformanceConfig {
  static const int minimumDownloadSpeedBytesPerSecond = 1024 * 1024; // 1MB/s
  static const int maximumMemoryUsageBytes = 100 * 1024 * 1024; // 100MB
  static const int qualitySwitchTimeoutMs = 2000;
  static const int downloadCancellationTimeoutMs = 100;
  static const int singleDownloadTimeoutMs = 300000; // 5 minutes
  static const int concurrentDownloadTimeoutMs = 600000; // 10 minutes
  
  // Network conditions simulation
  static const int poorNetworkSpeedBytesPerSecond = 512 * 1024; // 512KB/s
  static const int goodNetworkSpeedBytesPerSecond = 5 * 1024 * 1024; // 5MB/s
  static const int networkLatencyMs = 100;
}