package com.velocity.vpn

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class VelocityTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTileUI()
    }

    override fun onClick() {
        super.onClick()
        val tile = qsTile ?: return
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val currentState = prefs.getString("flutter.tile_vpn_state", "disconnected") ?: "disconnected"

        if (MainActivity.isFlutterReady) {
            val intent = Intent(MainActivity.ACTION_TOGGLE_VPN).apply {
                setPackage(packageName)
            }
            sendBroadcast(intent)
        } else {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra("action", "toggle_vpn")
            }
            if (launchIntent != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    val pendingIntent = PendingIntent.getActivity(
                        this,
                        0,
                        launchIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    startActivityAndCollapse(pendingIntent)
                } else {
                    @Suppress("DEPRECATION")
                    startActivityAndCollapse(launchIntent)
                }
            }
        }

        if (currentState == "connected") {
            tile.state = Tile.STATE_INACTIVE
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                tile.subtitle = "Disconnecting..."
            }
        } else {
            tile.state = Tile.STATE_ACTIVE
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                tile.subtitle = "Connecting..."
            }
        }
        tile.updateTile()
    }

    private fun updateTileUI() {
        val tile = qsTile ?: return
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val vpnState = prefs.getString("flutter.tile_vpn_state", "disconnected") ?: "disconnected"
        val serverName = prefs.getString("flutter.tile_server_name", "Velocity Node") ?: "Velocity Node"

        when (vpnState) {
            "connected" -> {
                tile.state = Tile.STATE_ACTIVE
                tile.label = "Velocity VPN"
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    tile.subtitle = if (serverName.isNotEmpty()) serverName else "Connected"
                }
            }
            "connecting" -> {
                tile.state = Tile.STATE_ACTIVE
                tile.label = "Velocity VPN"
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    tile.subtitle = "Connecting..."
                }
            }
            "disconnecting" -> {
                tile.state = Tile.STATE_INACTIVE
                tile.label = "Velocity VPN"
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    tile.subtitle = "Disconnecting..."
                }
            }
            else -> {
                tile.state = Tile.STATE_INACTIVE
                tile.label = "Velocity VPN"
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    tile.subtitle = "Disconnected"
                }
            }
        }
        tile.updateTile()
    }
}
