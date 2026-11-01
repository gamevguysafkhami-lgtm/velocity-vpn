package com.velocity.vpn

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.service.quicksettings.TileService
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.velocity.vpn/control"
    private var methodChannel: MethodChannel? = null

    companion object {
        const val ACTION_TOGGLE_VPN = "com.velocity.vpn.TOGGLE_VPN"
        const val ACTION_STATE_CHANGED = "com.velocity.vpn.STATE_CHANGED"
        var isFlutterReady = false
        var activeInstance: MainActivity? = null
    }

    private val toggleReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == ACTION_TOGGLE_VPN) {
                methodChannel?.invokeMethod("toggleVpnFromNative", null)
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        activeInstance = this
        isFlutterReady = true

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateTileState" -> {
                        val state = call.argument<String>("state") ?: "disconnected"
                        val server = call.argument<String>("server") ?: ""
                        updateTile(state, server)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        val filter = IntentFilter(ACTION_TOGGLE_VPN)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(toggleReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(toggleReceiver, filter)
        }

        handleLaunchIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleLaunchIntent(intent)
    }

    private fun handleLaunchIntent(intent: Intent?) {
        if (intent?.getStringExtra("action") == "toggle_vpn") {
            methodChannel?.invokeMethod("toggleVpnFromNative", null)
        }
    }

    private fun updateTile(state: String, server: String) {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            prefs.edit().apply {
                putString("flutter.tile_vpn_state", state)
                putString("flutter.tile_server_name", server)
                apply()
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                TileService.requestListeningState(this, ComponentName(this, VelocityTileService::class.java))
            }
        } catch (_: Exception) {}
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(toggleReceiver)
        } catch (_: Exception) {}
        if (activeInstance == this) {
            activeInstance = null
        }
        isFlutterReady = false
        super.onDestroy()
    }
}
