package com.erfan.flutter_erfan_youtube_muxer_2025

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.erfan.flutter_erfan_youtube_muxer_2025/mux"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "muxVideoAndAudio" -> {
                    val videoPath = call.argument<String>("videoPath")
                    val audioPath = call.argument<String>("audioPath")
                    val outputPath = call.argument<String>("outputPath")
                    if (videoPath != null && audioPath != null && outputPath != null) {
                        val success = MediaMuxerHandler().muxVideoAndAudio(videoPath, audioPath, outputPath)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing parameters", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
