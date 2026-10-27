package com.example.noor

import android.Manifest
import android.app.AppOpsManager
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.os.VibrationEffect
import android.os.Vibrator
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
                    "status" -> {
                        val pm = getSystemService(POWER_SERVICE) as PowerManager
                        result.success(
                            mapOf(
                                "usage" to hasUsage(),
                                "overlay" to Settings.canDrawOverlays(this),
                                "exact" to Azan.canExact(this),
                                "battery" to pm.isIgnoringBatteryOptimizations(packageName)
                            )
                        )
                    }
                    "getState" -> result.success(
                        mapOf(
                            "confirmed" to prefs.getLong("confirmed", 0L),
                            "force" to prefs.getBoolean("force", false)
                        )
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
                    "openExact" -> {
                        if (Build.VERSION.SDK_INT >= 31) {
                            startActivity(
                                Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:$packageName"))
                            )
                        }
                        result.success(null)
                    }
                    "openBattery" -> {
                        try {
                            startActivity(
                                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:$packageName"))
                            )
                        } catch (_: Exception) {
                            startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                        }
                        result.success(null)
                    }
                    "schedule" -> {
                        val t = call.arguments as List<*>
                        prefs.edit()
                            .putString("times", t.joinToString(",") { (it as Number).toLong().toString() })
                            .apply()
                        Azan.schedule(this)
                        result.success(null)
                    }
                    "confirm" -> {
                        prefs.edit()
                            .putLong("confirmed", (call.arguments as Number).toLong())
                            .putBoolean("force", false)
                            .apply()
                        result.success(null)
                    }
                    "testLock" -> {
                        prefs.edit().putBoolean("force", true).apply()
                        result.success(null)
                    }
                    "getApps" -> {
                        val i = Intent(Intent.ACTION_MAIN)
                        i.addCategory(Intent.CATEGORY_LAUNCHER)
                        val list = packageManager.queryIntentActivities(i, 0)
                            .map {
                                mapOf(
                                    "name" to it.loadLabel(packageManager).toString(),
                                    "pkg" to it.activityInfo.packageName
                                )
                            }
                            .filter { it["pkg"] != packageName }
                            .distinctBy { it["pkg"] }
                            .sortedBy { it["name"]!!.lowercase() }
                        result.success(list)
                    }
                    "getBlocked" -> {
                        val s = prefs.getString("blocked", null)
                        val list = if (s == null) BlockerService.DEFAULT_BLOCKED.toList()
                        else s.split(",").filter { it.isNotEmpty() }
                        result.success(list)
                    }
                    "setBlocked" -> {
                        val l = call.arguments as List<*>
                        prefs.edit().putString("blocked", l.joinToString(",")).apply()
                        result.success(null)
                    }
                    "vibrate" -> {
                        val ms = (call.arguments as Number).toLong()
                        val v = getSystemService(VIBRATOR_SERVICE) as Vibrator
                        v.vibrate(VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE))
                        result.success(null)
                    }
                    "start" -> {
                        if (Build.VERSION.SDK_INT >= 33 &&
                            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
                        ) {
                            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1)
                        }
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
