import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  static const Color electricCyan = Color(0xFF00E5FF);
  static const Color deepCyan = Color(0xFF00B0FF);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPink = Color(0xFFFF1744);
  static const Color neonYellow = Color(0xFFFFD600);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8FA0B8);
  static const Color textMuted = Color(0xFF4A5568);
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
    'import_prompt': {'en': 'Paste vless://, vmess://, trojan://, ss://, or hysteria2:// URL', 'fa': 'لینک کانفیگ (vless, vmess, trojan, ss, hysteria2) را وارد کنید'},
    'import_btn': {'en': 'Import & Test', 'fa': 'وارد کردن و تست'},
    'cancel': {'en': 'Cancel', 'fa': 'انصراف'},
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
    'tab_admin': {'en': 'Admin Key', 'fa': 'پنل ادمین'},
    'telegram_hint': {'en': '@username or Telegram ID', 'fa': '@نام_کاربری یا شناسه تلگرام'},
    'btn_connect_telegram': {'en': 'LINK TELEGRAM ACCOUNT', 'fa': 'اتصال به حساب تلگرام'},
    'gmail_hint': {'en': 'username@gmail.com', 'fa': 'آدرس ایمیل شما'},
    'btn_send_otp': {'en': 'SEND OTP', 'fa': 'ارسال کد تایید'},
    'btn_resend_otp': {'en': 'Resend in', 'fa': 'ارسال مجدد تا'},
    'otp_hint': {'en': '6-Digit OTP Code', 'fa': 'کد تایید ۶ رقمی'},
    'btn_verify_otp': {'en': 'VERIFY & SIGN IN', 'fa': 'تایید کد و ورود'},
    'admin_email_hint': {'en': 'admin@velocity.vpn', 'fa': 'ایمیل ادمین'},
    'admin_password_hint': {'en': 'Admin Security Key', 'fa': 'رمز عبور امنیتی'},
    'btn_admin_login': {'en': 'AUTHORIZE ADMIN ACCESS', 'fa': 'ورود به پنل مدیریت'},
    'quick_admin_fill': {'en': 'Autofill Admin Demo Credentials', 'fa': 'پر کردن سریع اطلاعات آزمایشی ادمین'},
    'admin_error': {'en': 'Invalid Admin Credentials! Check email or password.', 'fa': 'اطلاعات ادمین اشتباه است! ایمیل یا رمز را بررسی کنید.'},
    'admin_success': {'en': 'Admin access authorized! Control panel unlocked.', 'fa': 'دسترسی ادمین با موفقیت تایید شد! پنل کنترل فعال گردید.'},
    'sub_active': {'en': 'ACTIVE VIP', 'fa': 'اشتراک فعال'},
    'sub_free': {'en': 'FREE TIER', 'fa': 'نسخه رایگان'},
    'sub_expiry': {'en': 'Expires on', 'fa': 'تاریخ انقضا:'},
    'sub_quota': {'en': 'Bandwidth Usage', 'fa': 'میزان مصرف ترافیک'},
    'btn_upgrade': {'en': 'BROWSE PLANS & UPGRADE', 'fa': 'مشاهده و ارتقای پلن اشتراک'},
    'btn_open_admin': {'en': 'OPEN ADMIN CONTROL PANEL', 'fa': 'ورود به پنل مدیریت سرورها و پلن‌ها'},
    'btn_logout': {'en': 'LOG OUT', 'fa': 'خروج از حساب'},
    // Admin Dashboard & Plan Management Strings
    'admin_title': {'en': 'VELOCITY CORE • ADMIN PANEL', 'fa': 'ولوسیتی • پنل مدیریت ادمین'},
    'admin_sub': {'en': 'ROLE-BASED ACCESS CONTROL (RBAC)', 'fa': 'مدیریت پویا و سطح دسترسی سیستم'},
    'stat_total_plans': {'en': 'Total Plans', 'fa': 'کل پلن‌ها'},
    'stat_active_plans': {'en': 'Active in Store', 'fa': 'فعال در فروشگاه'},
    'stat_hidden_plans': {'en': 'Hidden / Draft', 'fa': 'مخفی / پیش‌نویس'},
    'stat_security': {'en': 'RBAC Status', 'fa': 'امنیت سیستم'},
    'filter_all': {'en': 'All Plans', 'fa': 'همه پلن‌ها'},
    'filter_active': {'en': 'Active Only', 'fa': 'فقط فعال'},
    'filter_hidden': {'en': 'Hidden Only', 'fa': 'فقط مخفی'},
    'btn_new_plan': {'en': 'CREATE NEW PLAN', 'fa': 'افزودن پلن جدید'},
    'edit_plan': {'en': 'Edit Plan', 'fa': 'ویرایش پلن'},
    'delete_plan': {'en': 'Delete Plan', 'fa': 'حذف پلن'},
    'delete_confirm': {'en': 'Are you sure you want to delete this subscription plan?', 'fa': 'آیا از حذف این پلن اشتراک اطمینان دارید؟'},
    'plan_name_field': {'en': 'Plan Title', 'fa': 'نام پلن'},
    'data_quota_field': {'en': 'Data Quota (e.g. 80 GB)', 'fa': 'حجم ترافیک (مثال: ۸۰ گیگابایت)'},
    'duration_days_field': {'en': 'Duration in Days', 'fa': 'مدت زمان (به روز)'},
    'price_tomans_field': {'en': 'Price in Tomans', 'fa': 'قیمت به تومان'},
    'price_usdt_field': {'en': 'Price in USDT', 'fa': 'قیمت به تتر (USDT)'},
    'protocol_type_field': {'en': 'Protocol Type', 'fa': 'نوع پروتکل'},
    'badge_field': {'en': 'Badge (Optional, e.g. POPULAR)', 'fa': 'برچسب (اختیاری، مثلا ویژه)'},
    'active_in_store': {'en': 'Active in Public Store', 'fa': 'نمایش در فروشگاه عمومی'},
    'save_plan_btn': {'en': 'SAVE PLAN', 'fa': 'ذخیره تغییرات'},
    'plan_saved': {'en': 'Plan successfully updated!', 'fa': 'پلن اشتراک با موفقیت ذخیره شد!'},
    'plan_deleted': {'en': 'Plan deleted from system.', 'fa': 'پلن از سیستم حذف شد.'},
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

class ServerProfile {
  final String id;
  String name;
  final String countryCode;
  final VpnProtocol protocol;
  final String host;
  final int port;
  final String sni;
  int? pingMs;
  bool isTesting;
  final String trafficUsage;

  ServerProfile({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.protocol,
    required this.host,
    required this.port,
    required this.sni,
    this.pingMs,
    this.isTesting = false,
    this.trafficUsage = '0.0 GB / 300 GB',
  });

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
  static ServerProfile parse(String rawUrl) {
    final trimmed = rawUrl.trim();
    VpnProtocol protocol = VpnProtocol.vless;
    String name = 'Velocity Custom Node';
    String host = 'node.velocity.net';
    int port = 443;
    String sni = host;

    try {
      if (trimmed.startsWith('vmess://')) {
        protocol = VpnProtocol.vmess;
        final base64Part = trimmed.substring(8);
        final decoded = utf8.decode(base64.decode(base64.normalize(base64Part)));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        name = json['ps']?.toString() ?? 'Velocity VMess';
        host = json['add']?.toString() ?? 'custom.vmess.com';
        port = int.tryParse(json['port']?.toString() ?? '443') ?? 443;
        sni = json['host']?.toString() ?? host;
      } else {
        final uri = Uri.parse(trimmed);
        switch (uri.scheme.toLowerCase()) {
          case 'vless':
            protocol = VpnProtocol.vless;
            break;
          case 'trojan':
            protocol = VpnProtocol.trojan;
            break;
          case 'ss':
            protocol = VpnProtocol.shadowsocks;
            break;
          case 'hy2':
          case 'hysteria2':
            protocol = VpnProtocol.hysteria2;
            break;
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
        sni = uri.queryParameters['sni'] ?? uri.queryParameters['peer'] ?? host;
      }
    } catch (_) {
      name = 'Velocity Custom (${trimmed.split('://').first.toUpperCase()})';
    }

    return ServerProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      countryCode: '🌐',
      protocol: protocol,
      host: host,
      port: port,
      sni: sni,
      pingMs: 95 + math.Random().nextInt(40),
      trafficUsage = '0.0 GB / 300 GB',
    );
  }
}

// ---------------------------------------------------------------------------
// User Authentication, RBAC & Subscription Plan Models
// ---------------------------------------------------------------------------
const String kAdminEmail = 'admin@velocity.vpn';
const String kAdminPassword = 'AdminSecurePassword123!';

enum UserRole { guest, user, admin }

enum AuthMethod { guest, telegram, gmailOtp, adminPassword }

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

  // Velocity Official Nodes
  final List<ServerProfile> _servers = [
    ServerProfile(
      id: 'vel-node-1',
      name: 'Velocity DE-Frankfurt Turbo',
      countryCode: '🇩🇪',
      protocol: VpnProtocol.vless,
      host: 'fra-velocity.node.net',
      port: 443,
      sni: 'speed.cloudflare.com',
      pingMs: 74,
      trafficUsage: '18.4 GB / 300 GB',
    ),
    ServerProfile(
      id: 'vel-node-2',
      name: 'Velocity FI-Helsinki Gaming UDP',
      countryCode: '🇫🇮',
      protocol: VpnProtocol.hysteria2,
      host: 'hel-velocity.node.net',
      port: 8443,
      sni: 'hel.apple.com',
      pingMs: 88,
      trafficUsage: '42.0 GB / 300 GB',
    ),
    ServerProfile(
      id: 'vel-node-3',
      name: 'Velocity NL-Amsterdam VIP gRPC',
      countryCode: '🇳🇱',
      protocol: VpnProtocol.trojan,
      host: 'ams-velocity.node.net',
      port: 443,
      sni: 'ams.microsoft.com',
      pingMs: 105,
      trafficUsage: '95.1 GB / 300 GB',
    ),
    ServerProfile(
      id: 'vel-node-4',
      name: 'Velocity US-Ashburn Cloud Direct',
      countryCode: '🇺🇸',
      protocol: VpnProtocol.vmess,
      host: 'iad-velocity.node.net',
      port: 2053,
      sni: 'iad.aws.amazon.com',
      pingMs: 158,
      trafficUsage: '8.3 GB / 300 GB',
    ),
    ServerProfile(
      id: 'vel-node-5',
      name: 'Velocity SG-Singapore FastPool',
      countryCode: '🇸🇬',
      protocol: VpnProtocol.shadowsocks,
      host: 'sin-velocity.node.net',
      port: 9000,
      sni: 'sg.google.com',
      pingMs: 176,
      trafficUsage: '2.1 GB / 300 GB',
    ),
  ];

  late ServerProfile _selectedServer;

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
          if (session.role == UserRole.admin) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: VelocityColors.surfaceElevated,
                content: Text(
                  I18n.t('admin_success'),
                  style: const TextStyle(color: VelocityColors.neonGreen, fontWeight: FontWeight.bold),
                ),
                action: SnackBarAction(
                  label: I18n.t('btn_open_admin'),
                  textColor: VelocityColors.electricCyan,
                  onPressed: _openAdminDashboard,
                ),
              ),
            );
          } else {
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
          }
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
        onOpenAdmin: () {
          Navigator.pop(ctx);
          _openAdminDashboard();
        },
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

  void _openAdminDashboard() {
    if (_currentUser.role != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: VelocityColors.neonPink,
          content: Text('Access Denied: Administrator role required.'),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AdminDashboardScreen(
          plans: _plans,
          currentUser: _currentUser,
          currentLang: widget.currentLang,
          onAddPlan: (newPlan) {
            setState(() => _plans.insert(0, newPlan));
          },
          onEditPlan: (updatedPlan) {
            setState(() {
              final idx = _plans.indexWhere((p) => p.id == updatedPlan.id);
              if (idx != -1) {
                _plans[idx] = updatedPlan;
              }
            });
          },
          onDeletePlan: (planId) {
            setState(() {
              _plans.removeWhere((p) => p.id == planId);
            });
          },
          onToggleActive: (planId, isActive) {
            setState(() {
              final idx = _plans.indexWhere((p) => p.id == planId);
              if (idx != -1) {
                _plans[idx].isActive = isActive;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedServer = _servers.first;

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

  @override
  void dispose() {
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
            if (region == 'iran') {
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
    } else if (_vpnState == VpnState.connected) {
      setState(() => _vpnState = VpnState.disconnecting);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _stopTelemetry();
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
  void _openTelegramSupport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VelocityColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VelocityColors.borderDark),
        ),
        title: Row(
          children: [
            const VelocityEmblemWidget(size: 26),
            const SizedBox(width: 10),
            const Text(
              'Velocity Support',
              style: TextStyle(color: VelocityColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              I18n.t('telegram_direct_buy'),
              style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VelocityColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: VelocityColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Official Channel:', style: TextStyle(color: VelocityColors.electricCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(I18n.t('telegram_channel'), style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13, fontFamily: 'monospace')),
                  const SizedBox(height: 8),
                  const Text('VIP Sales Desk:', style: TextStyle(color: VelocityColors.neonYellow, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(I18n.t('telegram_support_user'), style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13, fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(I18n.t('close'), style: const TextStyle(color: VelocityColors.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelocityColors.electricCyan,
              foregroundColor: VelocityColors.pureBlack,
            ),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: Text(I18n.t('open_telegram'), style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: VelocityColors.surfaceElevated,
                  content: Text('Telegram: ${I18n.t('telegram_channel')}', style: const TextStyle(color: VelocityColors.electricCyan)),
                ),
              );
            },
          ),
        ],
      ),
    );
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
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          _currentUser.role == UserRole.admin
                              ? Icons.admin_panel_settings_rounded
                              : (_currentUser.role == UserRole.user
                                  ? Icons.account_circle_rounded
                                  : Icons.no_accounts_outlined),
                          color: _currentUser.role == UserRole.admin
                              ? VelocityColors.neonYellow
                              : (_currentUser.role == UserRole.user
                                  ? VelocityColors.neonGreen
                                  : VelocityColors.electricCyan),
                          size: 22,
                        ),
                        if (_currentUser.role == UserRole.admin)
                          Positioned(
                            right: -1,
                            top: -1,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: VelocityColors.neonYellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    tooltip: I18n.t('profile'),
                    onPressed: _openAuthOrProfile,
                  ),
                  // If Admin, show Quick Admin Control Panel Launcher
                  if (_currentUser.role == UserRole.admin)
                    IconButton(
                      icon: const Icon(Icons.dashboard_customize_rounded, color: VelocityColors.neonYellow, size: 20),
                      tooltip: I18n.t('admin_panel'),
                      onPressed: _openAdminDashboard,
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
  // Status Indicator
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
  // Active Server Card
  // -------------------------------------------------------------------------
  Widget _buildActiveServerCard() {
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
                _selectedServer.countryCode,
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
                          _selectedServer.protocol.label,
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
                    _selectedServer.name,
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
                color: _selectedServer.pingColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _selectedServer.pingColor, width: 1),
              ),
              child: Text(
                _selectedServer.pingDisplay,
                style: TextStyle(
                  color: _selectedServer.pingColor,
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
            return Container(
              height: MediaQuery.of(context).size.height * 0.70,
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
                              '${_servers.length} ${I18n.t('servers_count')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: VelocityColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_link, color: VelocityColors.electricCyan),
                              tooltip: I18n.t('import_config'),
                              onPressed: () {
                                Navigator.pop(context);
                                _showImportDialog();
                              },
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: VelocityColors.electricCyan),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                await _pingAllServers();
                                setSheetState(() {});
                              },
                              icon: const Icon(Icons.bolt, color: VelocityColors.electricCyan, size: 16),
                              label: Text(
                                I18n.t('ping_all'),
                                style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: VelocityColors.borderDark, height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _servers.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final server = _servers[index];
                        final isSelected = server.id == _selectedServer.id;

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
                                  server.trafficUsage,
                                  style: const TextStyle(color: VelocityColors.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                            trailing: Container(
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

  // -------------------------------------------------------------------------
  // Import Config Dialog
  // -------------------------------------------------------------------------
  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
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
              Text(
                I18n.t('import_config'),
                style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                I18n.t('import_prompt'),
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'vless://..., vmess://..., trojan://..., hysteria2://...',
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(I18n.t('cancel'), style: const TextStyle(color: VelocityColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VelocityColors.electricCyan,
                foregroundColor: VelocityColors.pureBlack,
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final newProfile = ConfigLinkParser.parse(text);
                  setState(() {
                    _servers.insert(0, newProfile);
                    _selectedServer = newProfile;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(I18n.t('import_btn')),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Velocity VIP Activation & Receipt Upload Screen
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
  final _txIdController = TextEditingController();
  int _selectedPlanIndex = 0;
  bool _imageAttached = false;
  bool _isSubmitting = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: VelocityColors.surfaceElevated,
        content: Text(
          '$label copied to clipboard!',
          style: const TextStyle(color: VelocityColors.electricCyan, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitReceipt(List<VelocityPlan> activePlans) async {
    if (_txIdController.text.trim().isEmpty && !_imageAttached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: VelocityColors.neonPink,
          content: Text('Please enter Ref ID or attach receipt image proof'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    VelocityPlan? chosenPlan;
    if (activePlans.isNotEmpty && _selectedPlanIndex < activePlans.length) {
      chosenPlan = activePlans[_selectedPlanIndex];
      widget.onPlanPurchased?.call(chosenPlan);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: VelocityColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: VelocityColors.neonGreen),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: VelocityColors.neonGreen),
              SizedBox(width: 8),
              Text(
                'Proof Submitted',
                style: TextStyle(color: VelocityColors.neonGreen, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                I18n.t('receipt_success'),
                style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13),
              ),
              if (chosenPlan != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: VelocityColors.pureBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: VelocityColors.neonYellow, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Activated: ${chosenPlan.name} (${chosenPlan.dataQuota})',
                          style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VelocityColors.neonGreen,
                foregroundColor: VelocityColors.pureBlack,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(I18n.t('close')),
            ),
          ],
        );
      },
    );
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
                  onTap: widget.onOpenTelegram,
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

                const SizedBox(height: 12),

                // Payment Gateways with Quick Copy
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VelocityColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: VelocityColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.currency_exchange, color: VelocityColors.neonYellow, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Official Velocity Payment Gateways:',
                            style: TextStyle(color: VelocityColors.neonYellow, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // USDT TRC20
                      InkWell(
                        onTap: () => _copyToClipboard('TQk8mVELOCITY983xLp24VpNd78Qz', 'USDT Address'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: VelocityColors.pureBlack,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: VelocityColors.borderDark),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.monetization_on_outlined, color: VelocityColors.neonGreen, size: 15),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'USDT (TRC-20): TQk8mVELOCITY983xLp24VpNd78Qz',
                                  style: TextStyle(color: VelocityColors.textPrimary, fontSize: 10.5, fontFamily: 'monospace'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.copy, color: VelocityColors.electricCyan, size: 14),
                            ],
                          ),
                        ),
                      ),
                      // TON / Telegram Wallet
                      InkWell(
                        onTap: () => _copyToClipboard('EQBvVELOCITY_CORE_TON_4421', 'TON Address'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: VelocityColors.pureBlack,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: VelocityColors.borderDark),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, color: VelocityColors.electricCyan, size: 15),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'TON / Telegram: EQBvVELOCITY_CORE_TON_4421',
                                  style: TextStyle(color: VelocityColors.textPrimary, fontSize: 10.5, fontFamily: 'monospace'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.copy, color: VelocityColors.electricCyan, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Transaction Hash Field
                Text(
                  I18n.t('tx_id'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: VelocityColors.electricCyan,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _txIdController,
                  style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: I18n.t('tx_placeholder'),
                    hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: VelocityColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: VelocityColors.borderDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: VelocityColors.electricCyan),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Simulated Image Attachment
                InkWell(
                  onTap: () => setState(() => _imageAttached = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      color: _imageAttached
                          ? VelocityColors.neonGreen.withOpacity(0.08)
                          : VelocityColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _imageAttached ? VelocityColors.neonGreen : VelocityColors.borderDark,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _imageAttached ? Icons.check_circle : Icons.cloud_upload_outlined,
                          size: 36,
                          color: _imageAttached ? VelocityColors.neonGreen : VelocityColors.electricCyan,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _imageAttached
                              ? I18n.t('receipt_attached')
                              : I18n.t('upload_image_btn'),
                          style: TextStyle(
                            color: _imageAttached ? VelocityColors.neonGreen : VelocityColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (_imageAttached)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'velocity_receipt_2026.png (1.4 MB)',
                              style: TextStyle(color: VelocityColors.textSecondary, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelocityColors.electricCyan,
                      foregroundColor: VelocityColors.pureBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: _isSubmitting ? null : () => _submitReceipt(activePlans),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(VelocityColors.pureBlack),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                I18n.t('submit_receipt'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
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
      {'title': 'Lang', 'icon': Icons.language},
      {'title': 'Region', 'icon': Icons.cell_tower_rounded},
      {'title': 'Perms', 'icon': Icons.verified_user_rounded},
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
        return _buildLanguageStep(isFa);
      case 1:
        return _buildRegionStep(isFa);
      case 2:
      default:
        return _buildPermissionsStep(isFa);
    }
  }

  Widget _buildLanguageStep(bool isFa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('step_lang_title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: VelocityColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          I18n.t('step_lang_desc'),
          style: const TextStyle(fontSize: 12, color: VelocityColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 18),

        // English Card
        _buildSelectableCard(
          isSelected: _selectedLang == AppLanguage.en,
          onTap: () {
            setState(() => _selectedLang = AppLanguage.en);
            widget.onSetLanguage(AppLanguage.en);
          },
          leadingWidget: const Text('🇺🇸', style: TextStyle(fontSize: 26)),
          title: I18n.t('lang_en'),
          subtitle: I18n.t('lang_en_sub'),
          badgeText: 'LTR PREVIEW',
          badgeColor: VelocityColors.electricCyan,
        ),

        const SizedBox(height: 14),

        // Persian Card
        _buildSelectableCard(
          isSelected: _selectedLang == AppLanguage.fa,
          onTap: () {
            setState(() => _selectedLang = AppLanguage.fa);
            widget.onSetLanguage(AppLanguage.fa);
          },
          leadingWidget: const Text('🇮🇷', style: TextStyle(fontSize: 26)),
          title: I18n.t('lang_fa'),
          subtitle: I18n.t('lang_fa_sub'),
          badgeText: 'پیش‌نمایش راست‌چین RTL',
          badgeColor: VelocityColors.neonGreen,
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: VelocityColors.borderDark),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: VelocityColors.electricCyan, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isFa
                      ? 'انتخاب زبان فوراً ساختار صفحات را به صورت زنده منطبق می‌کند.'
                      : 'Selecting a language immediately updates the direction and layout live.',
                  style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegionStep(bool isFa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('step_region_title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: VelocityColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          I18n.t('step_region_desc'),
          style: const TextStyle(fontSize: 12, color: VelocityColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 18),

        // Iran Card
        _buildSelectableCard(
          isSelected: _selectedRegion == 'iran',
          onTap: () => setState(() => _selectedRegion = 'iran'),
          leadingWidget: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: VelocityColors.electricCyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cell_tower_rounded, color: VelocityColors.electricCyan, size: 22),
          ),
          title: I18n.t('region_iran_title'),
          subtitle: I18n.t('region_iran_desc'),
          badgeText: 'SMART BYPASS & REALITY',
          badgeColor: VelocityColors.electricCyan,
          tags: isFa
              ? ['همراه اول', 'ایرانسل', 'رایتل', 'مخابرات']
              : ['MCI', 'Irancell', 'Rightel', 'Fixed ISP'],
        ),

        const SizedBox(height: 14),

        // Global Card
        _buildSelectableCard(
          isSelected: _selectedRegion == 'global',
          onTap: () => setState(() => _selectedRegion = 'global'),
          leadingWidget: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: VelocityColors.neonGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.public_rounded, color: VelocityColors.neonGreen, size: 22),
          ),
          title: I18n.t('region_global_title'),
          subtitle: I18n.t('region_global_desc'),
          badgeText: 'GLOBAL PROXY',
          badgeColor: VelocityColors.neonGreen,
          tags: isFa
              ? ['استریم بین‌الملل', 'گیمینگ کم‌پینگ', 'بدون سانسور']
              : ['Global Stream', 'Low Ping Gaming', 'Direct Tunnel'],
        ),
      ],
    );
  }

  Widget _buildPermissionsStep(bool isFa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          I18n.t('step_perm_title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: VelocityColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          I18n.t('step_perm_desc'),
          style: const TextStyle(fontSize: 12, color: VelocityColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 18),

        // VpnService Primer Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VelocityColors.electricCyan.withOpacity(0.5), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: VelocityColors.electricCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.vpn_key_rounded, color: VelocityColors.electricCyan, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          I18n.t('perm_vpn_service'),
                          style: const TextStyle(
                            color: VelocityColors.electricCyan,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: VelocityColors.electricCyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: VelocityColors.electricCyan, width: 0.8),
                    ),
                    child: const Text(
                      'REQUIRED',
                      style: TextStyle(color: VelocityColors.electricCyan, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                I18n.t('perm_vpn_service_desc'),
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11.5, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Notification Primer Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: VelocityColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VelocityColors.neonGreen.withOpacity(0.5), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: VelocityColors.neonGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: VelocityColors.neonGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          I18n.t('perm_notif_service'),
                          style: const TextStyle(
                            color: VelocityColors.neonGreen,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: VelocityColors.neonGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: VelocityColors.neonGreen, width: 0.8),
                    ),
                    child: const Text(
                      'STABILITY',
                      style: TextStyle(color: VelocityColors.neonGreen, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                I18n.t('perm_notif_service_desc'),
                style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11.5, height: 1.4),
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
                children: tags.map((t) {
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
// Velocity User Authentication Terminal (Telegram, Gmail OTP, Admin Access)
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
  int _activeTab = 0; // 0: Telegram, 1: Gmail OTP, 2: Admin Key

  final _telegramController = TextEditingController(text: '@velocity_user');
  final _gmailController = TextEditingController(text: 'user@gmail.com');
  final _otpController = TextEditingController();

  final _adminEmailController = TextEditingController(text: kAdminEmail);
  final _adminPasswordController = TextEditingController(text: kAdminPassword);
  bool _obscureAdminPass = true;
  String? _adminError;

  int _otpCountdown = 0;
  Timer? _otpTimer;
  String? _simulatedOtp;

  @override
  void dispose() {
    _otpTimer?.cancel();
    _telegramController.dispose();
    _gmailController.dispose();
    _otpController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
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

  void _submitAdmin() {
    final email = _adminEmailController.text.trim().toLowerCase();
    final pass = _adminPasswordController.text.trim();

    if (email == kAdminEmail.toLowerCase() && pass == kAdminPassword) {
      setState(() => _adminError = null);
      final adminSession = const UserSession(
        id: 'admin_root',
        displayName: 'Root Administrator',
        identity: kAdminEmail,
        role: UserRole.admin,
        method: AuthMethod.adminPassword,
        planName: 'Enterprise Unlimited VIP (Root)',
        planExpiry: 'Permanent RBAC Root Privileges',
        dataUsed: '0.0 GB',
        dataTotal: 'Unlimited',
        isVipActive: true,
      );
      widget.onLoginSuccess(adminSession);
      Navigator.pop(context);
    } else {
      setState(() {
        _adminError = I18n.t('admin_error');
      });
    }
  }

  void _quickFillAdmin() {
    setState(() {
      _adminEmailController.text = kAdminEmail;
      _adminPasswordController.text = kAdminPassword;
      _adminError = null;
    });
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
                      _buildAuthTab(2, I18n.t('tab_admin'), Icons.admin_panel_settings_rounded, isHighlighted: true),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tab Contents
                if (_activeTab == 0) _buildTelegramTab(),
                if (_activeTab == 1) _buildGmailTab(),
                if (_activeTab == 2) _buildAdminTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthTab(int index, String title, IconData icon, {bool isHighlighted = false}) {
    final isSelected = _activeTab == index;
    final color = isHighlighted
        ? VelocityColors.neonYellow
        : VelocityColors.electricCyan;

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

  Widget _buildAdminTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: VelocityColors.neonYellow.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: VelocityColors.neonYellow.withOpacity(0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: VelocityColors.neonYellow, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SYSTEM ADMINISTRATOR PRIVILEGES (RBAC)\nUnlocks Dynamic Plan Management and Core Telemetry.',
                  style: TextStyle(color: VelocityColors.neonYellow, fontSize: 10.5, height: 1.35, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          I18n.t('admin_email_hint'),
          style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _adminEmailController,
          style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.account_box_outlined, color: VelocityColors.neonYellow, size: 18),
            hintText: 'admin@velocity.vpn',
            hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: VelocityColors.pureBlack,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.borderDark)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.neonYellow)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          I18n.t('admin_password_hint'),
          style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _adminPasswordController,
          obscureText: _obscureAdminPass,
          style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.key_rounded, color: VelocityColors.neonYellow, size: 18),
            suffixIcon: IconButton(
              icon: Icon(_obscureAdminPass ? Icons.visibility_off : Icons.visibility, color: VelocityColors.textSecondary, size: 18),
              onPressed: () => setState(() => _obscureAdminPass = !_obscureAdminPass),
            ),
            hintText: 'Admin password',
            hintStyle: const TextStyle(color: VelocityColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: VelocityColors.pureBlack,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.borderDark)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: VelocityColors.neonYellow)),
          ),
        ),
        if (_adminError != null) ...[
          const SizedBox(height: 8),
          Text(
            _adminError!,
            style: const TextStyle(color: VelocityColors.neonPink, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 8),
        InkWell(
          onTap: _quickFillAdmin,
          child: Text(
            I18n.t('quick_admin_fill'),
            style: const TextStyle(color: VelocityColors.electricCyan, fontSize: 11, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelocityColors.neonYellow,
              foregroundColor: VelocityColors.pureBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
            label: Text(I18n.t('btn_admin_login'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: _submitAdmin,
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
  final VoidCallback onOpenAdmin;
  final VoidCallback onOpenPlans;
  final VoidCallback onLogout;
  final VoidCallback onSwitchAccount;

  const UserProfileSheet({
    super.key,
    required this.session,
    required this.currentLang,
    required this.onOpenAdmin,
    required this.onOpenPlans,
    required this.onLogout,
    required this.onSwitchAccount,
  });

  @override
  Widget build(BuildContext context) {
    final isFa = currentLang == AppLanguage.fa;
    final isAdmin = session.role == UserRole.admin;
    final isUser = session.role == UserRole.user;

    final themeColor = isAdmin
        ? VelocityColors.neonYellow
        : (isUser ? VelocityColors.neonGreen : VelocityColors.electricCyan);

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
                    isAdmin
                        ? Icons.admin_panel_settings_rounded
                        : (isUser ? Icons.person_rounded : Icons.terminal_rounded),
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
                              isAdmin
                                  ? 'ADMINISTRATOR'
                                  : (isUser ? 'VIP SUBSCRIBER' : 'GUEST TERMINAL'),
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
                      value: isAdmin ? 0.05 : 0.35,
                      minHeight: 5,
                      backgroundColor: VelocityColors.pureBlack,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // If Admin: Quick Admin Launch Button
            if (isAdmin) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelocityColors.neonYellow,
                    foregroundColor: VelocityColors.pureBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.dashboard_customize_rounded, size: 18),
                  label: Text(
                    I18n.t('btn_open_admin'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: onOpenAdmin,
                ),
              ),
              const SizedBox(height: 10),
            ] else ...[
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
            ],

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
// Velocity Admin Dashboard Screen (CRUD Dynamic Plan Management)
// ---------------------------------------------------------------------------
class AdminDashboardScreen extends StatefulWidget {
  final List<VelocityPlan> plans;
  final UserSession currentUser;
  final AppLanguage currentLang;
  final Function(VelocityPlan) onAddPlan;
  final Function(VelocityPlan) onEditPlan;
  final Function(String planId) onDeletePlan;
  final Function(String planId, bool isActive) onToggleActive;

  const AdminDashboardScreen({
    super.key,
    required this.plans,
    required this.currentUser,
    required this.currentLang,
    required this.onAddPlan,
    required this.onEditPlan,
    required this.onDeletePlan,
    required this.onToggleActive,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _filter = 'all'; // 'all', 'active', 'hidden'

  void _showPlanFormDialog({VelocityPlan? existing}) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? 'Velocity VIP Turbo');
    final quotaCtrl = TextEditingController(text: existing?.dataQuota ?? '80 GB');
    final durationCtrl = TextEditingController(text: (existing?.durationDays ?? 30).toString());
    final priceTomansCtrl = TextEditingController(text: existing?.priceTomans ?? '390,000 Toman');
    final priceUsdtCtrl = TextEditingController(text: existing?.priceUsdt ?? '\$5.99 USDT');
    final protocolCtrl = TextEditingController(text: existing?.protocolType ?? 'VLESS Reality');
    final badgeCtrl = TextEditingController(text: existing?.badge ?? 'HOT');
    bool isActive = existing?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF101524),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: VelocityColors.electricCyan, width: 1.2),
              ),
              title: Row(
                children: [
                  const Icon(Icons.layers_rounded, color: VelocityColors.electricCyan),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? I18n.t('edit_plan') : I18n.t('btn_new_plan'),
                    style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFormField(nameCtrl, I18n.t('plan_name_field'), Icons.title),
                    const SizedBox(height: 8),
                    _buildFormField(quotaCtrl, I18n.t('data_quota_field'), Icons.data_usage),
                    const SizedBox(height: 8),
                    _buildFormField(durationCtrl, I18n.t('duration_days_field'), Icons.calendar_today, isNumeric: true),
                    const SizedBox(height: 8),
                    _buildFormField(priceTomansCtrl, I18n.t('price_tomans_field'), Icons.currency_exchange),
                    const SizedBox(height: 8),
                    _buildFormField(priceUsdtCtrl, I18n.t('price_usdt_field'), Icons.attach_money),
                    const SizedBox(height: 8),
                    _buildFormField(protocolCtrl, I18n.t('protocol_type_field'), Icons.security),
                    const SizedBox(height: 8),
                    _buildFormField(badgeCtrl, I18n.t('badge_field'), Icons.star_border),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      value: isActive,
                      activeColor: VelocityColors.electricCyan,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        I18n.t('active_in_store'),
                        style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12),
                      ),
                      onChanged: (v) => setDialogState(() => isActive = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(I18n.t('btn_cancel'), style: const TextStyle(color: VelocityColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelocityColors.electricCyan,
                    foregroundColor: VelocityColors.pureBlack,
                  ),
                  onPressed: () {
                    final dur = int.tryParse(durationCtrl.text.trim()) ?? 30;
                    if (isEditing) {
                      final updated = existing.copyWith(
                        name: nameCtrl.text.trim(),
                        dataQuota: quotaCtrl.text.trim(),
                        durationDays: dur,
                        priceTomans: priceTomansCtrl.text.trim(),
                        priceUsdt: priceUsdtCtrl.text.trim(),
                        protocolType: protocolCtrl.text.trim(),
                        badge: badgeCtrl.text.trim(),
                        isActive: isActive,
                      );
                      widget.onEditPlan(updated);
                    } else {
                      final newPlan = VelocityPlan(
                        id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        dataQuota: quotaCtrl.text.trim(),
                        durationDays: dur,
                        priceTomans: priceTomansCtrl.text.trim(),
                        priceUsdt: priceUsdtCtrl.text.trim(),
                        protocolType: protocolCtrl.text.trim(),
                        badge: badgeCtrl.text.trim(),
                        isActive: isActive,
                      );
                      widget.onAddPlan(newPlan);
                    }
                    setState(() {});
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: VelocityColors.surfaceElevated,
                        content: Text(I18n.t('plan_saved'), style: const TextStyle(color: VelocityColors.neonGreen)),
                      ),
                    );
                  },
                  child: Text(I18n.t('save_plan_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFormField(TextEditingController ctrl, String label, IconData icon, {bool isNumeric = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 12.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: VelocityColors.textSecondary, fontSize: 11),
        prefixIcon: Icon(icon, color: VelocityColors.electricCyan, size: 16),
        filled: true,
        fillColor: VelocityColors.pureBlack,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: VelocityColors.borderDark)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: VelocityColors.electricCyan)),
      ),
    );
  }

  void _confirmDelete(VelocityPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VelocityColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: VelocityColors.neonPink)),
        title: Text(I18n.t('delete_plan'), style: const TextStyle(color: VelocityColors.neonPink)),
        content: Text('${I18n.t('delete_confirm')}\n\n"${plan.name}"', style: const TextStyle(color: VelocityColors.textPrimary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(I18n.t('btn_cancel'), style: const TextStyle(color: VelocityColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VelocityColors.neonPink, foregroundColor: VelocityColors.pureBlack),
            onPressed: () {
              widget.onDeletePlan(plan.id);
              setState(() {});
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: VelocityColors.surfaceElevated,
                  content: Text(I18n.t('plan_deleted'), style: const TextStyle(color: VelocityColors.neonPink)),
                ),
              );
            },
            child: Text(I18n.t('delete_plan'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFa = widget.currentLang == AppLanguage.fa;

    List<VelocityPlan> displayedPlans = widget.plans;
    if (_filter == 'active') {
      displayedPlans = widget.plans.where((p) => p.isActive).toList();
    } else if (_filter == 'hidden') {
      displayedPlans = widget.plans.where((p) => !p.isActive).toList();
    }

    final totalCount = widget.plans.length;
    final activeCount = widget.plans.where((p) => p.isActive).length;
    final hiddenCount = widget.plans.where((p) => !p.isActive).length;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: VelocityColors.pureBlack,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D121F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: VelocityColors.neonYellow, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                I18n.t('admin_title'),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: VelocityColors.neonYellow,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                I18n.t('admin_sub'),
                style: const TextStyle(fontSize: 9.5, color: VelocityColors.textSecondary, letterSpacing: 0.5),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: VelocityColors.electricCyan, size: 22),
              tooltip: I18n.t('btn_new_plan'),
              onPressed: () => _showPlanFormDialog(),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // System Overview KPI Cards
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: Row(
                  children: [
                    _buildKpiCard(I18n.t('stat_total_plans'), '$totalCount', VelocityColors.electricCyan, Icons.folder_copy_outlined),
                    const SizedBox(width: 8),
                    _buildKpiCard(I18n.t('stat_active_plans'), '$activeCount', VelocityColors.neonGreen, Icons.visibility_outlined),
                    const SizedBox(width: 8),
                    _buildKpiCard(I18n.t('stat_hidden_plans'), '$hiddenCount', VelocityColors.neonYellow, Icons.visibility_off_outlined),
                    const SizedBox(width: 8),
                    _buildKpiCard(I18n.t('stat_security'), 'SECURE', VelocityColors.electricCyan, Icons.lock_outline),
                  ],
                ),
              ),

              // Filter Tabs & Create Button Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  children: [
                    _buildFilterChip('all', '${I18n.t('filter_all')} ($totalCount)'),
                    const SizedBox(width: 6),
                    _buildFilterChip('active', '${I18n.t('filter_active')} ($activeCount)'),
                    const SizedBox(width: 6),
                    _buildFilterChip('hidden', '${I18n.t('filter_hidden')} ($hiddenCount)'),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelocityColors.electricCyan,
                        foregroundColor: VelocityColors.pureBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('NEW PLAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _showPlanFormDialog(),
                    ),
                  ],
                ),
              ),

              const Divider(color: VelocityColors.borderDark, height: 16),

              // Dynamic Plan List
              Expanded(
                child: displayedPlans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: VelocityColors.textMuted, size: 48),
                            const SizedBox(height: 12),
                            const Text('No plans match current filter.', style: TextStyle(color: VelocityColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              icon: const Icon(Icons.add, color: VelocityColors.electricCyan),
                              label: const Text('Add Plan', style: TextStyle(color: VelocityColors.electricCyan)),
                              onPressed: () => _showPlanFormDialog(),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                        itemCount: displayedPlans.length,
                        itemBuilder: (context, index) {
                          final plan = displayedPlans[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1422),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: plan.isActive ? VelocityColors.borderDark : VelocityColors.neonYellow.withOpacity(0.3),
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
                                        color: (plan.isActive ? VelocityColors.electricCyan : VelocityColors.textMuted).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.bolt,
                                        color: plan.isActive ? VelocityColors.electricCyan : VelocityColors.textMuted,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
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
                                                    color: plan.isActive ? VelocityColors.textPrimary : VelocityColors.textMuted,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (plan.badge.isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: VelocityColors.neonYellow.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    plan.badge,
                                                    style: const TextStyle(color: VelocityColors.neonYellow, fontSize: 8.5, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            '${plan.dataQuota} • ${plan.durationDays} Days • ${plan.protocolType}',
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
                                          style: const TextStyle(color: VelocityColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          plan.priceTomans,
                                          style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(color: VelocityColors.borderDark, height: 1),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      plan.isActive ? 'Active in Public Store' : 'Hidden from Public Store',
                                      style: TextStyle(
                                        color: plan.isActive ? VelocityColors.neonGreen : VelocityColors.neonYellow,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Switch(
                                      value: plan.isActive,
                                      activeColor: VelocityColors.electricCyan,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (val) {
                                        widget.onToggleActive(plan.id, val);
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: VelocityColors.electricCyan, size: 18),
                                      tooltip: I18n.t('edit_plan'),
                                      onPressed: () => _showPlanFormDialog(existing: plan),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: VelocityColors.neonPink, size: 18),
                                      tooltip: I18n.t('delete_plan'),
                                      onPressed: () => _confirmDelete(plan),
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
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1420),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: VelocityColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: VelocityColors.textSecondary, fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? VelocityColors.electricCyan.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? VelocityColors.electricCyan : VelocityColors.borderDark),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? VelocityColors.electricCyan : VelocityColors.textSecondary,
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
