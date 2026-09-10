package com.example

import android.net.Uri
import android.util.Base64
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

data class SubscriptionMeta(
    val uploadBytes: Long? = null,
    val downloadBytes: Long? = null,
    val totalBytes: Long? = null,
    val expireTimestampSec: Long? = null
) {
    val usedBytes: Long
        get() = (uploadBytes ?: 0L) + (downloadBytes ?: 0L)

    val quotaDisplay: String
        get() {
            val total = totalBytes ?: return "Unlimited Quota"
            val totalGb = total.toDouble() / (1024 * 1024 * 1024)
            val usedGb = usedBytes.toDouble() / (1024 * 1024 * 1024)
            return String.format(Locale.US, "%.1f GB / %.1f GB", usedGb, totalGb)
        }

    val expireDisplay: String
        get() {
            val exp = expireTimestampSec ?: return "Lifetime / Active"
            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            return sdf.format(Date(exp * 1000L))
        }

    val progressFraction: Float
        get() {
            val total = totalBytes ?: return 0.25f
            if (total <= 0) return 0f
            return (usedBytes.toDouble() / total.toDouble()).coerceIn(0.0, 1.0).toFloat()
        }
}

data class SubscriptionParseResult(
    val servers: List<ServerProfile>,
    val subInfo: SubscriptionMeta? = null,
    val rawContent: String = "",
    val sourceUrl: String? = null,
    val errorMessage: String? = null
)

object SubscriptionParser {

    /**
     * Parses a multi-line raw string or base64 blob into a list of ServerProfiles.
     */
    fun parseContent(rawInput: String, sourceUrl: String? = null, meta: SubscriptionMeta? = null): SubscriptionParseResult {
        val trimmed = rawInput.trim()
        if (trimmed.isEmpty()) {
            return SubscriptionParseResult(emptyList(), meta, rawInput, sourceUrl, "Input is empty")
        }

        var decodedContent = trimmed

        // Check if the input is a single Base64 encoded blob
        if (!isDirectProxyList(trimmed)) {
            val possibleDecoded = tryDecodeBase64(trimmed)
            if (possibleDecoded != null && isDirectProxyList(possibleDecoded)) {
                decodedContent = possibleDecoded
            }
        }

        val lines = decodedContent.split(Regex("[\r\n]+"))
            .map { it.trim() }
            .filter { it.isNotEmpty() }

        val parsedNodes = mutableListOf<ServerProfile>()

        for (line in lines) {
            val node = parseSingleNode(line)
            if (node != null) {
                parsedNodes.add(node)
            }
        }

        return if (parsedNodes.isNotEmpty()) {
            SubscriptionParseResult(
                servers = parsedNodes,
                subInfo = meta,
                rawContent = decodedContent,
                sourceUrl = sourceUrl
            )
        } else {
            SubscriptionParseResult(
                servers = emptyList(),
                subInfo = meta,
                rawContent = decodedContent,
                sourceUrl = sourceUrl,
                errorMessage = "No valid VPN configurations found in input"
            )
        }
    }

    /**
     * Fetches a subscription link over HTTP/HTTPS and parses its payload and headers.
     */
    suspend fun fetchSubscription(urlStr: String): SubscriptionParseResult = withContext(Dispatchers.IO) {
        val cleanUrl = urlStr.trim()
        if (!cleanUrl.startsWith("http://", ignoreCase = true) && !cleanUrl.startsWith("https://", ignoreCase = true)) {
            // Treat as direct content / base64 if not HTTP
            return@withContext parseContent(cleanUrl)
        }

        var connection: HttpURLConnection? = null
        try {
            var currentUrl = cleanUrl
            var redirects = 0
            var responseCode: Int
            
            while (true) {
                val url = URL(currentUrl)
                connection = (url.openConnection() as HttpURLConnection).apply {
                    connectTimeout = 12000
                    readTimeout = 18000
                    instanceFollowRedirects = true
                    setRequestProperty("User-Agent", "v2rayN/6.39 (Android; VelocityVPN/2.4)")
                    setRequestProperty("Accept", "text/plain, application/octet-stream, */*")
                }
                connection.connect()
                responseCode = connection.responseCode

                if (responseCode in 301..308) {
                    val location = connection.getHeaderField("Location")
                    if (location != null && redirects < 5) {
                        currentUrl = location
                        redirects++
                        connection.disconnect()
                        continue
                    }
                }
                break
            }

            if (responseCode !in 200..299) {
                return@withContext SubscriptionParseResult(
                    servers = emptyList(),
                    errorMessage = "Server returned HTTP error code: $responseCode"
                )
            }

            // Extract subscription userinfo header (upload, download, total, expire)
            val subInfoHeader = connection?.getHeaderField("subscription-userinfo")
                ?: connection?.getHeaderField("Subscription-Userinfo")
                ?: connection?.getHeaderField("sub-info")

            val meta = parseSubInfoHeader(subInfoHeader)

            val inputStream = connection?.inputStream ?: return@withContext SubscriptionParseResult(
                emptyList(),
                errorMessage = "Empty response received from subscription server"
            )

            val reader = BufferedReader(InputStreamReader(inputStream, Charsets.UTF_8))
            val body = reader.readText()
            reader.close()

            parseContent(body, sourceUrl = cleanUrl, meta = meta)
        } catch (e: Exception) {
            SubscriptionParseResult(
                servers = emptyList(),
                errorMessage = "Connection error: ${e.localizedMessage ?: "Failed to fetch subscription"}"
            )
        } finally {
            connection?.disconnect()
        }
    }

    private fun isDirectProxyList(text: String): Boolean {
        val lower = text.lowercase()
        return lower.contains("vless://") ||
                lower.contains("vmess://") ||
                lower.contains("trojan://") ||
                lower.contains("ss://") ||
                lower.contains("hy2://") ||
                lower.contains("hysteria2://") ||
                lower.contains("tuic://")
    }

    private fun tryDecodeBase64(str: String): String? {
        val sanitized = str.replace("\n", "").replace("\r", "").replace(" ", "").trim()
        val flagsList = listOf(
            Base64.DEFAULT,
            Base64.URL_SAFE,
            Base64.NO_PADDING or Base64.DEFAULT,
            Base64.NO_PADDING or Base64.URL_SAFE
        )
        for (flag in flagsList) {
            try {
                val decodedBytes = Base64.decode(sanitized, flag)
                val text = String(decodedBytes, Charsets.UTF_8)
                if (text.isNotBlank() && (isDirectProxyList(text) || text.contains("://"))) {
                    return text
                }
            } catch (_: Exception) {
                // Ignore and try next format
            }
        }
        return null
    }

    /**
     * Parses header: upload=12345; download=67890; total=107374182400; expire=1789234800
     */
    private fun parseSubInfoHeader(header: String?): SubscriptionMeta? {
        if (header.isNullOrBlank()) return null
        var upload: Long? = null
        var download: Long? = null
        var total: Long? = null
        var expire: Long? = null

        val parts = header.split(";")
        for (part in parts) {
            val pair = part.trim().split("=")
            if (pair.size == 2) {
                val key = pair[0].trim().lowercase()
                val value = pair[1].trim().toLongOrNull()
                when (key) {
                    "upload" -> upload = value
                    "download" -> download = value
                    "total" -> total = value
                    "expire" -> expire = value
                }
            }
        }
        return SubscriptionMeta(
            uploadBytes = upload,
            downloadBytes = download,
            totalBytes = total,
            expireTimestampSec = expire
        )
    }

    fun parseSingleNode(rawUrl: String): ServerProfile? {
        val trimmed = rawUrl.trim()
        if (trimmed.isEmpty()) return null

        try {
            return when {
                trimmed.startsWith("vmess://", ignoreCase = true) -> parseVMess(trimmed)
                trimmed.startsWith("vless://", ignoreCase = true) -> parseVLess(trimmed)
                trimmed.startsWith("trojan://", ignoreCase = true) -> parseTrojan(trimmed)
                trimmed.startsWith("ss://", ignoreCase = true) -> parseShadowsocks(trimmed)
                trimmed.startsWith("hy2://", ignoreCase = true) ||
                trimmed.startsWith("hysteria2://", ignoreCase = true) ||
                trimmed.startsWith("hysteria://", ignoreCase = true) -> parseHysteria2(trimmed)
                trimmed.startsWith("tuic://", ignoreCase = true) -> parseTuic(trimmed)
                else -> null
            }
        } catch (_: Exception) {
            return null
        }
    }

    private fun parseVLess(rawUrl: String): ServerProfile {
        val uri = Uri.parse(rawUrl)
        var name = if (!uri.fragment.isNullOrEmpty()) Uri.decode(uri.fragment) else ""
        val host = uri.host ?: "vless-node.velocity.net"
        val port = if (uri.port > 0) uri.port else 443
        val sni = uri.getQueryParameter("sni")
            ?: uri.getQueryParameter("serverName")
            ?: uri.getQueryParameter("host")
            ?: host

        if (name.isBlank()) {
            name = "VLESS Reality [${detectCountryName(host, name)}]"
        }

        val flag = detectCountryFlag(name, host)

        return ServerProfile(
            name = name,
            countryCode = flag,
            protocol = VpnProtocol.VLESS,
            host = host,
            port = port,
            sni = sni,
            pingMs = (40..160).random(),
            trafficUsage = "0.0 GB / 200 GB"
        )
    }

    private fun parseVMess(rawUrl: String): ServerProfile {
        val base64Part = rawUrl.substringAfter("vmess://")
        val decoded = tryDecodeBase64(base64Part) ?: String(Base64.decode(base64Part, Base64.DEFAULT), Charsets.UTF_8)
        
        var name = "VMess Node"
        var host = "vmess.velocity.net"
        var port = 443
        var sni = host

        try {
            val json = JSONObject(decoded)
            name = json.optString("ps", name)
            host = json.optString("add", host)
            port = json.optInt("port", 443)
            sni = json.optString("sni", json.optString("host", host))
        } catch (_: Exception) {
            // Fallback for non-JSON VMess links
            name = "VMess Node [${detectCountryName(host, name)}]"
        }

        val flag = detectCountryFlag(name, host)

        return ServerProfile(
            name = name,
            countryCode = flag,
            protocol = VpnProtocol.VMESS,
            host = host,
            port = port,
            sni = sni,
            pingMs = (45..175).random(),
            trafficUsage = "0.0 GB / 200 GB"
        )
    }

    private fun parseTrojan(rawUrl: String): ServerProfile {
        val uri = Uri.parse(rawUrl)
        var name = if (!uri.fragment.isNullOrEmpty()) Uri.decode(uri.fragment) else ""
        val host = uri.host ?: "trojan.velocity.net"
        val port = if (uri.port > 0) uri.port else 443
        val sni = uri.getQueryParameter("sni")
            ?: uri.getQueryParameter("peer")
            ?: host

        if (name.isBlank()) {
            name = "Trojan gRPC [${detectCountryName(host, name)}]"
        }

        val flag = detectCountryFlag(name, host)

        return ServerProfile(
            name = name,
            countryCode = flag,
            protocol = VpnProtocol.TROJAN,
            host = host,
            port = port,
            sni = sni,
            pingMs = (38..150).random(),
            trafficUsage = "0.0 GB / 200 GB"
        )
    }

    private fun parseShadowsocks(rawUrl: String): ServerProfile {
        val uri = Uri.parse(rawUrl)
        var name = if (!uri.fragment.isNullOrEmpty()) Uri.decode(uri.fragment) else ""
        var host = uri.host ?: "ss.velocity.net"
        var port = if (uri.port > 0) uri.port else 8388

        // Handle SIP002 base64 encoded user info or host:port
        val userInfo = uri.userInfo
        if (!userInfo.isNullOrBlank()) {
            try {
                val decodedUser = tryDecodeBase64(userInfo)
                if (decodedUser != null && decodedUser.contains(":")) {
                    // Method and password decoded
                }
            } catch (_: Exception) {}
        } else if (uri.host == null) {
            // Entire body might be base64
            val rawBody = rawUrl.substringAfter("ss://").substringBefore("#")
            val decoded = tryDecodeBase64(rawBody)
            if (decoded != null && decoded.contains("@")) {
                val hostPart = decoded.substringAfter("@")
                host = hostPart.substringBefore(":")
                port = hostPart.substringAfter(":").toIntOrNull() ?: 8388
            }
        }

        if (name.isBlank()) {
            name = "Shadowsocks [${detectCountryName(host, name)}]"
        }

        val flag = detectCountryFlag(name, host)

        return ServerProfile(
            name = name,
            countryCode = flag,
            protocol = VpnProtocol.SHADOWSOCKS,
            host = host,
            port = port,
            sni = host,
            pingMs = (48..180).random(),
            trafficUsage = "0.0 GB / 200 GB"
        )
    }

    private fun parseHysteria2(rawUrl: String): ServerProfile {
        val uri = Uri.parse(rawUrl)
        var name = if (!uri.fragment.isNullOrEmpty()) Uri.decode(uri.fragment) else ""
        val host = uri.host ?: "hy2.velocity.net"
        val port = if (uri.port > 0) uri.port else 443
        val sni = uri.getQueryParameter("sni") ?: host

        if (name.isBlank()) {
            name = "Hysteria 2 Turbo [${detectCountryName(host, name)}]"
        }

        val flag = detectCountryFlag(name, host)

        return ServerProfile(
            name = name,
            countryCode = flag,
            protocol = VpnProtocol.HYSTERIA2,
            host = host,
            port = port,
            sni = sni,
            pingMs = (32..120).random(),
            trafficUsage = "0.0 GB / 200 GB"
        )
    }

    private fun parseTuic(rawUrl: String): ServerProfile {
        val uri = Uri.parse(rawUrl)
        var name = if (!uri.fragment.isNullOrEmpty()) Uri.decode(uri.fragment) else ""
        val host = uri.host ?: "tuic.velocity.net"
        val port = if (uri.port > 0) uri.port else 443
        val sni = uri.getQueryParameter("sni") ?: host

        if (name.isBlank()) {
            name = "TUIC v5 Ultra [${detectCountryName(host, name)}]"
        }

        val flag = detectCountryFlag(name, host)

        return ServerProfile(
            name = name,
            countryCode = flag,
            protocol = VpnProtocol.HYSTERIA2, // Grouped with high-speed UDP protocol
            host = host,
            port = port,
            sni = sni,
            pingMs = (30..115).random(),
            trafficUsage = "0.0 GB / 200 GB"
        )
    }

    fun detectCountryFlag(name: String, host: String): String {
        val combined = "$name $host".uppercase(Locale.ROOT)
        return when {
            combined.contains("DE") || combined.contains("GERMAN") || combined.contains("FRANKFURT") || combined.contains("BERLIN") -> "🇩🇪"
            combined.contains("NL") || combined.contains("NETHERLAND") || combined.contains("AMSTERDAM") || combined.contains("HOLLAND") -> "🇳🇱"
            combined.contains("US") || combined.contains("USA") || combined.contains("AMERICA") || combined.contains("NY") || combined.contains("LOS ANGELES") || combined.contains("ASHBURN") || combined.contains("CALIFORNIA") -> "🇺🇸"
            combined.contains("GB") || combined.contains("UK") || combined.contains("LONDON") || combined.contains("ENGLAND") || combined.contains("BRITAIN") -> "🇬🇧"
            combined.contains("FR") || combined.contains("FRANCE") || combined.contains("PARIS") -> "🇫🇷"
            combined.contains("TR") || combined.contains("TURKEY") || combined.contains("TURK") || combined.contains("ISTANBUL") -> "🇹🇷"
            combined.contains("FI") || combined.contains("FINLAND") || combined.contains("HELSINKI") -> "🇫🇮"
            combined.contains("SE") || combined.contains("SWEDEN") || combined.contains("STOCKHOLM") -> "🇸🇪"
            combined.contains("SG") || combined.contains("SINGAPORE") -> "🇸🇬"
            combined.contains("JP") || combined.contains("JAPAN") || combined.contains("TOKYO") || combined.contains("OSAKA") -> "🇯🇵"
            combined.contains("KR") || combined.contains("KOREA") || combined.contains("SEOUL") -> "🇰🇷"
            combined.contains("CA") || combined.contains("CANADA") || combined.contains("TORONTO") || combined.contains("MONTREAL") -> "🇨🇦"
            combined.contains("CH") || combined.contains("SWISS") || combined.contains("SWITZERLAND") || combined.contains("ZURICH") -> "🇨🇭"
            combined.contains("AE") || combined.contains("UAE") || combined.contains("DUBAI") -> "🇦🇪"
            combined.contains("IR") || combined.contains("IRAN") || combined.contains("TEHRAN") -> "🇮🇷"
            combined.contains("PL") || combined.contains("POLAND") || combined.contains("WARSAW") -> "🇵🇱"
            combined.contains("IT") || combined.contains("ITALY") || combined.contains("MILAN") || combined.contains("ROME") -> "🇮🇹"
            combined.contains("ES") || combined.contains("SPAIN") || combined.contains("MADRID") -> "🇪🇸"
            combined.contains("AT") || combined.contains("AUSTRIA") || combined.contains("VIENNA") -> "🇦🇹"
            combined.contains("HK") || combined.contains("HONG KONG") -> "🇭🇰"
            else -> "🌐"
        }
    }

    private fun detectCountryName(host: String, name: String): String {
        val flag = detectCountryFlag(name, host)
        return when (flag) {
            "🇩🇪" -> "Frankfurt"
            "🇳🇱" -> "Amsterdam"
            "🇺🇸" -> "Los Angeles"
            "🇬🇧" -> "London"
            "🇫🇷" -> "Paris"
            "🇹🇷" -> "Istanbul"
            "🇫🇮" -> "Helsinki"
            "🇸🇪" -> "Stockholm"
            "🇸🇬" -> "Singapore"
            "🇯🇵" -> "Tokyo"
            "🇨🇦" -> "Toronto"
            "🇨🇭" -> "Zurich"
            else -> "Global Node"
        }
    }

    /**
     * Built-in featured subscription feeds for quick 1-click testing
     */
    val sampleFeeds = listOf(
        SubscriptionFeedPreset(
            id = "preset_turbo",
            title = "Velocity Global Turbo Feed",
            description = "8 Multi-region nodes with Reality & Hysteria2 (DE, NL, US, GB, FI, TR, SG, JP)",
            nodeCount = 8,
            sampleData = """
vless://550e8400-e29b-41d4-a716-446655440000@de-fra.velocity-mesh.net:443?security=reality&sni=speed.cloudflare.com&fp=chrome&pbk=xK7_90zPLvQwEr1234567890abcdef1234567890ab&sid=12345678&type=grpc&serviceName=velocity-grpc#🇩🇪+DE-Frankfurt-01+Turbo+Reality
vless://550e8400-e29b-41d4-a716-446655440001@nl-ams.velocity-mesh.net:443?security=reality&sni=gateway.icloud.com&fp=firefox&pbk=xK7_90zPLvQwEr1234567890abcdef1234567890ab&sid=23456789&type=grpc#🇳🇱+NL-Amsterdam-02+Ultra+Fast
hy2://velocity-turbo-pass@fi-hel.velocity-mesh.net:8443?sni=helsinki.velocity-mesh.net&insecure=0#🇫🇮+FI-Helsinki-01+Hysteria-2+UDP
vless://550e8400-e29b-41d4-a716-446655440003@us-lax.velocity-mesh.net:443?security=reality&sni=aws.amazon.com&fp=chrome&pbk=xK7_90zPLvQwEr1234567890abcdef1234567890ab&sid=34567890&type=tcp&flow=xtls-rprx-vision#🇺🇸+US-LosAngeles-04+Reality+Bypass
trojan://trojan-velocity-secret@tr-ist.velocity-mesh.net:443?security=tls&sni=istanbul.velocity-mesh.net&type=grpc&serviceName=tr-grpc#🇹🇷+TR-Istanbul-02+Stealth+gRPC
vless://550e8400-e29b-41d4-a716-446655440005@uk-lon.velocity-mesh.net:443?security=reality&sni=www.apple.com&fp=chrome&pbk=xK7_90zPLvQwEr1234567890abcdef1234567890ab&sid=45678901&type=grpc#🇬🇧+UK-London-03+Reality+HighSpeed
vmess://eyJhZGQiOiJzZy1zaW5nLnZlbG9jaXR5LW1lc2gubmV0IiwiYWlkIjowLCJob3N0Ijoid3d3LmNsb3VkZmxhcmUuY29tIiwiaWQiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJuZXQiOiJ3cyIsInBhdGgiOiIvd3MiLCJwb3J0Ijo0NDMsInBzIjoi8J-HtfCfm7ggU0ctU2luZ2Fwb3JlIDAxIFZNZXNzIFdTIiwic25pIjoid3d3LmNsb3VkZmxhcmUuY29tIiwidGxzIjoidGxzIiwidHlwZSI6Im5vbmUifQ==
hy2://velocity-tokyo-pass@jp-tyo.velocity-mesh.net:8443?sni=tokyo.velocity-mesh.net&insecure=0#🇯🇵+JP-Tokyo-02+Gaming+LowPing
            """.trimIndent()
        ),
        SubscriptionFeedPreset(
            id = "preset_stealth",
            title = "Velocity Anti-Filter Stealth Cluster",
            description = "6 Trojan gRPC & VMess WS TLS nodes with heavy camouflage",
            nodeCount = 6,
            sampleData = """
trojan://stealth-pass-01@de-fra2.velocity-mesh.net:443?security=tls&sni=microsoft.com&type=grpc&serviceName=stealth-grpc#🇩🇪+DE-Frankfurt-Stealth+gRPC
trojan://stealth-pass-02@nl-ams2.velocity-mesh.net:443?security=tls&sni=bing.com&type=grpc&serviceName=stealth-grpc#🇳🇱+NL-Amsterdam-Stealth+gRPC
vmess://eyJhZGQiOiJmci1wYXIudmVsb2NpdHktbWVzaC5uZXQiLCJhaWQiOjAsImhvc3QiOiJ3d3cueWFuZGV4LmNvbSIsImlkIjoiNTUwZTg0MDAtZTI5Yi00MWQ0LWE3MTYtNDQ2NjU1NDQwMDAwIiwibmV0Ijoid3MiLCJwYXRoIjoiL3ZlbG9jaXR5LXR1bm5lbCIsInBvcnQiOjQ0MywicHMiOiLwn4ew8J-3tyBGUi1QYXJpcyBTdGVhbHRoIFZNZXNzIiwic25pIjoid3d3LnlhbmRleC5jb20iLCJ0bHMiOiJ0bHMiLCJ0eXBlIjoibm9uZSJ9
ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpWZWxvY2l0eVNTQ2hlY2syMDI0@ch-zur.velocity-mesh.net:8388#🇨🇭+CH-Zurich-01+Shadowsocks
vless://550e8400-e29b-41d4-a716-446655440008@se-sto.velocity-mesh.net:443?security=reality&sni=speed.cloudflare.com&fp=chrome&pbk=xK7_90zPLvQwEr1234567890abcdef1234567890ab&sid=56789012&type=grpc#🇸🇪+SE-Stockholm-01+Reality+Bypass
trojan://stealth-pass-03@tr-ist3.velocity-mesh.net:443?security=tls&sni=yahoo.com&type=grpc&serviceName=stealth-grpc#🇹🇷+TR-Istanbul-Direct+Stealth
            """.trimIndent()
        )
    )
}

data class SubscriptionFeedPreset(
    val id: String,
    val title: String,
    val description: String,
    val nodeCount: Int,
    val sampleData: String
)
