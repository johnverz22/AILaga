package com.ailaga.ailaga

import android.app.ActivityManager
import android.content.Context
import android.net.TrafficStats
import android.os.Build
import android.os.Process
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SHAKE_CHANNEL = "com.ailaga.ailaga/shake"
    private val TRAFFIC_CHANNEL = "com.ailaga.ailaga/traffic"
    private val DEVICE_CHANNEL = "com.ailaga.ailaga/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHAKE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "configureShakeDetection") {
                // TODO: configure shake detection
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        // C10: real per-UID traffic counters for the privacy proof panel.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TRAFFIC_CHANNEL).setMethodCallHandler { call, result ->
            val uid = Process.myUid()
            when (call.method) {
                "getUidRxBytes" -> result.success(TrafficStats.getUidRxBytes(uid))
                "getUidTxBytes" -> result.success(TrafficStats.getUidTxBytes(uid))
                else -> result.notImplemented()
            }
        }

        // C6: device capabilities for AI tier detection (RAM / ABI / SDK / free space).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val mem = ActivityManager.MemoryInfo()
                    am.getMemoryInfo(mem)
                    val stat = StatFs(filesDir.absolutePath)
                    result.success(mapOf(
                        "ramMb" to (mem.totalMem / (1024 * 1024)),
                        "sdkInt" to Build.VERSION.SDK_INT,
                        "abis" to Build.SUPPORTED_ABIS.toList(),
                        "freeStorageBytes" to stat.availableBytes
                    ))
                }
                else -> result.notImplemented()
            }
        }
    }
}
