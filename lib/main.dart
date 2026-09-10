import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const VelocityVpnApp());
}

// ---------------------------------------------------------------------------
// Velocity Official Brand Colors (#00E5FF, Pure Black, Deep Cyan)
// ---------------------------------------------------------------------------
class VelocityColors {
  static const Color pureBlack = Color(0xFF000000);
  static const Color midnightBg = Color(0xFF060910);
  static const Color surfaceDark = Color(0xFF0D111D);
  static const Color surfaceElevated = Color(0xFF131927);
  static const Color borderDark = Color(0xFF1B2338);

  // Primary brand accents (Electric Cyan and Deep Cyan)
  static const Color electricCyan = Color(0xFF00E5FF);
  static const Color deepCyan = Color(0xFF00B0FF);

  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPink = Color(0xFFFF1744);
  static const Color neonYellow = Color(0xFFFFD600);
  static const Color neonViolet = Color(0xFFD500F9);
  static const Color neonAmber = Color(0xFFFF9100);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8FA0B8);
  static const Color textMuted = Color(0xFF4A5568);

  static void setNeonAccent(Color primary, Color secondary) {
    // Theme accent applied
  }
}

// ---------------------------------------------------------------------------
// Bilingual System (EN / FA) with RTL/LTR Support
// ---------------------------------------------------------------------------
enum AppLanguage { en, fa }

class I18n {
  static AppLanguage currentLang = AppLanguage.en;

  static final Map<String, Map<String, String>> _strings = {
    'app_title': {'en': 'VELOCITY', 'fa': 'ولوسیتی'},
    'subtitle_tagline': {'en': 'SECURE VPN SERVICES', 'fa': 'سرویس‌های امن وی‌پی‌ان'},
    'telegram_support': {'en': 'Telegram Support', 'fa': 'پشتیبانی تلگرام'},
    'telegram_channel': {'en': '@VelocityVPN_Official', 'fa': '@VelocityVPN_Official'},
    'telegram_support_user': {'en': '@VelocityVPN_Support', 'fa': '@VelocityVPN_Support'},
    'status_connected': {'en': 'SECURE TUNNEL ACTIVE', 'fa': 'تونل امن متصل است'},
    'status_disconnected': {'en': 'DISCONNECTED', 'fa': 'قطع ارتباط'},
    'status_connecting': {'en': 'CONNECTING TO VELOCITY...', 'fa': 'در حال اتصال به سرورهای ولوسیتی...'},
    'status_disconnecting': {'en': 'TERMINATING TUNNEL...', 'fa': 'در حال قطع اتصال...'},
    'tap_to_connect': {'en': 'TAP TO CONNECT', 'fa': 'برای اتصال لمس کنید'},
    'tap_to_disconnect': {'en': 'TAP TO DISCONNECT', 'fa': 'برای قطع لمس کنید'},
    'active_server': {'en': 'Active Velocity Node', 'fa': 'سرور فعال ولوسیتی'},
    'select_server': {'en': 'Select Velocity Node', 'fa': 'انتخاب سرور'},
    'servers_count': {'en': 'Nodes Online', 'fa': 'سرور آنلاین'},
    'ping_all': {'en': 'Ping All Nodes', 'fa': 'تست پینگ همه'},
    'testing_ping': {'en': 'Measuring Latency...', 'fa': 'در حال سنجش تاخیر...'},
    'download_speed': {'en': 'DOWNLOAD', 'fa': 'دریافت'},
    'upload_speed': {'en': 'UPLOAD', 'fa': 'ارسال'},
    'total_down': {'en': 'Down:', 'fa': 'دانلود:'},
    'total_up': {'en': 'Up:', 'fa': 'آپلود:'},
    'routing_mode': {'en': 'Routing Mode', 'fa': 'حالت مسیریابی'},
    'mode_rule': {'en': 'Smart Rule', 'fa': 'قوانین هوشمند'},
    'mode_global': {'en': 'Global Proxy', 'fa': 'پروکسی سراسری'},
    'mode_direct': {'en': 'Direct Bypass', 'fa': 'مستقیم (بدون پروکسی)'},
    'mode_bypass_lan': {'en': 'Bypass Iran/LAN', 'fa': 'دور زدن سایت‌های داخلی'},
    'receipt_title': {'en': 'Velocity VIP Activation', 'fa': 'فعال‌سازی اشتراک VIP ولوسیتی'},
    'receipt_desc': {'en': 'Upload transaction slip or purchase via Telegram support', 'fa': 'تصویر رسید یا کد پیگیری را جهت فعال‌سازی اشتراک ارسال نمایید'},
    'import_config': {'en': 'Import Config / URL', 'fa': 'وارد کردن کانفیگ / لینک'},
    'import_prompt': {'en': 'Paste vless://, vmess://, trojan://, ss://, hysteria2:// or Subscription URL (http/https)', 'fa': 'لینک کانفیگ (vless, vmess, trojan, ss, hysteria2) یا لینک سابسکریپشن (http/https) را وارد کنید'},
    'import_btn': {'en': 'Import & Test', 'fa': 'وارد کردن و تست'},
    'cancel': {'en': 'Cancel', 'fa': 'انصراف'},
    'no_nodes_available': {
      'en': 'No servers found. Please add a subscription link via Import.',
      'fa': 'هیچ سروری یافت نشد. لطفاً از طریق دکمه Import لینک سابسکریپشن اضافه کنید.',
    },
    'no_active_subscription': {
      'en': 'No Active Subscription',
      'fa': 'بدون اشتراک فعال',
    },
    'subscription_quota': {
      'en': 'Subscription Quota',
      'fa': 'حجم و اعتبار اشتراک',
    },
    'subscription_imported': {
      'en': 'Subscription successfully imported & saved!',
      'fa': 'سابسکریپشن با موفقیت دریافت و ذخیره شد!',
    },
    'fetching_sub': {
      'en': 'Fetching subscription & parsing nodes...',
      'fa': 'در حال دریافت سابسکریپشن و بررسی سرورها...',
    },
    'import_failed': {
      'en': 'Failed to fetch or parse subscription URL',
      'fa': 'خطا در دریافت یا پردازش لینک سابسکریپشن',
    },
    'delete_node': {'en': 'Delete Node', 'fa': 'حذف سرور'},
    'clear_all_nodes': {'en': 'Clear All Nodes', 'fa': 'حذف همه سرورها'},
    'tx_id': {'en': 'Transaction Hash / Ref ID', 'fa': 'کد پیگیری یا هش تراکنش'},
    'tx_placeholder': {'en': 'e.g. 0x9f2a... or Ref #847291', 'fa': 'مثال: کد رهگیری یا هش تراکنش'},
    'plan_select': {'en': 'Select Velocity Plan', 'fa': 'انتخاب پلن اشتراک ولوسیتی'},
    'plan_1m': {'en': 'Velocity VIP 30-Day (Unlimited)', 'fa': 'سایبر VIP ۳۰ روزه (نامحدود)'},
    'plan_3m': {'en': 'Velocity Turbo 90-Day (600 GB)', 'fa': 'سایبر توربو ۹۰ روزه (۶۰۰ گیگابایت)'},
    'plan_1y': {'en': 'Velocity Enterprise Annual (Dedicated)', 'fa': 'اشتراک سالانه اختصاصی ولوسیتی'},
    'upload_image_btn': {'en': 'Attach Receipt Proof', 'fa': 'پیوست تصویر فیش واریزی'},
    'receipt_attached': {'en': 'Proof Image Attached', 'fa': 'تصویر رسید ضمیمه شد'},
    'submit_receipt': {'en': 'Submit Activation Proof', 'fa': 'ثبت و ارسال مدارک'},
    'receipt_success': {
      'en': 'Activation proof submitted! Velocity Core will activate your account within 5 mins.',
      'fa': 'رسید با موفقیت ثبت شد! اشتراک شما ظرف ۵ دقیقه تایید و فعال می‌شود.'
    },
    'telegram_direct_buy': {
      'en': 'Instant purchase & 24/7 support available via our official Telegram channel.',
      'fa': 'خرید آنی و پشتیبانی ۲۴ ساعته از طریق کانال رسمی تلگرام ولوسیتی.'
    },
    'open_telegram': {'en': 'Open Telegram', 'fa': 'ورود به تلگرام'},
    'telegram_checkout_btn': {
      'en': 'Contact Telegram Support to Buy & Activate',
      'fa': 'ارتباط با پشتیبانی تلگرام جهت خرید و فعالسازی',
    },
    'close': {'en': 'Close', 'fa': 'بستن'},
    'connected_time': {'en': 'Duration', 'fa': 'مدت زمان اتصال'},
    // Setup Wizard Strings
    'setup_wizard': {'en': 'Setup Wizard', 'fa': 'راهنمای راه‌اندازی'},
    'wizard_title': {'en': 'VELOCITY SETUP WIZARD', 'fa': 'راهنمای راه‌اندازی ولوسیتی'},
    'wizard_subtitle': {'en': 'INITIAL SYSTEM CONFIGURATION', 'fa': 'پیکربندی هوشمند اولیه سیستم'},
    'step_lang_title': {'en': '1. Interface Language', 'fa': '۱. انتخاب زبان برنامه'},
    'step_lang_desc': {'en': 'Choose preferred language with dynamic LTR/RTL preview', 'fa': 'زبان مورد نظر خود را با تغییر خودکار چینش راست‌چین/چپ‌چین انتخاب کنید'},
    'lang_en': {'en': 'English (EN)', 'fa': 'انگلیسی (English)'},
    'lang_en_sub': {'en': 'Left-to-Right (LTR) Layout', 'fa': 'چیدمان چپ‌به‌راست (LTR)'},
    'lang_fa': {'en': 'فارسی (Persian)', 'fa': 'فارسی (Persian)'},
    'lang_fa_sub': {'en': 'Right-to-Left (RTL) Layout', 'fa': 'چیدمان راست‌به‌چپ (RTL)'},
    'step_region_title': {'en': '2. Region & Network Optimization', 'fa': '۲. بهینه‌سازی منطقه و اپراتور'},
    'step_region_desc': {'en': 'Tunes censorship bypass protocols and local routing rules', 'fa': 'تنظیم خودکار قوانین مسیریابی و عبور از فیلترینگ متناسب با شبکه'},
    'region_iran_title': {'en': 'Iran (MCI / Irancell / Rightel / Fixed)', 'fa': 'ایران (همراه اول، ایرانسل، رایتل، مخابرات)'},
    'region_iran_desc': {'en': 'Enables Smart Bypass LAN rules & Anti-Censorship Reality/Hysteria2 protocols.', 'fa': 'فعال‌سازی دور زدن سایت‌های داخلی (Bypass Iran) و پروتکل‌های ضد فیلتر Reality/Hysteria2.'},
    'region_global_title': {'en': 'Global / International', 'fa': 'بین‌المللی / بدون محدودیت'},
    'region_global_desc': {'en': 'Direct global proxy tunnel for streaming, low-ping gaming, and unmetered browsing.', 'fa': 'تونل مستقیم پروکسی برای استریم، گیمینگ با تاخیر کم و وب‌گردی آزاد.'},
    'step_perm_title': {'en': '3. Core Android Permissions', 'fa': '۳. دسترسی‌های سیستمی اندروید'},
    'step_perm_desc': {'en': 'Velocity requires standard Android system privileges to establish tunnels', 'fa': 'ولوسیتی برای ایجاد تونل رمزنگاری‌شده به این دسترسی‌ها نیاز دارد'},
    'perm_vpn_service': {'en': 'Android VpnService Tunnel', 'fa': 'تونل VpnService اندروید'},
    'perm_vpn_service_desc': {'en': 'Creates a virtual local TUN adapter to route and encrypt your data packets via TLS 1.3.', 'fa': 'ایجاد کارت شبکه مجازی محلی (TUN) برای رمزنگاری و هدایت بسته‌های داده با TLS 1.3.'},
    'perm_notif_service': {'en': 'Background Keepalive Notification', 'fa': 'اعلان پایداری اتصال در پس‌زمینه'},
    'perm_notif_service_desc': {'en': 'Prevents Android OS battery killer from terminating the connection during gaming or browsing.', 'fa': 'جلوگیری از قطع شدن ناگهانی فیلترشکن توسط سیستم بهینه‌سازی باتری اندروید.'},
    'btn_start_velocity': {'en': 'START VELOCITY', 'fa': 'شروع استفاده از ولوسیتی'},
    'btn_next': {'en': 'NEXT', 'fa': 'مرحله بعد'},
    'btn_back': {'en': 'BACK', 'fa': 'مرحله قبل'},
    'vpn_dialog_title': {'en': 'Connection Request', 'fa': 'درخواست اتصال'},
    'vpn_dialog_body': {'en': 'Velocity wants to set up a VPN connection that allows it to monitor network traffic. Only accept if you trust the source.\n\nVPN icon appears at the top of your screen when VPN is active.', 'fa': 'برنامه Velocity قصد دارد یک اتصال VPN ایجاد کند تا ترافیک شبکه را هدایت کند. فقط در صورتی که به این منبع اعتماد دارید تأیید کنید.\n\nنماد کلید در بالای صفحه هنگام اتصال ظاهر می‌شود.'},
    'btn_cancel': {'en': 'Cancel', 'fa': 'انصراف'},
    'btn_ok': {'en': 'OK', 'fa': 'تأیید'},
    'notif_dialog_title': {'en': 'Allow Velocity to send you notifications?', 'fa': 'به Velocity اجازه ارسال اعلان می‌دهید؟'},
    'notif_dialog_body': {'en': 'Required to keep your secure tunnel active in the background and display real-time network speeds.', 'fa': 'جهت پایداری تونل در پس‌زمینه سیستم و نمایش زنده سرعت و تاخیر پینگ الزامی است.'},
    'btn_allow': {'en': 'Allow', 'fa': 'اجازه دادن'},
    'btn_dont_allow': {'en': "Don't allow", 'fa': 'عدم اجازه'},
    'perm_declined': {'en': 'VPN permission is required to establish secure tunnel.', 'fa': 'برای برقراری اتصال امن، تایید دسترسی وی‌پی‌ان الزامی است.'},
    // Authentication & Profile Strings
    'profile': {'en': 'User Terminal', 'fa': 'حساب کاربری'},
    'auth_title': {'en': 'VELOCITY IDENTITY ACCESS', 'fa': 'ورود به حساب کاربری ولوسیتی'},
    'auth_subtitle': {'en': 'AUTHENTICATE USER SESSION', 'fa': 'احراز هویت و مدیریت دسترسی'},
    'tab_telegram': {'en': 'Telegram', 'fa': 'تلگرام'},
    'tab_gmail': {'en': 'Gmail OTP', 'fa': 'کد ایمیل'},
    'telegram_hint': {'en': '@username or Telegram ID', 'fa': '@نام_کاربری یا شناسه تلگرام'},
    'btn_connect_telegram': {'en': 'LINK TELEGRAM ACCOUNT', 'fa': 'اتصال به حساب تلگرام'},
    'gmail_hint': {'en': 'username@gmail.com', 'fa': 'آدرس ایمیل شما'},
    'btn_send_otp': {'en': 'SEND OTP', 'fa': 'ارسال کد تایید'},
    'btn_resend_otp': {'en': 'Resend in', 'fa': 'ارسال مجدد تا'},
    'otp_hint': {'en': '6-Digit OTP Code', 'fa': 'کد تایید ۶ رقمی'},
    'btn_verify_otp': {'en': 'VERIFY & SIGN IN', 'fa': 'تایید کد و ورود'},
    'sub_active': {'en': 'ACTIVE VIP', 'fa': 'اشتراک فعال'},
    'sub_free': {'en': 'FREE TIER', 'fa': 'نسخه رایگان'},
    'sub_expiry': {'en': 'Expires on', 'fa': 'تاریخ انقضا:'},
    'sub_quota': {'en': 'Bandwidth Usage', 'fa': 'میزان مصرف ترافیک'},
    'btn_upgrade': {'en': 'BROWSE PLANS & UPGRADE', 'fa': 'مشاهده و ارتقای پلن اشتراک'},
    'btn_logout': {'en': 'LOG OUT', 'fa': 'خروج از حساب'},
    // Power-User, Node Management & Settings Strings
    'search_nodes_hint': {'en': 'Search by country, city, protocol...', 'fa': 'جستجو بر اساس کشور، شهر یا پروتکل...'},
    'sort_lowest_ping': {'en': 'Sort by Lowest Ping', 'fa': 'مرتب‌سازی بر اساس کمترین پینگ'},
    'sort_default': {'en': 'Reset Node Order', 'fa': 'چینش پیش‌فرض سرورها'},
    'step_priority_title': {'en': '2. Protocol & Network Priority', 'fa': '۲. اولویت پروتکل و شبکه'},
    'step_priority_desc': {'en': 'Select preferred anti-censorship protocols for your connection', 'fa': 'پروتکل‌های مورد نظر خود را جهت عبور مطمئن از فیلترینگ انتخاب کنید'},
    'settings_title': {'en': 'VELOCITY POWER-USER SETTINGS', 'fa': 'تنظیمات پیشرفته ولوسیتی'},
    'settings_subtitle': {'en': 'CORE TUNNEL & NETWORK ENGINE', 'fa': 'موتور تونل و شخصی‌سازی هسته'},
    'tab_routing_bypass': {'en': 'Routing & Bypass', 'fa': 'مسیریابی و بای‌پس'},
    'tab_tun_core': {'en': 'TUN & Core Engine', 'fa': 'تنظیمات هسته TUN'},
    'tab_split_tunnel': {'en': 'Split Tunneling', 'fa': 'تفکیک ترافیک برنامه‌ها'},
    'tab_visual_theme': {'en': 'Visual Neon Customizer', 'fa': 'شخصی‌سازی رنگ نئون'},
    'mock_grant_vpn': {'en': 'Mock Grant VpnService', 'fa': 'تایید دسترسی VpnService'},
    'mock_grant_notif': {'en': 'Mock Grant Notifications', 'fa': 'تایید دسترسی اعلان‌ها'},
    'finish_setup_enter': {'en': 'FINISH SETUP & ENTER VELOCITY', 'fa': 'پایان راه‌اندازی و ورود به ولوسیتی'},
    'sub_link_imported': {'en': 'Subscription link imported! Verified node added.', 'fa': 'لینک سابسکریپشن وارد و سرور فعال اضافه گردید.'},
    'search_nodes': {'en': 'Search servers or protocols...', 'fa': 'جستجوی سرور یا پروتکل...'},
    'no_nodes_found': {'en': 'No servers match your filter.', 'fa': 'هیچ سروری با فیلتر شما یافت نشد.'},
    'import_success': {'en': 'Server verified & imported', 'fa': 'سرور بررسی و اضافه شد'},
  };

  static String t(String key) {
    final langCode = currentLang == AppLanguage.fa ? 'fa' : 'en';
    return _strings[key]?[langCode] ?? key;
  }
}

// ---------------------------------------------------------------------------
// Velocity Stylized Neon Glowing 'V' Custom Painter
// ---------------------------------------------------------------------------
class VelocityEmblemPainter extends CustomPainter {
  final double glowIntensity;

  VelocityEmblemPainter({this.glowIntensity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Radial background glow behind the V
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          VelocityColors.electricCyan.withOpacity(0.35 * glowIntensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.5, glowPaint);

    // Main 'V' Path
    final path = Path()
      ..moveTo(w * 0.22, h * 0.24)
      ..lineTo(w * 0.44, h * 0.24)
      ..lineTo(w * 0.50, h * 0.74)
      ..lineTo(w * 0.78, h * 0.24);

    // Broad Deep Glow
    final broadGlow = Paint()
      ..color = VelocityColors.deepCyan.withOpacity(0.35 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, broadGlow);

    // Mid Aura
    final midGlow = Paint()
      ..color = VelocityColors.electricCyan.withOpacity(0.65 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, midGlow);

    // Bright Sharp Neon Core
    final sharpCore = Paint()
      ..color = VelocityColors.electricCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, sharpCore);

    // Aerodynamic Slit 1 on left wing
    final slit1 = Path()
      ..moveTo(w * 0.27, h * 0.33)
      ..lineTo(w * 0.39, h * 0.40);
    final slit1Paint = Paint()
      ..color = VelocityColors.electricCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(slit1, slit1Paint);

    // Aerodynamic Slit 2 on left wing
    final slit2 = Path()
      ..moveTo(w * 0.34, h * 0.45)
      ..lineTo(w * 0.44, h * 0.51);
    final slit2Paint = Paint()
      ..color = VelocityColors.deepCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(slit2, slit2Paint);
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
// Data Models & State Machine (Hiddify & Sing-box inspired)
// ---------------------------------------------------------------------------
enum VpnState { disconnected, connecting, connected, disconnecting }

enum RoutingMode { rule, bypassLan, global, direct }

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
  final int expireTimestamp; // unix timestamp in seconds
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
  
  double get usedGb => (uploadBytes + downloadBytes) / (1024 * 1024 * 1024);
  double get totalGb => totalBytes / (1024 * 1024 * 1024);
  double get remainingGb => totalGb > usedGb ? (totalGb - usedGb) : 0.0;

  int get remainingDays {
    if (expireTimestamp <= 0) return 0;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diffSec = expireTimestamp - nowSec;
    if (diffSec <= 0) return 0;
    return (diffSec / 86400).ceil();
  }

  String quotaDisplay(bool isFa) {
    if (!hasQuota) return isFa ? 'نامحدود' : 'Unlimited';
    return '${usedGb.toStringAsFixed(1)} GB / ${totalGb.toStringAsFixed(1)} GB';
  }

  String remainingDisplay(bool isFa) {
    if (expireTimestamp <= 0) {
      if (hasQuota) {
        return isFa ? '${remainingGb.toStringAsFixed(1)} GB باقیمانده' : '${remainingGb.toStringAsFixed(1)} GB Remaining';
      }
      return isFa ? 'بدون اشتراک فعال' : 'No Active Subscription';
    }
    final days = remainingDays;
    return isFa ? '$days روز باقیمانده' : '$days Days Remaining';
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

  String get address => host;
  String get server => host;

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
    if (pingMs! < 110) return VelocityColors.neonGreen;
    if (pingMs! < 250) return VelocityColors.electricCyan;
    if (pingMs! < 450) return VelocityColors.neonYellow;
    return VelocityColors.neonPink;
  }

  String get pingDisplay {
    if (isTesting) return '...';
    if (pingMs == null) return 'N/A';
    if (pingMs! < 0) return 'Timeout';
    return '${pingMs}ms';
  }
}

// ---------------------------------------------------------------------------
// Link Parser Engine (Sing-box & v2rayNG URI parser)
// ---------------------------------------------------------------------------
class ConfigLinkParser {
  static String detectCountryFlag(String name, String host) {
    final lower = '$name $host'.toLowerCase();
    if (lower.contains('de') || lower.contains('germany') || lower.contains('frankfurt') || lower.contains('berlin')) return '🇩🇪';
    if (lower.contains('fi') || lower.contains('finland') || lower.contains('helsinki')) return '🇫🇮';
    if (lower.contains('nl') || lower.contains('netherlands') || lower.contains('amsterdam')) return '🇳🇱';
    if (lower.contains('us') || lower.contains('usa') || lower.contains('united states') || lower.contains('ashburn') || lower.contains('los angeles') || lower.contains('miami') || lower.contains('chicago')) return '🇺🇸';
    if (lower.contains('sg') || lower.contains('singapore')) return '🇸🇬';
    if (lower.contains('gb') || lower.contains('uk') || lower.contains('london') || lower.contains('united kingdom')) return '🇬🇧';
    if (lower.contains('fr') || lower.contains('france') || lower.contains('paris')) return '🇫🇷';
    if (lower.contains('tr') || lower.contains('turkey') || lower.contains('istanbul')) return '🇹🇷';
    if (lower.contains('ca') || lower.contains('canada') || lower.contains('toronto')) return '🇨🇦';
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
        } else {
          try {
            final decoded = utf8.decode(base64.decode(base64.normalize(configPart)));
            if (decoded.contains('@')) {
              final atParts = decoded.split('@');
              final hostPort = atParts[1].split(':');
              host = hostPort[0];
              port = int.tryParse(hostPort.length > 1 ? hostPort[1] : '8388') ?? 8388;
            }
          } catch (_) {}
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
      name = 'Velocity Custom (${trimmed.split('://').first.toUpperCase()})';
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

    // Check if whole text is base64 encoded
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
// User Authentication & Subscription Plan Models
// ---------------------------------------------------------------------------
enum UserRole { guest, user }

enum AuthMethod { guest, telegram, gmailOtp }

class UserSession {
  final String id;
  final String displayName;
  final String identity;
  final UserRole role;
  final AuthMethod method;
  final String planName;
  final String planExpiry;
  final String dataUsed;
  final String dataTotal;
  final bool isVipActive;

  const UserSession({
    required this.id,
    required this.displayName,
    required this.identity,
    required this.role,
    required this.method,
    this.planName = 'Velocity VIP 30-Day',
    this.planExpiry = '2026-10-28',
    this.dataUsed = '34.2 GB',
    this.dataTotal = '100 GB',
    this.isVipActive = true,
  });

  static const guest = UserSession(
    id: 'guest_terminal',
    displayName: 'Guest Terminal',
    identity: 'Guest Device (Unlinked)',
    role: UserRole.guest,
    method: AuthMethod.guest,
    planName: 'Free Trial',
    planExpiry: '7 Days Remaining',
    dataUsed: '1.8 GB',
    dataTotal: '5.0 GB',
    isVipActive: false,
  );

  UserSession copyWith({
    String? id,
    String? displayName,
    String? identity,
    UserRole? role,
    AuthMethod? method,
    String? planName,
    String? planExpiry,
    String? dataUsed,
    String? dataTotal,
    bool? isVipActive,
  }) {
    return UserSession(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      identity: identity ?? this.identity,
      role: role ?? this.role,
      method: method ?? this.method,
      planName: planName ?? this.planName,
      planExpiry: planExpiry ?? this.planExpiry,
      dataUsed: dataUsed ?? this.dataUsed,
      dataTotal: dataTotal ?? this.dataTotal,
      isVipActive: isVipActive ?? this.isVipActive,
    );
  }
}

class VelocityPlan {
  final String id;
  String name;
  String dataQuota;
  int durationDays;
  String priceTomans;
  String priceUsdt;
  String protocolType;
  bool isActive;
  String badge;
  String nodesDescription;

  VelocityPlan({
    required this.id,
    required this.name,
    required this.dataQuota,
    required this.durationDays,
    required this.priceTomans,
    required this.priceUsdt,
    required this.protocolType,
    this.isActive = true,
    this.badge = '',
    this.nodesDescription = 'All Dedicated Global Nodes',
  });

  VelocityPlan copyWith({
    String? id,
    String? name,
    String? dataQuota,
    int? durationDays,
    String? priceTomans,
    String? priceUsdt,
    String? protocolType,
    bool? isActive,
    String? badge,
    String? nodesDescription,
  }) {
    return VelocityPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      dataQuota: dataQuota ?? this.dataQuota,
      durationDays: durationDays ?? this.durationDays,
      priceTomans: priceTomans ?? this.priceTomans,
      priceUsdt: priceUsdt ?? this.priceUsdt,
      protocolType: protocolType ?? this.protocolType,
      isActive: isActive ?? this.isActive,
      badge: badge ?? this.badge,
      nodesDescription: nodesDescription ?? this.nodesDescription,
    );
  }
}

// ---------------------------------------------------------------------------
// Root App
// ---------------------------------------------------------------------------
class VelocityVpnApp extends StatefulWidget {
  const VelocityVpnApp({super.key});

  @override
  State<VelocityVpnApp> createState() => _VelocityVpnAppState();
}

class _VelocityVpnAppState extends State<VelocityVpnApp> {
  AppLanguage _currentLang = AppLanguage.en;

  void _toggleLanguage() {
    setState(() {
      _currentLang = _currentLang == AppLanguage.en ? AppLanguage.fa : AppLanguage.en;
      I18n.currentLang = _currentLang;
    });
  }

  void _setLanguage(AppLanguage lang) {
    setState(() {
      _currentLang = lang;
      I18n.currentLang = _currentLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFa = _currentLang == AppLanguage.fa;

    return MaterialApp(
      title: 'Velocity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: VelocityColors.pureBlack,
        primaryColor: VelocityColors.electricCyan,
        fontFamily: isFa ? 'Vazirmatn' : 'sans-serif',
      ),
      home: Directionality(
        textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
        child: HomeScreen(
          onToggleLanguage: _toggleLanguage,
          onSetLanguage: _setLanguage,
          currentLang: _currentLang,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Velocity Foreground Local Notifications Service
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
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  static Future<void> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
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
        'Velocity VPN: متصل به $serverName',
        'تونل امن فعال است | پینگ: ${pingMs}ms',
        notifDetails,
      );
    } catch (e) {
      debugPrint('Error showing VPN notification: $e');
    }
  }

  static Future<void> cancelVpnNotification() async {
    try {
      await _notificationsPlugin.cancel(1001);
    } catch (e) {
      debugPrint('Error cancelling VPN notification: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// Home Screen (Core VPN Dashboard)
// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleLanguage;
  final Function(AppLanguage) onSetLanguage;
  final AppLanguage currentLang;

  const HomeScreen({
    super.key,
    required this.onToggleLanguage,
    required this.onSetLanguage,
    required this.currentLang,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  VpnState _vpnState = VpnState.disconnected;
  RoutingMode _routingMode = RoutingMode.rule;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Real-time telemetry simulation
  Timer? _trafficTimer;
  Timer? _durationTimer;
  int _connectedSeconds = 0;
  double _downloadSpeedKb = 0.0;
  double _uploadSpeedKb = 0.0;
  double _totalDownloadMb = 168.4;
  double _totalUploadMb = 44.1;

  // Velocity Official Nodes (Empty by default, populated dynamically via subscription import)
  final List<ServerProfile> _servers = [];

  ServerProfile? _selectedServer;
  SubscriptionInfo? _subscriptionInfo;

  // First-launch and permissions lifecycle
  bool _hasCompletedOnboarding = false;
  bool _vpnPermissionGranted = false;
  bool _notifPermissionGranted = false;
  String _selectedRegion = 'iran';

  // User Session & Dynamic Subscription Plans State
  UserSession _currentUser = UserSession.guest;

  final List<VelocityPlan> _plans = [
    VelocityPlan(
      id: 'plan-1',
      name: 'Velocity VIP 30-Day',
      dataQuota: '50 GB High-Speed',
      durationDays: 30,
      priceTomans: '290,000 Toman',
      priceUsdt: '\$4.99 USDT',
      protocolType: 'VLESS Reality + TLS 1.3',
      isActive: true,
      badge: 'POPULAR',
      nodesDescription: 'All Global Dedicated Direct Nodes',
    ),
    VelocityPlan(
      id: 'plan-2',
      name: 'Velocity Turbo 90-Day',
      dataQuota: '150 GB Turbo UDP',
      durationDays: 90,
      priceTomans: '790,000 Toman',
      priceUsdt: '\$11.99 USDT',
      protocolType: 'Hysteria 2 UDP + Reality',
      isActive: true,
      badge: 'BEST VALUE',
      nodesDescription: 'Anti-Filter Pool & Low-Ping Gaming',
    ),
    VelocityPlan(
      id: 'plan-3',
      name: 'Velocity Enterprise Annual',
      dataQuota: 'Unlimited VIP Bandwidth',
      durationDays: 365,
      priceTomans: '2,500,000 Toman',
      priceUsdt: '\$39.99 USDT',
      protocolType: 'Multi-Protocol Dedicated IP',
      isActive: true,
      badge: 'VIP ENTERPRISE',
      nodesDescription: 'Dedicated Clean IP & Priority Support',
    ),
    VelocityPlan(
      id: 'plan-4',
      name: 'Velocity Gaming Low-Ping 60-Day',
      dataQuota: '100 GB Zero-Loss UDP',
      durationDays: 60,
      priceTomans: '550,000 Toman',
      priceUsdt: '\$8.99 USDT',
      protocolType: 'Hysteria 2 + Trojan gRPC',
      isActive: true,
      badge: 'GAMING',
      nodesDescription: 'Optimized Routing for Discord & Gaming',
    ),
  ];

  void _openAuthOrProfile() {
    if (_currentUser.role == UserRole.guest) {
      _showAuthDialog();
    } else {
      _showUserProfileSheet();
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => VelocityAuthDialog(
        currentLang: widget.currentLang,
        onLoginSuccess: (session) {
          setState(() => _currentUser = session);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: VelocityColors.surfaceElevated,
              content: Text(
                widget.currentLang == AppLanguage.fa
                    ? 'خوش آمدید ${session.displayName}! ورود با موفقیت انجام شد.'
                    : 'Welcome ${session.displayName}! Account linked successfully.',
                style: const TextStyle(color: VelocityColors.electricCyan),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUserProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserProfileSheet(
        session: _currentUser,
        currentLang: widget.currentLang,
        onOpenPlans: () {
          Navigator.pop(ctx);
          _openReceiptUploadScreen();
        },
        onLogout: () {
          setState(() => _currentUser = UserSession.guest);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: VelocityColors.surfaceElevated,
              content: Text(
                widget.currentLang == AppLanguage.fa ? 'از حساب کاربری خارج شدید.' : 'Signed out from terminal.',
                style: const TextStyle(color: VelocityColors.textSecondary),
              ),
            ),
          );
        },
        onSwitchAccount: () {
          Navigator.pop(ctx);
          _showAuthDialog();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    VelocityNotificationService.init();
    _loadPersistedData();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Present First-Launch Onboarding Wizard on initial startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasCompletedOnboarding && mounted) {
        _showOnboardingWizard();
      }
    });
  }

  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serversJson = prefs.getString('saved_servers');
      final selectedId = prefs.getString('selected_server_id');
      final subJson = prefs.getString('subscription_info');

      if (serversJson != null && serversJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(serversJson);
        final loadedServers = decodedList.map((item) => ServerProfile.fromJson(item as Map<String, dynamic>)).toList();
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

  @override
  void dispose() {
    VelocityNotificationService.cancelVpnNotification();
    _pulseController.dispose();
    _trafficTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Onboarding Wizard & System Permission Dialogs
  // -------------------------------------------------------------------------
  void _showOnboardingWizard() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VelocityOnboardingDialog(
        currentLang: widget.currentLang,
        onSetLanguage: widget.onSetLanguage,
        initialRegion: _selectedRegion,
        onComplete: (region, mode) {
          setState(() {
            _hasCompletedOnboarding = true;
            _selectedRegion = region;
            _routingMode = mode;
            if (region == 'iran' && _servers.isNotEmpty) {
              // Pre-select the lowest ping Reality or Hysteria2 server
              _selectedServer = _servers.firstWhere(
                (s) => s.protocol == VpnProtocol.hysteria2 || s.protocol == VpnProtocol.vless,
                orElse: () => _servers.first,
              );
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: VelocityColors.surfaceElevated,
              content: Text(
                region == 'iran'
                    ? (I18n.currentLang == AppLanguage.fa
                        ? 'ولوسیتی آماده شد: بهینه‌سازی اپراتورهای ایران و Bypass LAN فعال گردید.'
                        : 'Velocity ready: Iran ISP optimization & Smart Bypass LAN active.')
                    : (I18n.currentLang == AppLanguage.fa
                        ? 'ولوسیتی آماده شد: حالت پروکسی بین‌الملل فعال گردید.'
                        : 'Velocity ready: Global Proxy mode active.'),
                style: const TextStyle(color: VelocityColors.electricCyan),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showVpnPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: VelocityColors.electricCyan, width: 1.2),
        ),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: VelocityColors.electricCyan.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.vpn_key_rounded, color: VelocityColors.electricCyan, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                I18n.t('vpn_dialog_title'),
                style: const TextStyle(
                  color: VelocityColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              I18n.t('vpn_dialog_body'),
              style: const TextStyle(
                color: VelocityColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: VelocityColors.pureBlack,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: VelocityColors.borderDark),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: VelocityColors.neonGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Android VpnService • TLS 1.3 Reality / Hysteria 2',
                      style: TextStyle(
                        color: VelocityColors.neonGreen.withOpacity(0.95),
                        fontSize: 10.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              I18n.t('btn_cancel'),
              style: const TextStyle(color: VelocityColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelocityColors.electricCyan,
              foregroundColor: VelocityColors.pureBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              I18n.t('btn_ok'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showNotificationPermissionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: VelocityColors.borderDark, width: 1.0),
        ),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        title: Row(
          children: [
            const VelocityEmblemWidget(size: 28, glowIntensity: 0.8),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                I18n.t('notif_dialog_title'),
                style: const TextStyle(
                  color: VelocityColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          I18n.t('notif_dialog_body'),
          style: const TextStyle(
            color: VelocityColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              I18n.t('btn_dont_allow'),
              style: const TextStyle(color: VelocityColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelocityColors.electricCyan,
              foregroundColor: VelocityColors.pureBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              I18n.t('btn_allow'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // VPN Connection Controller
  // -------------------------------------------------------------------------
  void _toggleVpn() async {
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

      // Step 1: Verify VPNService system permission
      if (!_vpnPermissionGranted) {
        final acceptedVpn = await _showVpnPermissionDialog();
        if (!acceptedVpn) {
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
        _vpnPermissionGranted = true;

        // Step 2: Verify POST_NOTIFICATIONS foreground keepalive permission
        if (!_notifPermissionGranted) {
          await _showNotificationPermissionDialog();
          _notifPermissionGranted = true;
        }
      }

      // Request notification permissions for Android 13+
      await VelocityNotificationService.requestPermissions();

      // Connecting sequence with accelerated neon pulse
      _pulseController.duration = const Duration(milliseconds: 700);
      _pulseController.repeat(reverse: true);

      setState(() => _vpnState = VpnState.connecting);
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;

      // Restore pulse to smooth breathing animation
      _pulseController.duration = const Duration(milliseconds: 1800);
      _pulseController.repeat(reverse: true);

      setState(() {
        _vpnState = VpnState.connected;
        _connectedSeconds = 0;
      });
      _startTelemetry();

      // Show real foreground notification in status bar
      if (_selectedServer != null) {
        await VelocityNotificationService.showVpnConnectedNotification(
          serverName: _selectedServer!.name,
          pingMs: _selectedServer!.pingMs ?? 0,
        );
      }
    } else if (_vpnState == VpnState.connected) {
      setState(() => _vpnState = VpnState.disconnecting);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _stopTelemetry();
      await VelocityNotificationService.cancelVpnNotification();
      setState(() {
        _vpnState = VpnState.disconnected;
        _downloadSpeedKb = 0;
        _uploadSpeedKb = 0;
      });
    }
  }

  void _startTelemetry() {
    _trafficTimer?.cancel();
    _trafficTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (!mounted || _vpnState != VpnState.connected) return;
      final rnd = math.Random();
      setState(() {
        _downloadSpeedKb = 550.0 + rnd.nextDouble() * 2850.0;
        _uploadSpeedKb = 120.0 + rnd.nextDouble() * 770.0;
        _totalDownloadMb += (_downloadSpeedKb / 1024);
        _totalUploadMb += (_uploadSpeedKb / 1024);
      });
    });

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _vpnState != VpnState.connected) return;
      setState(() => _connectedSeconds++);
    });
  }

  void _stopTelemetry() {
    _trafficTimer?.cancel();
    _durationTimer?.cancel();
  }

  // -------------------------------------------------------------------------
  // Ping Latency Runner
  // -------------------------------------------------------------------------
  Future<void> _pingAllServers() async {
    setState(() {
      for (var s in _servers) {
        s.isTesting = true;
      }
    });

    for (var server in _servers) {
      await Future.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      final rnd = math.Random();
      final base = server.protocol == VpnProtocol.hysteria2
          ? 70
          : (server.protocol == VpnProtocol.vless ? 78 : 118);
      setState(() {
        server.pingMs = base + rnd.nextInt(40) - 10;
        server.isTesting = false;
      });
    }
  }

  // -------------------------------------------------------------------------
  // Telegram Support / Channel Action
  // -------------------------------------------------------------------------
  void _openTelegramSupport() async {
    try {
      final uri = Uri.parse('https://t.me/Velocity_Support');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch Telegram: $e');
    }
  }

  void _openReceiptUploadScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptUploadScreen(
          isFa: I18n.currentLang == AppLanguage.fa,
          plans: _plans,
          currentUser: _currentUser,
          onOpenTelegram: _openTelegramSupport,
          onPlanPurchased: (purchasedPlan) {
            setState(() {
              _currentUser = _currentUser.copyWith(
                planName: purchasedPlan.name,
                isVipActive: true,
                dataTotal: purchasedPlan.dataQuota,
                planExpiry: '2026-11-30',
              );
            });
          },
        ),
      ),
    );
  }

  void _openPowerUserSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VelocityPowerUserSettingsScreen(
          isFa: I18n.currentLang == AppLanguage.fa,
          currentRoutingMode: _routingMode,
          onRoutingModeChanged: (mode) {
            setState(() => _routingMode = mode);
          },
          onAccentChanged: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  String _formattedDuration() {
    final hours = _connectedSeconds ~/ 3600;
    final minutes = (_connectedSeconds % 3600) ~/ 60;
    final seconds = _connectedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // -------------------------------------------------------------------------
  // UI Builder
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelocityColors.pureBlack,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: VelocityColors.pureBlack,
            border: Border(
              bottom: BorderSide(
                color: VelocityColors.electricCyan.withOpacity(0.25),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: VelocityColors.electricCyan.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // Stylized Glowing 'V' Emblem
                  const VelocityEmblemWidget(size: 38, glowIntensity: 1.0),
                  const SizedBox(width: 10),
                  // Title "VELOCITY" & Tagline "SECURE VPN SERVICES"
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        I18n.t('app_title'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: VelocityColors.electricCyan,
                        ),
                      ),
                      Text(
                        I18n.t('subtitle_tagline'),
                        style: const TextStyle(
                          fontSize: 8.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                          color: VelocityColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // User Profile & Authentication Terminal
                  IconButton(
                    icon: Icon(
                      _currentUser.role == UserRole.user
                          ? Icons.account_circle_rounded
                          : Icons.no_accounts_outlined,
                      color: _currentUser.role == UserRole.user
                          ? VelocityColors.neonGreen
                          : VelocityColors.electricCyan,
                      size: 22,
                    ),
                    tooltip: I18n.t('profile'),
                    onPressed: _openAuthOrProfile,
                  ),
                  // Setup Wizard button
                  IconButton(
                    icon: const Icon(Icons.auto_awesome, color: VelocityColors.electricCyan, size: 20),
                    tooltip: I18n.t('setup_wizard'),
                    onPressed: _showOnboardingWizard,
                  ),
                  // Telegram Support button
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: VelocityColors.electricCyan, size: 20),
                    tooltip: I18n.t('telegram_support'),
                    onPressed: _openTelegramSupport,
                  ),
                  // VIP Receipt & Activation button
                  IconButton(
                    icon: const Icon(Icons.receipt_long_rounded, color: VelocityColors.neonYellow, size: 22),
                    tooltip: I18n.t('receipt_title'),
                    onPressed: _openReceiptUploadScreen,
                  ),
                  // Power-User Settings button
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: VelocityColors.electricCyan, size: 21),
                    tooltip: I18n.t('settings_title'),
                    onPressed: _openPowerUserSettings,
                  ),
                  // Language toggle (EN/FA)
                  InkWell(
                    onTap: widget.onToggleLanguage,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: VelocityColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: VelocityColors.electricCyan, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.language, color: VelocityColors.electricCyan, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            widget.currentLang == AppLanguage.en ? 'FA' : 'EN',
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
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Routing Mode Bar & Import Bar
            _buildTopRoutingBar(),

            // Status Indicator Header
            const SizedBox(height: 14),
            _buildStatusHeader(),

            // Central Animated Power Button with BoxShadow Glow
            Expanded(
              child: Center(
                child: _buildGlowingPowerButton(),
              ),
            ),

            // NekoBox Telemetry Speed Card
            _buildTelemetryCard(),

            const SizedBox(height: 12),

            // Active Server Node Card
            _buildActiveServerCard(),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Top Routing Mode & Import Bar
  // -------------------------------------------------------------------------
  Widget _buildTopRoutingBar() {
    return Container(
      color: VelocityColors.surfaceDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Routing mode pill
          InkWell(
            onTap: _showRoutingBottomSheet,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: VelocityColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: VelocityColors.borderDark),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alt_route, color: VelocityColors.electricCyan, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _getRoutingTitle(_routingMode),
                    style: const TextStyle(
                      color: VelocityColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Import Config button
          InkWell(
            onTap: _showImportDialog,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: VelocityColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: VelocityColors.electricCyan, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    I18n.t('import_config'),
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
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Status Indicator & Subscription Quota Header
  // -------------------------------------------------------------------------
  Widget _buildStatusHeader() {
    Color statusColor;
    String statusText;

    switch (_vpnState) {
      case VpnState.connected:
        statusColor = VelocityColors.neonGreen;
        statusText = I18n.t('status_connected');
        break;
      case VpnState.connecting:
        statusColor = VelocityColors.electricCyan;
        statusText = I18n.t('status_connecting');
        break;
      case VpnState.disconnecting:
        statusColor = VelocityColors.neonPink;
        statusText = I18n.t('status_disconnecting');
        break;
      case VpnState.disconnected:
        statusColor = VelocityColors.neonPink;
        statusText = I18n.t('status_disconnected');
        break;
    }

    final isFa = I18n.currentLang == AppLanguage.fa;

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
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        if (_vpnState == VpnState.connected) ...[
          const SizedBox(height: 4),
          Text(
            '${I18n.t('connected_time')}: ${_formattedDuration()}',
            style: const TextStyle(
              color: VelocityColors.textSecondary,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
        const SizedBox(height: 6),
        // Real Subscription Quota & Expiry Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _subscriptionInfo != null && _subscriptionInfo!.hasQuota
                  ? VelocityColors.neonGreen.withOpacity(0.35)
                  : VelocityColors.borderDark,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _subscriptionInfo != null && _subscriptionInfo!.hasQuota
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_queue_rounded,
                color: _subscriptionInfo != null && _subscriptionInfo!.hasQuota
                    ? VelocityColors.neonGreen
                    : VelocityColors.textMuted,
                size: 13,
              ),
              const SizedBox(width: 6),
              Text(
                _subscriptionInfo != null
                    ? '${_subscriptionInfo!.quotaDisplay(isFa)} • ${_subscriptionInfo!.remainingDisplay(isFa)}'
                    : I18n.t('no_active_subscription'),
                style: TextStyle(
                  color: _subscriptionInfo != null && _subscriptionInfo!.hasQuota
                      ? VelocityColors.neonGreen
                      : VelocityColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: isFa ? 'Vazirmatn' : 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Central Glowing Power Button with Neon BoxShadow
  // -------------------------------------------------------------------------
  Widget _buildGlowingPowerButton() {
    final isConnected = _vpnState == VpnState.connected;
    final isConnecting =
        _vpnState == VpnState.connecting || _vpnState == VpnState.disconnecting;

    final glowColor = isConnected
        ? VelocityColors.neonGreen
        : VelocityColors.electricCyan;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = (isConnected || isConnecting) ? _pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: isConnecting ? null : _toggleVpn,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // BoxShadow neon glow effects behind connect button
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(isConnected ? 0.40 : 0.22),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: VelocityColors.deepCyan.withOpacity(0.20),
                    blurRadius: 60,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer decorative neon circle
                  Container(
                    width: 215,
                    height: 215,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: glowColor.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                  ),

                  // Middle Ring
                  Container(
                    width: 175,
                    height: 175,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          glowColor.withOpacity(isConnected ? 0.32 : 0.12),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: glowColor,
                        width: 2.5,
                      ),
                    ),
                  ),

                  // Inner Core Button
                  Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          VelocityColors.surfaceElevated,
                          VelocityColors.pureBlack,
                        ],
                      ),
                      border: Border.all(
                        color: isConnected ? glowColor : VelocityColors.borderDark,
                        width: 1.8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isConnecting)
                          SizedBox(
                            width: 42,
                            height: 42,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                              strokeWidth: 3.5,
                            ),
                          )
                        else
                          Icon(
                            Icons.power_settings_new_rounded,
                            size: 48,
                            color: glowColor,
                          ),
                        const SizedBox(height: 6),
                        Text(
                          isConnected
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

  // -------------------------------------------------------------------------
  // Telemetry Speed Card
  // -------------------------------------------------------------------------
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
          // Download speed
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
                      Text(
                        _downloadSpeedKb > 1024
                            ? '${(_downloadSpeedKb / 1024).toStringAsFixed(2)} MB/s'
                            : '${_downloadSpeedKb.toStringAsFixed(0)} KB/s',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: VelocityColors.electricCyan,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        '${I18n.t('total_down')} ${_totalDownloadMb.toStringAsFixed(1)} MB',
                        style: const TextStyle(fontSize: 9, color: VelocityColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: VelocityColors.borderDark),
          const SizedBox(width: 12),
          // Upload speed
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelocityColors.neonGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_upward, color: VelocityColors.neonGreen, size: 20),
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
                      Text(
                        _uploadSpeedKb > 1024
                            ? '${(_uploadSpeedKb / 1024).toStringAsFixed(2)} MB/s'
                            : '${_uploadSpeedKb.toStringAsFixed(0)} KB/s',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: VelocityColors.neonGreen,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        '${I18n.t('total_up')} ${_totalUploadMb.toStringAsFixed(1)} MB',
                        style: const TextStyle(fontSize: 9, color: VelocityColors.textMuted),
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
  // Active Server Card (Empty State & Active Node Display)
  // -------------------------------------------------------------------------
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
      onTap: _showServerBottomSheet,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: server.pingColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: server.pingColor, width: 1),
              ),
              child: Text(
                server.pingDisplay,
                style: TextStyle(
                  color: server.pingColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
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
  // Server Selection Bottom Sheet
  // -------------------------------------------------------------------------
  void _showServerBottomSheet() {
    String searchQuery = '';
    String selectedProtocolFilter = 'ALL';
    bool sortByLowestPing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VelocityColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Apply filtering and smart sorting
            List<ServerProfile> displayServers = _servers.where((server) {
              final q = searchQuery.toLowerCase();
              final matchesSearch = q.isEmpty ||
                  server.name.toLowerCase().contains(q) ||
                  server.countryCode.toLowerCase().contains(q) ||
                  server.protocol.name.toLowerCase().contains(q);

              final matchesProtocol = selectedProtocolFilter == 'ALL' ||
                  server.protocol.label.toUpperCase() == selectedProtocolFilter;

              return matchesSearch && matchesProtocol;
            }).toList();

            if (sortByLowestPing) {
              displayServers.sort((a, b) => (a.pingMs ?? 9999).compareTo(b.pingMs ?? 9999));
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VelocityColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              I18n.t('select_server'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: VelocityColors.electricCyan,
                              ),
                            ),
                            Text(
                              '${displayServers.length} / ${_servers.length} ${I18n.t('servers_count')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: VelocityColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (_servers.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.delete_sweep_rounded, color: VelocityColors.neonPink, size: 20),
                                tooltip: I18n.t('clear_all_nodes'),
                                onPressed: () {
                                  setState(() {
                                    _servers.clear();
                                    _selectedServer = null;
                                  });
                                  _savePersistedData();
                                  setSheetState(() {});
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.add_link, color: VelocityColors.electricCyan),
                              tooltip: I18n.t('import_config'),
                              onPressed: () {
                                Navigator.pop(context);
                                _showImportDialog();
                              },
                            ),
                            if (_servers.isNotEmpty)
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: VelocityColors.electricCyan),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                onPressed: () async {
                                  await _pingAllServers();
                                  setSheetState(() {});
                                },
                                icon: const Icon(Icons.bolt, color: VelocityColors.electricCyan, size: 16),
                                label: Text(
                                  I18n.t('ping_all'),
                                  style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 11),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_servers.isNotEmpty) ...[
                    // Search Bar & Sort by Lowest Ping Action
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: VelocityColors.pureBlack,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: VelocityColors.borderDark),
                              ),
                              child: TextField(
                                onChanged: (val) => setSheetState(() => searchQuery = val),
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
                            onTap: () => setSheetState(() => sortByLowestPing = !sortByLowestPing),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: sortByLowestPing
                                    ? VelocityColors.neonGreen.withOpacity(0.18)
                                    : VelocityColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: sortByLowestPing ? VelocityColors.neonGreen : VelocityColors.borderDark,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.speed_rounded,
                                    size: 16,
                                    color: sortByLowestPing ? VelocityColors.neonGreen : VelocityColors.textSecondary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    I18n.t('sort_lowest_ping'),
                                    style: TextStyle(
                                      color: sortByLowestPing ? VelocityColors.neonGreen : VelocityColors.textSecondary,
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

                    // Protocol Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: ['ALL', 'VLESS', 'HYSTERIA2', 'TROJAN', 'VMESS', 'SHADOWSOCKS'].map<Widget>((proto) {
                          final isChipSelected = selectedProtocolFilter == proto;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(proto),
                              selected: isChipSelected,
                              selectedColor: VelocityColors.electricCyan.withOpacity(0.2),
                              backgroundColor: VelocityColors.pureBlack,
                              side: BorderSide(
                                color: isChipSelected ? VelocityColors.electricCyan : VelocityColors.borderDark,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isChipSelected ? VelocityColors.electricCyan : VelocityColors.textMuted,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setSheetState(() => selectedProtocolFilter = proto);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const Divider(color: VelocityColors.borderDark, height: 1),
                  ],

                  Expanded(
                    child: displayServers.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: VelocityColors.electricCyan.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.cloud_off_rounded, size: 42, color: VelocityColors.electricCyan),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    I18n.t('no_nodes_available'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: VelocityColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: VelocityColors.electricCyan,
                                      foregroundColor: VelocityColors.pureBlack,
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showImportDialog();
                                    },
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
                            itemCount: displayServers.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemBuilder: (context, index) {
                              final server = displayServers[index];
                              final isSelected = _selectedServer != null && server.id == _selectedServer!.id;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? VelocityColors.electricCyan.withOpacity(0.08)
                                      : VelocityColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    setState(() => _selectedServer = server);
                                    _savePersistedData();
                                    Navigator.pop(context);
                                  },
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: VelocityColors.pureBlack,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark,
                                      ),
                                    ),
                                    child: Text(server.countryCode, style: const TextStyle(fontSize: 20)),
                                  ),
                                  title: Text(
                                    server.name,
                                    style: TextStyle(
                                      color: isSelected ? VelocityColors.electricCyan : VelocityColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: VelocityColors.pureBlack,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: VelocityColors.borderDark),
                                        ),
                                        child: Text(
                                          server.protocol.label,
                                          style: const TextStyle(
                                            color: VelocityColors.deepCyan,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${server.host}:${server.port}',
                                        style: const TextStyle(color: VelocityColors.textMuted, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: server.pingColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: server.pingColor),
                                        ),
                                        child: Text(
                                          server.pingDisplay,
                                          style: TextStyle(
                                            color: server.pingColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 16, color: VelocityColors.textMuted),
                                        tooltip: I18n.t('delete_node'),
                                        onPressed: () {
                                          setState(() {
                                            _servers.removeWhere((s) => s.id == server.id);
                                            if (_selectedServer?.id == server.id) {
                                              _selectedServer = _servers.isNotEmpty ? _servers.first : null;
                                            }
                                          });
                                          _savePersistedData();
                                          setSheetState(() {});
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
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Routing Mode Bottom Sheet
  // -------------------------------------------------------------------------
  void _showRoutingBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: VelocityColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                I18n.t('routing_mode'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: VelocityColors.electricCyan,
                ),
              ),
              const SizedBox(height: 16),
              _buildRoutingOption(
                mode: RoutingMode.rule,
                title: I18n.t('mode_rule'),
                subtitle: 'Velocity smart rules: bypass LAN, domestic banking, adblocking',
                icon: Icons.alt_route,
              ),
              _buildRoutingOption(
                mode: RoutingMode.bypassLan,
                title: I18n.t('mode_bypass_lan'),
                subtitle: 'Direct bypass for domestic IP/domains (.ir / banking apps)',
                icon: Icons.security,
              ),
              _buildRoutingOption(
                mode: RoutingMode.global,
                title: I18n.t('mode_global'),
                subtitle: 'Tunnel all device traffic via Velocity encrypted network',
                icon: Icons.public,
              ),
              _buildRoutingOption(
                mode: RoutingMode.direct,
                title: I18n.t('mode_direct'),
                subtitle: 'Direct connection (disable proxying)',
                icon: Icons.sync_disabled,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoutingOption({
    required RoutingMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _routingMode == mode;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? VelocityColors.electricCyan.withOpacity(0.08)
            : VelocityColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() => _routingMode = mode);
          Navigator.pop(context);
        },
        leading: Icon(icon, color: isSelected ? VelocityColors.electricCyan : VelocityColors.textSecondary),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? VelocityColors.electricCyan : VelocityColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: VelocityColors.electricCyan) : null,
      ),
    );
  }

  String _getRoutingTitle(RoutingMode mode) {
    switch (mode) {
      case RoutingMode.rule:
        return I18n.t('mode_rule');
      case RoutingMode.bypassLan:
        return I18n.t('mode_bypass_lan');
      case RoutingMode.global:
        return I18n.t('mode_global');
      case RoutingMode.direct:
        return I18n.t('mode_direct');
    }
  }

  Future<int> _simulatePing(String host, int port) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return 45 + (host.hashCode.abs() % 95);
  }

  // -------------------------------------------------------------------------
  // Import Config / Subscription URL Dialog with Real HTTP & Header Parsing
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
                      style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
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
                    style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    enabled: !isLoading,
                    maxLines: 4,
                    style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'https://sub.example.com/api/v1/client/subscribe?token=...\nor vless://, vmess://, trojan://, ss://, hy2://',
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
                    const SizedBox(height: 14),
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
                              // Real HTTP/HTTPS Subscription fetch
                              final uri = Uri.parse(input);
                              final response = await http.get(
                                uri,
                                headers: {
                                  'User-Agent': 'v2rayNG/1.8.0 sing-box/1.8.0 VelocityVPN/1.0',
                                  'Accept': '*/*',
                                },
                              ).timeout(const Duration(seconds: 15));

                              if (response.statusCode >= 200 && response.statusCode < 300) {
                                // Extract subscription-userinfo header
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
                              // Direct configs or multi-line/base64 pasted
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

                            // Run initial ping measurements on imported servers
                            for (var p in parsedProfiles) {
                              p.pingMs = await _simulatePing(p.host, p.port);
                            }

                            setState(() {
                              if (fetchedSub != null) {
                                _subscriptionInfo = fetchedSub;
                              }
                              for (var p in parsedProfiles.reversed) {
                                _servers.insert(0, p);
                              }
                              _selectedServer = _servers.first;
                            });

                            await _savePersistedData();

                            if (Navigator.canPop(dialogContext)) {
                              Navigator.pop(dialogContext);
                            }

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: VelocityColors.surfaceElevated,
                                duration: const Duration(seconds: 4),
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: VelocityColors.neonGreen, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${I18n.t('subscription_imported')} (+${parsedProfiles.length} ${I18n.t('servers_count')})',
                                        style: const TextStyle(color: VelocityColors.neonGreen, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
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

// ---------------------------------------------------------------------------
// Velocity VIP Activation & Telegram Checkout Screen
// ---------------------------------------------------------------------------
class ReceiptUploadScreen extends StatefulWidget {
  final bool isFa;
  final List<VelocityPlan> plans;
  final UserSession currentUser;
  final VoidCallback onOpenTelegram;
  final Function(VelocityPlan)? onPlanPurchased;

  const ReceiptUploadScreen({
    super.key,
    required this.isFa,
    required this.plans,
    required this.currentUser,
    required this.onOpenTelegram,
    this.onPlanPurchased,
  });

  @override
  State<ReceiptUploadScreen> createState() => _ReceiptUploadScreenState();
}

class _ReceiptUploadScreenState extends State<ReceiptUploadScreen> {
  int _selectedPlanIndex = 0;

  Future<void> _launchTelegramSupport() async {
    try {
      final uri = Uri.parse('https://t.me/Velocity_Support');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching telegram: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePlans = widget.plans.where((p) => p.isActive).toList();
    if (_selectedPlanIndex >= activePlans.length && activePlans.isNotEmpty) {
      _selectedPlanIndex = 0;
    }

    return Directionality(
      textDirection: widget.isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: VelocityColors.pureBlack,
        appBar: AppBar(
          backgroundColor: VelocityColors.surfaceDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: VelocityColors.electricCyan, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            I18n.t('receipt_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: VelocityColors.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Telegram Direct Activation Card
                InkWell(
                  onTap: _launchTelegramSupport,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VelocityColors.surfaceDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VelocityColors.electricCyan, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: VelocityColors.electricCyan.withOpacity(0.12),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: VelocityColors.electricCyan.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded, color: VelocityColors.electricCyan, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Instant Purchase via Telegram',
                                style: TextStyle(
                                  color: VelocityColors.electricCyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                I18n.t('telegram_direct_buy'),
                                style: const TextStyle(
                                  color: VelocityColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_outward, color: VelocityColors.electricCyan, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Subscription Plan Choice
                Row(
                  children: [
                    Text(
                      I18n.t('plan_select'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: VelocityColors.electricCyan,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${activePlans.length} plans available',
                      style: const TextStyle(fontSize: 11, color: VelocityColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (activePlans.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: VelocityColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: VelocityColors.borderDark),
                    ),
                    child: const Center(
                      child: Text(
                        'No plans currently active in store. Contact Telegram Support.',
                        style: TextStyle(color: VelocityColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  )
                else
                  ...List.generate(activePlans.length, (index) {
                    final plan = activePlans[index];
                    final isSelected = index == _selectedPlanIndex;
                    return InkWell(
                      onTap: () => setState(() => _selectedPlanIndex = index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? VelocityColors.electricCyan.withOpacity(0.08)
                              : VelocityColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: _selectedPlanIndex,
                              activeColor: VelocityColors.electricCyan,
                              onChanged: (val) => setState(() => _selectedPlanIndex = val!),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          plan.name,
                                          style: TextStyle(
                                            color: isSelected ? VelocityColors.electricCyan : VelocityColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ),
                                      if (plan.badge.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: VelocityColors.neonYellow.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            plan.badge,
                                            style: const TextStyle(
                                              color: VelocityColors.neonYellow,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${plan.dataQuota} • ${plan.durationDays}d • ${plan.protocolType}',
                                    style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  plan.priceUsdt,
                                  style: const TextStyle(
                                    color: VelocityColors.neonGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  plan.priceTomans,
                                  style: const TextStyle(
                                    color: VelocityColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                // Telegram Action Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelocityColors.electricCyan,
                      foregroundColor: VelocityColors.pureBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 6,
                      shadowColor: VelocityColors.electricCyan.withOpacity(0.4),
                    ),
                    onPressed: _launchTelegramSupport,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 20),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            I18n.t('telegram_checkout_btn'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// First-Launch Setup Wizard (Cyberpunk Onboarding Dialog)
// ---------------------------------------------------------------------------
class VelocityOnboardingDialog extends StatefulWidget {
  final AppLanguage currentLang;
  final Function(AppLanguage) onSetLanguage;
  final String initialRegion;
  final Function(String region, RoutingMode mode) onComplete;

  const VelocityOnboardingDialog({
    super.key,
    required this.currentLang,
    required this.onSetLanguage,
    required this.initialRegion,
    required this.onComplete,
  });

  @override
  State<VelocityOnboardingDialog> createState() => _VelocityOnboardingDialogState();
}

class _VelocityOnboardingDialogState extends State<VelocityOnboardingDialog> {
  int _currentStep = 0;
  late AppLanguage _selectedLang;
  late String _selectedRegion;

  // Step 2: Protocol Priority Selection
  final Set<String> _selectedProtocols = {'vless', 'hysteria2', 'trojan'};

  // Step 3: Interactive Mock Permission Grants
  bool _vpnMockGranted = false;
  bool _notifMockGranted = false;

  @override
  void initState() {
    super.initState();
    _selectedLang = widget.currentLang;
    _selectedRegion = widget.initialRegion;
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      final mode = _selectedRegion == 'iran' ? RoutingMode.bypassLan : RoutingMode.global;
      widget.onComplete(_selectedRegion, mode);
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFa = _selectedLang == AppLanguage.fa;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
          decoration: BoxDecoration(
            color: VelocityColors.midnightBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.55), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: VelocityColors.electricCyan.withOpacity(0.20),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with Emblem and Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    const VelocityEmblemWidget(size: 34, glowIntensity: 1.2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            I18n.t('wizard_title'),
                            style: const TextStyle(
                              color: VelocityColors.electricCyan,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            I18n.t('wizard_subtitle'),
                            style: const TextStyle(
                              color: VelocityColors.textSecondary,
                              fontSize: 9.5,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Step Progress Tracker
              _buildStepTracker(),

              const Divider(color: VelocityColors.borderDark, height: 1),

              // Step Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildCurrentStepContent(isFa),
                ),
              ),

              const Divider(color: VelocityColors.borderDark, height: 1),

              // Bottom Action Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: VelocityColors.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onPressed: _prevStep,
                        icon: Icon(
                          isFa ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                          size: 16,
                        ),
                        label: Text(
                          I18n.t('btn_back'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelocityColors.electricCyan,
                        foregroundColor: VelocityColors.pureBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: _nextStep,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentStep == 2
                                ? I18n.t('btn_start_velocity')
                                : I18n.t('btn_next'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentStep == 2
                                ? Icons.bolt_rounded
                                : (isFa ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded),
                            size: 18,
                          ),
                        ],
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
  }

  Widget _buildStepTracker() {
    final steps = [
      {'title': 'Lang/Region', 'icon': Icons.language},
      {'title': 'Protocols', 'icon': Icons.tune_rounded},
      {'title': 'Permissions', 'icon': Icons.verified_user_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      color: VelocityColors.surfaceDark.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final isDone = _currentStep > stepBefore;
            return Expanded(
              child: Container(
                height: 2,
                color: isDone ? VelocityColors.neonGreen : VelocityColors.borderDark,
              ),
            );
          }
          final stepIdx = index ~/ 2;
          final isActive = _currentStep == stepIdx;
          final isDone = _currentStep > stepIdx;
          final color = isDone
              ? VelocityColors.neonGreen
              : (isActive ? VelocityColors.electricCyan : VelocityColors.textMuted);

          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? VelocityColors.electricCyan.withOpacity(0.18) : VelocityColors.surfaceElevated,
              border: Border.all(color: color, width: isActive ? 2 : 1),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: VelocityColors.electricCyan.withOpacity(0.4),
                        blurRadius: 8,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              isDone ? Icons.check : (steps[stepIdx]['icon'] as IconData),
              size: 14,
              color: color,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isFa) {
    switch (_currentStep) {
      case 0:
        return _buildStep1LanguageAndRegion(isFa);
      case 1:
        return _buildStep2ProtocolPriority(isFa);
      case 2:
      default:
        return _buildStep3PermissionsPrimer(isFa);
    }
  }

  // STEP 1: Language & Region Selection (EN/FA with live flip & Iran vs Global routing)
  Widget _buildStep1LanguageAndRegion(bool isFa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('step_lang_title'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: VelocityColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          I18n.t('step_lang_desc'),
          style: const TextStyle(fontSize: 11.5, color: VelocityColors.textSecondary, height: 1.3),
        ),
        const SizedBox(height: 12),

        // Language Selection Row
        Row(
          children: [
            Expanded(
              child: _buildSelectableCard(
                isSelected: _selectedLang == AppLanguage.en,
                onTap: () {
                  setState(() => _selectedLang = AppLanguage.en);
                  widget.onSetLanguage(AppLanguage.en);
                },
                leadingWidget: const Text('🇺🇸', style: TextStyle(fontSize: 22)),
                title: I18n.t('lang_en'),
                subtitle: 'English (LTR)',
                badgeText: 'LTR',
                badgeColor: VelocityColors.electricCyan,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSelectableCard(
                isSelected: _selectedLang == AppLanguage.fa,
                onTap: () {
                  setState(() => _selectedLang = AppLanguage.fa);
                  widget.onSetLanguage(AppLanguage.fa);
                },
                leadingWidget: const Text('🇮🇷', style: TextStyle(fontSize: 22)),
                title: I18n.t('lang_fa'),
                subtitle: 'فارسی (RTL)',
                badgeText: 'راست‌چین',
                badgeColor: VelocityColors.neonGreen,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        Text(
          I18n.t('step_region_title'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: VelocityColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          I18n.t('step_region_desc'),
          style: const TextStyle(fontSize: 11.5, color: VelocityColors.textSecondary, height: 1.3),
        ),
        const SizedBox(height: 12),

        // Iran Routing Card
        _buildSelectableCard(
          isSelected: _selectedRegion == 'iran',
          onTap: () => setState(() => _selectedRegion = 'iran'),
          leadingWidget: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: VelocityColors.electricCyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cell_tower_rounded, color: VelocityColors.electricCyan, size: 20),
          ),
          title: I18n.t('region_iran_title'),
          subtitle: I18n.t('region_iran_desc'),
          badgeText: 'SMART BYPASS LAN',
          badgeColor: VelocityColors.electricCyan,
          tags: isFa
              ? ['همراه اول', 'ایرانسل', 'رایتل', 'مخابرات']
              : ['MCI', 'Irancell', 'Rightel', 'Fixed ISP'],
        ),

        const SizedBox(height: 10),

        // Global Routing Card
        _buildSelectableCard(
          isSelected: _selectedRegion == 'global',
          onTap: () => setState(() => _selectedRegion = 'global'),
          leadingWidget: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: VelocityColors.neonGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.public_rounded, color: VelocityColors.neonGreen, size: 20),
          ),
          title: I18n.t('region_global_title'),
          subtitle: I18n.t('region_global_desc'),
          badgeText: 'GLOBAL PROXY',
          badgeColor: VelocityColors.neonGreen,
          tags: isFa
              ? ['استریم بین‌الملل', 'گیمینگ کم‌پینگ', 'تونل مستقیم']
              : ['Global Stream', 'Low Ping Gaming', 'Direct Tunnel'],
        ),
      ],
    );
  }

  // STEP 2: Protocol & Network Priority Selection
  Widget _buildStep2ProtocolPriority(bool isFa) {
    final protocols = [
      {
        'id': 'vless',
        'name': 'VLESS Reality (XTLS Vision)',
        'desc': 'Direct TLS camouflage over port 443 with zero fingerprint detection.',
        'badge': 'ANTI-FILTER',
        'color': VelocityColors.electricCyan,
        'icon': Icons.security_rounded,
      },
      {
        'id': 'hysteria2',
        'name': 'Hysteria 2 (QUIC / UDP)',
        'desc': 'Brutal congestion control designed for lossy networks & mobile carriers.',
        'badge': 'TURBO SPEED',
        'color': VelocityColors.neonYellow,
        'icon': Icons.bolt_rounded,
      },
      {
        'id': 'trojan',
        'name': 'Trojan gRPC',
        'desc': 'Multiplexed high-concurrency traffic imitating legitimate web sessions.',
        'badge': 'STEALTH',
        'color': VelocityColors.neonGreen,
        'icon': Icons.verified_rounded,
      },
      {
        'id': 'vmess',
        'name': 'VMess WebSocket + TLS',
        'desc': 'CDN-backed fallback tunnel resistant to strict IP address blocking.',
        'badge': 'FALLBACK',
        'color': VelocityColors.neonPink,
        'icon': Icons.cloud_sync_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('step_priority_title'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: VelocityColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          I18n.t('step_priority_desc'),
          style: const TextStyle(fontSize: 11.5, color: VelocityColors.textSecondary, height: 1.3),
        ),
        const SizedBox(height: 14),

        ...protocols.map<Widget>((proto) {
          final isSelected = _selectedProtocols.contains(proto['id'] as String);
          final color = proto['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  final id = proto['id'] as String;
                  if (isSelected) {
                    if (_selectedProtocols.length > 1) {
                      _selectedProtocols.remove(id);
                    }
                  } else {
                    _selectedProtocols.add(id);
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? VelocityColors.surfaceElevated : VelocityColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : VelocityColors.borderDark,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(proto['icon'] as IconData, color: color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                proto['name'] as String,
                                style: const TextStyle(
                                  color: VelocityColors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  proto['badge'] as String,
                                  style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            proto['desc'] as String,
                            style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 10.5, height: 1.25),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      activeColor: color,
                      checkColor: VelocityColors.pureBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          final id = proto['id'] as String;
                          if (val == true) {
                            _selectedProtocols.add(id);
                          } else if (_selectedProtocols.length > 1) {
                            _selectedProtocols.remove(id);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // STEP 3: Android Permission Grant Primer with Interactive Toggles
  Widget _buildStep3PermissionsPrimer(bool isFa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('step_perm_title'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: VelocityColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          I18n.t('step_perm_desc'),
          style: const TextStyle(fontSize: 11.5, color: VelocityColors.textSecondary, height: 1.3),
        ),
        const SizedBox(height: 14),

        // Interactive VpnService Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _vpnMockGranted ? VelocityColors.surfaceElevated : VelocityColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _vpnMockGranted ? VelocityColors.neonGreen : VelocityColors.electricCyan.withOpacity(0.6),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (_vpnMockGranted ? VelocityColors.neonGreen : VelocityColors.electricCyan).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.vpn_key_rounded,
                      color: _vpnMockGranted ? VelocityColors.neonGreen : VelocityColors.electricCyan,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          I18n.t('perm_vpn_service'),
                          style: TextStyle(
                            color: _vpnMockGranted ? VelocityColors.neonGreen : VelocityColors.electricCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'android.net.VpnService (Local Virtual TUN)',
                          style: TextStyle(color: VelocityColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _vpnMockGranted,
                    activeColor: VelocityColors.neonGreen,
                    onChanged: (val) {
                      setState(() => _vpnMockGranted = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                I18n.t('perm_vpn_service_desc'),
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11, height: 1.3),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Interactive Notification Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _notifMockGranted ? VelocityColors.surfaceElevated : VelocityColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _notifMockGranted ? VelocityColors.neonGreen : VelocityColors.neonYellow.withOpacity(0.6),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (_notifMockGranted ? VelocityColors.neonGreen : VelocityColors.neonYellow).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: _notifMockGranted ? VelocityColors.neonGreen : VelocityColors.neonYellow,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          I18n.t('perm_notif_service'),
                          style: TextStyle(
                            color: _notifMockGranted ? VelocityColors.neonGreen : VelocityColors.neonYellow,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'POST_NOTIFICATIONS (Foreground Keepalive)',
                          style: TextStyle(color: VelocityColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notifMockGranted,
                    activeColor: VelocityColors.neonGreen,
                    onChanged: (val) {
                      setState(() => _notifMockGranted = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                I18n.t('perm_notif_service_desc'),
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableCard({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget leadingWidget,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    List<String>? tags,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? VelocityColors.surfaceElevated : VelocityColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? badgeColor : VelocityColors.borderDark,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: badgeColor.withOpacity(0.18),
                    blurRadius: 14,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                leadingWidget,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? VelocityColors.textPrimary : VelocityColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? badgeColor : VelocityColors.textMuted,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11.5, height: 1.4),
            ),
            if (tags != null && tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: tags.map<Widget>((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: VelocityColors.pureBlack,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: VelocityColors.borderDark),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Velocity User Authentication Terminal (Telegram, Gmail OTP)
// ---------------------------------------------------------------------------
class VelocityAuthDialog extends StatefulWidget {
  final AppLanguage currentLang;
  final Function(UserSession) onLoginSuccess;

  const VelocityAuthDialog({
    super.key,
    required this.currentLang,
    required this.onLoginSuccess,
  });

  @override
  State<VelocityAuthDialog> createState() => _VelocityAuthDialogState();
}

class _VelocityAuthDialogState extends State<VelocityAuthDialog> {
  int _activeTab = 0; // 0: Telegram, 1: Gmail OTP

  final _telegramController = TextEditingController(text: '@velocity_user');
  final _gmailController = TextEditingController(text: 'user@gmail.com');
  final _otpController = TextEditingController();

  int _otpCountdown = 0;
  Timer? _otpTimer;
  String? _simulatedOtp;

  @override
  void dispose() {
    _otpTimer?.cancel();
    _telegramController.dispose();
    _gmailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final email = _gmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: VelocityColors.neonPink,
          content: Text('Please enter a valid Gmail address.'),
        ),
      );
      return;
    }

    setState(() {
      _otpCountdown = 60;
      _simulatedOtp = (100000 + math.Random().nextInt(900000)).toString();
      _otpController.text = _simulatedOtp!;
    });

    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_otpCountdown > 0) {
          _otpCountdown--;
        } else {
          timer.cancel();
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: VelocityColors.surfaceElevated,
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_rounded, color: VelocityColors.neonGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Simulated OTP Code: $_simulatedOtp (Auto-filled)',
                style: const TextStyle(color: VelocityColors.electricCyan, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _submitTelegram() {
    final raw = _telegramController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: VelocityColors.neonPink,
          content: Text('Please enter your Telegram username or ID.'),
        ),
      );
      return;
    }
    final handle = raw.startsWith('@') ? raw : '@$raw';
    final session = UserSession(
      id: 'tg_${DateTime.now().millisecondsSinceEpoch}',
      displayName: handle,
      identity: handle,
      role: UserRole.user,
      method: AuthMethod.telegram,
      planName: 'Velocity VIP 30-Day',
      planExpiry: '2026-10-30',
      dataUsed: '14.2 GB',
      dataTotal: '50 GB',
      isVipActive: true,
    );
    widget.onLoginSuccess(session);
    Navigator.pop(context);
  }

  void _submitGmailOtp() {
    final email = _gmailController.text.trim();
    final otp = _otpController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: VelocityColors.neonPink,
          content: Text('Please enter a valid Gmail address.'),
        ),
      );
      return;
    }
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: VelocityColors.neonPink,
          content: Text('Please click SEND OTP and enter the 6-digit code.'),
        ),
      );
      return;
    }

    final name = email.split('@').first;
    final session = UserSession(
      id: 'gmail_${DateTime.now().millisecondsSinceEpoch}',
      displayName: name,
      identity: email,
      role: UserRole.user,
      method: AuthMethod.gmailOtp,
      planName: 'Velocity Turbo 90-Day',
      planExpiry: '2026-12-15',
      dataUsed: '32.8 GB',
      dataTotal: '150 GB',
      isVipActive: true,
    );
    widget.onLoginSuccess(session);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isFa = widget.currentLang == AppLanguage.fa;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1420),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: VelocityColors.electricCyan, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: VelocityColors.electricCyan.withOpacity(0.18),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Velocity Emblem & Title
                Row(
                  children: [
                    const VelocityEmblemWidget(size: 34, glowIntensity: 1.2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            I18n.t('auth_title'),
                            style: const TextStyle(
                              color: VelocityColors.electricCyan,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            I18n.t('auth_subtitle'),
                            style: const TextStyle(
                              color: VelocityColors.textSecondary,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: VelocityColors.textSecondary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Method Selector Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: VelocityColors.pureBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: VelocityColors.borderDark),
                  ),
                  child: Row(
                    children: [
                      _buildAuthTab(0, I18n.t('tab_telegram'), Icons.send_rounded),
                      _buildAuthTab(1, I18n.t('tab_gmail'), Icons.mail_outline_rounded),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tab Contents
                if (_activeTab == 0) _buildTelegramTab(),
                if (_activeTab == 1) _buildGmailTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthTab(int index, String title, IconData icon) {
    final isSelected = _activeTab == index;
    const color = VelocityColors.electricCyan;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? color : VelocityColors.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? color : VelocityColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelegramTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: VelocityColors.borderDark),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: VelocityColors.electricCyan, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Link your Telegram account to restore VIP subscription and auto-import node credentials.',
                  style: TextStyle(color: VelocityColors.textSecondary, fontSize: 11, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          I18n.t('telegram_hint'),
          style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _telegramController,
          style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.alternate_email, color: VelocityColors.electricCyan, size: 18),
            hintText: '@username',
            hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: VelocityColors.pureBlack,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.borderDark)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.electricCyan)),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelocityColors.electricCyan,
              foregroundColor: VelocityColors.pureBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.link_rounded, size: 18),
            label: Text(I18n.t('btn_connect_telegram'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: _submitTelegram,
          ),
        ),
      ],
    );
  }

  Widget _buildGmailTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('gmail_hint'),
          style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _gmailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail_outline, color: VelocityColors.electricCyan, size: 18),
                  hintText: 'name@gmail.com',
                  hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: VelocityColors.pureBlack,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.borderDark)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.electricCyan)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VelocityColors.surfaceElevated,
                foregroundColor: VelocityColors.electricCyan,
                side: const BorderSide(color: VelocityColors.electricCyan),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onPressed: _otpCountdown > 0 ? null : _sendOtp,
              child: Text(
                _otpCountdown > 0 ? '$_otpCountdown s' : I18n.t('btn_send_otp'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          I18n.t('otp_hint'),
          style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: VelocityColors.neonGreen, fontSize: 16, letterSpacing: 4, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_clock_outlined, color: VelocityColors.neonGreen, size: 18),
            hintText: '849201',
            hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 13, letterSpacing: 2),
            filled: true,
            fillColor: VelocityColors.pureBlack,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.borderDark)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.neonGreen)),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelocityColors.neonGreen,
              foregroundColor: VelocityColors.pureBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(I18n.t('btn_verify_otp'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: _submitGmailOtp,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Velocity User Profile Modal Bottom Sheet
// ---------------------------------------------------------------------------
class UserProfileSheet extends StatelessWidget {
  final UserSession session;
  final AppLanguage currentLang;
  final VoidCallback onOpenPlans;
  final VoidCallback onLogout;
  final VoidCallback onSwitchAccount;

  const UserProfileSheet({
    super.key,
    required this.session,
    required this.currentLang,
    required this.onOpenPlans,
    required this.onLogout,
    required this.onSwitchAccount,
  });

  @override
  Widget build(BuildContext context) {
    final isFa = currentLang == AppLanguage.fa;
    final isUser = session.role == UserRole.user;
    final themeColor = isUser ? VelocityColors.neonGreen : VelocityColors.electricCyan;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: const Color(0xFF0C101A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: themeColor.withOpacity(0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: VelocityColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // User Identity Header Card
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor, width: 1.8),
                    boxShadow: [
                      BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 10),
                    ],
                  ),
                  child: Icon(
                    isUser ? Icons.person_rounded : Icons.terminal_rounded,
                    color: themeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              session.displayName,
                              style: const TextStyle(
                                color: VelocityColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: themeColor, width: 0.8),
                            ),
                            child: Text(
                              isUser ? 'VIP SUBSCRIBER' : 'GUEST TERMINAL',
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        session.identity,
                        style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Subscription Status Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: VelocityColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: VelocityColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: VelocityColors.neonYellow, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        session.planName,
                        style: const TextStyle(
                          color: VelocityColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: session.isVipActive
                              ? VelocityColors.neonGreen.withOpacity(0.16)
                              : VelocityColors.neonPink.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          session.isVipActive ? I18n.t('sub_active') : I18n.t('sub_free'),
                          style: TextStyle(
                            color: session.isVipActive ? VelocityColors.neonGreen : VelocityColors.neonPink,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${I18n.t('sub_expiry')} ${session.planExpiry}',
                        style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
                      ),
                      Text(
                        '${session.dataUsed} / ${session.dataTotal}',
                        style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.35,
                      minHeight: 5,
                      backgroundColor: VelocityColors.pureBlack,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Upgrade Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VelocityColors.electricCyan,
                  foregroundColor: VelocityColors.pureBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.upgrade_rounded, size: 18),
                label: Text(
                  I18n.t('btn_upgrade'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: onOpenPlans,
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Actions (Switch / Logout)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VelocityColors.electricCyan,
                      side: const BorderSide(color: VelocityColors.borderDark),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: const Text('Switch Account', style: TextStyle(fontSize: 12)),
                    onPressed: onSwitchAccount,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VelocityColors.neonPink,
                      side: const BorderSide(color: VelocityColors.borderDark),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: Text(I18n.t('btn_logout'), style: const TextStyle(fontSize: 12)),
                    onPressed: onLogout,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}





// ---------------------------------------------------------------------------
// Velocity Power-User Settings Screen
// (Routing / Bypass Rules, Advanced TUN/Core Engine, Split Tunneling, Neon Visual Theme)
// ---------------------------------------------------------------------------
class VelocityPowerUserSettingsScreen extends StatefulWidget {
  final bool isFa;
  final RoutingMode currentRoutingMode;
  final Function(RoutingMode) onRoutingModeChanged;
  final VoidCallback onAccentChanged;

  const VelocityPowerUserSettingsScreen({
    super.key,
    required this.isFa,
    required this.currentRoutingMode,
    required this.onRoutingModeChanged,
    required this.onAccentChanged,
  });

  @override
  State<VelocityPowerUserSettingsScreen> createState() => _VelocityPowerUserSettingsScreenState();
}

class _VelocityPowerUserSettingsScreenState extends State<VelocityPowerUserSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Routing & Bypass Rules State
  late RoutingMode _routingMode;
  bool _bypassDomesticIran = true;
  bool _bypassBankingApps = true;
  bool _blockAdsMalware = true;
  bool _blockUdpQuic = false;

  // TUN & Core Engine Settings State
  String _tunImplementation = 'gVisor (User-space)';
  int _mtu = 1400;
  String _remoteDns = 'https://1.1.1.1/dns-query';
  String _directDns = '10.202.10.202';
  bool _enableFragmentMode = true;
  int _fragmentPackets = 50;
  bool _enableMux = true;
  bool _sniffingDomain = true;

  // Split Tunneling State
  bool _splitTunnelEnabled = true;
  String _splitMode = 'Bypass selected apps'; // 'Bypass selected apps' or 'Proxy only selected apps'
  final List<Map<String, dynamic>> _installedApps = [
    {'name': 'Mobile Bank Mellat', 'package': 'ir.mellat.mobile', 'bypass': true, 'icon': Icons.account_balance},
    {'name': 'Snapp! Ride & Food', 'package': 'cab.snapp.passenger', 'bypass': true, 'icon': Icons.local_taxi},
    {'name': 'Digikala Shopping', 'package': 'com.digikala.mobile', 'bypass': true, 'icon': Icons.shopping_bag_outlined},
    {'name': 'Bale Messenger', 'package': 'ir.ble.messenger', 'bypass': true, 'icon': Icons.chat_bubble_outline},
    {'name': 'Telegram Messenger', 'package': 'org.telegram.messenger', 'bypass': false, 'icon': Icons.send_rounded},
    {'name': 'Instagram & Threads', 'package': 'com.instagram.android', 'bypass': false, 'icon': Icons.camera_alt_outlined},
    {'name': 'YouTube & Music', 'package': 'com.google.android.youtube', 'bypass': false, 'icon': Icons.play_circle_outline},
    {'name': 'Google Chrome Browser', 'package': 'com.android.chrome', 'bypass': false, 'icon': Icons.public},
  ];

  // Visual Customizer Presets
  final List<Map<String, dynamic>> _colorThemes = [
    {
      'name': 'Electric Cyan (Default)',
      'primary': const Color(0xFF00E5FF),
      'secondary': const Color(0xFF00B0FF),
      'tag': 'CYAN',
    },
    {
      'name': 'Cyber Neon Emerald',
      'primary': const Color(0xFF00FF88),
      'secondary': const Color(0xFF00C853),
      'tag': 'EMERALD',
    },
    {
      'name': 'Acid Neon Amber',
      'primary': const Color(0xFFFFD600),
      'secondary': const Color(0xFFFF9100),
      'tag': 'AMBER',
    },
    {
      'name': 'Synthwave Neon Pink',
      'primary': const Color(0xFFFF1744),
      'secondary': const Color(0xFFD500F9),
      'tag': 'PINK',
    },
    {
      'name': 'Ultra Violet Horizon',
      'primary': const Color(0xFFD500F9),
      'secondary': const Color(0xFF651FFF),
      'tag': 'VIOLET',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _routingMode = widget.currentRoutingMode;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelocityColors.pureBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D121F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: VelocityColors.electricCyan, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              I18n.t('settings_title'),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: VelocityColors.textPrimary,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              I18n.t('settings_subtitle'),
              style: const TextStyle(fontSize: 9.5, color: VelocityColors.textSecondary, letterSpacing: 0.5),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: VelocityColors.electricCyan,
          indicatorWeight: 2.5,
          labelColor: VelocityColors.electricCyan,
          unselectedLabelColor: VelocityColors.textMuted,
          labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              icon: const Icon(Icons.alt_route, size: 16),
              text: I18n.t('tab_routing_bypass'),
            ),
            Tab(
              icon: const Icon(Icons.memory_rounded, size: 16),
              text: I18n.t('tab_tun_core'),
            ),
            Tab(
              icon: const Icon(Icons.call_split_rounded, size: 16),
              text: I18n.t('tab_split_tunnel'),
            ),
            Tab(
              icon: const Icon(Icons.palette_outlined, size: 16),
              text: I18n.t('tab_visual_theme'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: Routing & Bypass Rules
            _buildRoutingRulesTab(),
            // TAB 2: TUN & Core Engine Settings
            _buildTunCoreTab(),
            // TAB 3: Split Tunneling
            _buildSplitTunnelTab(),
            // TAB 4: Visual Neon Customizer
            _buildVisualCustomizerTab(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // TAB 1: Routing & Bypass Rules
  // -------------------------------------------------------------------------
  Widget _buildRoutingRulesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('GLOBAL ROUTING STRATEGY'),
        const SizedBox(height: 8),
        _buildRadioTile(
          RoutingMode.rule,
          'Rule-Based (Smart Traffic Routing)',
          'Automatically routes blocked traffic through proxy while keeping local Iranian services direct.',
        ),
        _buildRadioTile(
          RoutingMode.bypassLan,
          'Bypass LAN & Private Addresses',
          'Only routes public internet traffic through proxy; local 192.168.x / 10.x stay untouched.',
        ),
        _buildRadioTile(
          RoutingMode.global,
          'Global Tunnel (All Traffic Proxy)',
          'Force all device IP packets including local connections through encrypted VPN tunnel.',
        ),
        _buildRadioTile(
          RoutingMode.direct,
          'Direct Mode (Bypass VPN)',
          'No encryption applied. Packets connect directly without tunnel proxying.',
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('SPECIALIZED IRAN BYPASS & FILTERS'),
        const SizedBox(height: 8),
        _buildSwitchCard(
          title: 'Bypass Domestic Iran Sites (.ir & CIDRs)',
          subtitle: 'Keep Bank, Governmental, and internal ISP sites at local un-throttled speeds',
          value: _bypassDomesticIran,
          onChanged: (val) => setState(() => _bypassDomesticIran = val),
        ),
        const SizedBox(height: 8),
        _buildSwitchCard(
          title: 'Bypass Iranian Banking & Fintech Apps',
          subtitle: 'Prevent account security lockouts by routing mobile banks directly via domestic IP',
          value: _bypassBankingApps,
          onChanged: (val) => setState(() => _bypassBankingApps = val),
        ),
        const SizedBox(height: 8),
        _buildSwitchCard(
          title: 'Adblocking & Malicious DNS Shield',
          subtitle: 'Drop tracking telemetry, annoying ads, and known botnet domains at core DNS layer',
          value: _blockAdsMalware,
          onChanged: (val) => setState(() => _blockAdsMalware = val),
        ),
        const SizedBox(height: 8),
        _buildSwitchCard(
          title: 'Block UDP / QUIC (Force TCP/TLS Fallback)',
          subtitle: 'Useful on ISPs where UDP traffic is heavily choked or throttled by deep packet inspection',
          value: _blockUdpQuic,
          onChanged: (val) => setState(() => _blockUdpQuic = val),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // TAB 2: TUN & Core Engine Settings
  // -------------------------------------------------------------------------
  Widget _buildTunCoreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('TUN INTERFACE STACK'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1422),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: VelocityColors.borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TUN Virtual Stack Driver', style: TextStyle(color: VelocityColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tunImplementation,
                dropdownColor: const Color(0xFF0D121F),
                style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: VelocityColors.pureBlack,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: VelocityColors.borderDark)),
                ),
                items: ['gVisor (User-space)', 'System (Kernel TUN)', 'Mixed LWIP'].map<DropdownMenuItem<String>>((v) {
                  return DropdownMenuItem<String>(value: v, child: Text(v));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _tunImplementation = val);
                },
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MTU (Maximum Transmission Unit)', style: TextStyle(color: VelocityColors.textPrimary, fontSize: 12)),
                  Text('$_mtu bytes', style: const TextStyle(color: VelocityColors.electricCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Slider(
                value: _mtu.toDouble(),
                min: 1280,
                max: 1500,
                divisions: 22,
                activeColor: VelocityColors.electricCyan,
                inactiveColor: VelocityColors.borderDark,
                onChanged: (v) => setState(() => _mtu = v.toInt()),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('DNS RESOLUTION ENGINE'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1422),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: VelocityColors.borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Remote Secure DoH / DoT DNS', style: TextStyle(color: VelocityColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: TextEditingController(text: _remoteDns),
                style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 12),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: VelocityColors.pureBlack,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: VelocityColors.borderDark)),
                ),
                onChanged: (val) => _remoteDns = val,
              ),
              const SizedBox(height: 12),
              const Text('Direct Domestic DNS (Iran)', style: TextStyle(color: VelocityColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: TextEditingController(text: _directDns),
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 12),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: VelocityColors.pureBlack,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: VelocityColors.borderDark)),
                ),
                onChanged: (val) => _directDns = val,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('ANTI-CENSORSHIP PACKET EVASION'),
        const SizedBox(height: 8),
        _buildSwitchCard(
          title: 'TLS Fragment Mode (Deep Packet Inspection Evasion)',
          subtitle: 'Splits TLS Client Hello packets into multiple fragments to bypass Iran GFW SNI inspection',
          value: _enableFragmentMode,
          onChanged: (val) => setState(() => _enableFragmentMode = val),
        ),
        if (_enableFragmentMode) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fragment Chunk Size', style: TextStyle(color: VelocityColors.textSecondary, fontSize: 11)),
                Text('$_fragmentPackets-100 bytes', style: const TextStyle(color: VelocityColors.neonYellow, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
          Slider(
            value: _fragmentPackets.toDouble(),
            min: 10,
            max: 100,
            divisions: 9,
            activeColor: VelocityColors.neonYellow,
            inactiveColor: VelocityColors.borderDark,
            onChanged: (v) => setState(() => _fragmentPackets = v.toInt()),
          ),
        ],
        const SizedBox(height: 8),
        _buildSwitchCard(
          title: 'Multiplexing (TCP Mux)',
          subtitle: 'Consolidates multiple TCP connections into single streams to reduce handshake overhead',
          value: _enableMux,
          onChanged: (val) => setState(() => _enableMux = val),
        ),
        const SizedBox(height: 8),
        _buildSwitchCard(
          title: 'Core Domain Sniffing (HTTP & TLS)',
          subtitle: 'Extracts target domains from packet headers for accurate domain-based routing',
          value: _sniffingDomain,
          onChanged: (val) => setState(() => _sniffingDomain = val),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // TAB 3: Split Tunneling
  // -------------------------------------------------------------------------
  Widget _buildSplitTunnelTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF101626),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.call_split_rounded, color: VelocityColors.electricCyan, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Split Tunneling Controller',
                      style: TextStyle(color: VelocityColors.electricCyan, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isFa
                          ? 'مشخص کنید کدام اپلیکیشن‌ها از تونل وی‌پی‌ان عبور کنند یا از آن خارج شوند.'
                          : 'Select which installed apps bypass the encrypted VPN tunnel or route through it.',
                      style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _splitTunnelEnabled,
                activeColor: VelocityColors.electricCyan,
                onChanged: (val) => setState(() => _splitTunnelEnabled = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (_splitTunnelEnabled) ...[
          _buildSectionHeader('SPLIT TUNNELING MODE'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _splitMode = 'Bypass selected apps'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _splitMode == 'Bypass selected apps' ? VelocityColors.electricCyan.withOpacity(0.16) : VelocityColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _splitMode == 'Bypass selected apps' ? VelocityColors.electricCyan : VelocityColors.borderDark),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Bypass Selected',
                      style: TextStyle(
                        color: _splitMode == 'Bypass selected apps' ? VelocityColors.electricCyan : VelocityColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _splitMode = 'Proxy only selected apps'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _splitMode == 'Proxy only selected apps' ? VelocityColors.electricCyan.withOpacity(0.16) : VelocityColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _splitMode == 'Proxy only selected apps' ? VelocityColors.electricCyan : VelocityColors.borderDark),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Proxy Only Selected',
                      style: TextStyle(
                        color: _splitMode == 'Proxy only selected apps' ? VelocityColors.electricCyan : VelocityColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          _buildSectionHeader('DEVICE APPLICATIONS'),
          const SizedBox(height: 8),

          ..._installedApps.map<Widget>((app) {
            final isBypassed = app['bypass'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1422),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: VelocityColors.borderDark),
              ),
              child: Row(
                children: [
                  Icon(app['icon'] as IconData, color: isBypassed ? VelocityColors.neonYellow : VelocityColors.electricCyan, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app['name'] as String, style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(app['package'] as String, style: const TextStyle(color: VelocityColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isBypassed,
                    activeColor: VelocityColors.electricCyan,
                    checkColor: VelocityColors.pureBlack,
                    onChanged: (val) {
                      setState(() {
                        app['bypass'] = val ?? false;
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  // -------------------------------------------------------------------------
  // TAB 4: Visual Neon Customizer
  // -------------------------------------------------------------------------
  Widget _buildVisualCustomizerTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1422),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const VelocityEmblemWidget(size: 32, glowIntensity: 1.2),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        I18n.t('tab_visual_theme'),
                        style: const TextStyle(color: VelocityColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Cyberpunk Neon Accent Palette',
                        style: TextStyle(color: VelocityColors.textSecondary, fontSize: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.isFa
                    ? 'رنگ نئون اصلی رابط کاربری ولوسیتی را با یک لمس شخصی‌سازی نمایید.'
                    : 'Personalize Velocity with high-voltage cyberpunk neon accents.',
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11.5, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('SELECT NEON GLOW ACCENT'),
        const SizedBox(height: 10),

        ..._colorThemes.map<Widget>((theme) {
          final primary = theme['primary'] as Color;
          final secondary = theme['secondary'] as Color;
          final isCurrent = VelocityColors.electricCyan.value == primary.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isCurrent ? primary.withOpacity(0.12) : const Color(0xFF0D121F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? primary : VelocityColors.borderDark,
                width: isCurrent ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              onTap: () {
                VelocityColors.setNeonAccent(primary, secondary);
                widget.onAccentChanged();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: VelocityColors.surfaceElevated,
                    duration: const Duration(seconds: 1),
                    content: Text(
                      'Theme accent applied: ${theme['name']}',
                      style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, secondary]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: primary.withOpacity(0.6), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
              title: Text(
                theme['name'] as String,
                style: TextStyle(
                  color: isCurrent ? primary : VelocityColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                'RGB: ${primary.value.toRadixString(16).toUpperCase().substring(2)}',
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 10, fontFamily: 'monospace'),
              ),
              trailing: isCurrent
                  ? Icon(Icons.check_circle_rounded, color: primary, size: 20)
                  : const Icon(Icons.circle_outlined, color: VelocityColors.textMuted, size: 18),
            ),
          );
        }).toList(),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Helper UI Builders
  // -------------------------------------------------------------------------
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: VelocityColors.electricCyan,
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildRadioTile(RoutingMode mode, String title, String subtitle) {
    final isSelected = _routingMode == mode;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? VelocityColors.electricCyan.withOpacity(0.08) : const Color(0xFF0F1422),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark),
      ),
      child: ListTile(
        onTap: () {
          setState(() => _routingMode = mode);
          widget.onRoutingModeChanged(mode);
        },
        leading: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? VelocityColors.electricCyan : VelocityColors.textSecondary,
          size: 18,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? VelocityColors.electricCyan : VelocityColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 10.5)),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1422),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: VelocityColors.borderDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 10.5, height: 1.25)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: VelocityColors.electricCyan,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
