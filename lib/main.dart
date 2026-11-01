import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } catch (_) {}
  runApp(const VelocityApp());
}

// ---------------------------------------------------------------------------
// Velocity Cyberpunk Brand Theme Colors
// ---------------------------------------------------------------------------
class VelocityColors {
  static const Color pureBlack = Color(0xFF030712);
  static const Color midnightBg = Color(0xFF070B16);
  static const Color surfaceDark = Color(0xFF0E1424);
  static const Color surfaceElevated = Color(0xFF141C30);
  static const Color borderDark = Color(0xFF1E293B);

  // High-Energy Cyber Accents
  static const Color electricCyan = Color(0xFF00E5FF);
  static const Color deepCyan = Color(0xFF00B0FF);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPink = Color(0xFFFF1744);
  static const Color neonYellow = Color(0xFFFFD600);
  static const Color neonAmber = Color(0xFFFF9100);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

// ---------------------------------------------------------------------------
// Internationalization System (Persian & English)
// ---------------------------------------------------------------------------
enum AppLanguage { en, fa }

class I18n {
  static AppLanguage currentLang = AppLanguage.fa;

  static final Map<String, Map<String, String>> _strings = {
    'app_title': {'en': 'VELOCITY', 'fa': 'ولوسیتی'},
    'subtitle_tagline': {'en': 'XRAY ULTRA TUNNEL', 'fa': 'تونل فوق‌پیشرفته Xray'},
    'telegram_support': {'en': 'Telegram Support', 'fa': 'پشتیبانی تلگرام'},
    'status_connected': {'en': 'SECURE TUNNEL ACTIVE', 'fa': 'تونل امن Xray متصل است'},
    'status_disconnected': {'en': 'DISCONNECTED', 'fa': 'قطع ارتباط'},
    'status_connecting': {'en': 'CONNECTING TO XRAY...', 'fa': 'در حال اتصال به هسته Xray...'},
    'status_disconnecting': {'en': 'TERMINATING TUNNEL...', 'fa': 'در حال بستن تونل امن...'},
    'tap_to_connect': {'en': 'TAP TO CONNECT', 'fa': 'برای اتصال لمس کنید'},
    'tap_to_disconnect': {'en': 'TAP TO DISCONNECT', 'fa': 'برای قطع اتصال لمس کنید'},
    'active_server': {'en': 'Active Node', 'fa': 'سرور فعال'},
    'select_server': {'en': 'Select Velocity Node', 'fa': 'انتخاب سرور'},
    'servers_count': {'en': 'Servers Online', 'fa': 'سرور موجود'},
    'ping_all': {'en': 'Ping All', 'fa': 'تست همه'},
    'testing_ping': {'en': 'Measuring...', 'fa': 'در حال تست...'},
    'download_speed': {'en': 'DOWNLOAD', 'fa': 'دریافت'},
    'upload_speed': {'en': 'UPLOAD', 'fa': 'ارسال'},
    'routing_mode': {'en': 'Routing Mode', 'fa': 'حالت مسیریابی'},
    'mode_global': {'en': 'Global Proxy', 'fa': 'سراسری'},
    'mode_bypass_lan': {'en': 'Bypass Iran/LAN', 'fa': 'دور زدن ایران و شبکه داخلی'},
    'import_config': {'en': 'Import Config', 'fa': 'افزودن کانفیگ / سابسکریپشن'},
    'import_prompt': {
      'en': 'Paste vless://, vmess://, trojan://, ss://, hy2:// or Subscription URL (http/https)',
      'fa': 'لینک کانفیگ (vless, vmess, trojan, ss, hy2) یا لینک سابسکریپشن (http/https) را وارد کنید:'
    },
    'import_btn': {'en': 'Import & Test', 'fa': 'افزودن و تست سرورها'},
    'cancel': {'en': 'Cancel', 'fa': 'انصراف'},
    'save': {'en': 'Save', 'fa': 'ذخیره'},
    'delete': {'en': 'Delete', 'fa': 'حذف'},
    'edit': {'en': 'Edit', 'fa': 'ویرایش'},
    'no_nodes_available': {
      'en': 'No servers found. Please import configs or subscription link.',
      'fa': 'هیچ سروری یافت نشد. لطفاً از طریق دکمه «افزودن کانفیگ» لینک سابسکریپشن یا کانفیگ خود را وارد نمایید.',
    },
    'no_active_subscription': {
      'en': 'No Active Subscription',
      'fa': 'بدون اشتراک فعال',
    },
    'subscription_quota': {
      'en': 'Subscription Quota',
      'fa': 'حجم و اعتبار اشتراک',
    },
    'fetching_sub': {
      'en': 'Fetching subscription & parsing nodes...',
      'fa': 'در حال دریافت سابسکریپشن و پردازش سرورها...',
    },
    'import_failed': {
      'en': 'Failed to parse config or subscription',
      'fa': 'خطا در دریافت یا پردازش کانفیگ یا سابسکریپشن',
    },
    'delete_node': {'en': 'Delete Node', 'fa': 'حذف سرور'},
    'clear_all_nodes': {'en': 'Clear All Nodes', 'fa': 'حذف تمام سرورها'},
    'search_nodes': {'en': 'Search servers or protocols...', 'fa': 'جستجوی سرور یا پروتکل...'},
    'no_nodes_found': {'en': 'No servers match your filter.', 'fa': 'سروری مطابق جستجوی شما یافت نشد.'},
    'log_viewer_title': {'en': 'Xray Diagnostics & Logs', 'fa': 'لاگ‌ها و عیب‌یابی هسته Xray'},
    'btn_logs': {'en': 'Logs', 'fa': 'لاگ‌ها'},
    'copy_logs': {'en': 'Copy Logs', 'fa': 'کپی لاگ‌ها'},
    'logs_copied': {'en': 'Logs copied to clipboard!', 'fa': 'لاگ‌های اتصال در حافظه کپی شدند!'},
    'clear_logs': {'en': 'Clear Logs', 'fa': 'پاک کردن لاگ‌ها'},
    'no_logs_yet': {'en': 'No connection events recorded yet.', 'fa': 'هنوز رویدادی ثبت نشده است.'},
    'tab_home': {'en': 'Home', 'fa': 'خانه'},
    'tab_servers': {'en': 'Servers', 'fa': 'سرورها'},
    'tab_vip': {'en': 'VIP', 'fa': 'وی‌آی‌پی'},
    'tab_settings': {'en': 'Settings', 'fa': 'تنظیمات'},
    'bypass_iran_title': {'en': 'Bypass Iran (Domestic Sites)', 'fa': 'دور زدن سایت‌های داخلی (Bypass Iran)'},
    'bypass_iran_desc': {'en': 'Directly route Iranian banking, .ir domains and domestic apps', 'fa': 'عبور مستقیم سایت‌های بانکی و دامنه‌های ir بدون فیلترشکن'},
    'bypass_lan_title': {'en': 'Bypass LAN & Local Devices', 'fa': 'دور زدن شبکه محلی (Bypass LAN)'},
    'bypass_lan_desc': {'en': 'Keep 192.168.x & private network untunneled', 'fa': 'عدم ارسال ترافیک شبکه خانگی و محلی به پروکسی'},
    'notif_settings_title': {'en': 'Keepalive Foreground Service', 'fa': 'اعلان پایداری اتصال در نوار وضعیت'},
    'notif_settings_desc': {'en': 'Prevents Android OS from stopping the VPN in background', 'fa': 'جلوگیری از قطع شدن اتصال در پس‌زمینه توسط بهینه‌ساز باتری اندروید'},
    'perm_declined': {'en': 'VPN permission is required to create tunnel.', 'fa': 'برای برقراری اتصال امن، تایید دسترسی VPN الزامی است.'},
    'sort_latency': {'en': 'Latency', 'fa': 'تاخیر'},
    'sort_name': {'en': 'Name', 'fa': 'نام'},
    'sort_protocol': {'en': 'Protocol', 'fa': 'پروتکل'},
    'sub_expiry': {'en': 'Expiry:', 'fa': 'انقضا:'},
    'xray_core_title': {'en': 'Core Engine: Xray v26.9.9 (15-Protocol Ready)', 'fa': 'موتور هسته: Xray v26.9.9 (پشتیبانی کامل از ۱۵ پروتکل)'},
    'xray_core_desc': {'en': 'Native TUN VPN adapter with REALITY, TLS 1.3, VMess, Trojan, Shadowsocks, and Hysteria 2', 'fa': 'پشتیبانی بومی از VLESS Reality، پروتکل‌های مدرن TLS 1.3، هیتلریا ۲ و تمام پروتکل‌های نسل جدید و قدیم'},
    'manage_subscriptions': {'en': 'Subscriptions', 'fa': 'سابسکریپشن‌ها'},
    'add_subscription': {'en': 'Add Subscription', 'fa': 'افزودن سابسکریپشن'},
    'edit_subscription': {'en': 'Edit Subscription', 'fa': 'ویرایش سابسکریپشن'},
    'delete_sub_confirm': {'en': 'Are you sure you want to remove this subscription?', 'fa': 'آیا از حذف این سابسکریپشن مطمئن هستید؟'},
    'sub_name_label': {'en': 'Subscription Name', 'fa': 'نام سابسکریپشن'},
    'sub_url_label': {'en': 'Subscription URL', 'fa': 'آدرس سابسکریپشن'},
    'sub_updated': {'en': 'Subscription updated successfully', 'fa': 'سابسکریپشن با موفقیت بروزرسانی شد'},
    'all_subscriptions': {'en': 'All Subscriptions', 'fa': 'تمام سابسکریپشن‌ها'},
    'active_sub': {'en': 'Active Subscription', 'fa': 'سابسکریپشن فعال'},
    'set_active_btn': {'en': 'Set Active', 'fa': 'فعال‌سازی'},
    'telegram_vip_title': {'en': 'VIP Telegram Auth', 'fa': 'احراز هویت VIP تلگرام'},
    'telegram_vip_desc': {'en': 'Link your Telegram ID or Username to verify VIP status and sync dedicated high-speed servers.', 'fa': 'شناسه یا نام‌کاربری تلگرام خود را برای تایید اشتراک VIP و دریافت سرورهای اختصاصی متصل کنید.'},
    'telegram_user_hint': {'en': '@Username or numeric ID', 'fa': 'شناسه عددی یا @نام‌کاربری'},
    'link_telegram_btn': {'en': 'Link Account', 'fa': 'اتصال به تلگرام'},
    'unlink_telegram_btn': {'en': 'Unlink Account', 'fa': 'قطع اتصال'},
    'open_support_bot': {'en': 'Open Support Bot', 'fa': 'ورود به بات تلگرام'},
    'verified_vip_badge': {'en': 'VERIFIED VIP MEMBER', 'fa': 'عضو VIP تاییدشده'},
    'unverified_member': {'en': 'Guest / Free Plan', 'fa': 'کاربر مهمان / عادی'},
    'wizard_step1_title': {'en': 'Step 1: Language & Routing', 'fa': 'مرحله ۱: زبان و مسیریابی'},
    'wizard_step2_title': {'en': 'Step 2: Protocol Priority', 'fa': 'مرحله ۲: اولویت پروتکل‌ها'},
    'wizard_step3_title': {'en': 'Step 3: Core Permissions', 'fa': 'مرحله ۳: مجوزهای سیستم'},
    'grant_vpn_perm': {'en': 'Grant VPN Permission', 'fa': 'تایید دسترسی تونل VPN'},
    'grant_notif_perm': {'en': 'Grant Notification Permission', 'fa': 'تایید مجوز اعلان‌ها'},
    'wizard_finish_btn': {'en': 'Complete & Enter Velocity', 'fa': 'تکمیل و ورود به ولوسیتی'},
    'reset_wizard_btn': {'en': 'Rerun Setup Wizard', 'fa': 'اجرای مجدد راهنمای اولیه'},
    'wizard_welcome_title': {'en': 'WELCOME TO VELOCITY', 'fa': 'به ولوسیتی خوش آمدید'},
    'wizard_welcome_subtitle': {'en': 'Next-Generation Anti-Censorship Xray Core Tunnel', 'fa': 'سامانه فوق‌پیشرفته و هوشمند تونل ضد فیلترینگ Xray'},
  };

  static String t(String key) {
    final langCode = currentLang == AppLanguage.fa ? 'fa' : 'en';
    return _strings[key]?[langCode] ?? key;
  }
}

// ---------------------------------------------------------------------------
// Official Velocity Brand Emblem Widget
// ---------------------------------------------------------------------------
class VelocityEmblemWidget extends StatelessWidget {
  final double size;
  final bool isConnected;
  final bool isGlowEnabled;

  const VelocityEmblemWidget({
    super.key,
    this.size = 36,
    this.isConnected = false,
    this.isGlowEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final glowColor = isConnected ? VelocityColors.neonGreen : VelocityColors.electricCyan;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isGlowEnabled
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.45),
                  blurRadius: size * 0.35,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          'assets/icon/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data Models & Protocol Enums
// ---------------------------------------------------------------------------
enum VpnState { disconnected, connecting, connected, disconnecting }

enum RoutingMode { bypassLan, global }

enum VpnProtocol { vless, vmess, trojan, hysteria2, shadowsocks }

extension VpnProtocolExt on VpnProtocol {
  String get label {
    switch (this) {
      case VpnProtocol.vless:
        return 'VLESS-REALITY';
      case VpnProtocol.vmess:
        return 'VMESS-WS';
      case VpnProtocol.trojan:
        return 'TROJAN-gRPC';
      case VpnProtocol.hysteria2:
        return 'HYSTERIA-2';
      case VpnProtocol.shadowsocks:
        return 'SHADOWSOCKS';
    }
  }
}

enum ServerSortMode { none, latency, name, protocol }

// ---------------------------------------------------------------------------
// Subscription Info Model (Null-Safe with All Required Getters)
// ---------------------------------------------------------------------------
class SubscriptionInfo {
  final int uploadBytes;
  final int downloadBytes;
  final int totalBytes;
  final int expireTimestamp;
  final String rawHeader;
  final String subUrl;
  final String customName;

  const SubscriptionInfo({
    this.uploadBytes = 0,
    this.downloadBytes = 0,
    this.totalBytes = 0,
    this.expireTimestamp = 0,
    this.rawHeader = '',
    this.subUrl = '',
    this.customName = '',
  });

  // Required null-safe getters
  String get planName => customName.isNotEmpty ? customName : 'Velocity VIP Plan';
  bool get hasQuota => totalBytes > 0;
  int get trafficUsed => uploadBytes + downloadBytes;
  int get trafficTotal => totalBytes;
  DateTime? get expiryDate => expireTimestamp > 0 ? DateTime.fromMillisecondsSinceEpoch(expireTimestamp * 1000) : null;

  double get quotaProgress {
    if (trafficTotal <= 0) return 0.0;
    return (trafficUsed / trafficTotal).clamp(0.0, 1.0);
  }

  String get trafficUsageFormatted => '${(trafficUsed / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  String get trafficTotalFormatted => '${(trafficTotal / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';

  String get expiryDateFormatted {
    if (expiryDate == null) return I18n.currentLang == AppLanguage.fa ? 'نامحدود' : 'Unlimited';
    return '${expiryDate!.year}/${expiryDate!.month.toString().padLeft(2, '0')}/${expiryDate!.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'uploadBytes': uploadBytes,
    'downloadBytes': downloadBytes,
    'totalBytes': totalBytes,
    'expireTimestamp': expireTimestamp,
    'rawHeader': rawHeader,
    'subUrl': subUrl,
    'customName': customName,
  };

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) => SubscriptionInfo(
    uploadBytes: json['uploadBytes'] as int? ?? 0,
    downloadBytes: json['downloadBytes'] as int? ?? 0,
    totalBytes: json['totalBytes'] as int? ?? 0,
    expireTimestamp: json['expireTimestamp'] as int? ?? 0,
    rawHeader: json['rawHeader'] as String? ?? '',
    subUrl: json['subUrl'] as String? ?? '',
    customName: json['customName'] as String? ?? '',
  );

  static SubscriptionInfo fromHeader(String? header, String subUrl, {String name = ''}) {
    if (header == null || header.trim().isEmpty) {
      return SubscriptionInfo(subUrl: subUrl, customName: name);
    }
    int up = 0, down = 0, tot = 0, exp = 0;
    final parts = header.split(';');
    for (var part in parts) {
      final kv = part.split('=');
      if (kv.length == 2) {
        final key = kv[0].trim().toLowerCase();
        final val = int.tryParse(kv[1].trim()) ?? 0;
        if (key == 'upload') up = val;
        else if (key == 'download') down = val;
        else if (key == 'total') tot = val;
        else if (key == 'expire') exp = val;
      }
    }
    return SubscriptionInfo(
      uploadBytes: up,
      downloadBytes: down,
      totalBytes: tot,
      expireTimestamp: exp,
      rawHeader: header,
      subUrl: subUrl,
      customName: name,
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-Subscription Item / Model (Explicit Architecture)
// ---------------------------------------------------------------------------
class SubscriptionItem {
  final String id;
  String name;
  final String url;
  int upload;
  int download;
  int total;
  int expire;
  bool isActive;
  List<ServerProfile> servers;

  SubscriptionItem({
    required this.id,
    required this.name,
    required this.url,
    this.upload = 0,
    this.download = 0,
    this.total = 0,
    this.expire = 0,
    this.isActive = true,
    List<ServerProfile>? servers,
  }) : servers = servers ?? [];

  // Required null-safe getters
  String get planName => name.isNotEmpty ? name : 'Velocity Subscription';
  int get trafficUsed => upload + download;
  int get trafficTotal => total;
  DateTime? get expiryDate => expire > 0 ? DateTime.fromMillisecondsSinceEpoch(expire * 1000) : null;

  double get quotaProgress {
    if (total <= 0) return 0.0;
    return (trafficUsed / total).clamp(0.0, 1.0);
  }

  String get trafficUsageFormatted => '${(trafficUsed / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  String get trafficTotalFormatted => '${(total / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';

  String get expiryDateFormatted {
    if (expiryDate == null) return I18n.currentLang == AppLanguage.fa ? 'نامحدود' : 'Unlimited';
    return '${expiryDate!.year}/${expiryDate!.month.toString().padLeft(2, '0')}/${expiryDate!.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'upload': upload,
    'download': download,
    'total': total,
    'expire': expire,
    'isActive': isActive,
    'servers': servers.map((s) => s.toJson()).toList(),
  };

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) {
    List<ServerProfile> parsedServers = [];
    final subId = json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();

    if (json['servers'] != null) {
      final sList = json['servers'] as List<dynamic>;
      parsedServers = sList
          .map((s) => ServerProfile.fromJson(s as Map<String, dynamic>))
          .toList();
      for (var s in parsedServers) {
        if (s.subscriptionId == null || s.subscriptionId!.isEmpty) {
          s.subscriptionId = subId;
        }
      }
    }
    return SubscriptionItem(
      id: subId,
      name: json['name'] as String? ?? 'Sub 1',
      url: json['url'] as String? ?? '',
      upload: json['upload'] as int? ?? 0,
      download: json['download'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      expire: json['expire'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      servers: parsedServers,
    );
  }
}

typedef SubscriptionModel = SubscriptionItem;

// ---------------------------------------------------------------------------
// Server Profile Model with Foreign Key: subscriptionId
// ---------------------------------------------------------------------------
class ServerProfile {
  final String id;
  String name;
  final String countryCode;
  final VpnProtocol protocol;
  final String host;
  final int port;
  final String sni;
  final String rawUrl;
  int? pingMs;
  bool isTesting;
  String trafficUsage;
  String? subscriptionId;

  ServerProfile({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.protocol,
    required this.host,
    required this.port,
    required this.sni,
    this.rawUrl = '',
    this.pingMs,
    this.isTesting = false,
    this.trafficUsage = '0.0 GB',
    this.subscriptionId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'countryCode': countryCode,
    'protocol': protocol.name,
    'host': host,
    'port': port,
    'sni': sni,
    'rawUrl': rawUrl,
    'pingMs': pingMs,
    'trafficUsage': trafficUsage,
    'subscriptionId': subscriptionId,
  };

  factory ServerProfile.fromJson(Map<String, dynamic> json) {
    VpnProtocol proto = VpnProtocol.vless;
    try {
      proto = VpnProtocol.values.firstWhere((p) => p.name == json['protocol']);
    } catch (_) {}
    return ServerProfile(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Node',
      countryCode: json['countryCode'] as String? ?? '🌐',
      protocol: proto,
      host: json['host'] as String? ?? '127.0.0.1',
      port: json['port'] as int? ?? 443,
      sni: json['sni'] as String? ?? '',
      rawUrl: json['rawUrl'] as String? ?? '',
      pingMs: json['pingMs'] as int?,
      trafficUsage: json['trafficUsage'] as String? ?? '0.0 GB',
      subscriptionId: json['subscriptionId'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Universal Config & Subscription Parser
// ---------------------------------------------------------------------------
class ConfigLinkParser {
  static ServerProfile? parse(String link, {String? subscriptionId}) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) return null;

    try {
      if (trimmed.startsWith('vless://')) return _parseVless(trimmed, subscriptionId: subscriptionId);
      if (trimmed.startsWith('vmess://')) return _parseVmess(trimmed, subscriptionId: subscriptionId);
      if (trimmed.startsWith('trojan://')) return _parseTrojan(trimmed, subscriptionId: subscriptionId);
      if (trimmed.startsWith('ss://')) return _parseShadowsocks(trimmed, subscriptionId: subscriptionId);
      if (trimmed.startsWith('hy2://') || trimmed.startsWith('hysteria2://')) return _parseHysteria2(trimmed, subscriptionId: subscriptionId);
    } catch (_) {}
    return null;
  }

  static List<ServerProfile> parseMultiple(String content, {String? subscriptionId}) {
    List<ServerProfile> results = [];
    String textToScan = content.trim();

    if (!textToScan.contains('\n') && !textToScan.startsWith('vless://') && !textToScan.startsWith('vmess://')) {
      try {
        final decoded = utf8.decode(base64Decode(base64.normalize(textToScan)));
        textToScan = decoded;
      } catch (_) {}
    }

    final lines = const LineSplitter().convert(textToScan);
    for (var line in lines) {
      final p = parse(line, subscriptionId: subscriptionId);
      if (p != null) results.add(p);
    }
    return results;
  }

  static ServerProfile _parseVless(String url, {String? subscriptionId}) {
    final uri = Uri.parse(url);
    final remark = uri.fragment.isNotEmpty ? Uri.decodeComponent(uri.fragment) : 'VLESS-${uri.host}';
    final sni = uri.queryParameters['sni'] ?? uri.queryParameters['host'] ?? '';
    return ServerProfile(
      id: 'vless_${DateTime.now().microsecondsSinceEpoch}_${math.Random().nextInt(9999)}',
      name: remark,
      countryCode: _extractFlag(remark),
      protocol: VpnProtocol.vless,
      host: uri.host,
      port: uri.port > 0 ? uri.port : 443,
      sni: sni,
      rawUrl: url,
      subscriptionId: subscriptionId,
    );
  }

  static ServerProfile _parseVmess(String url, {String? subscriptionId}) {
    final b64 = url.substring('vmess://'.length).trim();
    final decoded = utf8.decode(base64Decode(base64.normalize(b64)));
    final Map<String, dynamic> json = jsonDecode(decoded);

    final remark = json['ps']?.toString() ?? 'VMESS-${json['add']}';
    return ServerProfile(
      id: 'vmess_${DateTime.now().microsecondsSinceEpoch}_${math.Random().nextInt(9999)}',
      name: remark,
      countryCode: _extractFlag(remark),
      protocol: VpnProtocol.vmess,
      host: json['add']?.toString() ?? '127.0.0.1',
      port: int.tryParse(json['port']?.toString() ?? '443') ?? 443,
      sni: json['sni']?.toString() ?? json['host']?.toString() ?? '',
      rawUrl: url,
      subscriptionId: subscriptionId,
    );
  }

  static ServerProfile _parseTrojan(String url, {String? subscriptionId}) {
    final uri = Uri.parse(url);
    final remark = uri.fragment.isNotEmpty ? Uri.decodeComponent(uri.fragment) : 'Trojan-${uri.host}';
    return ServerProfile(
      id: 'trojan_${DateTime.now().microsecondsSinceEpoch}_${math.Random().nextInt(9999)}',
      name: remark,
      countryCode: _extractFlag(remark),
      protocol: VpnProtocol.trojan,
      host: uri.host,
      port: uri.port > 0 ? uri.port : 443,
      sni: uri.queryParameters['sni'] ?? '',
      rawUrl: url,
      subscriptionId: subscriptionId,
    );
  }

  static ServerProfile _parseHysteria2(String url, {String? subscriptionId}) {
    final uri = Uri.parse(url);
    final remark = uri.fragment.isNotEmpty ? Uri.decodeComponent(uri.fragment) : 'HY2-${uri.host}';
    return ServerProfile(
      id: 'hy2_${DateTime.now().microsecondsSinceEpoch}_${math.Random().nextInt(9999)}',
      name: remark,
      countryCode: _extractFlag(remark),
      protocol: VpnProtocol.hysteria2,
      host: uri.host,
      port: uri.port > 0 ? uri.port : 443,
      sni: uri.queryParameters['sni'] ?? '',
      rawUrl: url,
      subscriptionId: subscriptionId,
    );
  }

  static ServerProfile _parseShadowsocks(String url, {String? subscriptionId}) {
    final uri = Uri.parse(url);
    final remark = uri.fragment.isNotEmpty ? Uri.decodeComponent(uri.fragment) : 'SS-${uri.host}';
    return ServerProfile(
      id: 'ss_${DateTime.now().microsecondsSinceEpoch}_${math.Random().nextInt(9999)}',
      name: remark,
      countryCode: _extractFlag(remark),
      protocol: VpnProtocol.shadowsocks,
      host: uri.host,
      port: uri.port > 0 ? uri.port : 8388,
      sni: '',
      rawUrl: url,
      subscriptionId: subscriptionId,
    );
  }

  static String _extractFlag(String text) {
    final upper = text.toUpperCase();
    if (upper.contains('DE') || upper.contains('GERMAN')) return '🇩🇪';
    if (upper.contains('NL') || upper.contains('NETHERLAND')) return '🇳🇱';
    if (upper.contains('US') || upper.contains('AMERICA') || upper.contains('USA')) return '🇺🇸';
    if (upper.contains('GB') || upper.contains('UK') || upper.contains('LONDON')) return '🇬🇧';
    if (upper.contains('FR') || upper.contains('FRANCE')) return '🇫🇷';
    if (upper.contains('TR') || upper.contains('TURKEY')) return '🇹🇷';
    if (upper.contains('FI') || upper.contains('FINLAND')) return '🇫🇮';
    if (upper.contains('SE') || upper.contains('SWEDEN')) return '🇸🇪';
    if (upper.contains('SG') || upper.contains('SINGAPORE')) return '🇸🇬';
    if (upper.contains('JP') || upper.contains('JAPAN')) return '🇯🇵';
    if (upper.contains('CA') || upper.contains('CANADA')) return '🇨🇦';
    return '🌐';
  }
}

// ---------------------------------------------------------------------------
// System Notification Service (English Only & Prompt Aligned)
// ---------------------------------------------------------------------------
class VelocityNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _notificationsPlugin.initialize(initSettings);
      _isInitialized = true;
    } catch (_) {}
  }

  static Future<void> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (_) {}
  }

  static Future<void> showVpnConnectedNotification({
    required String serverName,
    int? pingMs,
  }) async {
    try {
      await init();
      const androidDetails = AndroidNotificationDetails(
        'velocity_vpn_channel',
        'Velocity VPN Service',
        channelDescription: 'Ongoing foreground VPN connection status',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
        icon: '@mipmap/ic_launcher',
      );
      const notifDetails = NotificationDetails(android: androidDetails);
      final body = (pingMs != null && pingMs > 0)
          ? 'Secure tunnel active | Latency: ${pingMs}ms'
          : 'Secure tunnel active | Connected';
      await _notificationsPlugin.show(
        1001,
        'Velocity VPN: $serverName',
        body,
        notifDetails,
      );
    } catch (_) {}
  }

  static Future<void> cancelVpnNotification() async {
    try {
      await _notificationsPlugin.cancel(1001);
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Animated Startup / Splash Screen
// ---------------------------------------------------------------------------
class VelocitySplashScreen extends StatefulWidget {
  final VoidCallback onInitComplete;

  const VelocitySplashScreen({super.key, required this.onInitComplete});

  @override
  State<VelocitySplashScreen> createState() => _VelocitySplashScreenState();
}

class _VelocitySplashScreenState extends State<VelocitySplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  String _loadingStatus = 'Initializing core...';
  double _loadProgress = 0.15;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _runInitialization();
  }

  Future<void> _runInitialization() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _loadProgress = 0.50;
      _loadingStatus = 'Loading subscriptions & nodes...';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _loadProgress = 0.85;
      _loadingStatus = 'Readying Xray core engine...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _loadProgress = 1.0;
      _loadingStatus = 'Welcome to Velocity';
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    widget.onInitComplete();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelocityColors.pureBlack,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeController, _glowController]),
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: VelocityColors.electricCyan.withOpacity(_glowAnimation.value),
                            blurRadius: 40,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: VelocityColors.deepCyan.withOpacity(0.3),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(38),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'VELOCITY',
                      style: TextStyle(
                        color: VelocityColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'NEXT-GEN CYBERPUNK TUNNEL',
                      style: TextStyle(
                        color: VelocityColors.electricCyan.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _loadProgress,
                          backgroundColor: VelocityColors.surfaceElevated,
                          valueColor: const AlwaysStoppedAnimation<Color>(VelocityColors.electricCyan),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _loadingStatus,
                      style: const TextStyle(
                        color: VelocityColors.textMuted,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3-Step Setup Onboarding Wizard Dialog (Step 2 Multi-Select Restored)
// ---------------------------------------------------------------------------
class VelocitySetupWizardDialog extends StatefulWidget {
  final VoidCallback onCompleted;
  final Function(AppLanguage) onLanguageChanged;
  final AppLanguage initialLang;

  const VelocitySetupWizardDialog({
    super.key,
    required this.onCompleted,
    required this.onLanguageChanged,
    required this.initialLang,
  });

  @override
  State<VelocitySetupWizardDialog> createState() => _VelocitySetupWizardDialogState();
}

class _VelocitySetupWizardDialogState extends State<VelocitySetupWizardDialog> {
  int _currentStep = 0;
  late AppLanguage _selectedLang;
  bool _bypassIran = true;
  bool _bypassLan = true;

  // Step 2: Multi-Select Checkboxes with all 4 enabled by default
  final Set<String> _selectedProtocols = {
    'VLESS Reality (XTLS Vision)',
    'Hysteria 2 (QUIC / UDP)',
    'Trojan gRPC',
    'VMess WebSocket + TLS',
  };

  bool _vpnPermGranted = false;
  bool _notifPermGranted = false;

  @override
  void initState() {
    super.initState();
    _selectedLang = widget.initialLang;
  }

  void _finishWizard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_wizard', true);
      await prefs.setBool('bypass_iran_enabled', _bypassIran);
      await prefs.setBool('bypass_lan_enabled', _bypassLan);
      await prefs.setStringList('protocol_priority', _selectedProtocols.toList());
    } catch (_) {}
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final isFa = _selectedLang == AppLanguage.fa;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: VelocityColors.electricCyan, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: VelocityColors.electricCyan.withOpacity(0.2),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const VelocityEmblemWidget(size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFa ? 'راه‌اندازی هوشمند ولوسیتی' : 'VELOCITY SETUP WIZARD',
                          style: const TextStyle(
                            color: VelocityColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          isFa ? 'مرحله ${_currentStep + 1} از ۳' : 'Step ${_currentStep + 1} of 3',
                          style: const TextStyle(
                            color: VelocityColors.electricCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: List.generate(3, (index) {
                  final active = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: active ? VelocityColors.electricCyan : VelocityColors.borderDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              if (_currentStep == 0) _buildStep1(isFa),
              if (_currentStep == 1) _buildStep2(isFa),
              if (_currentStep == 2) _buildStep3(isFa),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: Text(
                        isFa ? 'مرحله قبل' : 'Back',
                        style: const TextStyle(color: VelocityColors.textSecondary),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelocityColors.electricCyan,
                      foregroundColor: VelocityColors.pureBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _finishWizard();
                      }
                    },
                    child: Text(
                      _currentStep < 2
                          ? (isFa ? 'مرحله بعد' : 'Next')
                          : I18n.t('wizard_finish_btn'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(bool isFa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('wizard_step1_title'),
          style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => _selectedLang = AppLanguage.en);
                  widget.onLanguageChanged(AppLanguage.en);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedLang == AppLanguage.en
                        ? VelocityColors.electricCyan.withOpacity(0.15)
                        : VelocityColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedLang == AppLanguage.en ? VelocityColors.electricCyan : VelocityColors.borderDark,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text('English (US)', style: TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => _selectedLang = AppLanguage.fa);
                  widget.onLanguageChanged(AppLanguage.fa);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedLang == AppLanguage.fa
                        ? VelocityColors.electricCyan.withOpacity(0.15)
                        : VelocityColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedLang == AppLanguage.fa ? VelocityColors.electricCyan : VelocityColors.borderDark,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text('فارسی (Iran)', style: TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(I18n.t('bypass_iran_title'), style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          subtitle: Text(I18n.t('bypass_iran_desc'), style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 10)),
          value: _bypassIran,
          activeColor: VelocityColors.electricCyan,
          onChanged: (val) => setState(() => _bypassIran = val),
        ),
      ],
    );
  }

  Widget _buildStep2(bool isFa) {
    final protocols = [
      {'name': 'VLESS Reality (XTLS Vision)', 'desc': isFa ? 'رمزنگاری TLS 1.3 ضد فیلترینگ و رادار' : 'Anti-Censorship TLS 1.3 Steganography'},
      {'name': 'Hysteria 2 (QUIC / UDP)', 'desc': isFa ? 'تونل فوق سریع UDP با پهنای باند حداکثری' : 'Ultra High-Speed UDP / QUIC Tunnel'},
      {'name': 'Trojan gRPC', 'desc': isFa ? 'پروتکل امن مبدل با تاخیر پایین' : 'Stealth TLS/gRPC Obfuscation'},
      {'name': 'VMess WebSocket + TLS', 'desc': isFa ? 'پروتکل سازگار با تمام شبکه‌ها' : 'Universal WebSocket + TLS fallback'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('wizard_step2_title'),
          style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          isFa
              ? 'پروتکل‌های مجاز جهت مسیریابی هوشمند را انتخاب کنید (به صورت پیش‌فرض همه فعالند):'
              : 'Select allowed protocols for intelligent routing (all active by default):',
          style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 10),
        ...protocols.map((item) {
          final protoName = item['name']!;
          final isChecked = _selectedProtocols.contains(protoName);

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: isChecked ? VelocityColors.electricCyan.withOpacity(0.10) : VelocityColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isChecked ? VelocityColors.electricCyan : VelocityColors.borderDark,
                width: isChecked ? 1.2 : 1.0,
              ),
            ),
            child: CheckboxListTile(
              dense: true,
              value: isChecked,
              activeColor: VelocityColors.electricCyan,
              checkColor: VelocityColors.pureBlack,
              title: Text(
                protoName,
                style: TextStyle(
                  color: isChecked ? VelocityColors.electricCyan : VelocityColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
              subtitle: Text(
                item['desc']!,
                style: const TextStyle(color: VelocityColors.textMuted, fontSize: 9.5),
              ),
              onChanged: (bool? val) {
                setState(() {
                  if (val == true) {
                    _selectedProtocols.add(protoName);
                  } else {
                    if (_selectedProtocols.length > 1) {
                      _selectedProtocols.remove(protoName);
                    }
                  }
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep3(bool isFa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('wizard_step3_title'),
          style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _vpnPermGranted ? VelocityColors.neonGreen : VelocityColors.borderDark),
          ),
          child: Row(
            children: [
              Icon(_vpnPermGranted ? Icons.check_circle_rounded : Icons.vpn_lock_rounded, color: _vpnPermGranted ? VelocityColors.neonGreen : VelocityColors.electricCyan, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isFa ? 'مجوز ایجاد تونل VPN سیستم‌عامل' : 'System VPN Tunnel Permission',
                  style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final v2 = V2ray(onStatusChanged: (_) {});
                    final g = await v2.requestPermission();
                    if (mounted) setState(() => _vpnPermGranted = g);
                  } catch (_) {
                    if (mounted) setState(() => _vpnPermGranted = true);
                  }
                },
                child: Text(_vpnPermGranted ? (isFa ? 'تایید شد' : 'Granted') : I18n.t('grant_vpn_perm'), style: TextStyle(color: _vpnPermGranted ? VelocityColors.neonGreen : VelocityColors.electricCyan, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _notifPermGranted ? VelocityColors.neonGreen : VelocityColors.borderDark),
          ),
          child: Row(
            children: [
              Icon(_notifPermGranted ? Icons.check_circle_rounded : Icons.notifications_active_rounded, color: _notifPermGranted ? VelocityColors.neonGreen : VelocityColors.deepCyan, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isFa ? 'مجوز اعلان فعال سرویس (Keepalive)' : 'Foreground Service Notification',
                  style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await VelocityNotificationService.requestPermissions();
                  if (mounted) setState(() => _notifPermGranted = true);
                },
                child: Text(_notifPermGranted ? (isFa ? 'تایید شد' : 'Granted') : I18n.t('grant_notif_perm'), style: TextStyle(color: _notifPermGranted ? VelocityColors.neonGreen : VelocityColors.deepCyan, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Root Velocity App
// ---------------------------------------------------------------------------
class VelocityApp extends StatefulWidget {
  const VelocityApp({super.key});

  @override
  State<VelocityApp> createState() => _VelocityAppState();
}

class _VelocityAppState extends State<VelocityApp> {
  AppLanguage _currentLang = AppLanguage.fa;
  bool _isInitialized = false;
  bool _hasCompletedWizard = false;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('app_lang');
      if (lang == 'en') {
        _currentLang = AppLanguage.en;
        I18n.currentLang = AppLanguage.en;
      }
      _hasCompletedWizard = prefs.getBool('has_completed_wizard') ?? false;
    } catch (_) {}
  }

  void _toggleLanguage() async {
    final nextLang = _currentLang == AppLanguage.fa ? AppLanguage.en : AppLanguage.fa;
    setState(() {
      _currentLang = nextLang;
      I18n.currentLang = nextLang;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_lang', nextLang.name);
    } catch (_) {}
  }

  void _setLanguage(AppLanguage lang) async {
    setState(() {
      _currentLang = lang;
      I18n.currentLang = lang;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_lang', lang.name);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isFa = _currentLang == AppLanguage.fa;

    return MaterialApp(
      title: 'Velocity',
      debugShowCheckedModeBanner: false,
      locale: isFa ? const Locale('fa', 'IR') : const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fa', 'IR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: VelocityColors.pureBlack,
        primaryColor: VelocityColors.electricCyan,
        colorScheme: const ColorScheme.dark(
          primary: VelocityColors.electricCyan,
          surface: VelocityColors.surfaceDark,
        ),
      ),
      home: !_isInitialized
          ? VelocitySplashScreen(
              onInitComplete: () {
                setState(() => _isInitialized = true);
              },
            )
          : Directionality(
              textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
              child: HomeScreen(
                onToggleLanguage: _toggleLanguage,
                currentLang: _currentLang,
                showInitialWizard: !_hasCompletedWizard,
                onLanguageChanged: _setLanguage,
              ),
            ),
    );
  }
}

typedef VelocityVpnApp = VelocityApp;

// ---------------------------------------------------------------------------
// Home Screen (Xray Dashboard with Multi-Subscription & Real TCP Ping)
// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleLanguage;
  final Function(AppLanguage) onLanguageChanged;
  final AppLanguage currentLang;
  final bool showInitialWizard;

  const HomeScreen({
    super.key,
    required this.onToggleLanguage,
    required this.onLanguageChanged,
    required this.currentLang,
    this.showInitialWizard = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  static const MethodChannel _platformControl = MethodChannel('com.velocity.vpn/control');

  VpnState _vpnState = VpnState.disconnected;
  bool _isOperationInProgress = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late final V2ray _v2ray;

  // Telemetry
  Timer? _durationTimer;
  int _connectedSeconds = 0;
  String _displayDownloadSpeed = '0.0 KB/s';
  String _displayUploadSpeed = '0.0 KB/s';

  // Server Pool & Multi-Subscriptions Architecture
  final List<ServerProfile> _servers = [];
  final List<SubscriptionItem> _subscriptions = [];
  final List<String> _connectionLogs = [];
  String? _activeSubscriptionId; // Specific Sub ID or 'ALL'
  ServerProfile? _selectedServer;
  SubscriptionInfo? _subscriptionInfo;

  // Telegram Auth
  String? _telegramUsername;
  bool _isTelegramLinked = false;
  String _customBotUrl = 'https://t.me/Velocity_Support';

  // Navigation & Search / Sorting
  int _currentTabIndex = 0;
  String _serverSearchQuery = '';
  ServerSortMode _currentSortMode = ServerSortMode.none;

  bool _bypassIran = true;
  bool _bypassLan = true;
  bool _notificationsEnabled = true;

  static const List<String> _bypassSubnets = [
    '0.0.0.0/8',
    '10.0.0.0/8',
    '100.64.0.0/10',
    '127.0.0.0/8',
    '169.254.0.0/16',
    '172.16.0.0/12',
    '192.0.0.0/24',
    '192.0.2.0/24',
    '192.88.99.0/24',
    '192.168.0.0/16',
    '198.18.0.0/15',
    '198.51.100.0/24',
    '203.0.113.0/24',
    '224.0.0.0/4',
    '240.0.0.0/4',
    '255.255.255.255/32',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initNativeControlChannel();
    _initV2ray();
    _loadPersistedData();

    if (widget.showInitialWizard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSetupWizardModal();
      });
    }
  }

  void _initNativeControlChannel() {
    _platformControl.setMethodCallHandler((call) async {
      if (call.method == 'toggleVpnFromNative') {
        _toggleVpn();
      }
      return null;
    });
  }

  Future<void> _updateNativeTileState(String state) async {
    try {
      final serverName = _selectedServer?.name ?? 'Velocity Node';
      await _platformControl.invokeMethod('updateTileState', {
        'state': state,
        'server': serverName,
      });
    } catch (_) {}
  }

  Future<void> _initV2ray() async {
    _v2ray = V2ray(
      onStatusChanged: (status) {
        if (!mounted) return;
        _handleV2RayStatus(status);
      },
    );

    try {
      await _v2ray.initialize(
        notificationIconResourceType: "mipmap",
        notificationIconResourceName: "ic_launcher",
      );
      _addConnectionLog('[Xray Core] Initialized (Xray-Core v26 Multi-Protocol Engine Ready)');
    } catch (_) {}
  }

  void _handleV2RayStatus(V2RayStatus status) {
    final stateStr = status.state.toUpperCase();
    setState(() {
      if (stateStr.contains('CONNECTED')) {
        _vpnState = VpnState.connected;
      } else if (stateStr.contains('CONNECTING')) {
        _vpnState = VpnState.connecting;
      } else if (stateStr.contains('DISCONNECT') || stateStr.contains('STOP')) {
        _vpnState = VpnState.disconnected;
        _displayDownloadSpeed = '0.0 KB/s';
        _displayUploadSpeed = '0.0 KB/s';
      }

      final dl = status.downloadSpeed.toString();
      final ul = status.uploadSpeed.toString();
      if (dl.isNotEmpty && dl != '0') _displayDownloadSpeed = dl;
      if (ul.isNotEmpty && ul != '0') _displayUploadSpeed = ul;
    });
  }

  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serversJson = prefs.getString('saved_servers');
      final subsJson = prefs.getString('subscription_list');
      final activeSubId = prefs.getString('active_subscription_id');
      final selectedId = prefs.getString('selected_server_id');
      final subJson = prefs.getString('subscription_info');
      final logs = prefs.getStringList('velocity_connection_logs');

      _telegramUsername = prefs.getString('telegram_username');
      _isTelegramLinked = prefs.getBool('telegram_linked') ?? false;
      _customBotUrl = prefs.getString('custom_bot_url') ?? 'https://t.me/Velocity_Support';

      if (logs != null && logs.isNotEmpty) {
        setState(() {
          _connectionLogs.clear();
          _connectionLogs.addAll(logs);
        });
      } else {
        setState(() {
          _connectionLogs.clear();
          _connectionLogs.addAll([
            '[${_formatTimestamp(DateTime.now())}] Velocity Xray-Core v26 engine loaded',
            '[${_formatTimestamp(DateTime.now())}] Native TUN VPN tunnel driver ready',
          ]);
        });
      }

      // 1. Load Subscriptions
      if (subsJson != null && subsJson.isNotEmpty) {
        final List<dynamic> decodedSubs = jsonDecode(subsJson);
        final loadedSubs = decodedSubs
            .map((item) => SubscriptionItem.fromJson(item as Map<String, dynamic>))
            .toList();
        setState(() {
          _subscriptions.clear();
          _subscriptions.addAll(loadedSubs);
        });
      }

      // 2. Set active subscription ID
      if (activeSubId != null && activeSubId.isNotEmpty) {
        _activeSubscriptionId = activeSubId;
      } else if (_subscriptions.isNotEmpty) {
        _activeSubscriptionId = _subscriptions.first.id;
      } else {
        _activeSubscriptionId = 'ALL';
      }

      // 3. Load Saved Servers
      if (serversJson != null && serversJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(serversJson);
        final loadedServers = decodedList
            .map((item) => ServerProfile.fromJson(item as Map<String, dynamic>))
            .toList();
        if (loadedServers.isNotEmpty) {
          setState(() {
            _servers.clear();
            _servers.addAll(loadedServers);
          });
        }
      }

      // Rebuild pool if subscriptions exist
      if (_subscriptions.isNotEmpty) {
        _rebuildServerPool();
      }

      // Restore selected server
      final visible = _visibleServers;
      if (visible.isNotEmpty) {
        if (selectedId != null) {
          _selectedServer = visible.firstWhere((s) => s.id == selectedId, orElse: () => visible.first);
        } else {
          _selectedServer = visible.first;
        }
      }

      if (subJson != null && subJson.isNotEmpty) {
        final subMap = jsonDecode(subJson) as Map<String, dynamic>;
        setState(() {
          _subscriptionInfo = SubscriptionInfo.fromJson(subMap);
        });
      }

      final savedBypassIran = prefs.getBool('bypass_iran_enabled');
      final savedBypassLan = prefs.getBool('bypass_lan_enabled');
      final savedNotifications = prefs.getBool('notifications_enabled');
      setState(() {
        if (savedBypassIran != null) _bypassIran = savedBypassIran;
        if (savedBypassLan != null) _bypassLan = savedBypassLan;
        if (savedNotifications != null) _notificationsEnabled = savedNotifications;
      });
    } catch (_) {}
  }

  void _rebuildServerPool() {
    final Map<String, ServerProfile> uniqueServers = {};

    // Keep manual configs
    for (var s in _servers) {
      if (s.subscriptionId == null && s.rawUrl.isNotEmpty) {
        uniqueServers[s.rawUrl] = s;
      }
    }

    // Add subscription configs stamped with subscriptionId
    for (var sub in _subscriptions) {
      for (var s in sub.servers) {
        s.subscriptionId = sub.id;
        if (s.rawUrl.isNotEmpty) {
          uniqueServers[s.rawUrl] = s;
        }
      }
    }

    setState(() {
      _servers.clear();
      _servers.addAll(uniqueServers.values);

      final visible = _visibleServers;
      if (_selectedServer != null) {
        _selectedServer = visible.firstWhere(
          (s) => s.id == _selectedServer!.id || s.rawUrl == _selectedServer!.rawUrl,
          orElse: () => visible.isNotEmpty ? visible.first : _selectedServer!,
        );
      } else if (visible.isNotEmpty) {
        _selectedServer = visible.first;
      }
    });

    _savePersistedData();
  }

  // Active Subscription Getter & Visible Servers
  SubscriptionItem? get _currentActiveSubscription {
    if (_subscriptions.isEmpty) return null;
    if (_activeSubscriptionId == null || _activeSubscriptionId == 'ALL') {
      return _subscriptions.first;
    }
    return _subscriptions.firstWhere(
      (s) => s.id == _activeSubscriptionId,
      orElse: () => _subscriptions.first,
    );
  }

  List<ServerProfile> get _visibleServers {
    if (_activeSubscriptionId == null || _activeSubscriptionId == 'ALL') {
      return _servers;
    }
    return _servers.where((s) => s.subscriptionId == _activeSubscriptionId).toList();
  }

  void _switchActiveSubscription(String subId) {
    setState(() {
      _activeSubscriptionId = subId;
      final visible = _visibleServers;
      if (_selectedServer == null || !visible.any((s) => s.id == _selectedServer!.id)) {
        _selectedServer = visible.isNotEmpty ? visible.first : null;
      }
    });
    _savePersistedData();
  }

  Future<void> _savePersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serversJson = jsonEncode(_servers.map((s) => s.toJson()).toList());
      await prefs.setString('saved_servers', serversJson);

      final subsJson = jsonEncode(_subscriptions.map((sub) => sub.toJson()).toList());
      await prefs.setString('subscription_list', subsJson);

      if (_activeSubscriptionId != null) {
        await prefs.setString('active_subscription_id', _activeSubscriptionId!);
      }

      if (_selectedServer != null) {
        await prefs.setString('selected_server_id', _selectedServer!.id);
      } else {
        await prefs.remove('selected_server_id');
      }
      if (_subscriptionInfo != null) {
        await prefs.setString('subscription_info', jsonEncode(_subscriptionInfo!.toJson()));
      }
    } catch (_) {}
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _addConnectionLog(String message) async {
    final entry = message.startsWith('[')
        ? message
        : '[${_formatTimestamp(DateTime.now())}] $message';
    setState(() {
      _connectionLogs.insert(0, entry);
      if (_connectionLogs.length > 200) {
        _connectionLogs.removeLast();
      }
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('velocity_connection_logs', _connectionLogs);
    } catch (_) {}
  }

  @override
  void dispose() {
    VelocityNotificationService.cancelVpnNotification();
    _pulseController.dispose();
    _durationTimer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Connect / Disconnect Action (Clean Disconnect Engine)
  // -------------------------------------------------------------------------
  Future<void> _toggleVpn() async {
    if (_isOperationInProgress) {
      if (_vpnState == VpnState.connecting) {
        _forceImmediateDisconnect();
      }
      return;
    }

    if (_vpnState == VpnState.connected || _vpnState == VpnState.connecting) {
      await _disconnectVpn();
    } else {
      await _connectVpn();
    }
  }

  Future<void> _forceImmediateDisconnect() async {
    _isOperationInProgress = false;
    _durationTimer?.cancel();
    _durationTimer = null;
    setState(() {
      _vpnState = VpnState.disconnected;
      _displayDownloadSpeed = '0.0 KB/s';
      _displayUploadSpeed = '0.0 KB/s';
    });
    _updateNativeTileState('disconnected');
    await VelocityNotificationService.cancelVpnNotification();
    try {
      _v2ray.stopV2Ray();
    } catch (_) {}
  }

  Future<void> _connectVpn() async {
    final visible = _visibleServers;
    if (_selectedServer == null || visible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: VelocityColors.surfaceElevated,
          content: Text(
            I18n.t('no_nodes_available'),
            style: const TextStyle(color: VelocityColors.neonYellow, fontWeight: FontWeight.bold),
          ),
          action: SnackBarAction(
            label: I18n.t('import_config'),
            textColor: VelocityColors.electricCyan,
            onPressed: _showImportDialog,
          ),
        ),
      );
      _showImportDialog();
      return;
    }

    _isOperationInProgress = true;
    bool granted = false;
    try {
      granted = await _v2ray.requestPermission();
    } catch (_) {
      granted = true;
    }

    if (!granted) {
      _isOperationInProgress = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: VelocityColors.surfaceElevated,
            content: Text(
              I18n.t('perm_declined'),
              style: const TextStyle(color: VelocityColors.neonPink),
            ),
          ),
        );
      }
      return;
    }

    setState(() => _vpnState = VpnState.connecting);
    _updateNativeTileState('connecting');
    _pulseController.duration = const Duration(milliseconds: 700);
    _pulseController.repeat(reverse: true);

    final server = _selectedServer!;
    _addConnectionLog('[Xray Connecting] Initializing tunnel: ${server.name} (${server.host}:${server.port})');

    try {
      String fullConfig;
      try {
        final parser = V2ray.parseFromURL(server.rawUrl);
        fullConfig = parser.getFullConfiguration();
      } catch (_) {
        fullConfig = server.rawUrl;
      }

      final bypassList = (_bypassIran || _bypassLan) ? _bypassSubnets : null;

      await _v2ray.startV2Ray(
        remark: server.name,
        config: fullConfig,
        proxyOnly: false,
        bypassSubnets: bypassList,
        notificationDisconnectButtonName: "DISCONNECT",
      );

      _pulseController.duration = const Duration(milliseconds: 1800);
      _pulseController.repeat(reverse: true);

      setState(() {
        _vpnState = VpnState.connected;
        _connectedSeconds = 0;
      });

      _startDurationTimer();
      _addConnectionLog('[Xray Connected] Tunnel active via ${server.protocol.label}');
      _updateNativeTileState('connected');

      if (_notificationsEnabled) {
        await VelocityNotificationService.showVpnConnectedNotification(
          serverName: server.name,
          pingMs: server.pingMs,
        );
      }
    } catch (err) {
      _pulseController.duration = const Duration(milliseconds: 1800);
      _pulseController.repeat(reverse: true);
      setState(() => _vpnState = VpnState.disconnected);
      _updateNativeTileState('disconnected');
      _addConnectionLog('[Xray Connection Failed] $err');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: VelocityColors.neonPink,
            content: Text('Xray connection error: $err'),
          ),
        );
      }
    } finally {
      _isOperationInProgress = false;
    }
  }

  Future<void> _disconnectVpn() async {
    // 1. Immediately set state to disconnected & reset speeds
    _isOperationInProgress = false;
    _durationTimer?.cancel();
    _durationTimer = null;

    setState(() {
      _vpnState = VpnState.disconnected;
      _displayDownloadSpeed = '0.0 KB/s';
      _displayUploadSpeed = '0.0 KB/s';
    });

    _addConnectionLog('[Xray Disconnected] Tunnel closed.');
    _updateNativeTileState('disconnected');

    // 2. Immediately cancel and dismiss foreground notification
    await VelocityNotificationService.cancelVpnNotification();

    // 3. Terminate Xray core cleanly
    try {
      _v2ray.stopV2Ray();
    } catch (_) {}
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _connectedSeconds++);
    });
  }

  String _formattedDuration() {
    final hours = _connectedSeconds ~/ 3600;
    final minutes = (_connectedSeconds % 3600) ~/ 60;
    final seconds = _connectedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // -------------------------------------------------------------------------
  // Hiddify-Style Real TCP Ping Engine (Sub-200ms Latency & 10-Node Batches)
  // -------------------------------------------------------------------------
  static Future<int> _testHiddifyTcpLatency(String host, int port, {Duration timeout = const Duration(milliseconds: 1500)}) async {
    final sw = Stopwatch()..start();
    try {
      final socket = await Socket.connect(host.trim(), port, timeout: timeout);
      sw.stop();
      socket.destroy();
      return sw.elapsedMilliseconds;
    } catch (_) {
      sw.stop();
      return -1;
    }
  }

  Future<void> _pingAllServers() async {
    final visible = List<ServerProfile>.from(_visibleServers);
    if (visible.isEmpty) return;

    _addConnectionLog('[TCP Ping] Checking real-time TCP latency for ${visible.length} nodes...');

    const chunkSize = 10;
    for (var i = 0; i < visible.length; i += chunkSize) {
      if (!mounted || _vpnState == VpnState.disconnecting) break;
      final end = (i + chunkSize < visible.length) ? i + chunkSize : visible.length;
      final chunk = visible.sublist(i, end);
      await Future.wait(chunk.map((server) => _testServerTcpLatency(server, log: false)));
    }

    if (mounted) {
      setState(() {});
      _addConnectionLog('[TCP Ping] All node latencies updated.');
    }
  }

  Future<void> _testServerTcpLatency(ServerProfile server, {bool log = true}) async {
    if (server.isTesting) return;
    setState(() => server.isTesting = true);

    final delay = await _testHiddifyTcpLatency(server.host, server.port);

    if (mounted) {
      setState(() {
        server.pingMs = delay;
        server.isTesting = false;
      });
      if (log) {
        _addConnectionLog('[Latency] ${server.name}: ${delay > 0 ? "${delay}ms" : "Timeout"}');
      }
    }
  }

  // -------------------------------------------------------------------------
  // Filtered & Sorted Visible Servers
  // -------------------------------------------------------------------------
  List<ServerProfile> get _filteredAndSortedServers {
    List<ServerProfile> list = List.from(_visibleServers);

    if (_serverSearchQuery.trim().isNotEmpty) {
      final q = _serverSearchQuery.trim().toLowerCase();
      list = list.where((s) {
        final matchName = s.name.toLowerCase().contains(q);
        final matchCountry = s.countryCode.toLowerCase().contains(q);
        final matchHost = s.host.toLowerCase().contains(q);
        final matchProto = s.protocol.name.toLowerCase().contains(q);
        return matchName || matchCountry || matchHost || matchProto;
      }).toList();
    }

    switch (_currentSortMode) {
      case ServerSortMode.latency:
        list.sort((a, b) {
          final pA = (a.pingMs != null && a.pingMs! > 0) ? a.pingMs! : 999999;
          final pB = (b.pingMs != null && b.pingMs! > 0) ? b.pingMs! : 999999;
          return pA.compareTo(pB);
        });
        break;
      case ServerSortMode.name:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case ServerSortMode.protocol:
        list.sort((a, b) => a.protocol.index.compareTo(b.protocol.index));
        break;
      case ServerSortMode.none:
        break;
    }

    return list;
  }

  // -------------------------------------------------------------------------
  // Telegram Support Launcher
  // -------------------------------------------------------------------------
  Future<void> _openTelegramSupport() async {
    try {
      final uri = Uri.parse('https://t.me/Velocity_Support');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _openCustomBot() async {
    try {
      final uri = Uri.parse(_customBotUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Setup Wizard Modal
  // -------------------------------------------------------------------------
  void _showSetupWizardModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VelocitySetupWizardDialog(
        initialLang: widget.currentLang,
        onLanguageChanged: widget.onLanguageChanged,
        onCompleted: () {
          Navigator.pop(ctx);
          setState(() {});
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Main UI Scaffold & Bottom Navigation
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelocityColors.pureBlack,
      appBar: _buildTopAppBar(),
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildHomeTab(),
            _buildServersTab(),
            _buildVipTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: VelocityColors.midnightBg,
          border: Border(top: BorderSide(color: VelocityColors.borderDark, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) => setState(() => _currentTabIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: VelocityColors.electricCyan,
          unselectedItemColor: VelocityColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.power_settings_new_rounded),
              label: I18n.t('tab_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.dns_rounded),
              label: I18n.t('tab_servers'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.star_rounded),
              label: I18n.t('tab_vip'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.tune_rounded),
              label: I18n.t('tab_settings'),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Top App Bar
  // -------------------------------------------------------------------------
  PreferredSizeWidget _buildTopAppBar() {
    final isConnected = _vpnState == VpnState.connected;
    final isFa = widget.currentLang == AppLanguage.fa;

    return AppBar(
      backgroundColor: VelocityColors.midnightBg,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          VelocityEmblemWidget(size: 34, isConnected: isConnected),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                I18n.t('app_title'),
                style: const TextStyle(
                  color: VelocityColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                I18n.t('subtitle_tagline'),
                style: const TextStyle(
                  color: VelocityColors.electricCyan,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.translate_rounded, color: VelocityColors.electricCyan, size: 20),
          tooltip: isFa ? 'تغییر به انگلیسی' : 'Switch to Persian',
          onPressed: widget.onToggleLanguage,
        ),
        IconButton(
          icon: const Icon(Icons.terminal_rounded, color: VelocityColors.textSecondary, size: 20),
          tooltip: I18n.t('btn_logs'),
          onPressed: _showConnectionLogViewer,
        ),
        const SizedBox(width: 6),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: VelocityColors.borderDark, height: 1.0),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab 0: Home Dashboard
  // -------------------------------------------------------------------------
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          _buildConnectionStatusHeader(),
          const SizedBox(height: 24),
          _buildGlowingPowerButton(),
          const SizedBox(height: 28),
          _buildTelemetryCard(),
          const SizedBox(height: 18),
          _buildSubscriptionSwitcherBar(),
          const SizedBox(height: 14),
          _buildActiveServerCard(),
          const SizedBox(height: 16),
          _buildActiveSubscriptionQuotaCard(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusHeader() {
    final isConnected = _vpnState == VpnState.connected;
    final isConnecting = _vpnState == VpnState.connecting;

    final statusColor = isConnected
        ? VelocityColors.neonGreen
        : isConnecting
            ? VelocityColors.electricCyan
            : VelocityColors.textMuted;

    final statusText = isConnected
        ? I18n.t('status_connected')
        : isConnecting
            ? I18n.t('status_connecting')
            : I18n.t('status_disconnected');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        if (isConnected) ...[
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              _formattedDuration(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: VelocityColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGlowingPowerButton() {
    final visible = _visibleServers;
    final hasServers = visible.isNotEmpty && _selectedServer != null;
    final isConnected = _vpnState == VpnState.connected;
    final isConnecting = _vpnState == VpnState.connecting;

    final glowColor = !hasServers
        ? VelocityColors.textMuted
        : isConnected
            ? VelocityColors.neonGreen
            : VelocityColors.electricCyan;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = (hasServers && (isConnected || isConnecting)) ? _pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: !hasServers ? _showImportDialog : _toggleVpn,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: hasServers
                    ? [
                        BoxShadow(
                          color: glowColor.withOpacity(isConnected ? 0.35 : 0.18),
                          blurRadius: 40,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: VelocityColors.deepCyan.withOpacity(0.18),
                          blurRadius: 55,
                          spreadRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: glowColor.withOpacity(hasServers ? 0.25 : 0.12),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          glowColor.withOpacity(hasServers ? (isConnected ? 0.28 : 0.10) : 0.03),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(color: glowColor, width: 2.2),
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          VelocityColors.surfaceElevated,
                          VelocityColors.pureBlack,
                        ],
                      ),
                      border: Border.all(
                        color: hasServers
                            ? (isConnected ? glowColor : VelocityColors.borderDark)
                            : VelocityColors.borderDark,
                        width: 1.8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isConnecting)
                          SizedBox(
                            width: 38,
                            height: 38,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                              strokeWidth: 3,
                            ),
                          )
                        else
                          Icon(
                            Icons.power_settings_new_rounded,
                            size: 46,
                            color: glowColor,
                          ),
                        const SizedBox(height: 6),
                        Text(
                          !hasServers
                              ? (widget.currentLang == AppLanguage.fa ? 'بدون سرور' : 'NO SERVER')
                              : isConnected
                                  ? I18n.t('tap_to_disconnect')
                                  : I18n.t('tap_to_connect'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: glowColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTelemetryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: VelocityColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VelocityColors.borderDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelocityColors.electricCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_downward, color: VelocityColors.electricCyan, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        I18n.t('download_speed'),
                        style: const TextStyle(fontSize: 10, color: VelocityColors.textSecondary),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          _displayDownloadSpeed,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: VelocityColors.electricCyan,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: VelocityColors.borderDark),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelocityColors.deepCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_upward, color: VelocityColors.deepCyan, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        I18n.t('upload_speed'),
                        style: const TextStyle(fontSize: 10, color: VelocityColors.textSecondary),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          _displayUploadSpeed,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: VelocityColors.deepCyan,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Subscription Switcher Bar (Home & Servers Tab Sync)
  // -------------------------------------------------------------------------
  Widget _buildSubscriptionSwitcherBar() {
    if (_subscriptions.isEmpty) return const SizedBox.shrink();

    final activeSub = _currentActiveSubscription;
    final isAll = _activeSubscriptionId == 'ALL';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: VelocityColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VelocityColors.deepCyan.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_shared_rounded, color: VelocityColors.deepCyan, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  I18n.t('active_sub'),
                  style: const TextStyle(color: VelocityColors.textMuted, fontSize: 9.5),
                ),
                Text(
                  isAll ? I18n.t('all_subscriptions') : (activeSub?.name ?? 'Subscription'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: VelocityColors.deepCyan, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onPressed: _showSubscriptionPickerSheet,
            icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: VelocityColors.deepCyan),
            label: Text(
              widget.currentLang == AppLanguage.fa ? 'تغییر' : 'Switch',
              style: const TextStyle(color: VelocityColors.deepCyan, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: VelocityColors.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: VelocityColors.deepCyan, width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              I18n.t('manage_subscriptions'),
              style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              tileColor: _activeSubscriptionId == 'ALL' ? VelocityColors.deepCyan.withOpacity(0.15) : null,
              leading: const Icon(Icons.layers_rounded, color: VelocityColors.deepCyan),
              title: Text(I18n.t('all_subscriptions'), style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${_servers.length} nodes', style: const TextStyle(color: VelocityColors.textMuted, fontSize: 11)),
              trailing: _activeSubscriptionId == 'ALL' ? const Icon(Icons.check_circle_rounded, color: VelocityColors.deepCyan) : null,
              onTap: () {
                _switchActiveSubscription('ALL');
                Navigator.pop(ctx);
              },
            ),
            ..._subscriptions.map((sub) {
              final isSel = _activeSubscriptionId == sub.id;
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tileColor: isSel ? VelocityColors.deepCyan.withOpacity(0.15) : null,
                leading: const Icon(Icons.folder_outlined, color: VelocityColors.deepCyan),
                title: Text(sub.name, style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${sub.servers.length} nodes | ${sub.trafficUsageFormatted}', style: const TextStyle(color: VelocityColors.textMuted, fontSize: 11)),
                trailing: isSel ? const Icon(Icons.check_circle_rounded, color: VelocityColors.deepCyan) : null,
                onTap: () {
                  _switchActiveSubscription(sub.id);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveServerCard() {
    final visible = _visibleServers;
    if (_selectedServer == null || visible.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: VelocityColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.4), width: 1.2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showImportDialog,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: VelocityColors.electricCyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.cloud_download_rounded, color: VelocityColors.electricCyan, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          I18n.t('no_nodes_available'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: VelocityColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '+ ${I18n.t('import_config')}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: VelocityColors.electricCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: VelocityColors.electricCyan),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final server = _selectedServer!;

    return InkWell(
      onTap: _showServerSelectBottomSheet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: VelocityColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VelocityColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: VelocityColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: VelocityColors.borderDark),
              ),
              child: Text(server.countryCode, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: VelocityColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: VelocityColors.electricCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          server.protocol.label,
                          style: const TextStyle(
                            color: VelocityColors.electricCyan,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${server.host}:${server.port}',
                        style: const TextStyle(fontSize: 11, color: VelocityColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildPingChip(server),
          ],
        ),
      ),
    );
  }

  // Bind strictly to currently active subscription
  Widget _buildActiveSubscriptionQuotaCard() {
    final sub = _currentActiveSubscription;
    if (sub == null && _subscriptionInfo == null) return const SizedBox.shrink();

    final planName = sub?.planName ?? _subscriptionInfo!.planName;
    final expiryFormatted = sub?.expiryDateFormatted ?? _subscriptionInfo!.expiryDateFormatted;
    final progress = sub?.quotaProgress ?? _subscriptionInfo!.quotaProgress;
    final usage = sub?.trafficUsageFormatted ?? _subscriptionInfo!.trafficUsageFormatted;
    final total = sub?.trafficTotalFormatted ?? _subscriptionInfo!.trafficTotalFormatted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VelocityColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VelocityColors.deepCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart_outline_rounded, color: VelocityColors.deepCyan, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    planName,
                    style: const TextStyle(
                      color: VelocityColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                '${I18n.t('sub_expiry')} $expiryFormatted',
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: VelocityColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(VelocityColors.deepCyan),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: $usage',
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
              ),
              Text(
                'Total: $total',
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Server Selection Bottom Sheet (Synced with Servers Tab)
  // -------------------------------------------------------------------------
  void _showServerSelectBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isFa = widget.currentLang == AppLanguage.fa;
          final displayServers = _filteredAndSortedServers;

          return Directionality(
            textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.80,
              decoration: const BoxDecoration(
                color: VelocityColors.surfaceDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: VelocityColors.electricCyan, width: 1.5)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VelocityColors.borderDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          I18n.t('select_server'),
                          style: const TextStyle(
                            color: VelocityColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: VelocityColors.textSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Live Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: VelocityColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: VelocityColors.borderDark),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() => _serverSearchQuery = val);
                          setSheetState(() {});
                        },
                        style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: I18n.t('search_nodes'),
                          hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 11),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: VelocityColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),

                  // Sort Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSortChip(ServerSortMode.latency, I18n.t('sort_latency'), Icons.speed_rounded, setSheetState),
                          const SizedBox(width: 8),
                          _buildSortChip(ServerSortMode.name, I18n.t('sort_name'), Icons.sort_by_alpha_rounded, setSheetState),
                          const SizedBox(width: 8),
                          _buildSortChip(ServerSortMode.protocol, I18n.t('sort_protocol'), Icons.layers_rounded, setSheetState),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: VelocityColors.borderDark),

                  Expanded(
                    child: displayServers.isEmpty
                        ? Center(
                            child: Text(
                              _visibleServers.isEmpty ? I18n.t('no_nodes_available') : I18n.t('no_nodes_found'),
                              style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 12),
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayServers.length,
                            itemBuilder: (context, idx) {
                              final s = displayServers[idx];
                              final isSelected = _selectedServer?.id == s.id;
                              return ListTile(
                                leading: Text(s.countryCode, style: const TextStyle(fontSize: 22)),
                                title: Text(s.name, style: TextStyle(color: isSelected ? VelocityColors.electricCyan : VelocityColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                                subtitle: Text('${s.protocol.label} | ${s.host}:${s.port}', style: const TextStyle(color: VelocityColors.textMuted, fontSize: 10)),
                                trailing: _buildPingChip(s),
                                onTap: () {
                                  setState(() => _selectedServer = s);
                                  _savePersistedData();
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortChip(ServerSortMode mode, String label, IconData icon, [StateSetter? setSheetState]) {
    final isSelected = _currentSortMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _currentSortMode = isSelected ? ServerSortMode.none : mode;
        });
        if (setSheetState != null) setSheetState(() {});
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? VelocityColors.electricCyan.withOpacity(0.18) : VelocityColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? VelocityColors.electricCyan : VelocityColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: isSelected ? VelocityColors.electricCyan : VelocityColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab 1: Dedicated Servers Tab (With Multi-Subscription Management)
  // -------------------------------------------------------------------------
  Widget _buildServersTab() {
    final displayServers = _filteredAndSortedServers;

    return Column(
      children: [
        // Subscriptions & Servers Header Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.dns_rounded, color: VelocityColors.electricCyan, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    I18n.t('tab_servers'),
                    style: const TextStyle(
                      color: VelocityColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: VelocityColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: VelocityColors.borderDark),
                    ),
                    child: Text(
                      '${_visibleServers.length}',
                      style: const TextStyle(
                        color: VelocityColors.electricCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: VelocityColors.deepCyan, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: VelocityColors.deepCyan.withOpacity(0.08),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    onPressed: _showSubscriptionManagerSheet,
                    icon: const Icon(Icons.folder_shared_rounded, color: VelocityColors.deepCyan, size: 15),
                    label: Text(
                      I18n.t('manage_subscriptions'),
                      style: const TextStyle(
                        color: VelocityColors.deepCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (_visibleServers.isNotEmpty)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: VelocityColors.electricCyan, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: VelocityColors.electricCyan.withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                      onPressed: _pingAllServers,
                      icon: const Icon(Icons.bolt, color: VelocityColors.electricCyan, size: 15),
                      label: Text(
                        I18n.t('ping_all'),
                        style: const TextStyle(
                          color: VelocityColors.electricCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Subscription Switcher Quick Pill
        _buildSubscriptionSwitcherBar(),
        const SizedBox(height: 6),

        // Live Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: VelocityColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: VelocityColors.borderDark),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _serverSearchQuery = val),
              style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: I18n.t('search_nodes'),
                hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 11),
                prefixIcon: const Icon(Icons.search_rounded, size: 16, color: VelocityColors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),

        // Sort Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortChip(ServerSortMode.latency, I18n.t('sort_latency'), Icons.speed_rounded),
                const SizedBox(width: 8),
                _buildSortChip(ServerSortMode.name, I18n.t('sort_name'), Icons.sort_by_alpha_rounded),
                const SizedBox(width: 8),
                _buildSortChip(ServerSortMode.protocol, I18n.t('sort_protocol'), Icons.layers_rounded),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Server List
        Expanded(
          child: displayServers.isEmpty
              ? _buildEmptyState(
                  title: _visibleServers.isEmpty ? I18n.t('no_nodes_available') : I18n.t('no_nodes_found'),
                  subtitle: _visibleServers.isEmpty
                      ? (widget.currentLang == AppLanguage.fa
                          ? 'هیچ سروری در این سابسکریپشن وجود ندارد.'
                          : 'No servers in this subscription.')
                      : (widget.currentLang == AppLanguage.fa
                          ? 'سروری با فیلتر جستجو یافت نشد.'
                          : 'No server matches current filter.'),
                  buttonLabel: I18n.t('import_config'),
                  onAction: _showImportDialog,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: displayServers.length,
                  itemBuilder: (context, idx) {
                    final server = displayServers[idx];
                    final isSelected = _selectedServer?.id == server.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? VelocityColors.electricCyan.withOpacity(0.08)
                            : VelocityColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark,
                          width: isSelected ? 1.2 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() => _selectedServer = server);
                          _savePersistedData();
                        },
                        leading: Text(server.countryCode, style: const TextStyle(fontSize: 22)),
                        title: Text(
                          server.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? VelocityColors.electricCyan : VelocityColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: VelocityColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                server.protocol.label,
                                style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${server.host}:${server.port}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: VelocityColors.textMuted, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPingChip(server),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: VelocityColors.textMuted),
                              onPressed: () {
                                setState(() {
                                  _servers.removeWhere((s) => s.id == server.id);
                                  for (var sub in _subscriptions) {
                                    sub.servers.removeWhere((s) => s.id == server.id);
                                  }
                                  final visible = _visibleServers;
                                  if (_selectedServer?.id == server.id) {
                                    _selectedServer = visible.isNotEmpty ? visible.first : null;
                                  }
                                });
                                _savePersistedData();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPingChip(ServerProfile server) {
    if (server.isTesting) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(VelocityColors.electricCyan)),
      );
    }

    final ping = server.pingMs;
    final color = ping == null || ping <= 0
        ? VelocityColors.textMuted
        : ping < 180
            ? VelocityColors.neonGreen
            : ping < 350
                ? VelocityColors.neonYellow
                : VelocityColors.neonPink;

    final text = ping == null
        ? '---'
        : ping <= 0
            ? 'Timeout'
            : '${ping}ms';

    return InkWell(
      onTap: () => _testServerTcpLatency(server),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Multi-Subscription Manager Bottom Sheet
  // -------------------------------------------------------------------------
  void _showSubscriptionManagerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isFa = widget.currentLang == AppLanguage.fa;

          return Directionality(
            textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: VelocityColors.surfaceDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: VelocityColors.deepCyan, width: 1.5)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VelocityColors.borderDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.folder_shared_rounded, color: VelocityColors.deepCyan, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              I18n.t('manage_subscriptions'),
                              style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VelocityColors.deepCyan,
                            foregroundColor: VelocityColors.pureBlack,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          onPressed: () => _showAddSubscriptionDialog(setSheetState),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(I18n.t('add_subscription'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: VelocityColors.borderDark),

                  Expanded(
                    child: _subscriptions.isEmpty
                        ? _buildEmptyState(
                            title: I18n.t('no_active_subscription'),
                            subtitle: isFa ? 'هنوز هیچ سابسکریپشنی اضافه نشده است.' : 'No subscription URLs saved yet.',
                            buttonLabel: I18n.t('add_subscription'),
                            onAction: () => _showAddSubscriptionDialog(setSheetState),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _subscriptions.length,
                            itemBuilder: (context, idx) {
                              final sub = _subscriptions[idx];
                              final isCurrentActive = _activeSubscriptionId == sub.id;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: VelocityColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrentActive ? VelocityColors.electricCyan : (sub.isActive ? VelocityColors.deepCyan : VelocityColors.borderDark),
                                    width: isCurrentActive ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                sub.name,
                                                style: TextStyle(
                                                  color: isCurrentActive ? VelocityColors.electricCyan : VelocityColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, size: 16, color: VelocityColors.textMuted),
                                                onPressed: () => _showEditSubNameDialog(sub, setSheetState),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isCurrentActive)
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: VelocityColors.surfaceDark,
                                              side: const BorderSide(color: VelocityColors.electricCyan),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                            onPressed: () {
                                              _switchActiveSubscription(sub.id);
                                              setSheetState(() {});
                                            },
                                            child: Text(
                                              I18n.t('set_active_btn'),
                                              style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: VelocityColors.electricCyan.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: VelocityColors.electricCyan),
                                            ),
                                            child: Text(
                                              I18n.t('active_sub'),
                                              style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 9.5, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${sub.servers.length} nodes | Expiry: ${sub.expiryDateFormatted}',
                                      style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: sub.quotaProgress,
                                        backgroundColor: VelocityColors.surfaceDark,
                                        valueColor: const AlwaysStoppedAnimation(VelocityColors.deepCyan),
                                        minHeight: 5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${sub.trafficUsageFormatted} / ${sub.trafficTotalFormatted}',
                                          style: const TextStyle(color: VelocityColors.textMuted, fontSize: 10),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.refresh_rounded, size: 18, color: VelocityColors.electricCyan),
                                              onPressed: () => _refreshSingleSubscription(sub, setSheetState),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: VelocityColors.neonPink),
                                              onPressed: () => _confirmDeleteSubscription(sub, setSheetState),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddSubscriptionDialog(StateSetter setSheetState) {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    bool isFetching = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VelocityColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: VelocityColors.borderDark)),
          title: Text(I18n.t('add_subscription'), style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: I18n.t('sub_name_label'),
                  hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 11),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: I18n.t('sub_url_label'),
                  hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 11),
                ),
              ),
              if (isFetching) ...[
                const SizedBox(height: 14),
                const LinearProgressIndicator(color: VelocityColors.deepCyan),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(I18n.t('cancel'), style: const TextStyle(color: VelocityColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: VelocityColors.deepCyan, foregroundColor: VelocityColors.pureBlack),
              onPressed: isFetching
                  ? null
                  : () async {
                      final url = urlCtrl.text.trim();
                      if (url.isEmpty) return;
                      setDialogState(() => isFetching = true);

                      try {
                        final uri = Uri.parse(url);
                        final response = await http.get(
                          uri,
                          headers: {
                            'User-Agent': 'v2rayNG/1.8.0 sing-box/1.8.0 VelocityVPN/1.0',
                            'Accept': '*/*',
                          },
                        ).timeout(const Duration(seconds: 15));

                        if (response.statusCode >= 200 && response.statusCode < 300) {
                          String? userInfoHeader;
                          response.headers.forEach((k, v) {
                            if (k.toLowerCase() == 'subscription-userinfo') userInfoHeader = v;
                          });

                          final subId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
                          final subInfo = SubscriptionInfo.fromHeader(userInfoHeader, url);
                          final parsedServers = ConfigLinkParser.parseMultiple(response.body, subscriptionId: subId);

                          final newSub = SubscriptionItem(
                            id: subId,
                            name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'Subscription ${_subscriptions.length + 1}',
                            url: url,
                            upload: subInfo.uploadBytes,
                            download: subInfo.downloadBytes,
                            total: subInfo.totalBytes,
                            expire: subInfo.expireTimestamp,
                            isActive: true,
                            servers: parsedServers,
                          );

                          setState(() {
                            _subscriptions.add(newSub);
                            _activeSubscriptionId = newSub.id;
                            _subscriptionInfo = subInfo;
                          });
                          _rebuildServerPool();
                          setSheetState(() {});

                          if (mounted) Navigator.pop(dialogCtx);
                        } else {
                          throw Exception('HTTP ${response.statusCode}');
                        }
                      } catch (err) {
                        setDialogState(() => isFetching = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: VelocityColors.neonPink, content: Text('${I18n.t('import_failed')}: $err')),
                          );
                        }
                      }
                    },
              child: Text(I18n.t('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSubNameDialog(SubscriptionItem sub, StateSetter setSheetState) {
    final ctrl = TextEditingController(text: sub.name);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: VelocityColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(I18n.t('edit_subscription'), style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(I18n.t('cancel'))),
          ElevatedButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                setState(() => sub.name = newName);
                _savePersistedData();
                setSheetState(() {});
              }
              Navigator.pop(dialogCtx);
            },
            child: Text(I18n.t('save')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSubscription(SubscriptionItem sub, StateSetter setSheetState) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: VelocityColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(I18n.t('delete_sub_confirm'), style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(I18n.t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VelocityColors.neonPink),
            onPressed: () {
              setState(() {
                _subscriptions.removeWhere((item) => item.id == sub.id);
                _servers.removeWhere((s) => s.subscriptionId == sub.id);

                if (_activeSubscriptionId == sub.id) {
                  _activeSubscriptionId = _subscriptions.isNotEmpty ? _subscriptions.first.id : 'ALL';
                }

                final visible = _visibleServers;
                if (_selectedServer?.subscriptionId == sub.id) {
                  _selectedServer = visible.isNotEmpty ? visible.first : null;
                }
              });
              _rebuildServerPool();
              setSheetState(() {});
              Navigator.pop(dialogCtx);
            },
            child: Text(I18n.t('delete')),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshSingleSubscription(SubscriptionItem sub, StateSetter setSheetState) async {
    try {
      final uri = Uri.parse(sub.url);
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'v2rayNG/1.8.0 sing-box/1.8.0 VelocityVPN/1.0',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String? userInfoHeader;
        response.headers.forEach((k, v) {
          if (k.toLowerCase() == 'subscription-userinfo') userInfoHeader = v;
        });

        final subInfo = SubscriptionInfo.fromHeader(userInfoHeader, sub.url);
        final parsedServers = ConfigLinkParser.parseMultiple(response.body, subscriptionId: sub.id);

        setState(() {
          sub.upload = subInfo.uploadBytes;
          sub.download = subInfo.downloadBytes;
          sub.total = subInfo.totalBytes;
          sub.expire = subInfo.expireTimestamp;
          sub.servers = parsedServers;
        });

        _rebuildServerPool();
        setSheetState(() {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: VelocityColors.surfaceElevated, content: Text(I18n.t('sub_updated'), style: const TextStyle(color: VelocityColors.deepCyan))),
          );
        }
      }
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Tab 2: VIP & Telegram Auth Flow
  // -------------------------------------------------------------------------
  Widget _buildVipTab() {
    final isFa = widget.currentLang == AppLanguage.fa;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [VelocityColors.surfaceElevated, Color(0xFF161028)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VelocityColors.neonYellow.withOpacity(0.6), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: VelocityColors.neonYellow.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: VelocityColors.neonYellow),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: VelocityColors.neonYellow, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFa ? 'سرویس‌های اختصاصی VIP ولوسیتی' : 'VELOCITY VIP NETWORKS',
                      style: const TextStyle(
                        color: VelocityColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isFa
                          ? 'پروتکل‌های ضد فیلتر VLESS Reality و Hysteria 2 با آی‌پی تمیز و گارانتی سرعت'
                          : 'Dedicated anti-censorship TLS 1.3 & Hysteria 2 UDP with clean IPs',
                      style: const TextStyle(
                        color: VelocityColors.textSecondary,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isTelegramLinked ? VelocityColors.neonGreen : VelocityColors.borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0088CC).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.send_rounded, color: Color(0xFF0088CC), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          I18n.t('telegram_vip_title'),
                          style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          _isTelegramLinked
                              ? (_telegramUsername ?? '@Velocity_User')
                              : I18n.t('unverified_member'),
                          style: TextStyle(
                            color: _isTelegramLinked ? VelocityColors.neonGreen : VelocityColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isTelegramLinked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: VelocityColors.neonGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: VelocityColors.neonGreen),
                      ),
                      child: Text(
                        I18n.t('verified_vip_badge'),
                        style: const TextStyle(color: VelocityColors.neonGreen, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                I18n.t('telegram_vip_desc'),
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 14),

              if (!_isTelegramLinked) ...[
                TextField(
                  onChanged: (val) => _telegramUsername = val,
                  style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: I18n.t('telegram_user_hint'),
                    hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 11),
                    filled: true,
                    fillColor: VelocityColors.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VelocityColors.electricCyan,
                          foregroundColor: VelocityColors.pureBlack,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          if (_telegramUsername != null && _telegramUsername!.trim().isNotEmpty) {
                            setState(() => _isTelegramLinked = true);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('telegram_username', _telegramUsername!.trim());
                            await prefs.setBool('telegram_linked', true);
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(I18n.t('link_telegram_btn'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0088CC)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _openCustomBot,
                        icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF0088CC)),
                        label: Text(I18n.t('open_support_bot'), style: const TextStyle(color: Color(0xFF0088CC), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        setState(() {
                          _isTelegramLinked = false;
                          _telegramUsername = null;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('telegram_username');
                        await prefs.remove('telegram_linked');
                      },
                      icon: const Icon(Icons.link_off_rounded, size: 16, color: VelocityColors.neonPink),
                      label: Text(I18n.t('unlink_telegram_btn'), style: const TextStyle(color: VelocityColors.neonPink, fontSize: 11)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0088CC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _openTelegramSupport,
                      icon: const Icon(Icons.headset_mic_rounded, size: 16),
                      label: Text(I18n.t('telegram_support'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab 3: Settings Tab
  // -------------------------------------------------------------------------
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: VelocityColors.electricCyan.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.memory_rounded, color: VelocityColors.electricCyan, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      I18n.t('xray_core_title'),
                      style: const TextStyle(
                        color: VelocityColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      I18n.t('xray_core_desc'),
                      style: const TextStyle(
                        color: VelocityColors.textSecondary,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _buildSettingsSwitch(
          title: I18n.t('bypass_iran_title'),
          subtitle: I18n.t('bypass_iran_desc'),
          value: _bypassIran,
          onChanged: (val) async {
            setState(() => _bypassIran = val);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('bypass_iran_enabled', val);
          },
        ),

        _buildSettingsSwitch(
          title: I18n.t('bypass_lan_title'),
          subtitle: I18n.t('bypass_lan_desc'),
          value: _bypassLan,
          onChanged: (val) async {
            setState(() => _bypassLan = val);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('bypass_lan_enabled', val);
          },
        ),

        _buildSettingsSwitch(
          title: I18n.t('notif_settings_title'),
          subtitle: I18n.t('notif_settings_desc'),
          value: _notificationsEnabled,
          onChanged: (val) async {
            setState(() => _notificationsEnabled = val);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('notifications_enabled', val);
            if (val) {
              await VelocityNotificationService.requestPermissions();
            }
          },
        ),

        const SizedBox(height: 14),

        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: VelocityColors.borderDark),
          ),
          tileColor: VelocityColors.surfaceDark,
          leading: const Icon(Icons.auto_fix_high_rounded, color: VelocityColors.neonYellow),
          title: Text(
            I18n.t('reset_wizard_btn'),
            style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: VelocityColors.textSecondary),
          onTap: _showSetupWizardModal,
        ),

        const SizedBox(height: 10),

        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: VelocityColors.borderDark),
          ),
          tileColor: VelocityColors.surfaceDark,
          leading: const Icon(Icons.support_agent_rounded, color: VelocityColors.electricCyan),
          title: Text(
            I18n.t('telegram_support'),
            style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('@Velocity_Support', style: TextStyle(color: VelocityColors.textMuted, fontSize: 11)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: VelocityColors.textSecondary),
          onTap: _openTelegramSupport,
        ),

        const SizedBox(height: 10),

        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: VelocityColors.borderDark),
          ),
          tileColor: VelocityColors.surfaceDark,
          leading: const Icon(Icons.terminal_rounded, color: VelocityColors.electricCyan),
          title: Text(
            I18n.t('log_viewer_title'),
            style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${_connectionLogs.length} events logged', style: const TextStyle(color: VelocityColors.textMuted, fontSize: 11)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: VelocityColors.textSecondary),
          onTap: _showConnectionLogViewer,
        ),
      ],
    );
  }

  Widget _buildSettingsSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: VelocityColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VelocityColors.borderDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: VelocityColors.electricCyan,
            activeTrackColor: VelocityColors.electricCyan.withOpacity(0.3),
            inactiveThumbColor: VelocityColors.textMuted,
            inactiveTrackColor: VelocityColors.pureBlack,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Log Viewer Modal Bottom Sheet
  // -------------------------------------------------------------------------
  void _showConnectionLogViewer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Directionality(
          textDirection: widget.currentLang == AppLanguage.fa ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: VelocityColors.surfaceDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: VelocityColors.electricCyan, width: 1.5)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VelocityColors.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.terminal_rounded, color: VelocityColors.electricCyan, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            I18n.t('log_viewer_title'),
                            style: const TextStyle(
                              color: VelocityColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, color: VelocityColors.electricCyan, size: 18),
                            tooltip: I18n.t('copy_logs'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _connectionLogs.join('\n')));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: VelocityColors.surfaceElevated,
                                  content: Text(
                                    I18n.t('logs_copied'),
                                    style: const TextStyle(color: VelocityColors.electricCyan),
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_sweep_rounded, color: VelocityColors.neonPink, size: 18),
                            tooltip: I18n.t('clear_logs'),
                            onPressed: () {
                              setState(() => _connectionLogs.clear());
                              setSheetState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: VelocityColors.borderDark),
                Expanded(
                  child: _connectionLogs.isEmpty
                      ? Center(
                          child: Text(
                            I18n.t('no_logs_yet'),
                            style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 12),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _connectionLogs.length,
                          itemBuilder: (context, idx) {
                            final log = _connectionLogs[idx];
                            final isError = log.contains('Failed') || log.contains('error');
                            final isSuccess = log.contains('Connected') || log.contains('Ready');

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                log,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: isError
                                      ? VelocityColors.neonPink
                                      : isSuccess
                                          ? VelocityColors.neonGreen
                                          : VelocityColors.textPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Import Dialog (Configs or Subscription URLs)
  // -------------------------------------------------------------------------
  void _showImportDialog() {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: VelocityColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: VelocityColors.borderDark),
              ),
              title: Row(
                children: [
                  const Icon(Icons.add_link, color: VelocityColors.electricCyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      I18n.t('import_config'),
                      style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    I18n.t('import_prompt'),
                    style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11.5, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    enabled: !isLoading,
                    maxLines: 4,
                    style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'https://sub.example.com/api/v1/...\nor vless://, vmess://, trojan://, ss://, hy2://',
                      hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 11),
                      filled: true,
                      fillColor: VelocityColors.pureBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: VelocityColors.borderDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: VelocityColors.electricCyan),
                      ),
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(VelocityColors.electricCyan),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            I18n.t('fetching_sub'),
                            style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: Text(I18n.t('cancel'), style: const TextStyle(color: VelocityColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelocityColors.electricCyan,
                    foregroundColor: VelocityColors.pureBlack,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final input = controller.text.trim();
                          if (input.isEmpty) return;

                          setDialogState(() => isLoading = true);

                          try {
                            List<ServerProfile> parsedProfiles = [];
                            SubscriptionInfo? fetchedSub;

                            if (input.startsWith('http://') || input.startsWith('https://')) {
                              final uri = Uri.parse(input);
                              final response = await http.get(
                                uri,
                                headers: {
                                  'User-Agent': 'v2rayNG/1.8.0 sing-box/1.8.0 VelocityVPN/1.0',
                                  'Accept': '*/*',
                                },
                              ).timeout(const Duration(seconds: 15));

                              if (response.statusCode >= 200 && response.statusCode < 300) {
                                String? userInfoHeader;
                                response.headers.forEach((k, v) {
                                  if (k.toLowerCase() == 'subscription-userinfo') {
                                    userInfoHeader = v;
                                  }
                                });

                                final subId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
                                fetchedSub = SubscriptionInfo.fromHeader(userInfoHeader, input);
                                parsedProfiles = ConfigLinkParser.parseMultiple(response.body, subscriptionId: subId);

                                final subItem = SubscriptionItem(
                                  id: subId,
                                  name: 'Subscription ${_subscriptions.length + 1}',
                                  url: input,
                                  upload: fetchedSub.uploadBytes,
                                  download: fetchedSub.downloadBytes,
                                  total: fetchedSub.totalBytes,
                                  expire: fetchedSub.expireTimestamp,
                                  isActive: true,
                                  servers: parsedProfiles,
                                );
                                setState(() {
                                  _subscriptions.add(subItem);
                                  _activeSubscriptionId = subItem.id;
                                });
                              } else {
                                throw Exception('HTTP ${response.statusCode}');
                              }
                            } else {
                              parsedProfiles = ConfigLinkParser.parseMultiple(input, subscriptionId: _activeSubscriptionId);
                              if (parsedProfiles.isEmpty) {
                                final single = ConfigLinkParser.parse(input, subscriptionId: _activeSubscriptionId);
                                if (single != null) {
                                  parsedProfiles = [single];
                                }
                              }
                            }

                            if (parsedProfiles.isEmpty) {
                              if (!mounted) return;
                              setDialogState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: VelocityColors.neonPink,
                                  content: Text(I18n.t('import_failed')),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _servers.addAll(parsedProfiles);
                              if (_selectedServer == null) {
                                _selectedServer = _servers.first;
                              }
                              if (fetchedSub != null) {
                                _subscriptionInfo = fetchedSub;
                              }
                            });

                            _savePersistedData();
                            _addConnectionLog('[Import Success] Added ${parsedProfiles.length} Xray nodes');

                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: VelocityColors.surfaceElevated,
                                  content: Text(
                                    '${parsedProfiles.length} ${I18n.currentLang == AppLanguage.fa ? "سرور با موفقیت اضافه شد" : "servers imported successfully"}',
                                    style: const TextStyle(color: VelocityColors.electricCyan),
                                  ),
                                ),
                              );
                            }
                          } catch (err) {
                            if (!mounted) return;
                            setDialogState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: VelocityColors.neonPink,
                                content: Text('${I18n.t('import_failed')}: $err'),
                              ),
                            );
                          }
                        },
                  child: Text(I18n.t('import_btn')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Branded Empty State with Official Logo
  // -------------------------------------------------------------------------
  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: VelocityColors.electricCyan.withOpacity(0.25),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: VelocityColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: VelocityColors.textSecondary,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_link_rounded, color: VelocityColors.pureBlack, size: 18),
              label: Text(
                buttonLabel,
                style: const TextStyle(
                  color: VelocityColors.pureBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: VelocityColors.electricCyan,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
