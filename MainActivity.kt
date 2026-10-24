package com.example.noor

import android.app.AppOpsManager
import android.content.Intent
import android.net.Uri
import android.os.Process
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "noor/blocker")
            .setMethodCallHandler { call, result ->
                val prefs = getSharedPreferences("noor", MODE_PRIVATE)
                when (call.method) {
                    "status" -> result.success(
                        mapOf("usage" to hasUsage(), "overlay" to Settings.canDrawOverlays(this))
                    )
                    "openUsage" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "openOverlay" -> {
                        startActivity(
                            Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                        )
                        result.success(null)
                    }
                    "schedule" -> {
                        val t = call.arguments as List<*>
                        prefs.edit()
                            .putString("times", t.joinToString(",") { (it as Number).toLong().toString() })
                            .apply()
                        result.success(null)
                    }
                    "confirm" -> {
                        prefs.edit().putLong("confirmed", (call.arguments as Number).toLong()).apply()
                        result.success(null)
                    }
                    "start" -> {
                        ContextCompat.startForegroundService(this, Intent(this, BlockerService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsage(): Boolean {
        val ops = getSystemService(APP_OPS_SERVICE) as AppOpsManager
        return ops.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
        ) == AppOpsManager.MODE_ALLOWED
    }
}
