package com.example.upi_analyzer_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Bundle

class MainActivity : FlutterActivity() {
    private lateinit var smsPlatformChannel: SmsPlatformChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        smsPlatformChannel = SmsPlatformChannel(this)
        smsPlatformChannel.configureFlutterEngine(flutterEngine)
    }
}
