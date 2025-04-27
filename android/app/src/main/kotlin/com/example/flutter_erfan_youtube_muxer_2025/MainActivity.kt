package com.example.flutter_erfan_youtube_muxer_2025

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.downloader/mux"

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
                "muxSingleVideoFile" -> {
                    val videoPath = call.argument<String>("videoPath")
                    val outputPath = call.argument<String>("outputPath")
                    if (videoPath != null && outputPath != null) {
                        val success = MediaMuxerHandler().muxSingleVideoFile(videoPath, outputPath)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing parameters", null)
                    }
                }
                "muxSingleVideoBytes" -> {
                    val videoBytes = call.argument<ByteArray>("videoBytes")
                    val outputPath = call.argument<String>("outputPath")
                    if (videoBytes != null && outputPath != null) {
                        val success = MediaMuxerHandler().muxSingleVideoBytes(videoBytes, outputPath)
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
