package com.example

import android.widget.Toast
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.CloudDownload
import androidx.compose.material.icons.filled.ContentPaste
import androidx.compose.material.icons.filled.DeleteOutline
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material.icons.filled.FilterList
import androidx.compose.material.icons.filled.Key
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.Layers
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.SelectAll
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.WifiTethering
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.TabRowDefaults
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.BorderDark
import com.example.ui.theme.ElectricCyan
import com.example.ui.theme.NeonGreen
import com.example.ui.theme.NeonPink
import com.example.ui.theme.NeonYellow
import com.example.ui.theme.PureBlack
import com.example.ui.theme.SurfaceDark
import com.example.ui.theme.SurfaceElevated
import com.example.ui.theme.TextMuted
import com.example.ui.theme.TextPrimary
import com.example.ui.theme.TextSecondary
import kotlinx.coroutines.launch

@Composable
fun SubscriptionScreen(
    onBack: () -> Unit,
    onImportServers: (servers: List<ServerProfile>, replaceExisting: Boolean, autoTestLatency: Boolean) -> Unit
) {
    val context = LocalContext.current
    val clipboardManager = LocalClipboardManager.current
    val coroutineScope = rememberCoroutineScope()

    var selectedTab by remember { mutableIntStateOf(0) }
    var subscriptionUrl by remember { mutableStateOf("") }
    var rawTextContent by remember { mutableStateOf("") }
    var isFetching by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var successInfo by remember { mutableStateOf<String?>(null) }

    val parsedNodes = remember { mutableStateListOf<ServerProfile>() }
    val selectedNodeIds = remember { mutableStateListOf<String>() }
    var subscriptionMeta by remember { mutableStateOf<SubscriptionMeta?>(null) }

    var replaceExistingList by remember { mutableStateOf(true) }
    var autoTestLatency by remember { mutableStateOf(true) }
    var searchQuery by remember { mutableStateOf("") }
    var protocolFilter by remember { mutableStateOf("ALL") }

    fun processParseResult(result: SubscriptionParseResult) {
        if (result.errorMessage != null && result.servers.isEmpty()) {
            errorMessage = result.errorMessage
            successInfo = null
        } else if (result.servers.isEmpty()) {
            errorMessage = I18n.t("parsing_error_none")
            successInfo = null
        } else {
            errorMessage = null
            parsedNodes.clear()
            parsedNodes.addAll(result.servers)
            selectedNodeIds.clear()
            selectedNodeIds.addAll(result.servers.map { it.id })
            subscriptionMeta = result.subInfo
            successInfo = "${result.servers.size} ${I18n.t("nodes_found")}"
            Toast.makeText(context, "${result.servers.size} ${I18n.t("sub_success_toast")}", Toast.LENGTH_SHORT).show()
        }
    }

    fun triggerFetchUrl() {
        val url = subscriptionUrl.trim()
        if (url.isEmpty()) {
            errorMessage = I18n.t("parsing_error_empty")
            return
        }

        isFetching = true
        errorMessage = null
        successInfo = null

        coroutineScope.launch {
            try {
                val result = SubscriptionParser.fetchSubscription(url)
                isFetching = false
                processParseResult(result)
            } catch (e: Exception) {
                isFetching = false
                errorMessage = e.localizedMessage ?: "Failed to fetch subscription"
            }
        }
    }

    fun triggerParseRaw() {
        val raw = rawTextContent.trim()
        if (raw.isEmpty()) {
            errorMessage = I18n.t("parsing_error_empty")
            return
        }
        val result = SubscriptionParser.parseContent(raw)
        processParseResult(result)
    }

    Scaffold(
        containerColor = PureBlack,
        topBar = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(SurfaceDark)
                    .statusBarsPadding()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 8.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(
                        onClick = onBack,
                        modifier = Modifier.testTag("subscription_back_button")
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back",
                            tint = ElectricCyan
                        )
                    }

                    Spacer(modifier = Modifier.width(4.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = I18n.t("sub_screen_title"),
                                color = TextPrimary,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 0.5.sp
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Surface(
                                color = ElectricCyan.copy(alpha = 0.15f),
                                shape = RoundedCornerShape(4.dp)
                            ) {
                                Text(
                                    text = "SUBSCRIBE",
                                    color = ElectricCyan,
                                    fontSize = 9.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                                )
                            }
                        }
                        Text(
                            text = I18n.t("sub_screen_subtitle"),
                            color = TextSecondary,
                            fontSize = 11.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }

                    if (parsedNodes.isNotEmpty()) {
                        IconButton(
                            onClick = {
                                parsedNodes.clear()
                                selectedNodeIds.clear()
                                subscriptionMeta = null
                                successInfo = null
                            }
                        ) {
                            Icon(
                                imageVector = Icons.Default.DeleteOutline,
                                contentDescription = "Clear",
                                tint = TextMuted
                            )
                        }
                    }
                }

                // Tabs: URL vs Raw/Base64 vs Featured Presets
                TabRow(
                    selectedTabIndex = selectedTab,
                    containerColor = SurfaceDark,
                    contentColor = ElectricCyan,
                    indicator = { tabPositions ->
                        TabRowDefaults.SecondaryIndicator(
                            Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                            color = ElectricCyan,
                            height = 2.5.dp
                        )
                    }
                ) {
                    Tab(
                        selected = selectedTab == 0,
                        onClick = { selectedTab = 0 },
                        text = {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Link, contentDescription = null, modifier = Modifier.size(14.dp))
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(I18n.t("tab_sub_url"), fontSize = 11.5.sp, fontWeight = FontWeight.SemiBold)
                            }
                        }
                    )
                    Tab(
                        selected = selectedTab == 1,
                        onClick = { selectedTab = 1 },
                        text = {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Key, contentDescription = null, modifier = Modifier.size(14.dp))
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(I18n.t("tab_raw_base64"), fontSize = 11.5.sp, fontWeight = FontWeight.SemiBold)
                            }
                        }
                    )
                    Tab(
                        selected = selectedTab == 2,
                        onClick = { selectedTab = 2 },
                        text = {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Bolt, contentDescription = null, modifier = Modifier.size(14.dp))
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(I18n.t("tab_presets"), fontSize = 11.5.sp, fontWeight = FontWeight.SemiBold)
                            }
                        }
                    )
                }
            }
        },
        bottomBar = {
            if (parsedNodes.isNotEmpty()) {
                Surface(
                    color = SurfaceDark,
                    border = androidx.compose.foundation.BorderStroke(1.dp, BorderDark),
                    modifier = Modifier
                        .fillMaxWidth()
                        .navigationBarsPadding()
                ) {
                    Column(
                        modifier = Modifier.padding(14.dp)
                    ) {
                        // Options Row
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier.clickable { replaceExistingList = !replaceExistingList }
                            ) {
                                Switch(
                                    checked = replaceExistingList,
                                    onCheckedChange = { replaceExistingList = it },
                                    colors = SwitchDefaults.colors(
                                        checkedThumbColor = PureBlack,
                                        checkedTrackColor = ElectricCyan,
                                        uncheckedThumbColor = TextMuted,
                                        uncheckedTrackColor = SurfaceElevated
                                    ),
                                    modifier = Modifier.padding(end = 6.dp)
                                )
                                Text(
                                    text = if (replaceExistingList) I18n.t("opt_replace") else I18n.t("opt_append"),
                                    color = TextPrimary,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            }

                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier.clickable { autoTestLatency = !autoTestLatency }
                            ) {
                                Switch(
                                    checked = autoTestLatency,
                                    onCheckedChange = { autoTestLatency = it },
                                    colors = SwitchDefaults.colors(
                                        checkedThumbColor = PureBlack,
                                        checkedTrackColor = NeonGreen,
                                        uncheckedThumbColor = TextMuted,
                                        uncheckedTrackColor = SurfaceElevated
                                    ),
                                    modifier = Modifier.padding(end = 6.dp)
                                )
                                Text(
                                    text = I18n.t("opt_auto_test"),
                                    color = TextSecondary,
                                    fontSize = 11.sp
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(10.dp))

                        // Big Apply Action Button
                        val selectedNodes = parsedNodes.filter { selectedNodeIds.contains(it.id) }
                        Button(
                            onClick = {
                                if (selectedNodes.isNotEmpty()) {
                                    onImportServers(selectedNodes, replaceExistingList, autoTestLatency)
                                } else {
                                    Toast.makeText(context, "Select at least 1 server to import", Toast.LENGTH_SHORT).show()
                                }
                            },
                            enabled = selectedNodes.isNotEmpty(),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = ElectricCyan,
                                contentColor = PureBlack,
                                disabledContainerColor = SurfaceElevated,
                                disabledContentColor = TextMuted
                            ),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(48.dp)
                                .testTag("btn_apply_subscription_nodes")
                        ) {
                            Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "${I18n.t("btn_import_apply")} (${selectedNodes.size})",
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 0.5.sp
                            )
                        }
                    }
                }
            }
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = 14.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // TAB 0: Subscription URL Input
            if (selectedTab == 0) {
                item {
                    Card(
                        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                        shape = RoundedCornerShape(14.dp),
                        border = androidx.compose.foundation.BorderStroke(1.dp, BorderDark),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(modifier = Modifier.padding(14.dp)) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = I18n.t("sub_url_label"),
                                    color = TextPrimary,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold
                                )

                                TextButton(
                                    onClick = {
                                        val clipText = clipboardManager.getText()?.text
                                        if (!clipText.isNullOrBlank()) {
                                            subscriptionUrl = clipText
                                            Toast.makeText(context, "Pasted from clipboard", Toast.LENGTH_SHORT).show()
                                        }
                                    }
                                ) {
                                    Icon(Icons.Default.ContentPaste, contentDescription = null, tint = ElectricCyan, modifier = Modifier.size(14.dp))
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text(I18n.t("btn_paste_clipboard"), color = ElectricCyan, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                }
                            }

                            Spacer(modifier = Modifier.height(6.dp))

                            OutlinedTextField(
                                value = subscriptionUrl,
                                onValueChange = { subscriptionUrl = it },
                                placeholder = {
                                    Text(
                                        text = I18n.t("sub_url_hint"),
                                        color = TextMuted,
                                        fontSize = 11.sp
                                    )
                                },
                                textStyle = androidx.compose.ui.text.TextStyle(
                                    color = TextPrimary,
                                    fontSize = 12.sp,
                                    fontFamily = FontFamily.Monospace
                                ),
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = ElectricCyan,
                                    unfocusedBorderColor = BorderDark,
                                    focusedContainerColor = PureBlack,
                                    unfocusedContainerColor = PureBlack
                                ),
                                shape = RoundedCornerShape(10.dp),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .testTag("subscription_url_input"),
                                singleLine = false,
                                maxLines = 3
                            )

                            Spacer(modifier = Modifier.height(12.dp))

                            Button(
                                onClick = { triggerFetchUrl() },
                                enabled = !isFetching && subscriptionUrl.isNotBlank(),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = ElectricCyan,
                                    contentColor = PureBlack
                                ),
                                shape = RoundedCornerShape(10.dp),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(44.dp)
                                    .testTag("fetch_subscription_button")
                            ) {
                                if (isFetching) {
                                    CircularProgressIndicator(
                                        color = PureBlack,
                                        modifier = Modifier.size(16.dp),
                                        strokeWidth = 2.dp
                                    )
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text(I18n.t("fetching_sub"), fontSize = 12.sp, fontWeight = FontWeight.Bold)
                                } else {
                                    Icon(Icons.Default.CloudDownload, contentDescription = null, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text(I18n.t("btn_fetch_parse"), fontSize = 12.5.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    }
                }
            }

            // TAB 1: Raw / Base64 Multiline Input
            if (selectedTab == 1) {
                item {
                    Card(
                        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                        shape = RoundedCornerShape(14.dp),
                        border = androidx.compose.foundation.BorderStroke(1.dp, BorderDark),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(modifier = Modifier.padding(14.dp)) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = I18n.t("sub_raw_label"),
                                    color = TextPrimary,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold
                                )

                                TextButton(
                                    onClick = {
                                        val clipText = clipboardManager.getText()?.text
                                        if (!clipText.isNullOrBlank()) {
                                            rawTextContent = clipText
                                            Toast.makeText(context, "Pasted from clipboard", Toast.LENGTH_SHORT).show()
                                        }
                                    }
                                ) {
                                    Icon(Icons.Default.ContentPaste, contentDescription = null, tint = ElectricCyan, modifier = Modifier.size(14.dp))
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text(I18n.t("btn_paste_clipboard"), color = ElectricCyan, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                }
                            }

                            Spacer(modifier = Modifier.height(6.dp))

                            OutlinedTextField(
                                value = rawTextContent,
                                onValueChange = { rawTextContent = it },
                                placeholder = {
                                    Text(
                                        text = I18n.t("sub_raw_hint"),
                                        color = TextMuted,
                                        fontSize = 11.sp
                                    )
                                },
                                textStyle = androidx.compose.ui.text.TextStyle(
                                    color = TextPrimary,
                                    fontSize = 11.sp,
                                    fontFamily = FontFamily.Monospace
                                ),
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = ElectricCyan,
                                    unfocusedBorderColor = BorderDark,
                                    focusedContainerColor = PureBlack,
                                    unfocusedContainerColor = PureBlack
                                ),
                                shape = RoundedCornerShape(10.dp),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(130.dp)
                                    .testTag("subscription_raw_input"),
                                maxLines = 8
                            )

                            Spacer(modifier = Modifier.height(12.dp))

                            Button(
                                onClick = { triggerParseRaw() },
                                enabled = rawTextContent.isNotBlank(),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = ElectricCyan,
                                    contentColor = PureBlack
                                ),
                                shape = RoundedCornerShape(10.dp),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(44.dp)
                                    .testTag("parse_raw_button")
                            ) {
                                Icon(Icons.Default.Check, contentDescription = null, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(I18n.t("btn_parse_content"), fontSize = 12.5.sp, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            }

            // TAB 2: Featured Feeds & Presets
            if (selectedTab == 2) {
                items(SubscriptionParser.sampleFeeds) { preset ->
                    Card(
                        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                        shape = RoundedCornerShape(12.dp),
                        border = androidx.compose.foundation.BorderStroke(1.dp, BorderDark),
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable {
                                rawTextContent = preset.sampleData
                                val result = SubscriptionParser.parseContent(preset.sampleData)
                                processParseResult(result)
                            }
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(14.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Surface(
                                color = ElectricCyan.copy(alpha = 0.15f),
                                shape = RoundedCornerShape(10.dp),
                                modifier = Modifier.size(40.dp)
                            ) {
                                Box(contentAlignment = Alignment.Center) {
                                    Icon(
                                        imageVector = Icons.Default.Bolt,
                                        contentDescription = null,
                                        tint = ElectricCyan,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.width(12.dp))

                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = preset.title,
                                    color = TextPrimary,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Spacer(modifier = Modifier.height(2.dp))
                                Text(
                                    text = preset.description,
                                    color = TextSecondary,
                                    fontSize = 11.sp,
                                    lineHeight = 15.sp
                                )
                            }

                            Spacer(modifier = Modifier.width(8.dp))

                            Surface(
                                color = NeonGreen.copy(alpha = 0.15f),
                                shape = RoundedCornerShape(6.dp)
                            ) {
                                Text(
                                    text = "${preset.nodeCount} NODES",
                                    color = NeonGreen,
                                    fontSize = 9.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                                )
                            }
                        }
                    }
                }
            }

            // Error or Success Banner
            if (errorMessage != null) {
                item {
                    Surface(
                        color = NeonPink.copy(alpha = 0.12f),
                        shape = RoundedCornerShape(10.dp),
                        border = androidx.compose.foundation.BorderStroke(1.dp, NeonPink.copy(alpha = 0.6f)),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(
                            modifier = Modifier.padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(Icons.Default.ErrorOutline, contentDescription = null, tint = NeonPink, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = errorMessage!!,
                                color = NeonPink,
                                fontSize = 11.5.sp,
                                lineHeight = 16.sp
                            )
                        }
                    }
                }
            }

            // Subscription Quota and Metadata Card (if available)
            if (subscriptionMeta != null) {
                item {
                    Card(
                        colors = CardDefaults.cardColors(containerColor = SurfaceElevated),
                        shape = RoundedCornerShape(12.dp),
                        border = androidx.compose.foundation.BorderStroke(1.dp, ElectricCyan.copy(alpha = 0.4f)),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(modifier = Modifier.padding(12.dp)) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(Icons.Default.WifiTethering, contentDescription = null, tint = ElectricCyan, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        text = I18n.t("sub_traffic_info"),
                                        color = TextPrimary,
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                }

                                Text(
                                    text = subscriptionMeta!!.quotaDisplay,
                                    color = ElectricCyan,
                                    fontSize = 11.5.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }

                            Spacer(modifier = Modifier.height(8.dp))

                            LinearProgressIndicator(
                                progress = { subscriptionMeta!!.progressFraction },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(6.dp)
                                    .clip(RoundedCornerShape(3.dp)),
                                color = ElectricCyan,
                                trackColor = PureBlack
                            )

                            Spacer(modifier = Modifier.height(8.dp))

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text(
                                    text = "${I18n.t("sub_expiry_info")}: ${subscriptionMeta!!.expireDisplay}",
                                    color = TextSecondary,
                                    fontSize = 10.5.sp
                                )

                                Text(
                                    text = "Active Profile",
                                    color = NeonGreen,
                                    fontSize = 10.5.sp,
                                    fontWeight = FontWeight.SemiBold
                                )
                            }
                        }
                    }
                }
            }

            // Extracted Nodes Header & Control
            if (parsedNodes.isNotEmpty()) {
                item {
                    Column {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "${parsedNodes.size} ${I18n.t("nodes_found")}",
                                color = TextPrimary,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold
                            )

                            Row(verticalAlignment = Alignment.CenterVertically) {
                                TextButton(
                                    onClick = {
                                        selectedNodeIds.clear()
                                        selectedNodeIds.addAll(parsedNodes.map { it.id })
                                    }
                                ) {
                                    Text(I18n.t("select_all"), color = ElectricCyan, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                }

                                Text(text = "•", color = TextMuted, fontSize = 12.sp)

                                TextButton(
                                    onClick = { selectedNodeIds.clear() }
                                ) {
                                    Text(I18n.t("deselect_all"), color = TextSecondary, fontSize = 11.sp)
                                }
                            }
                        }

                        // Search Bar & Filter
                        OutlinedTextField(
                            value = searchQuery,
                            onValueChange = { searchQuery = it },
                            placeholder = { Text("Filter parsed nodes...", color = TextMuted, fontSize = 11.sp) },
                            leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = TextMuted, modifier = Modifier.size(16.dp)) },
                            trailingIcon = {
                                if (searchQuery.isNotEmpty()) {
                                    IconButton(onClick = { searchQuery = "" }) {
                                        Icon(Icons.Default.DeleteOutline, contentDescription = null, tint = TextMuted, modifier = Modifier.size(16.dp))
                                    }
                                }
                            },
                            textStyle = androidx.compose.ui.text.TextStyle(color = TextPrimary, fontSize = 11.5.sp),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = ElectricCyan,
                                unfocusedBorderColor = BorderDark,
                                focusedContainerColor = SurfaceDark,
                                unfocusedContainerColor = SurfaceDark
                            ),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(44.dp)
                        )

                        Spacer(modifier = Modifier.height(8.dp))

                        // Protocol Filter Chips
                        val protocols = listOf("ALL", "VLESS", "VMESS", "TROJAN", "HYSTERIA-2", "SHADOWSOCKS")
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            protocols.take(4).forEach { proto ->
                                val isSelected = protocolFilter == proto
                                Surface(
                                    color = if (isSelected) ElectricCyan.copy(alpha = 0.2f) else SurfaceDark,
                                    shape = RoundedCornerShape(6.dp),
                                    border = androidx.compose.foundation.BorderStroke(
                                        1.dp,
                                        if (isSelected) ElectricCyan else BorderDark
                                    ),
                                    modifier = Modifier
                                        .clickable { protocolFilter = proto }
                                ) {
                                    Text(
                                        text = proto,
                                        color = if (isSelected) ElectricCyan else TextSecondary,
                                        fontSize = 9.5.sp,
                                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                    )
                                }
                            }
                        }
                    }
                }

                // Filtered List of Parsed Nodes
                val filteredList = parsedNodes.filter { node ->
                    val matchesQuery = searchQuery.isBlank() ||
                            node.name.contains(searchQuery, ignoreCase = true) ||
                            node.host.contains(searchQuery, ignoreCase = true)
                    val matchesProto = when (protocolFilter) {
                        "VLESS" -> node.protocol == VpnProtocol.VLESS
                        "VMESS" -> node.protocol == VpnProtocol.VMESS
                        "TROJAN" -> node.protocol == VpnProtocol.TROJAN
                        "HYSTERIA-2" -> node.protocol == VpnProtocol.HYSTERIA2
                        "SHADOWSOCKS" -> node.protocol == VpnProtocol.SHADOWSOCKS
                        else -> true
                    }
                    matchesQuery && matchesProto
                }

                items(filteredList) { node ->
                    val isChecked = selectedNodeIds.contains(node.id)
                    Card(
                        colors = CardDefaults.cardColors(
                            containerColor = if (isChecked) SurfaceDark else SurfaceDark.copy(alpha = 0.6f)
                        ),
                        shape = RoundedCornerShape(10.dp),
                        border = androidx.compose.foundation.BorderStroke(
                            1.dp,
                            if (isChecked) ElectricCyan.copy(alpha = 0.5f) else BorderDark
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable {
                                if (isChecked) {
                                    selectedNodeIds.remove(node.id)
                                } else {
                                    selectedNodeIds.add(node.id)
                                }
                            }
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(10.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Checkbox(
                                checked = isChecked,
                                onCheckedChange = { checked ->
                                    if (checked) {
                                        if (!selectedNodeIds.contains(node.id)) selectedNodeIds.add(node.id)
                                    } else {
                                        selectedNodeIds.remove(node.id)
                                    }
                                },
                                colors = CheckboxDefaults.colors(
                                    checkedColor = ElectricCyan,
                                    checkmarkColor = PureBlack,
                                    uncheckedColor = TextMuted
                                ),
                                modifier = Modifier.size(20.dp)
                            )

                            Spacer(modifier = Modifier.width(8.dp))

                            Text(
                                text = node.countryCode,
                                fontSize = 18.sp
                            )

                            Spacer(modifier = Modifier.width(8.dp))

                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = node.name,
                                    color = if (isChecked) TextPrimary else TextMuted,
                                    fontSize = 12.5.sp,
                                    fontWeight = FontWeight.Bold,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                                Spacer(modifier = Modifier.height(2.dp))
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Surface(
                                        color = when (node.protocol) {
                                            VpnProtocol.VLESS -> ElectricCyan.copy(alpha = 0.15f)
                                            VpnProtocol.VMESS -> NeonYellow.copy(alpha = 0.15f)
                                            VpnProtocol.TROJAN -> NeonPink.copy(alpha = 0.15f)
                                            VpnProtocol.HYSTERIA2 -> NeonGreen.copy(alpha = 0.15f)
                                            VpnProtocol.SHADOWSOCKS -> TextMuted.copy(alpha = 0.2f)
                                        },
                                        shape = RoundedCornerShape(4.dp)
                                    ) {
                                        Text(
                                            text = node.protocol.label,
                                            color = when (node.protocol) {
                                                VpnProtocol.VLESS -> ElectricCyan
                                                VpnProtocol.VMESS -> NeonYellow
                                                VpnProtocol.TROJAN -> NeonPink
                                                VpnProtocol.HYSTERIA2 -> NeonGreen
                                                VpnProtocol.SHADOWSOCKS -> TextSecondary
                                            },
                                            fontSize = 8.5.sp,
                                            fontWeight = FontWeight.Bold,
                                            modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.5.dp)
                                        )
                                    }
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        text = "${node.host}:${node.port}",
                                        color = TextSecondary,
                                        fontSize = 10.sp,
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.width(6.dp))

                            // Ping badge
                            Surface(
                                color = node.pingColor.copy(alpha = 0.12f),
                                shape = RoundedCornerShape(6.dp),
                                border = androidx.compose.foundation.BorderStroke(1.dp, node.pingColor.copy(alpha = 0.4f))
                            ) {
                                Text(
                                    text = node.pingDisplay,
                                    color = node.pingColor,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
