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
    private val TRAFFIC_CHANNEL = "com.ailaga.ailaga/traffic"
    private val DEVICE_CHANNEL = "com.ailaga.ailaga/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // C10: real per-UID traffic counters for the privacy proof panel.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TRAFFIC_CHANNEL).setMethodCallHandler { call, result ->
            val uid = Process.myUid()
            when (call.method) {
                "getUidRxBytes" -> result.success(TrafficStats.getUidRxBytes(uid))
                "getUidTxBytes" -> result.success(TrafficStats.getUidTxBytes(uid))
                else -> result.notImplemented()
            }
        }

        // C6: device capabilities for AI tier detection (RAM / ABI / SDK / free
        // space / SoC chipset).
        //
        // socModel: Build.SOC_MODEL (API 31+) is the authoritative Android field
        // for the SoC identifier, e.g. "SM8750" on Snapdragon 8 Gen 4 devices.
        // On older devices (API 30) it falls back to Build.HARDWARE, which often
        // encodes enough information ("qcom" → Qualcomm, "google tensor" variants).
        // The value is lower-cased so Dart .contains() comparisons are
        // case-insensitive without extra work.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val mem = ActivityManager.MemoryInfo()
                    am.getMemoryInfo(mem)
                    val stat = StatFs(filesDir.absolutePath)

                    // SoC identification:
                    //   Build.SOC_MODEL  — API 31+  e.g. "SM8750", "G5 Pro"
                    //   Build.HARDWARE   — API 1+   e.g. "qcom", "google"
                    //   Build.MODEL      — optional human-readable device model
                    // We concatenate them (space-separated) so downstream
                    // substring checks work regardless of which field is populated.
                    val socModel: String = buildString {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            append(Build.SOC_MODEL)
                        }
                        // Also append HARDWARE for older devices and for
                        // supplemental matching (e.g. "tensor g5" is in MODEL).
                        if (Build.HARDWARE.isNotBlank()) {
                            if (isNotEmpty()) append(' ')
                            append(Build.HARDWARE)
                        }
                        // Device model name can encode SoC generation info
                        // (e.g. Google Pixel 9 → "Pixel 9", helps Tensor G5).
                        if (Build.MODEL.isNotBlank()) {
                            if (isNotEmpty()) append(' ')
                            append(Build.MODEL)
                        }
                    }.lowercase().trim()

                    result.success(mapOf(
                        "ramMb"            to (mem.totalMem / (1024 * 1024)),
                        "sdkInt"           to Build.VERSION.SDK_INT,
                        "abis"             to Build.SUPPORTED_ABIS.toList(),
                        "freeStorageBytes" to stat.availableBytes,
                        "platform"         to "android",
                        "socModel"         to socModel
                    ))
                }
                else -> result.notImplemented()
            }
        }
    }
}
