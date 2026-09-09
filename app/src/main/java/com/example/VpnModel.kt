package com.example

import android.net.Uri
import android.util.Base64
import androidx.compose.ui.graphics.Color
import com.example.ui.theme.ElectricCyan
import com.example.ui.theme.NeonGreen
import com.example.ui.theme.NeonPink
import com.example.ui.theme.NeonYellow
import com.example.ui.theme.TextMuted
import org.json.JSONObject
import java.util.UUID

enum class VpnProtocol(val label: String) {
    VLESS("VLESS-REALITY"),
    VMESS("VMESS-WS"),
    TROJAN("TROJAN-gRPC"),
    HYSTERIA2("HYSTERIA-2"),
    SHADOWSOCKS("SHADOWSOCKS")
}

enum class VpnState {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    DISCONNECTING
}

enum class RoutingMode {
    RULE,
    BYPASS_LAN,
    GLOBAL,
    DIRECT
}

data class ServerProfile(
    val id: String = UUID.randomUUID().toString(),
    var name: String,
    val countryCode: String,
    val protocol: VpnProtocol,
    val host: String,
    val port: Int,
    val sni: String,
    var pingMs: Int? = null,
    var isTesting: Boolean = false,
    val trafficUsage: String = "0.0 GB / 200 GB"
) {
    val pingColor: Color
        get() {
            val ping = pingMs ?: return TextMuted
            return when {
                ping < 0 -> NeonPink
                ping < 120 -> NeonGreen
                ping < 250 -> ElectricCyan
                ping < 450 -> NeonYellow
                else -> NeonPink
            }
        }

    val pingDisplay: String
        get() {
            if (isTesting) return "..."
            val ping = pingMs ?: return "N/A"
            return if (ping < 0) "Timeout" else "${ping}ms"
        }
}

object ConfigLinkParser {
    fun parse(rawUrl: String): ServerProfile {
        val trimmed = rawUrl.trim()
        var protocol = VpnProtocol.VLESS
        var name = "Imported Node"
        var host = "custom.cybernode.net"
        var port = 443
        var sni = host

        try {
            if (trimmed.startsWith("vmess://")) {
                protocol = VpnProtocol.VMESS
                val base64Part = trimmed.removePrefix("vmess://")
                val decoded = String(Base64.decode(base64Part, Base64.DEFAULT), Charsets.UTF_8)
                val json = JSONObject(decoded)
                name = json.optString("ps", "VMess Import")
                host = json.optString("add", "custom.vmess.com")
                port = json.optInt("port", 443)
                sni = json.optString("host", host)
            } else {
                val uri = Uri.parse(trimmed)
                when (uri.scheme?.lowercase()) {
                    "vless" -> protocol = VpnProtocol.VLESS
                    "trojan" -> protocol = VpnProtocol.TROJAN
                    "ss" -> protocol = VpnProtocol.SHADOWSOCKS
                    "hy2", "hysteria2" -> protocol = VpnProtocol.HYSTERIA2
                }
                if (!uri.fragment.isNullOrEmpty()) {
                    name = Uri.decode(uri.fragment)
                }
                if (!uri.host.isNullOrEmpty()) {
                    host = uri.host!!
                }
                if (uri.port > 0) {
                    port = uri.port
                }
                sni = uri.getQueryParameter("sni") ?: host
            }
        } catch (_: Exception) {
            name = "Imported Node (${trimmed.split("://").firstOrNull()?.uppercase() ?: "VPN"})"
        }

        return ServerProfile(
            name = name,
            countryCode = "🌐",
            protocol = protocol,
            host = host,
            port = port,
            sni = sni,
            pingMs = (110..180).random(),
            trafficUsage = "0.0 GB / 200 GB"
        )
    }
}
