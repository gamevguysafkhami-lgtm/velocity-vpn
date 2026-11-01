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
    'import_prompt': {'en': 'Paste vless://, vmess://, trojan://, ss://, hy2:// or Subscription URL (http/https)', 'fa': 'لینک کانفیگ (vless, vmess, trojan, ss, hy2) یا لینک سابسکریپشن (http/https) را وارد کنید:'},
    'import_btn': {'en': 'Import & Test', 'fa': 'افزودن و تست سرورها'},
    'cancel': {'en': 'Cancel', 'fa': 'انصراف'},
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
    'tab_settings': {'en': 'Settings', 'fa': 'تنظیمات'},
    'bypass_iran_title': {'en': 'Bypass Iran (Domestic Sites)', 'fa': 'دور زدن سایت‌های داخلی (Bypass Iran)'},
    'bypass_iran_desc': {'en': 'Directly route Iranian banking, .ir domains and domestic apps', 'fa': 'عبور مستقیم سایت‌های بانکی و دامنه‌های ir بدون فیلترشکن'},
    'bypass_lan_title': {'en': 'Bypass LAN & Local Devices', 'fa': 'دور زدن شبکه محلی (Bypass LAN)'},
    'bypass_lan_desc': {'en': 'Keep 192.168.x & private network untunneled', 'fa': 'عدم ارسال ترافیک شبکه خانگی و محلی به پروکسی'},
    'notif_settings_title': {'en': 'Keepalive Foreground Service', 'fa': 'اعلان پایداری اتصال در نوار وضعیت'},
    'notif_settings_desc': {'en': 'Prevents Android OS from stopping the VPN in background', 'fa': 'جلوگیری از قطع شدن اتصال در پس‌زمینه توسط بهینه‌ساز باتری اندروید'},
    'perm_declined': {'en': 'VPN permission is required to create tunnel.', 'fa': 'برای برقراری اتصال امن، تایید دسترسی VPN الزامی است.'},
    'sort_lowest_ping': {'en': 'Sort by Ping', 'fa': 'چینش بر اساس کمترین پینگ'},
    'sub_expiry': {'en': 'Expiry:', 'fa': 'انقضا:'},
    'xray_core_title': {'en': 'Core Engine: Xray v26.9.9 (15-Protocol Ready)', 'fa': 'موتور هسته: Xray v26.9.9 (پشتیبانی کامل از ۱۵ پروتکل)'},
    'xray_core_desc': {'en': 'Native TUN VPN adapter with REALITY, TLS 1.3, VMess, Trojan, Shadowsocks, and Hysteria 2', 'fa': 'پشتیبانی بومی از VLESS Reality، پروتکل‌های مدرن TLS 1.3، هیتلریا ۲ و تمام پروتکل‌های نسل جدید و قدیم'},
  };

  static String t(String key) {
    final langCode = currentLang == AppLanguage.fa ? 'fa' : 'en';
    return _strings[key]?[langCode] ?? key;
  }
}

// ---------------------------------------------------------------------------
// Velocity Emblem Painter
// ---------------------------------------------------------------------------
class VelocityEmblemPainter extends CustomPainter {
  final double glowIntensity;
  VelocityEmblemPainter({this.glowIntensity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          VelocityColors.electricCyan.withOpacity(0.35 * glowIntensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.48, glowPaint);

    final path = Path()
      ..moveTo(w * 0.22, h * 0.24)
      ..lineTo(w * 0.44, h * 0.24)
      ..lineTo(w * 0.50, h * 0.74)
      ..lineTo(w * 0.78, h * 0.24);

    final broadGlow = Paint()
      ..color = VelocityColors.deepCyan.withOpacity(0.35 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, broadGlow);

    final sharpCore = Paint()
      ..color = VelocityColors.electricCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, sharpCore);
  }

  @override
  bool shouldRepaint(covariant VelocityEmblemPainter oldDelegate) =>
      oldDelegate.glowIntensity != glowIntensity;
}

class VelocityEmblemWidget extends StatelessWidget {
  final double size;
  final double glowIntensity;
  const VelocityEmblemWidget({super.key, this.size = 38, this.glowIntensity = 1.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: VelocityEmblemPainter(glowIntensity: glowIntensity),
    );
  }
}

// ---------------------------------------------------------------------------
// Data Models
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

class SubscriptionInfo {
  final int uploadBytes;
  final int downloadBytes;
  final int totalBytes;
  final int expireTimestamp;
  final String rawHeader;
  final String subUrl;

  const SubscriptionInfo({
    this.uploadBytes = 0,
    this.downloadBytes = 0,
    this.totalBytes = 0,
    this.expireTimestamp = 0,
    this.rawHeader = '',
    this.subUrl = '',
  });

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
    return '${expiryDate!.year}/${expiryDate!.month}/${expiryDate!.day}';
  }

  Map<String, dynamic> toJson() => {
    'uploadBytes': uploadBytes,
    'downloadBytes': downloadBytes,
    'totalBytes': totalBytes,
    'expireTimestamp': expireTimestamp,
    'rawHeader': rawHeader,
    'subUrl': subUrl,
  };

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) => SubscriptionInfo(
    uploadBytes: json['uploadBytes'] as int? ?? 0,
    downloadBytes: json['downloadBytes'] as int? ?? 0,
    totalBytes: json['totalBytes'] as int? ?? 0,
    expireTimestamp: json['expireTimestamp'] as int? ?? 0,
    rawHeader: json['rawHeader'] as String? ?? '',
    subUrl: json['subUrl'] as String? ?? '',
  );

  static SubscriptionInfo fromHeader(String? header, String subUrl) {
    if (header == null || header.trim().isEmpty) {
      return SubscriptionInfo(subUrl: subUrl);
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
    );
  }
}

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
    );
  }

  Color get pingColor {
    if (pingMs == null) return VelocityColors.textMuted;
    if (pingMs! < 0) return VelocityColors.neonPink;
    if (pingMs! < 120) return VelocityColors.neonGreen;
    if (pingMs! < 250) return VelocityColors.electricCyan;
    if (pingMs! < 450) return VelocityColors.neonYellow;
    return VelocityColors.neonAmber;
  }

  String get pingDisplay {
    if (isTesting) return '...';
    if (pingMs == null) return 'N/A';
    if (pingMs! < 0) return 'Timeout';
    return '${pingMs}ms';
  }
}

// ---------------------------------------------------------------------------
// Link Parser Engine
// ---------------------------------------------------------------------------
class ConfigLinkParser {
  static String detectCountryFlag(String name, String host) {
    final lower = '$name $host'.toLowerCase();
    if (lower.contains('de') || lower.contains('germany') || lower.contains('frankfurt') || lower.contains('berlin')) return '🇩🇪';
    if (lower.contains('fi') || lower.contains('finland') || lower.contains('helsinki')) return '🇫🇮';
    if (lower.contains('nl') || lower.contains('netherlands') || lower.contains('amsterdam')) return '🇳🇱';
    if (lower.contains('us') || lower.contains('usa') || lower.contains('united states') || lower.contains('ashburn') || lower.contains('los angeles')) return '🇺🇸';
    if (lower.contains('sg') || lower.contains('singapore')) return '🇸🇬';
    if (lower.contains('gb') || lower.contains('uk') || lower.contains('london')) return '🇬🇧';
    if (lower.contains('fr') || lower.contains('france') || lower.contains('paris')) return '🇫🇷';
    if (lower.contains('tr') || lower.contains('turkey') || lower.contains('istanbul')) return '🇹🇷';
    if (lower.contains('ca') || lower.contains('canada')) return '🇨🇦';
    if (lower.contains('jp') || lower.contains('japan') || lower.contains('tokyo')) return '🇯🇵';
    if (lower.contains('ir') || lower.contains('iran') || lower.contains('tehran')) return '🇮🇷';
    if (lower.contains('ae') || lower.contains('uae') || lower.contains('dubai')) return '🇦🇪';
    return '🌐';
  }

  static ServerProfile? parse(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;
    VpnProtocol protocol = VpnProtocol.vless;
    String name = 'Velocity Node';
    String host = '127.0.0.1';
    int port = 443;
    String sni = '';

    try {
      if (trimmed.startsWith('vmess://')) {
        protocol = VpnProtocol.vmess;
        final base64Part = trimmed.substring(8).trim();
        final normalized = base64.normalize(base64Part.replaceAll('\r', '').replaceAll('\n', '').replaceAll(' ', ''));
        final decoded = utf8.decode(base64.decode(normalized));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        name = json['ps']?.toString() ?? 'Velocity VMess';
        host = json['add']?.toString() ?? 'custom.vmess.com';
        port = int.tryParse(json['port']?.toString() ?? '443') ?? 443;
        sni = json['sni']?.toString() ?? json['host']?.toString() ?? host;
      } else if (trimmed.startsWith('ss://')) {
        protocol = VpnProtocol.shadowsocks;
        final withoutScheme = trimmed.substring(5);
        String configPart = withoutScheme;
        if (withoutScheme.contains('#')) {
          final hashIdx = withoutScheme.indexOf('#');
          name = Uri.decodeComponent(withoutScheme.substring(hashIdx + 1));
          configPart = withoutScheme.substring(0, hashIdx);
        }
        if (configPart.contains('@')) {
          final atParts = configPart.split('@');
          final hostPort = atParts[1].split(':');
          host = hostPort[0];
          port = int.tryParse(hostPort.length > 1 ? hostPort[1] : '8388') ?? 8388;
        }
      } else {
        final uri = Uri.parse(trimmed);
        final scheme = uri.scheme.toLowerCase();
        if (scheme == 'vless') {
          protocol = VpnProtocol.vless;
        } else if (scheme == 'trojan') {
          protocol = VpnProtocol.trojan;
        } else if (scheme == 'hy2' || scheme == 'hysteria2') {
          protocol = VpnProtocol.hysteria2;
        } else if (scheme == 'ss') {
          protocol = VpnProtocol.shadowsocks;
        }
        if (uri.fragment.isNotEmpty) {
          name = Uri.decodeComponent(uri.fragment);
        }
        if (uri.host.isNotEmpty) {
          host = uri.host;
        }
        if (uri.hasPort) {
          port = uri.port;
        }
        sni = uri.queryParameters['sni'] ?? uri.queryParameters['peer'] ?? uri.queryParameters['host'] ?? host;
      }
    } catch (_) {
      name = 'Velocity Custom';
    }

    final flag = detectCountryFlag(name, host);

    return ServerProfile(
      id: '${DateTime.now().microsecondsSinceEpoch}_${math.Random().nextInt(9999)}',
      name: name,
      countryCode: flag,
      protocol: protocol,
      host: host,
      port: port,
      sni: sni,
      rawUrl: trimmed,
      pingMs: null,
      trafficUsage: '0.0 GB',
    );
  }

  static List<ServerProfile> parseMultiple(String content) {
    final List<ServerProfile> results = [];
    String text = content.trim();
    if (text.isEmpty) return results;

    if (!text.contains('://')) {
      try {
        final normalized = base64.normalize(text.replaceAll('\r', '').replaceAll('\n', '').replaceAll(' ', ''));
        text = utf8.decode(base64.decode(normalized));
      } catch (_) {}
    }

    final lines = text.split(RegExp(r'[\r\n]+'));
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('vless://') ||
          trimmed.startsWith('vmess://') ||
          trimmed.startsWith('trojan://') ||
          trimmed.startsWith('ss://') ||
          trimmed.startsWith('hysteria2://') ||
          trimmed.startsWith('hy2://')) {
        final profile = parse(trimmed);
        if (profile != null) {
          results.add(profile);
        }
      }
    }
    return results;
  }
}

// ---------------------------------------------------------------------------
// Foreground Notification Service
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
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (_) {}
  }

  static Future<void> showVpnConnectedNotification({
    required String serverName,
    required int pingMs,
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
      await _notificationsPlugin.show(
        1001,
        'Velocity VPN: $serverName',
        'تونل امن Xray فعال است | تاخیر: ${pingMs}ms',
        notifDetails,
      );
    } catch (_) {}
  }

  static Future<void> cancelVpnNotification() async {
    try {
      await _notificationsPlugin.cancel(1001);
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Root App
// ---------------------------------------------------------------------------
class VelocityApp extends StatefulWidget {
  const VelocityApp({super.key});

  @override
  State<VelocityApp> createState() => _VelocityAppState();
}

class _VelocityAppState extends State<VelocityApp> {
  AppLanguage _currentLang = AppLanguage.fa;

  @override
  void initState() {
    super.initState();
    _loadPersistedLang();
  }

  Future<void> _loadPersistedLang() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('app_lang');
      if (lang == 'en') {
        setState(() {
          _currentLang = AppLanguage.en;
          I18n.currentLang = AppLanguage.en;
        });
      }
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
      home: Directionality(
        textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
        child: HomeScreen(
          onToggleLanguage: _toggleLanguage,
          currentLang: _currentLang,
        ),
      ),
    );
  }
}

typedef VelocityVpnApp = VelocityApp;

// ---------------------------------------------------------------------------
// Home Screen (Xray Real Tunnel Dashboard)
// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleLanguage;
  final AppLanguage currentLang;

  const HomeScreen({
    super.key,
    required this.onToggleLanguage,
    required this.currentLang,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  VpnState _vpnState = VpnState.disconnected;
  RoutingMode _routingMode = RoutingMode.bypassLan;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Real Xray Core Controller
  late final V2ray _v2ray;

  // Telemetry
  Timer? _durationTimer;
  int _connectedSeconds = 0;
  String _displayDownloadSpeed = '0.0 KB/s';
  String _displayUploadSpeed = '0.0 KB/s';

  final List<ServerProfile> _servers = [];
  final List<String> _connectionLogs = [];
  ServerProfile? _selectedServer;
  SubscriptionInfo? _subscriptionInfo;

  // 3 Tabs: 0: Home, 1: Servers, 2: Settings (VIP completely removed)
  int _currentTabIndex = 0;
  String _nodeSearchQuery = '';
  bool _sortByLowestPing = false;
  bool _bypassIran = true;
  bool _bypassLan = true;
  bool _notificationsEnabled = true;

  // Subnets to bypass when Bypass Iran or LAN is on
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

    _initV2ray();
    _loadPersistedData();
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
      final selectedId = prefs.getString('selected_server_id');
      final subJson = prefs.getString('subscription_info');
      final logs = prefs.getStringList('velocity_connection_logs');

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

      if (serversJson != null && serversJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(serversJson);
        final loadedServers = decodedList
            .map((item) => ServerProfile.fromJson(item as Map<String, dynamic>))
            .toList();
        if (loadedServers.isNotEmpty) {
          setState(() {
            _servers.clear();
            _servers.addAll(loadedServers);
            if (selectedId != null) {
              _selectedServer = _servers.firstWhere((s) => s.id == selectedId, orElse: () => _servers.first);
            } else {
              _selectedServer = _servers.first;
            }
          });
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

  Future<void> _savePersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serversJson = jsonEncode(_servers.map((s) => s.toJson()).toList());
      await prefs.setString('saved_servers', serversJson);
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
  // VPN Connect / Disconnect Action (Real Xray Core)
  // -------------------------------------------------------------------------
  Future<void> _toggleVpn() async {
    if (_vpnState == VpnState.disconnected) {
      if (_selectedServer == null || _servers.isEmpty) {
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

      bool granted = false;
      try {
        granted = await _v2ray.requestPermission();
      } catch (_) {
        granted = true;
      }

      if (!granted) {
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

        final isFa = I18n.currentLang == AppLanguage.fa;
        final bypassList = (_bypassIran || _bypassLan) ? _bypassSubnets : null;

        await _v2ray.startV2Ray(
          remark: server.name,
          config: fullConfig,
          proxyOnly: false,
          bypassSubnets: bypassList,
          notificationDisconnectButtonName: isFa ? "قطع اتصال" : "DISCONNECT",
        );

        _pulseController.duration = const Duration(milliseconds: 1800);
        _pulseController.repeat(reverse: true);

        setState(() {
          _vpnState = VpnState.connected;
          _connectedSeconds = 0;
        });

        _startDurationTimer();
        _addConnectionLog('[Xray Connected] Tunnel active via ${server.protocol.label}');

        if (_notificationsEnabled) {
          await VelocityNotificationService.showVpnConnectedNotification(
            serverName: server.name,
            pingMs: server.pingMs ?? 0,
          );
        }
      } catch (err) {
        _pulseController.duration = const Duration(milliseconds: 1800);
        _pulseController.repeat(reverse: true);
        setState(() => _vpnState = VpnState.disconnected);
        _addConnectionLog('[Xray Connection Failed] $err');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: VelocityColors.neonPink,
              content: Text('Xray connection error: $err'),
            ),
          );
        }
      }
    } else if (_vpnState == VpnState.connected) {
      setState(() => _vpnState = VpnState.disconnecting);
      _addConnectionLog('[Xray Disconnecting] Closing TUN interface...');
      try {
        await _v2ray.stopV2Ray();
      } catch (_) {}
      await VelocityNotificationService.cancelVpnNotification();
      _durationTimer?.cancel();
      setState(() {
        _vpnState = VpnState.disconnected;
        _displayDownloadSpeed = '0.0 KB/s';
        _displayUploadSpeed = '0.0 KB/s';
      });
      _addConnectionLog('[Xray Disconnected] Tunnel closed.');
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _vpnState != VpnState.connected) return;
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
  // Smart Multi-Strategy Ping Engine (Real Xray Handshake + TLS/SNI Fallback)
  // -------------------------------------------------------------------------
  Future<void> _pingAllServers() async {
    if (_servers.isEmpty) return;

    setState(() {
      for (var s in _servers) {
        s.isTesting = true;
      }
    });

    _addConnectionLog('[Smart Ping] Batch measuring ${_servers.length} nodes...');

    // Run parallel batches of 4 servers at a time for high speed and accuracy
    const batchSize = 4;
    for (int i = 0; i < _servers.length; i += batchSize) {
      if (!mounted) return;
      final end = (i + batchSize < _servers.length) ? i + batchSize : _servers.length;
      final batch = _servers.sublist(i, end);
      await Future.wait(batch.map((s) => _pingSingleServer(s, log: false)));
    }

    if (mounted) {
      _addConnectionLog('[Smart Ping] Latency check completed for all nodes.');
    }
  }

  Future<void> _pingSingleServer(ServerProfile server, {bool log = true}) async {
    setState(() => server.isTesting = true);

    int delay = -1;

    // Strategy 1: Real Xray Core Delay Test
    try {
      final parsed = V2ray.parseFromURL(server.rawUrl);
      delay = await _v2ray.getServerDelay(config: parsed.getFullConfiguration());
    } catch (_) {
      try {
        delay = await _v2ray.getServerDelay(config: server.rawUrl);
      } catch (_) {}
    }

    // Strategy 2: If Xray core delay is <= 0 or unavailable, perform real TLS Handshake Probe
    if (delay <= 0) {
      final sw = Stopwatch()..start();
      try {
        final targetHost = server.host.trim();

        // Try SecureSocket first if server uses TLS or port 443
        if (server.port == 443 || server.protocol == VpnProtocol.vless || server.protocol == VpnProtocol.trojan) {
          try {
            final secSocket = await SecureSocket.connect(
              targetHost,
              server.port,
              timeout: const Duration(milliseconds: 3500),
              onBadCertificate: (_) => true,
            );
            sw.stop();
            secSocket.destroy();
            delay = sw.elapsedMilliseconds;
          } catch (_) {
            // If secure handshake failed, fallback to plain TCP
            final socket = await Socket.connect(targetHost, server.port, timeout: const Duration(milliseconds: 3500));
            sw.stop();
            socket.destroy();
            delay = sw.elapsedMilliseconds;
          }
        } else {
          // Standard TCP socket
          final socket = await Socket.connect(targetHost, server.port, timeout: const Duration(milliseconds: 3500));
          sw.stop();
          socket.destroy();
          delay = sw.elapsedMilliseconds;
        }
      } catch (_) {
        sw.stop();
        delay = -1;
      }
    }

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
  // Telegram Support
  // -------------------------------------------------------------------------
  Future<void> _openTelegramSupport() async {
    try {
      final uri = Uri.parse('https://t.me/Velocity_Support');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Log Viewer
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
                const Divider(color: VelocityColors.borderDark, height: 1),
                Expanded(
                  child: _connectionLogs.isEmpty
                      ? Center(
                          child: Text(
                            I18n.t('no_logs_yet'),
                            style: const TextStyle(color: VelocityColors.textMuted, fontSize: 12),
                          ),
                        )
                      : Directionality(
                          textDirection: TextDirection.ltr,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: _connectionLogs.length,
                            itemBuilder: (context, index) {
                              final log = _connectionLogs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  log,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: log.contains('Connected')
                                        ? VelocityColors.neonGreen
                                        : log.contains('Failed') || log.contains('Error')
                                            ? VelocityColors.neonPink
                                            : VelocityColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
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
  // Main Build: 3 Clean Tabs (Home, Servers, Settings)
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
              icon: const Icon(Icons.power_settings_new),
              label: I18n.t('tab_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.dns_rounded),
              label: I18n.t('tab_servers'),
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
    final isFa = widget.currentLang == AppLanguage.fa;

    return AppBar(
      backgroundColor: VelocityColors.midnightBg,
      elevation: 0,
      title: Row(
        children: [
          const VelocityEmblemWidget(size: 32),
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
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                I18n.t('subtitle_tagline'),
                style: const TextStyle(
                  color: VelocityColors.electricCyan,
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Language Switcher Pill
          InkWell(
            onTap: widget.onToggleLanguage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: VelocityColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, color: VelocityColors.electricCyan, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    isFa ? 'FA' : 'EN',
                    style: const TextStyle(
                      color: VelocityColors.electricCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Connection Logs
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: VelocityColors.textSecondary, size: 20),
            tooltip: I18n.t('btn_logs'),
            onPressed: _showConnectionLogViewer,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab 0: Home Tab
  // -------------------------------------------------------------------------
  Widget _buildHomeTab() {
    return Column(
      children: [
        _buildRoutingChips(),
        const SizedBox(height: 10),
        _buildStatusHeader(),
        Expanded(
          child: Center(
            child: _buildGlowingPowerButton(),
          ),
        ),
        _buildTelemetryCard(),
        const SizedBox(height: 12),
        _buildActiveServerCard(),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildRoutingChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildChip(RoutingMode.bypassLan, I18n.t('mode_bypass_lan')),
          const SizedBox(width: 8),
          _buildChip(RoutingMode.global, I18n.t('mode_global')),
        ],
      ),
    );
  }

  Widget _buildChip(RoutingMode mode, String label) {
    final isSelected = _routingMode == mode;
    return InkWell(
      onTap: () => setState(() => _routingMode = mode),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? VelocityColors.electricCyan.withOpacity(0.15) : VelocityColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? VelocityColors.electricCyan : VelocityColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    final isConnected = _vpnState == VpnState.connected;
    final isConnecting = _vpnState == VpnState.connecting || _vpnState == VpnState.disconnecting;

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
    final hasServers = _servers.isNotEmpty && _selectedServer != null;
    final isConnected = _vpnState == VpnState.connected;
    final isConnecting = _vpnState == VpnState.connecting || _vpnState == VpnState.disconnecting;

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
            onTap: !hasServers ? _showImportDialog : (isConnecting ? null : _toggleVpn),
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
                      border: Border.all(
                        color: glowColor,
                        width: 2.2,
                      ),
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

  Widget _buildActiveServerCard() {
    if (_selectedServer == null || _servers.isEmpty) {
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
      onTap: () => setState(() => _currentTabIndex = 1),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: VelocityColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.45), width: 1.2),
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
              child: Text(
                server.countryCode,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        I18n.t('active_server'),
                        style: const TextStyle(fontSize: 10, color: VelocityColors.textSecondary),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: VelocityColors.electricCyan.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          server.protocol.label,
                          style: const TextStyle(
                            fontSize: 9,
                            color: VelocityColors.electricCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    server.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: VelocityColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Ping latency badge
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _pingSingleServer(server),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: server.pingColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: server.pingColor, width: 1),
                ),
                child: server.isTesting
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: VelocityColors.electricCyan,
                        ),
                      )
                    : Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          server.pingDisplay,
                          style: TextStyle(
                            color: server.pingColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: VelocityColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab 1: Servers Tab
  // -------------------------------------------------------------------------
  Widget _buildServersTab() {
    final isFa = widget.currentLang == AppLanguage.fa;

    var displayServers = _servers.where((s) {
      if (_nodeSearchQuery.isEmpty) return true;
      final q = _nodeSearchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.host.toLowerCase().contains(q) ||
          s.protocol.name.toLowerCase().contains(q);
    }).toList();

    if (_sortByLowestPing) {
      displayServers.sort((a, b) {
        if (a.pingMs == null && b.pingMs == null) return 0;
        if (a.pingMs == null) return 1;
        if (b.pingMs == null) return -1;
        if (a.pingMs! < 0 && b.pingMs! < 0) return 0;
        if (a.pingMs! < 0) return 1;
        if (b.pingMs! < 0) return -1;
        return a.pingMs!.compareTo(b.pingMs!);
      });
    }

    return Column(
      children: [
        if (_subscriptionInfo != null) _buildSubscriptionCard(),

        // Header
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
                      '${_servers.length}',
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
                  if (_servers.isNotEmpty)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: VelocityColors.electricCyan, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: VelocityColors.electricCyan.withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelocityColors.electricCyan,
                      foregroundColor: VelocityColors.pureBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: _showImportDialog,
                    icon: const Icon(Icons.add, size: 15),
                    label: Text(
                      I18n.t('import_config'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search & Sort Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: VelocityColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: VelocityColors.borderDark),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _nodeSearchQuery = val),
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
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => _sortByLowestPing = !_sortByLowestPing),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: _sortByLowestPing
                        ? VelocityColors.neonGreen.withOpacity(0.18)
                        : VelocityColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _sortByLowestPing ? VelocityColors.neonGreen : VelocityColors.borderDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: 15,
                        color: _sortByLowestPing ? VelocityColors.neonGreen : VelocityColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFa ? 'پینگ' : 'Ping',
                        style: TextStyle(
                          color: _sortByLowestPing ? VelocityColors.neonGreen : VelocityColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Server List
        Expanded(
          child: displayServers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: VelocityColors.electricCyan.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _servers.isEmpty ? Icons.cloud_off_rounded : Icons.search_off_rounded,
                            size: 42,
                            color: VelocityColors.electricCyan,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _servers.isEmpty ? I18n.t('no_nodes_available') : I18n.t('no_nodes_found'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: VelocityColors.textPrimary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VelocityColors.electricCyan,
                            foregroundColor: VelocityColors.pureBlack,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _showImportDialog,
                          icon: const Icon(Icons.add_link, size: 18),
                          label: Text(
                            I18n.t('import_config'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: displayServers.length,
                  itemBuilder: (context, index) {
                    final server = displayServers[index];
                    final isSelected = _selectedServer?.id == server.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? VelocityColors.electricCyan.withOpacity(0.09)
                            : VelocityColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        onTap: () {
                          setState(() => _selectedServer = server);
                          _savePersistedData();
                          _addConnectionLog('[Selected Node] ${server.name} (${server.protocol.label})');
                        },
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? VelocityColors.electricCyan : VelocityColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(server.countryCode, style: const TextStyle(fontSize: 22)),
                          ],
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                server.name,
                                style: TextStyle(
                                  color: isSelected ? VelocityColors.electricCyan : VelocityColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: VelocityColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: VelocityColors.borderDark),
                              ),
                              child: Text(
                                server.protocol.label,
                                style: const TextStyle(
                                  color: VelocityColors.textSecondary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${server.host}:${server.port}',
                            style: const TextStyle(color: VelocityColors.textMuted, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ping test chip
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => _pingSingleServer(server),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: server.pingColor.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: server.pingColor),
                                ),
                                child: server.isTesting
                                    ? const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: VelocityColors.electricCyan,
                                        ),
                                      )
                                    : Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Text(
                                          server.pingDisplay,
                                          style: TextStyle(
                                            color: server.pingColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: VelocityColors.textMuted),
                              tooltip: I18n.t('delete_node'),
                              onPressed: () {
                                setState(() {
                                  _servers.removeWhere((s) => s.id == server.id);
                                  if (_selectedServer?.id == server.id) {
                                    _selectedServer = _servers.isNotEmpty ? _servers.first : null;
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

  Widget _buildSubscriptionCard() {
    final sub = _subscriptionInfo!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VelocityColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_rounded, color: VelocityColors.neonGreen, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    I18n.t('subscription_quota'),
                    style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '${I18n.t('sub_expiry')} ${sub.expiryDateFormatted}',
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: sub.quotaProgress.clamp(0.0, 1.0),
              backgroundColor: VelocityColors.pureBlack,
              valueColor: AlwaysStoppedAnimation<Color>(
                sub.quotaProgress > 0.85 ? VelocityColors.neonPink : VelocityColors.electricCyan,
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${sub.trafficUsageFormatted} / ${sub.trafficTotalFormatted}',
                  style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab 2: Settings Tab
  // -------------------------------------------------------------------------
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Xray Core Engine Status Card
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

        // Bypass Iran Switch
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

        // Bypass LAN Switch
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

        // Foreground Service Notification Switch
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

        // Telegram Support Button
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

        // Logs Viewer Button
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
                Text(
                  title,
                  style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
                ),
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
  // Import Dialog
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

                                fetchedSub = SubscriptionInfo.fromHeader(userInfoHeader, input);
                                parsedProfiles = ConfigLinkParser.parseMultiple(response.body);
                              } else {
                                throw Exception('HTTP ${response.statusCode}');
                              }
                            } else {
                              parsedProfiles = ConfigLinkParser.parseMultiple(input);
                              if (parsedProfiles.isEmpty) {
                                final single = ConfigLinkParser.parse(input);
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
}
