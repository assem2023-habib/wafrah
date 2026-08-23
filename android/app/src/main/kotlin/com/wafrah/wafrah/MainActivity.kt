package com.wafrah.wafrah

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.wafrah.wafrah/app_icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setIcon" -> {
                        val isDark = call.argument<Boolean>("isDark") ?: false
                        setIcon(isDark)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setIcon(isDark: Boolean) {
        val pm = packageManager
        val light = ComponentName(this, "com.wafrah.wafrah.MainActivityLight")
        val dark = ComponentName(this, "com.wafrah.wafrah.MainActivityDark")
        val enableLight = if (isDark) PackageManager.COMPONENT_ENABLED_STATE_DISABLED else PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        val enableDark = if (isDark) PackageManager.COMPONENT_ENABLED_STATE_ENABLED else PackageManager.COMPONENT_ENABLED_STATE_DISABLED
        pm.setComponentEnabledSetting(light, enableLight, PackageManager.DONT_KILL_APP)
        pm.setComponentEnabledSetting(dark, enableDark, PackageManager.DONT_KILL_APP)
    }
}
