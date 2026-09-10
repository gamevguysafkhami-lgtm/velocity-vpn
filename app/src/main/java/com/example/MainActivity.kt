package com.example

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.AddLink
import androidx.compose.material.icons.filled.AltRoute
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowForwardIos
import androidx.compose.material.icons.filled.ArrowOutward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.foundation.horizontalScroll
import androidx.compose.material.icons.filled.CurrencyExchange
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.Headphones
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.PowerSettingsNew
import androidx.compose.material.icons.filled.Public
import androidx.compose.material.icons.filled.ReceiptLong
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Send
import androidx.compose.material.icons.filled.SignalCellularAlt
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.SyncDisabled
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material.icons.filled.UploadFile
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableDoubleStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.BorderDark
import com.example.ui.theme.DeepCyan
import com.example.ui.theme.ElectricCyan
import com.example.ui.theme.ElectricCyanGlow
import com.example.ui.theme.MidnightBg
import com.example.ui.theme.MyApplicationTheme
import com.example.ui.theme.NeonGreen
import com.example.ui.theme.NeonPink
import com.example.ui.theme.NeonYellow
import com.example.ui.theme.PureBlack
import com.example.ui.theme.SurfaceDark
import com.example.ui.theme.SurfaceElevated
import com.example.ui.theme.TextMuted
import com.example.ui.theme.TextPrimary
import com.example.ui.theme.TextSecondary
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.random.Random

class MainActivity : io.flutter.embedding.android.FlutterActivity()

// ---------------------------------------------------------------------------
// Velocity Stylized Neon 'V' Emblem
// ---------------------------------------------------------------------------
@Composable
fun VelocityVLogo(
    modifier: Modifier = Modifier,
    size: Dp = 38.dp,
    glowIntensity: Float = 0.8f
) {
    Canvas(modifier = modifier.size(size)) {
        val w = this.size.width
        val h = this.size.height

        // Outer Neon Glow Layer
        val glowBrush = Brush.radialGradient(
            colors = listOf(ElectricCyan.copy(alpha = 0.35f * glowIntensity), Color.Transparent),
            center = Offset(w / 2, h / 2),
            radius = w * 0.7f
        )
        drawCircle(brush = glowBrush, radius = w * 0.7f)

        // Geometry of the Velocity 'V'
        val pathGlow = Path().apply {
            moveTo(w * 0.22f, h * 0.24f)
            lineTo(w * 0.44f, h * 0.24f)
            lineTo(w * 0.50f, h * 0.74f)
            lineTo(w * 0.78f, h * 0.24f)
        }

        // Broad halo
        drawPath(
            path = pathGlow,
            color = DeepCyan.copy(alpha = 0.35f * glowIntensity),
            style = Stroke(width = w * 0.16f, cap = StrokeCap.Round, join = StrokeJoin.Round)
        )

        // Medium aura
        drawPath(
            path = pathGlow,
            color = ElectricCyan.copy(alpha = 0.65f * glowIntensity),
            style = Stroke(width = w * 0.09f, cap = StrokeCap.Round, join = StrokeJoin.Round)
        )

        // Sharp Electric Core
        drawPath(
            path = pathGlow,
            color = ElectricCyan,
            style = Stroke(width = w * 0.05f, cap = StrokeCap.Round, join = StrokeJoin.Round)
        )

        // Dynamic cyber slits on left wing
        val slit1 = Path().apply {
            moveTo(w * 0.27f, h * 0.33f)
            lineTo(w * 0.39f, h * 0.40f)
        }
        drawPath(
            path = slit1,
            color = ElectricCyan,
            style = Stroke(width = w * 0.04f, cap = StrokeCap.Round)
        )

        val slit2 = Path().apply {
            moveTo(w * 0.34f, h * 0.45f)
            lineTo(w * 0.44f, h * 0.51f)
        }
        drawPath(
            path = slit2,
            color = DeepCyan,
            style = Stroke(width = w * 0.035f, cap = StrokeCap.Round)
        )
    }
}

// ---------------------------------------------------------------------------
// Main Screen Composable
// ---------------------------------------------------------------------------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VelocityVpnMainScreen() {
    val context = LocalContext.current
    var currentLang by remember { mutableStateOf(AppLanguage.EN) }
    I18n.currentLang = currentLang
    val isFa = currentLang == AppLanguage.FA
    val layoutDirection = if (isFa) LayoutDirection.Rtl else LayoutDirection.Ltr

    var vpnState by remember { mutableStateOf(VpnState.DISCONNECTED) }
    var routingMode by remember { mutableStateOf(RoutingMode.RULE) }

    // Servers list
    val servers = remember {
        mutableStateListOf(
            ServerProfile(
                name = "Velocity DE-Frankfurt Turbo",
                countryCode = "🇩🇪",
                protocol = VpnProtocol.VLESS,
                host = "fra-velocity.node.net",
                port = 443,
                sni = "speed.cloudflare.com",
                pingMs = 74,
                trafficUsage = "18.4 GB / 300 GB"
            ),
            ServerProfile(
                name = "Velocity FI-Helsinki Gaming UDP",
                countryCode = "🇫🇮",
                protocol = VpnProtocol.HYSTERIA2,
                host = "hel-velocity.node.net",
                port = 8443,
                sni = "hel.apple.com",
                pingMs = 88,
                trafficUsage = "42.0 GB / 300 GB"
            ),
            ServerProfile(
                name = "Velocity NL-Amsterdam VIP gRPC",
                countryCode = "🇳🇱",
                protocol = VpnProtocol.TROJAN,
                host = "ams-velocity.node.net",
                port = 443,
                sni = "ams.microsoft.com",
                pingMs = 105,
                trafficUsage = "95.1 GB / 300 GB"
            ),
            ServerProfile(
                name = "Velocity US-Ashburn Cloud Direct",
                countryCode = "🇺🇸",
                protocol = VpnProtocol.VMESS,
                host = "iad-velocity.node.net",
                port = 2053,
                sni = "iad.aws.amazon.com",
                pingMs = 158,
                trafficUsage = "8.3 GB / 300 GB"
            ),
            ServerProfile(
                name = "Velocity SG-Singapore FastPool",
                countryCode = "🇸🇬",
                protocol = VpnProtocol.SHADOWSOCKS,
                host = "sin-velocity.node.net",
                port = 9000,
                sni = "sg.google.com",
                pingMs = 176,
                trafficUsage = "2.1 GB / 300 GB"
            )
        )
    }

    var selectedServer by remember { mutableStateOf(servers.first()) }

    // Telemetry state
    var downloadSpeedKb by remember { mutableDoubleStateOf(0.0) }
    var uploadSpeedKb by remember { mutableDoubleStateOf(0.0) }
    var totalDownloadMb by remember { mutableDoubleStateOf(168.4) }
    var totalUploadMb by remember { mutableDoubleStateOf(44.1) }
    var connectedSeconds by remember { mutableIntStateOf(0) }

    // Dialog & sheet controllers
    var showSubscriptionScreen by remember { mutableStateOf(false) }
    var showServerSheet by remember { mutableStateOf(false) }
    var showRoutingSheet by remember { mutableStateOf(false) }
    var showImportDialog by remember { mutableStateOf(false) }
    var showReceiptSheet by remember { mutableStateOf(false) }
    var showTelegramSupportDialog by remember { mutableStateOf(false) }

    val coroutineScope = rememberCoroutineScope()

    // Live latency & testing state
    var isLivePingEnabled by remember { mutableStateOf(false) }
    var isPingAllRunning by remember { mutableStateOf(false) }

    // Live ping background periodic loop
    LaunchedEffect(isLivePingEnabled) {
        if (isLivePingEnabled) {
            while (true) {
                delay(12000)
                val targetServer = selectedServer
                val updated = LatencyChecker.testSingleServer(targetServer)
                val idx = servers.indexOfFirst { it.id == updated.id }
                if (idx != -1) {
                    servers[idx] = updated
                    selectedServer = updated
                }
            }
        }
    }

    // Telemetry ticker loop
    LaunchedEffect(vpnState) {
        if (vpnState == VpnState.CONNECTED) {
            while (true) {
                delay(1000)
                downloadSpeedKb = Random.nextDouble(550.0, 3400.0)
                uploadSpeedKb = Random.nextDouble(120.0, 890.0)
                totalDownloadMb += (downloadSpeedKb / 1024.0)
                totalUploadMb += (uploadSpeedKb / 1024.0)
                connectedSeconds++
            }
        } else {
            downloadSpeedKb = 0.0
            uploadSpeedKb = 0.0
        }
    }

    fun toggleVpn() {
        if (vpnState == VpnState.DISCONNECTED) {
            vpnState = VpnState.CONNECTING
            coroutineScope.launch {
                delay(1200)
                connectedSeconds = 0
                vpnState = VpnState.CONNECTED
            }
        } else if (vpnState == VpnState.CONNECTED) {
            vpnState = VpnState.DISCONNECTING
            coroutineScope.launch {
                delay(600)
                vpnState = VpnState.DISCONNECTED
            }
        }
    }

    fun pingSingleServer(target: ServerProfile) {
        coroutineScope.launch {
            val idx = servers.indexOfFirst { it.id == target.id }
            if (idx != -1) {
                servers[idx] = servers[idx].copy(isTesting = true)
                val tested = LatencyChecker.testSingleServer(servers[idx])
                servers[idx] = tested
                if (selectedServer.id == tested.id) {
                    selectedServer = tested
                }
            }
        }
    }

    fun pingAllServers() {
        if (isPingAllRunning) return
        isPingAllRunning = true
        coroutineScope.launch {
            for (i in servers.indices) {
                servers[i] = servers[i].copy(isTesting = true)
            }
            LatencyChecker.testAllServersConcurrent(servers) { tested ->
                val idx = servers.indexOfFirst { it.id == tested.id }
                if (idx != -1) {
                    servers[idx] = tested
                    if (selectedServer.id == tested.id) {
                        selectedServer = tested
                    }
                }
            }
            isPingAllRunning = false
        }
    }

    fun autoSelectFastestServer() {
        val best = LatencyChecker.findBestServer(servers)
        if (best != null) {
            selectedServer = best
            Toast.makeText(
                context,
                "${I18n.t("best_selected_toast")}: ${best.name} (${best.pingDisplay})",
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    fun openTelegram() {
        val url = "https://t.me/VelocityVPN_Official"
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            context.startActivity(intent)
        } catch (_: Exception) {
            Toast.makeText(context, "Telegram: @VelocityVPN_Official", Toast.LENGTH_LONG).show()
        }
    }

    CompositionLocalProvider(LocalLayoutDirection provides layoutDirection) {
        if (showSubscriptionScreen) {
            SubscriptionScreen(
                onBack = { showSubscriptionScreen = false },
                onImportServers = { newServers, replaceExisting, autoTestLatency ->
                    if (replaceExisting) {
                        servers.clear()
                        servers.addAll(newServers)
                    } else {
                        val existingIds = servers.map { it.id }.toSet()
                        val toAdd = newServers.filter { !existingIds.contains(it.id) }
                        servers.addAll(0, toAdd)
                    }
                    if (servers.isNotEmpty()) {
                        selectedServer = servers.first()
                    }
                    showSubscriptionScreen = false
                    if (autoTestLatency) {
                        pingAllServers()
                    }
                }
            )
        } else {
            Scaffold(
                modifier = Modifier
                    .fillMaxSize()
                    .background(PureBlack)
                    .statusBarsPadding()
                    .navigationBarsPadding(),
                containerColor = PureBlack,
                topBar = {
                    VelocityHeaderBar(
                        onToggleLang = {
                            currentLang = if (currentLang == AppLanguage.EN) AppLanguage.FA else AppLanguage.EN
                        },
                        onOpenReceipt = { showReceiptSheet = true },
                        onOpenSupport = { showTelegramSupportDialog = true },
                        currentLang = currentLang
                    )
                }
            ) { paddingValues ->
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Top Routing Mode & Quick Action Bar
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(SurfaceDark)
                            .padding(horizontal = 16.dp, vertical = 9.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Routing Mode Pill
                        Surface(
                            color = SurfaceElevated,
                            shape = RoundedCornerShape(8.dp),
                            border = androidx.compose.foundation.BorderStroke(1.dp, BorderDark),
                            modifier = Modifier
                                .testTag("routing_mode_button")
                                .clickable { showRoutingSheet = true }
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.AltRoute,
                                    contentDescription = null,
                                    tint = ElectricCyan,
                                    modifier = Modifier.size(14.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = when (routingMode) {
                                        RoutingMode.RULE -> I18n.t("mode_rule")
                                        RoutingMode.BYPASS_LAN -> I18n.t("mode_bypass_lan")
                                        RoutingMode.GLOBAL -> I18n.t("mode_global")
                                        RoutingMode.DIRECT -> I18n.t("mode_direct")
                                    },
                                    color = TextPrimary,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.SemiBold
                                )
                            }
                        }

                        // Import Subscription / Config Button
                        Surface(
                            color = SurfaceElevated,
                            shape = RoundedCornerShape(8.dp),
                            border = androidx.compose.foundation.BorderStroke(1.dp, ElectricCyan.copy(alpha = 0.5f)),
                            modifier = Modifier
                                .testTag("import_config_button")
                                .clickable { showSubscriptionScreen = true }
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Add,
                                    contentDescription = null,
                                    tint = ElectricCyan,
                                    modifier = Modifier.size(14.dp)
                                )
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(
                                    text = I18n.t("sub_screen_title"),
                                    color = ElectricCyan,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }

                Spacer(modifier = Modifier.height(14.dp))

                // Tunnel Status Header
                val statusColor = when (vpnState) {
                    VpnState.CONNECTED -> NeonGreen
                    VpnState.CONNECTING -> ElectricCyan
                    VpnState.DISCONNECTING, VpnState.DISCONNECTED -> NeonPink
                }
                val statusText = when (vpnState) {
                    VpnState.CONNECTED -> I18n.t("status_connected")
                    VpnState.CONNECTING -> I18n.t("status_connecting")
                    VpnState.DISCONNECTING -> I18n.t("status_disconnecting")
                    VpnState.DISCONNECTED -> I18n.t("status_disconnected")
                }

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(statusColor)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = statusText,
                        color = statusColor,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.2.sp
                    )
                }

                if (vpnState == VpnState.CONNECTED) {
                    val h = connectedSeconds / 3600
                    val m = (connectedSeconds % 3600) / 60
                    val s = connectedSeconds % 60
                    val timeStr = String.format("%02d:%02d:%02d", h, m, s)
                    Text(
                        text = "${I18n.t("connected_time")}: $timeStr",
                        color = TextSecondary,
                        fontSize = 11.sp,
                        fontFamily = FontFamily.Monospace,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }

                // Central Power Button with Electric Cyan BoxShadow Glow
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    VelocityGlowingPowerButton(
                        vpnState = vpnState,
                        onToggle = { toggleVpn() }
                    )
                }

                // NekoBox Telemetry Speed Card
                VelocityTelemetryCard(
                    downloadSpeedKb = downloadSpeedKb,
                    uploadSpeedKb = uploadSpeedKb,
                    totalDownloadMb = totalDownloadMb,
                    totalUploadMb = totalUploadMb
                )

                Spacer(modifier = Modifier.height(12.dp))

                // Active Node Selection Card
                VelocityActiveNodeCard(
                    server = selectedServer,
                    onClick = { showServerSheet = true }
                )

                Spacer(modifier = Modifier.height(12.dp))
            }

            // Server Selection Bottom Sheet
            if (showServerSheet) {
                ModalBottomSheet(
                    onDismissRequest = { showServerSheet = false },
                    sheetState = rememberModalBottomSheetState(),
                    containerColor = SurfaceDark,
                    dragHandle = null
                ) {
                    VelocityServerBottomSheetContent(
                        servers = servers,
                        selectedServer = selectedServer,
                        isPingAllRunning = isPingAllRunning,
                        isLivePingEnabled = isLivePingEnabled,
                        onToggleLivePing = { isLivePingEnabled = it },
                        onSelectServer = { server ->
                            selectedServer = server
                            showServerSheet = false
                        },
                        onAutoSelectBest = {
                            autoSelectFastestServer()
                            showServerSheet = false
                        },
                        onPingAll = { pingAllServers() },
                        onPingSingle = { server -> pingSingleServer(server) },
                        onOpenImport = {
                            showServerSheet = false
                            showSubscriptionScreen = true
                        }
                    )
                }
            }

            // Routing Mode Sheet
            if (showRoutingSheet) {
                ModalBottomSheet(
                    onDismissRequest = { showRoutingSheet = false },
                    containerColor = SurfaceDark,
                    dragHandle = null
                ) {
                    VelocityRoutingModeSheetContent(
                        currentMode = routingMode,
                        onSelectMode = { mode ->
                            routingMode = mode
                            showRoutingSheet = false
                        }
                    )
                }
            }

            // Import Config Dialog
            if (showImportDialog) {
                VelocityImportConfigDialog(
                    onDismiss = { showImportDialog = false },
                    onImport = { url ->
                        val newServer = ConfigLinkParser.parse(url)
                        newServer.name = "Velocity ${newServer.name}"
                        servers.add(0, newServer)
                        selectedServer = newServer
                        showImportDialog = false
                    }
                )
            }

            // Velocity VIP Activation Sheet
            if (showReceiptSheet) {
                ModalBottomSheet(
                    onDismissRequest = { showReceiptSheet = false },
                    sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
                    containerColor = PureBlack,
                    dragHandle = null
                ) {
                    VelocityVipActivationContent(
                        onClose = { showReceiptSheet = false },
                        onOpenTelegram = { openTelegram() }
                    )
                }
            }

            // Telegram Support Dialog
            if (showTelegramSupportDialog) {
                AlertDialog(
                    onDismissRequest = { showTelegramSupportDialog = false },
                    containerColor = SurfaceDark,
                    shape = RoundedCornerShape(16.dp),
                    title = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            VelocityVLogo(size = 28.dp)
                            Spacer(modifier = Modifier.width(10.dp))
                            Text(
                                text = "Velocity Official Support",
                                color = TextPrimary,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    },
                    text = {
                        Column {
                            Text(
                                text = "Join our official community channel for latest proxy nodes, server updates, and fast 24/7 technical assistance.",
                                color = TextSecondary,
                                fontSize = 12.sp,
                                lineHeight = 18.sp
                            )
                            Spacer(modifier = Modifier.height(14.dp))
                            Card(
                                shape = RoundedCornerShape(10.dp),
                                colors = CardDefaults.cardColors(containerColor = SurfaceElevated),
                                border = androidx.compose.foundation.BorderStroke(1.dp, BorderDark)
                            ) {
                                Column(modifier = Modifier.padding(12.dp)) {
                                    Text(
                                        text = "Official Channel:",
                                        color = ElectricCyan,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                    Text(
                                        text = "@VelocityVPN_Official",
                                        color = TextPrimary,
                                        fontSize = 13.sp,
                                        fontFamily = FontFamily.Monospace,
                                        fontWeight = FontWeight.SemiBold
                                    )
                                    Spacer(modifier = Modifier.height(8.dp))
                                    Text(
                                        text = "VIP Sales & Support Desk:",
                                        color = NeonYellow,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                    Text(
                                        text = "@VelocityVPN_Support",
                                        color = TextPrimary,
                                        fontSize = 13.sp,
                                        fontFamily = FontFamily.Monospace,
                                        fontWeight = FontWeight.SemiBold
                                    )
                                }
                            }
                        }
                    },
                    confirmButton = {
                        Button(
                            onClick = {
                                showTelegramSupportDialog = false
                                openTelegram()
                            },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = ElectricCyan,
                                contentColor = PureBlack
                            ),
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(imageVector = Icons.Default.Send, contentDescription = null, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(text = I18n.t("open_telegram"), fontWeight = FontWeight.Bold)
                            }
                        }
                    },
                    dismissButton = {
                        TextButton(onClick = { showTelegramSupportDialog = false }) {
                            Text(text = I18n.t("close"), color = TextSecondary)
                        }
                    }
                )
            }

        }
    }
}
}

// ---------------------------------------------------------------------------
// Velocity Top Branding Header
// ---------------------------------------------------------------------------
@Composable
fun VelocityHeaderBar(
    onToggleLang: () -> Unit,
    onOpenReceipt: () -> Unit,
    onOpenSupport: () -> Unit,
    currentLang: AppLanguage
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .drawBehind {
                // Subtle bottom neon glow line
                drawRect(
                    brush = Brush.verticalGradient(
                        colors = listOf(Color(0xFF0D121F), PureBlack)
                    )
                )
                drawLine(
                    color = ElectricCyan.copy(alpha = 0.22f),
                    start = Offset(0f, size.height),
                    end = Offset(size.width, size.height),
                    strokeWidth = 1.dp.toPx()
                )
            }
            .padding(horizontal = 16.dp, vertical = 10.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Left: Glowing 'V' Emblem + Title "VELOCITY" + "SECURE VPN SERVICES"
            Row(verticalAlignment = Alignment.CenterVertically) {
                VelocityVLogo(size = 38.dp)
                Spacer(modifier = Modifier.width(10.dp))
                Column {
                    Text(
                        text = I18n.t("app_title"),
                        color = ElectricCyan,
                        fontSize = 17.sp,
                        fontWeight = FontWeight.Black,
                        letterSpacing = 2.sp
                    )
                    Text(
                        text = I18n.t("subtitle_tagline"),
                        color = TextSecondary,
                        fontSize = 8.5.sp,
                        fontWeight = FontWeight.Medium,
                        letterSpacing = 1.2.sp
                    )
                }
            }

            // Right: Telegram Support Icon + Activation Button + Language Toggle
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Telegram Support Button
                IconButton(
                    onClick = onOpenSupport,
                    modifier = Modifier.testTag("telegram_support_button")
                ) {
                    Icon(
                        imageVector = Icons.Default.Send,
                        contentDescription = "Telegram Support",
                        tint = ElectricCyan,
                        modifier = Modifier.size(19.dp)
                    )
                }

                // VIP Receipt Button
                IconButton(
                    onClick = onOpenReceipt,
                    modifier = Modifier.testTag("receipt_button")
                ) {
                    Icon(
                        imageVector = Icons.Default.ReceiptLong,
                        contentDescription = "VIP Activation",
                        tint = NeonYellow,
                        modifier = Modifier.size(21.dp)
                    )
                }

                // Language Toggle (EN / FA)
                Surface(
                    color = SurfaceElevated,
                    shape = RoundedCornerShape(8.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, ElectricCyan),
                    modifier = Modifier
                        .testTag("language_toggle_button")
                        .clickable { onToggleLang() }
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 9.dp, vertical = 5.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.Language,
                            contentDescription = null,
                            tint = ElectricCyan,
                            modifier = Modifier.size(13.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = if (currentLang == AppLanguage.EN) "FA" else "EN",
                            color = ElectricCyan,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Velocity Central Glowing Power Button with Neon BoxShadow Glow
// ---------------------------------------------------------------------------
@Composable
fun VelocityGlowingPowerButton(
    vpnState: VpnState,
    onToggle: () -> Unit
) {
    val isConnected = vpnState == VpnState.CONNECTED
    val isConnecting = vpnState == VpnState.CONNECTING || vpnState == VpnState.DISCONNECTING

    val glowColor = when {
        isConnected -> NeonGreen
        isConnecting -> ElectricCyan
        else -> ElectricCyan
    }

    val infiniteTransition = rememberInfiniteTransition(label = "pulse")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 0.96f,
        targetValue = 1.05f,
        animationSpec = infiniteRepeatable(
            animation = tween(1700, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "scale"
    )

    val currentScale = if (isConnected || isConnecting) pulseScale else 1.0f

    Box(
        modifier = Modifier
            .size(230.dp)
            .scale(currentScale)
            .testTag("power_button")
            .clickable(enabled = !isConnecting) { onToggle() },
        contentAlignment = Alignment.Center
    ) {
        // Outer simulated BoxShadow neon halo
        Canvas(modifier = Modifier.size(230.dp)) {
            val centerOffset = Offset(size.width / 2, size.height / 2)
            val glowAlpha = if (isConnected) 0.38f else 0.22f
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(glowColor.copy(alpha = glowAlpha), Color.Transparent),
                    center = centerOffset,
                    radius = size.width * 0.48f
                ),
                radius = size.width * 0.48f
            )
        }

        // Secondary Neon Ring
        Box(
            modifier = Modifier
                .size(175.dp)
                .background(
                    Brush.radialGradient(
                        listOf(glowColor.copy(alpha = if (isConnected) 0.28f else 0.12f), Color.Transparent)
                    ),
                    CircleShape
                )
                .border(2.5.dp, glowColor, CircleShape)
        )

        // Core Button Interior
        Box(
            modifier = Modifier
                .size(136.dp)
                .clip(CircleShape)
                .background(
                    Brush.radialGradient(
                        listOf(SurfaceElevated, PureBlack)
                    )
                )
                .border(1.8.dp, if (isConnected) glowColor else BorderDark, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                if (isConnecting) {
                    CircularProgressIndicator(
                        color = glowColor,
                        strokeWidth = 3.5.dp,
                        modifier = Modifier.size(42.dp)
                    )
                } else {
                    Icon(
                        imageVector = Icons.Default.PowerSettingsNew,
                        contentDescription = "Power",
                        tint = glowColor,
                        modifier = Modifier.size(48.dp)
                    )
                }
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = if (isConnected) I18n.t("tap_to_disconnect") else I18n.t("tap_to_connect"),
                    color = glowColor,
                    fontSize = 9.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.5.sp,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Telemetry Speed Card
// ---------------------------------------------------------------------------
@Composable
fun VelocityTelemetryCard(
    downloadSpeedKb: Double,
    uploadSpeedKb: Double,
    totalDownloadMb: Double,
    totalUploadMb: Double
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .testTag("telemetry_card"),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        border = androidx.compose.foundation.BorderStroke(1.dp, BorderDark)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Download speed column
            Row(
                modifier = Modifier.weight(1f),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(38.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(ElectricCyan.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.ArrowDownward,
                        contentDescription = null,
                        tint = ElectricCyan,
                        modifier = Modifier.size(20.dp)
                    )
                }
                Spacer(modifier = Modifier.width(10.dp))
                Column {
                    Text(
                        text = I18n.t("download_speed"),
                        fontSize = 10.sp,
                        color = TextSecondary
                    )
                    Text(
                        text = if (downloadSpeedKb > 1024) {
                            String.format("%.2f MB/s", downloadSpeedKb / 1024)
                        } else {
                            String.format("%.0f KB/s", downloadSpeedKb)
                        },
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = ElectricCyan,
                        fontFamily = FontFamily.Monospace
                    )
                    Text(
                        text = "${I18n.t("total_down")} ${String.format("%.1f", totalDownloadMb)} MB",
                        fontSize = 9.sp,
                        color = TextMuted
                    )
                }
            }

            Box(
                modifier = Modifier
                    .width(1.dp)
                    .height(40.dp)
                    .background(BorderDark)
            )

            Spacer(modifier = Modifier.width(12.dp))

            // Upload speed column
            Row(
                modifier = Modifier.weight(1f),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(38.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(NeonGreen.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.ArrowUpward,
                        contentDescription = null,
                        tint = NeonGreen,
                        modifier = Modifier.size(20.dp)
                    )
                }
                Spacer(modifier = Modifier.width(10.dp))
                Column {
                    Text(
                        text = I18n.t("upload_speed"),
                        fontSize = 10.sp,
                        color = TextSecondary
                    )
                    Text(
                        text = if (uploadSpeedKb > 1024) {
                            String.format("%.2f MB/s", uploadSpeedKb / 1024)
                        } else {
                            String.format("%.0f KB/s", uploadSpeedKb)
                        },
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = NeonGreen,
                        fontFamily = FontFamily.Monospace
                    )
                    Text(
                        text = "${I18n.t("total_up")} ${String.format("%.1f", totalUploadMb)} MB",
                        fontSize = 9.sp,
                        color = TextMuted
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Latency Signal Bars & Indicators
// ---------------------------------------------------------------------------
@Composable
fun LatencySignalBars(
    signalBars: Int,
    color: Color,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(2.dp),
        verticalAlignment = Alignment.Bottom
    ) {
        val heights = listOf(4.dp, 7.dp, 10.dp, 13.dp)
        heights.forEachIndexed { index, height ->
            val isActive = index < signalBars
            Box(
                modifier = Modifier
                    .width(3.dp)
                    .height(height)
                    .clip(RoundedCornerShape(1.dp))
                    .background(if (isActive) color else TextMuted.copy(alpha = 0.25f))
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Active Node Card
// ---------------------------------------------------------------------------
@Composable
fun VelocityActiveNodeCard(
    server: ServerProfile,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .testTag("active_node_card")
            .clickable { onClick() },
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        border = androidx.compose.foundation.BorderStroke(1.2.dp, ElectricCyan.copy(alpha = 0.45f))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(SurfaceElevated)
                    .border(1.dp, BorderDark, RoundedCornerShape(10.dp)),
                contentAlignment = Alignment.Center
            ) {
                Text(text = server.countryCode, fontSize = 22.sp)
            }
            Spacer(modifier = Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = I18n.t("active_server"),
                        fontSize = 10.sp,
                        color = TextSecondary
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(4.dp))
                            .background(ElectricCyan.copy(alpha = 0.15f))
                            .padding(horizontal = 4.dp, vertical = 1.dp)
                    ) {
                        Text(
                            text = server.protocol.label,
                            fontSize = 9.sp,
                            color = ElectricCyan,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = server.name,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
            // Ping latency chip with signal bars
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .background(server.pingColor.copy(alpha = 0.12f))
                    .border(1.dp, server.pingColor.copy(alpha = 0.7f), RoundedCornerShape(8.dp))
                    .padding(horizontal = 8.dp, vertical = 5.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(5.dp)
                ) {
                    if (server.isTesting) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(10.dp),
                            color = ElectricCyan,
                            strokeWidth = 1.5.dp
                        )
                    } else {
                        LatencySignalBars(signalBars = server.signalBars, color = server.pingColor)
                    }
                    Text(
                        text = server.pingDisplay,
                        color = server.pingColor,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            Spacer(modifier = Modifier.width(8.dp))
            Icon(
                imageVector = Icons.Default.ArrowForwardIos,
                contentDescription = null,
                tint = TextSecondary,
                modifier = Modifier.size(14.dp)
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Server Selection Bottom Sheet Content (Real-time Latency Engine)
// ---------------------------------------------------------------------------
@Composable
fun VelocityServerBottomSheetContent(
    servers: List<ServerProfile>,
    selectedServer: ServerProfile,
    isPingAllRunning: Boolean,
    isLivePingEnabled: Boolean,
    onToggleLivePing: (Boolean) -> Unit,
    onSelectServer: (ServerProfile) -> Unit,
    onAutoSelectBest: () -> Unit,
    onPingAll: () -> Unit,
    onPingSingle: (ServerProfile) -> Unit,
    onOpenImport: () -> Unit
) {
    var searchQuery by remember { mutableStateOf("") }
    var sortOption by remember { mutableStateOf(LatencySortOption.FASTEST_FIRST) }
    var filterOption by remember { mutableStateOf(LatencyFilterOption.ALL) }

    val filteredServers = remember(servers, sortOption, filterOption, searchQuery) {
        LatencyChecker.filterAndSort(servers, sortOption, filterOption, searchQuery)
    }

    val bestServer = remember(servers) {
        LatencyChecker.findBestServer(servers)
    }

    val validPings = remember(servers) {
        servers.mapNotNull { it.pingMs }.filter { it > 0 }
    }
    val avgPing = remember(validPings) {
        if (validPings.isNotEmpty()) validPings.average().toInt() else null
    }
    val onlineCount = remember(servers) {
        servers.count { (it.pingMs ?: -1) > 0 }
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(620.dp)
            .background(SurfaceDark)
            .padding(top = 10.dp)
    ) {
        // Drag indicator
        Box(
            modifier = Modifier
                .align(Alignment.CenterHorizontally)
                .size(width = 48.dp, height = 4.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(TextMuted)
        )

        Spacer(modifier = Modifier.height(10.dp))

        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = I18n.t("select_server"),
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold,
                    color = ElectricCyan
                )
                Text(
                    text = "$onlineCount/${servers.size} ${I18n.t("servers_count")}",
                    fontSize = 11.5.sp,
                    color = TextSecondary
                )
            }
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                // Auto Select Fastest button
                OutlinedButton(
                    onClick = onAutoSelectBest,
                    colors = ButtonDefaults.outlinedButtonColors(
                        containerColor = PureBlack,
                        contentColor = NeonGreen
                    ),
                    border = androidx.compose.foundation.BorderStroke(1.dp, NeonGreen.copy(alpha = 0.8f)),
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Bolt,
                        contentDescription = null,
                        modifier = Modifier.size(15.dp),
                        tint = NeonGreen
                    )
                    Spacer(modifier = Modifier.width(3.dp))
                    Text(text = I18n.t("auto_select_fastest"), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }

                // Ping All button
                Button(
                    onClick = onPingAll,
                    enabled = !isPingAllRunning,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = ElectricCyan,
                        contentColor = PureBlack
                    ),
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 10.dp, vertical = 4.dp)
                ) {
                    if (isPingAllRunning) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(14.dp),
                            color = PureBlack,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(imageVector = Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(15.dp))
                    }
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = if (isPingAllRunning) I18n.t("ping_testing") else I18n.t("ping_all"),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                IconButton(
                    onClick = onOpenImport,
                    modifier = Modifier.size(36.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.AddLink,
                        contentDescription = "Import",
                        tint = ElectricCyan,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }
        }

        // Live Monitoring & Summary Strip
        Surface(
            color = SurfaceElevated,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 6.dp),
            shape = RoundedCornerShape(10.dp),
            border = androidx.compose.foundation.BorderStroke(1.dp, BorderDark)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 12.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                // Live Monitor Switch
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(if (isLivePingEnabled) NeonGreen else TextMuted)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = I18n.t("live_ping_monitor"),
                        fontSize = 11.sp,
                        color = if (isLivePingEnabled) NeonGreen else TextSecondary,
                        fontWeight = FontWeight.SemiBold
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Switch(
                        checked = isLivePingEnabled,
                        onCheckedChange = onToggleLivePing,
                        modifier = Modifier.height(24.dp),
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = PureBlack,
                            checkedTrackColor = NeonGreen,
                            uncheckedThumbColor = TextMuted,
                            uncheckedTrackColor = PureBlack
                        )
                    )
                }

                // Average & Fastest Summary
                Row(verticalAlignment = Alignment.CenterVertically) {
                    if (avgPing != null) {
                        Text(
                            text = "${I18n.t("stat_avg_latency")}: ",
                            fontSize = 10.5.sp,
                            color = TextMuted
                        )
                        Text(
                            text = "${avgPing}ms",
                            fontSize = 11.sp,
                            color = ElectricCyan,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    if (bestServer != null) {
                        Spacer(modifier = Modifier.width(8.dp))
                        Surface(
                            color = NeonGreen.copy(alpha = 0.12f),
                            shape = RoundedCornerShape(4.dp),
                            modifier = Modifier.clickable { onSelectServer(bestServer) }
                        ) {
                            Text(
                                text = "⚡ ${bestServer.countryCode} ${bestServer.pingDisplay}",
                                color = NeonGreen,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 5.dp, vertical = 2.dp)
                            )
                        }
                    }
                }
            }
        }

        // Search Bar
        OutlinedTextField(
            value = searchQuery,
            onValueChange = { searchQuery = it },
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 4.dp),
            placeholder = { Text(I18n.t("search_server_hint"), fontSize = 12.sp, color = TextMuted) },
            leadingIcon = {
                Icon(Icons.Default.Search, contentDescription = null, tint = TextSecondary, modifier = Modifier.size(16.dp))
            },
            trailingIcon = {
                if (searchQuery.isNotEmpty()) {
                    IconButton(onClick = { searchQuery = "" }, modifier = Modifier.size(24.dp)) {
                        Icon(Icons.Default.Close, contentDescription = "Clear", tint = TextSecondary, modifier = Modifier.size(14.dp))
                    }
                }
            },
            singleLine = true,
            shape = RoundedCornerShape(10.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedContainerColor = PureBlack,
                unfocusedContainerColor = PureBlack,
                focusedBorderColor = ElectricCyan,
                unfocusedBorderColor = BorderDark,
                focusedTextColor = TextPrimary,
                unfocusedTextColor = TextPrimary
            )
        )

        // Filter and Sort Chips Scroll Row
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(androidx.compose.foundation.rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 2.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Sort: Fastest First
            FilterChip(
                selected = sortOption == LatencySortOption.FASTEST_FIRST,
                onClick = { sortOption = LatencySortOption.FASTEST_FIRST },
                label = { Text("⚡ ${I18n.t("sort_latency")}", fontSize = 11.sp) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = ElectricCyan.copy(alpha = 0.2f),
                    selectedLabelColor = ElectricCyan,
                    containerColor = SurfaceElevated,
                    labelColor = TextSecondary
                ),
                border = FilterChipDefaults.filterChipBorder(
                    enabled = true,
                    selected = sortOption == LatencySortOption.FASTEST_FIRST,
                    borderColor = BorderDark,
                    selectedBorderColor = ElectricCyan
                )
            )

            // Sort: Country
            FilterChip(
                selected = sortOption == LatencySortOption.COUNTRY_NAME,
                onClick = { sortOption = LatencySortOption.COUNTRY_NAME },
                label = { Text("🌐 ${I18n.t("sort_country")}", fontSize = 11.sp) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = ElectricCyan.copy(alpha = 0.2f),
                    selectedLabelColor = ElectricCyan,
                    containerColor = SurfaceElevated,
                    labelColor = TextSecondary
                ),
                border = FilterChipDefaults.filterChipBorder(
                    enabled = true,
                    selected = sortOption == LatencySortOption.COUNTRY_NAME,
                    borderColor = BorderDark,
                    selectedBorderColor = ElectricCyan
                )
            )

            // Sort: Protocol
            FilterChip(
                selected = sortOption == LatencySortOption.PROTOCOL,
                onClick = { sortOption = LatencySortOption.PROTOCOL },
                label = { Text("⚙️ ${I18n.t("sort_protocol")}", fontSize = 11.sp) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = ElectricCyan.copy(alpha = 0.2f),
                    selectedLabelColor = ElectricCyan,
                    containerColor = SurfaceElevated,
                    labelColor = TextSecondary
                ),
                border = FilterChipDefaults.filterChipBorder(
                    enabled = true,
                    selected = sortOption == LatencySortOption.PROTOCOL,
                    borderColor = BorderDark,
                    selectedBorderColor = ElectricCyan
                )
            )

            // Filter: Online Only
            FilterChip(
                selected = filterOption == LatencyFilterOption.ONLINE_ONLY,
                onClick = {
                    filterOption = if (filterOption == LatencyFilterOption.ONLINE_ONLY) LatencyFilterOption.ALL else LatencyFilterOption.ONLINE_ONLY
                },
                label = { Text(I18n.t("filter_online"), fontSize = 11.sp) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = NeonGreen.copy(alpha = 0.2f),
                    selectedLabelColor = NeonGreen,
                    containerColor = SurfaceElevated,
                    labelColor = TextSecondary
                ),
                border = FilterChipDefaults.filterChipBorder(
                    enabled = true,
                    selected = filterOption == LatencyFilterOption.ONLINE_ONLY,
                    borderColor = BorderDark,
                    selectedBorderColor = NeonGreen
                )
            )

            // Filter: Ultra Fast (<150ms)
            FilterChip(
                selected = filterOption == LatencyFilterOption.ULTRA_FAST,
                onClick = {
                    filterOption = if (filterOption == LatencyFilterOption.ULTRA_FAST) LatencyFilterOption.ALL else LatencyFilterOption.ULTRA_FAST
                },
                label = { Text(I18n.t("filter_ultra_fast"), fontSize = 11.sp) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = NeonGreen.copy(alpha = 0.2f),
                    selectedLabelColor = NeonGreen,
                    containerColor = SurfaceElevated,
                    labelColor = TextSecondary
                ),
                border = FilterChipDefaults.filterChipBorder(
                    enabled = true,
                    selected = filterOption == LatencyFilterOption.ULTRA_FAST,
                    borderColor = BorderDark,
                    selectedBorderColor = NeonGreen
                )
            )
        }

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 4.dp)
                .height(1.dp)
                .background(BorderDark)
        )

        // Server List
        LazyColumn(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .padding(horizontal = 16.dp, vertical = 6.dp)
        ) {
            items(filteredServers, key = { it.id }) { server ->
                val isSelected = server.id == selectedServer.id
                val isFastestInList = bestServer?.id == server.id && (server.pingMs ?: -1) > 0

                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 8.dp)
                        .clickable { onSelectServer(server) },
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = if (isSelected) ElectricCyan.copy(alpha = 0.08f) else SurfaceElevated
                    ),
                    border = androidx.compose.foundation.BorderStroke(
                        if (isSelected) 1.5.dp else if (isFastestInList) 1.dp else 1.dp,
                        if (isSelected) ElectricCyan else if (isFastestInList) NeonGreen.copy(alpha = 0.5f) else BorderDark
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 12.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Country Flag
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(PureBlack)
                                .border(1.dp, if (isSelected) ElectricCyan else BorderDark, RoundedCornerShape(10.dp)),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(text = server.countryCode, fontSize = 20.sp)
                        }

                        Spacer(modifier = Modifier.width(12.dp))

                        // Info Column
                        Column(modifier = Modifier.weight(1f)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(
                                    text = server.name,
                                    fontSize = 13.5.sp,
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                    color = if (isSelected) ElectricCyan else TextPrimary,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                                if (isFastestInList) {
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Surface(
                                        color = NeonGreen.copy(alpha = 0.15f),
                                        shape = RoundedCornerShape(4.dp)
                                    ) {
                                        Text(
                                            text = "FASTEST",
                                            color = NeonGreen,
                                            fontSize = 8.sp,
                                            fontWeight = FontWeight.Bold,
                                            modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.dp)
                                        )
                                    }
                                }
                            }

                            Spacer(modifier = Modifier.height(3.dp))

                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(4.dp))
                                        .background(PureBlack)
                                        .border(1.dp, BorderDark, RoundedCornerShape(4.dp))
                                        .padding(horizontal = 4.dp, vertical = 1.dp)
                                ) {
                                    Text(
                                        text = server.protocol.label,
                                        fontSize = 9.sp,
                                        color = DeepCyan,
                                        fontWeight = FontWeight.Bold
                                    )
                                }
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "${server.host}:${server.port}",
                                    fontSize = 9.5.sp,
                                    color = TextSecondary,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                            }
                        }

                        Spacer(modifier = Modifier.width(8.dp))

                        // Interactive Latency Badge (Tap to re-test individual server)
                        Surface(
                            onClick = { onPingSingle(server) },
                            color = server.pingColor.copy(alpha = 0.12f),
                            shape = RoundedCornerShape(8.dp),
                            border = androidx.compose.foundation.BorderStroke(1.dp, server.pingColor.copy(alpha = 0.7f))
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 5.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(5.dp)
                            ) {
                                if (server.isTesting) {
                                    CircularProgressIndicator(
                                        modifier = Modifier.size(11.dp),
                                        color = server.pingColor,
                                        strokeWidth = 1.5.dp
                                    )
                                } else {
                                    LatencySignalBars(
                                        signalBars = server.signalBars,
                                        color = server.pingColor
                                    )
                                }
                                Text(
                                    text = server.pingDisplay,
                                    color = server.pingColor,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Routing Mode Bottom Sheet Content
// ---------------------------------------------------------------------------
@Composable
fun VelocityRoutingModeSheetContent(
    currentMode: RoutingMode,
    onSelectMode: (RoutingMode) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(SurfaceDark)
            .padding(20.dp)
    ) {
        Text(
            text = I18n.t("routing_mode"),
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            color = ElectricCyan
        )
        Spacer(modifier = Modifier.height(16.dp))

        val modes = listOf(
            Triple(RoutingMode.RULE, I18n.t("mode_rule"), "Velocity smart routing: auto-bypass LAN, domestic banking, and adblocking"),
            Triple(RoutingMode.BYPASS_LAN, I18n.t("mode_bypass_lan"), "Direct connection for domestic IP/domains (.ir / banking apps)"),
            Triple(RoutingMode.GLOBAL, I18n.t("mode_global"), "Tunnel all device traffic via Velocity encrypted network"),
            Triple(RoutingMode.DIRECT, I18n.t("mode_direct"), "Bypass proxy engine completely")
        )

        modes.forEach { (mode, title, desc) ->
            val isSelected = currentMode == mode
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 8.dp)
                    .clickable { onSelectMode(mode) },
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(
                    containerColor = if (isSelected) ElectricCyan.copy(alpha = 0.1f) else SurfaceElevated
                ),
                border = androidx.compose.foundation.BorderStroke(
                    1.dp,
                    if (isSelected) ElectricCyan else BorderDark
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(14.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = when (mode) {
                            RoutingMode.RULE -> Icons.Default.AltRoute
                            RoutingMode.BYPASS_LAN -> Icons.Default.Security
                            RoutingMode.GLOBAL -> Icons.Default.Public
                            RoutingMode.DIRECT -> Icons.Default.SyncDisabled
                        },
                        contentDescription = null,
                        tint = if (isSelected) ElectricCyan else TextSecondary
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = title,
                            color = if (isSelected) ElectricCyan else TextPrimary,
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                        Text(
                            text = desc,
                            color = TextSecondary,
                            fontSize = 11.sp
                        )
                    }
                    if (isSelected) {
                        Icon(
                            imageVector = Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = ElectricCyan,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Import Config Dialog
// ---------------------------------------------------------------------------
@Composable
fun VelocityImportConfigDialog(
    onDismiss: () -> Unit,
    onImport: (String) -> Unit
) {
    var urlText by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = SurfaceDark,
        shape = RoundedCornerShape(16.dp),
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Default.AddLink, contentDescription = null, tint = ElectricCyan)
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = I18n.t("import_config"),
                    color = TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        },
        text = {
            Column {
                Text(
                    text = I18n.t("import_prompt"),
                    color = TextSecondary,
                    fontSize = 12.sp
                )
                Spacer(modifier = Modifier.height(12.dp))
                OutlinedTextField(
                    value = urlText,
                    onValueChange = { urlText = it },
                    placeholder = {
                        Text(
                            text = "vless://..., vmess://..., trojan://..., hysteria2://...",
                            color = TextMuted,
                            fontSize = 11.sp
                        )
                    },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = ElectricCyan,
                        unfocusedBorderColor = BorderDark,
                        focusedTextColor = TextPrimary,
                        unfocusedTextColor = TextPrimary,
                        focusedContainerColor = PureBlack,
                        unfocusedContainerColor = PureBlack
                    ),
                    modifier = Modifier.fillMaxWidth(),
                    maxLines = 4
                )
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    if (urlText.isNotBlank()) onImport(urlText.trim())
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = ElectricCyan,
                    contentColor = PureBlack
                ),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text(text = I18n.t("import_btn"), fontWeight = FontWeight.Bold)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(text = I18n.t("cancel"), color = TextSecondary)
            }
        }
    )
}

// ---------------------------------------------------------------------------
// Velocity VIP Activation Section Content
// ---------------------------------------------------------------------------
@Composable
fun VelocityVipActivationContent(
    onClose: () -> Unit,
    onOpenTelegram: () -> Unit
) {
    var selectedPlanIndex by remember { mutableIntStateOf(0) }
    var txId by remember { mutableStateOf("") }
    var imageAttached by remember { mutableStateOf(false) }
    var isSubmitting by remember { mutableStateOf(false) }
    var showSuccessDialog by remember { mutableStateOf(false) }

    val coroutineScope = rememberCoroutineScope()

    val plans = listOf(
        Triple("Velocity VIP 30-Day", "Unlimited Ultra High-Speed | All Global Nodes", "$4.99 / 290,000 T"),
        Triple("Velocity Turbo 90-Day", "600 GB VIP Bandwidth | Gaming Low-Ping Pool", "$11.99 / 790,000 T"),
        Triple("Velocity Enterprise Annual", "Unlimited 4K Multi-Device | Dedicated IP", "$39.99 / 2,500,000 T")
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(PureBlack)
            .padding(16.dp)
            .verticalScroll(rememberScrollState())
    ) {
        // Top Header
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                VelocityVLogo(size = 30.dp)
                Spacer(modifier = Modifier.width(10.dp))
                Column {
                    Text(
                        text = I18n.t("receipt_title"),
                        color = TextPrimary,
                        fontSize = 17.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Velocity Secure Network Services",
                        color = ElectricCyan,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
            IconButton(onClick = onClose) {
                Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = ElectricCyan)
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // Direct Telegram Purchase Card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { onOpenTelegram() },
            shape = RoundedCornerShape(14.dp),
            colors = CardDefaults.cardColors(containerColor = SurfaceDark),
            border = androidx.compose.foundation.BorderStroke(1.2.dp, ElectricCyan)
        ) {
            Row(
                modifier = Modifier.padding(14.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(42.dp)
                        .clip(CircleShape)
                        .background(ElectricCyan.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Send,
                        contentDescription = null,
                        tint = ElectricCyan,
                        modifier = Modifier.size(22.dp)
                    )
                }
                Spacer(modifier = Modifier.width(12.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Instant Purchase via Telegram",
                        color = ElectricCyan,
                        fontWeight = FontWeight.Bold,
                        fontSize = 13.sp
                    )
                    Text(
                        text = I18n.t("telegram_support_msg"),
                        color = TextSecondary,
                        fontSize = 11.sp
                    )
                }
                Icon(
                    imageVector = Icons.Default.ArrowOutward,
                    contentDescription = null,
                    tint = ElectricCyan,
                    modifier = Modifier.size(18.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Plans selection
        Text(
            text = I18n.t("plan_select"),
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold,
            color = ElectricCyan
        )
        Spacer(modifier = Modifier.height(10.dp))

        plans.forEachIndexed { index, (title, quota, price) ->
            val isSelected = index == selectedPlanIndex
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 10.dp)
                    .clickable { selectedPlanIndex = index },
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(
                    containerColor = if (isSelected) ElectricCyan.copy(alpha = 0.08f) else SurfaceDark
                ),
                border = androidx.compose.foundation.BorderStroke(
                    if (isSelected) 1.5.dp else 1.dp,
                    if (isSelected) ElectricCyan else BorderDark
                )
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    RadioButton(
                        selected = isSelected,
                        onClick = { selectedPlanIndex = index },
                        colors = RadioButtonDefaults.colors(selectedColor = ElectricCyan)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = title,
                            fontWeight = FontWeight.Bold,
                            color = if (isSelected) ElectricCyan else TextPrimary,
                            fontSize = 14.sp
                        )
                        Text(
                            text = quota,
                            color = TextSecondary,
                            fontSize = 11.sp
                        )
                    }
                    Text(
                        text = price,
                        color = NeonGreen,
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Gateways Card
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = SurfaceDark),
            border = androidx.compose.foundation.BorderStroke(1.dp, BorderDark)
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.CurrencyExchange,
                        contentDescription = null,
                        tint = NeonYellow,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "Official Velocity Payment Gateways:",
                        color = NeonYellow,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "• USDT (TRC-20): TQk8mVELOCITY983xLp24VpNd78Qz\n• TON / Telegram Wallet: EQBvVELOCITY...4421\n• Direct Card-to-Card (via @VelocityVPN_Support)",
                    color = TextSecondary,
                    fontSize = 11.sp,
                    lineHeight = 16.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Transaction ID
        Text(
            text = I18n.t("tx_id"),
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold,
            color = ElectricCyan
        )
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(
            value = txId,
            onValueChange = { txId = it },
            placeholder = { Text(I18n.t("tx_placeholder"), color = TextMuted, fontSize = 12.sp) },
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = ElectricCyan,
                unfocusedBorderColor = BorderDark,
                focusedTextColor = TextPrimary,
                unfocusedTextColor = TextPrimary,
                focusedContainerColor = SurfaceDark,
                unfocusedContainerColor = SurfaceDark
            ),
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(14.dp))

        // Simulated Image Upload Card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { imageAttached = true },
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(
                containerColor = if (imageAttached) NeonGreen.copy(alpha = 0.08f) else SurfaceDark
            ),
            border = androidx.compose.foundation.BorderStroke(
                1.5.dp,
                if (imageAttached) NeonGreen else BorderDark
            )
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 22.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Icon(
                    imageVector = if (imageAttached) Icons.Default.CheckCircle else Icons.Default.UploadFile,
                    contentDescription = null,
                    tint = if (imageAttached) NeonGreen else ElectricCyan,
                    modifier = Modifier.size(36.dp)
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = if (imageAttached) I18n.t("receipt_attached") else I18n.t("upload_image_btn"),
                    color = if (imageAttached) NeonGreen else TextPrimary,
                    fontWeight = FontWeight.Bold,
                    fontSize = 13.sp
                )
                if (imageAttached) {
                    Text(
                        text = "velocity_receipt_2026.png (1.4 MB)",
                        color = TextSecondary,
                        fontSize = 10.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(22.dp))

        // Submit Button
        Button(
            onClick = {
                if (txId.isNotBlank() || imageAttached) {
                    isSubmitting = true
                    coroutineScope.launch {
                        delay(1200)
                        isSubmitting = false
                        showSuccessDialog = true
                    }
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = ElectricCyan,
                contentColor = PureBlack
            ),
            shape = RoundedCornerShape(12.dp),
            enabled = !isSubmitting
        ) {
            if (isSubmitting) {
                CircularProgressIndicator(
                    color = PureBlack,
                    strokeWidth = 2.dp,
                    modifier = Modifier.size(20.dp)
                )
            } else {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Send, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(text = I18n.t("submit_receipt"), fontWeight = FontWeight.Bold, fontSize = 15.sp)
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))
    }

    if (showSuccessDialog) {
        AlertDialog(
            onDismissRequest = {
                showSuccessDialog = false
                onClose()
            },
            containerColor = SurfaceDark,
            title = {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null, tint = NeonGreen)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(text = "Activation Request Queued", color = NeonGreen, fontWeight = FontWeight.Bold)
                }
            },
            text = {
                Text(
                    text = I18n.t("receipt_success"),
                    color = TextPrimary,
                    fontSize = 13.sp
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        showSuccessDialog = false
                        onClose()
                    },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = NeonGreen,
                        contentColor = PureBlack
                    )
                ) {
                    Text(text = I18n.t("close"), fontWeight = FontWeight.Bold)
                }
            }
        )
    }
}

// Kept for Roborazzi screenshot test compatibility
@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(text = "Hello $name!", modifier = modifier)
}
