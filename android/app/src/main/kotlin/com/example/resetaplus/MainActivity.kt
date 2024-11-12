package com.example.resetaplus

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.MethodChannel
import java.io.File;


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.resetaplus/fileScanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                val mimeType = call.argument<String>("mimeType")

                if (path != null && mimeType != null) {
                    val file = File(path)
                    val uri = Uri.fromFile(file)
                    val scanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri)
                    sendBroadcast(scanIntent)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Path or MIME type missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
