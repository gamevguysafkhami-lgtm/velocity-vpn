package com.example

enum class AppLanguage { EN, FA }

object I18n {
    var currentLang: AppLanguage = AppLanguage.EN

    private val strings = mapOf(
        "app_title" to mapOf("en" to "VELOCITY", "fa" to "ولوسیتی"),
        "subtitle_tagline" to mapOf("en" to "SECURE VPN SERVICES", "fa" to "سرویس‌های امن وی‌پی‌ان"),
        "telegram_support" to mapOf("en" to "Support / Channel", "fa" to "پشتیبانی / کانال تلگرام"),
        "telegram_handle" to mapOf("en" to "@VelocityVPN_Official", "fa" to "@VelocityVPN_Official"),
        "status_connected" to mapOf("en" to "SECURE TUNNEL ACTIVE", "fa" to "تونل امن متصل است"),
        "status_disconnected" to mapOf("en" to "DISCONNECTED", "fa" to "قطع ارتباط"),
        "status_connecting" to mapOf("en" to "CONNECTING TO VELOCITY...", "fa" to "در حال اتصال به سرورهای ولوسیتی..."),
        "status_disconnecting" to mapOf("en" to "TERMINATING TUNNEL...", "fa" to "در حال قطع اتصال..."),
        "tap_to_connect" to mapOf("en" to "TAP TO CONNECT", "fa" to "برای اتصال لمس کنید"),
        "tap_to_disconnect" to mapOf("en" to "TAP TO DISCONNECT", "fa" to "برای قطع لمس کنید"),
        "active_server" to mapOf("en" to "Active Velocity Node", "fa" to "سرور فعال ولوسیتی"),
        "select_server" to mapOf("en" to "Select Velocity Node", "fa" to "انتخاب سرور"),
        "servers_count" to mapOf("en" to "Nodes Online", "fa" to "سرور آنلاین"),
        "ping_all" to mapOf("en" to "Ping All Nodes", "fa" to "تست پینگ همه"),
        "testing_ping" to mapOf("en" to "Measuring Latency...", "fa" to "در حال سنجش تاخیر..."),
        "download_speed" to mapOf("en" to "DOWNLOAD", "fa" to "دریافت"),
        "upload_speed" to mapOf("en" to "UPLOAD", "fa" to "ارسال"),
        "total_down" to mapOf("en" to "Down:", "fa" to "دانلود:"),
        "total_up" to mapOf("en" to "Up:", "fa" to "آپلود:"),
        "routing_mode" to mapOf("en" to "Routing Mode", "fa" to "حالت مسیریابی"),
        "mode_rule" to mapOf("en" to "Smart Rule", "fa" to "قوانین هوشمند"),
        "mode_global" to mapOf("en" to "Global Proxy", "fa" to "پروکسی سراسری"),
        "mode_direct" to mapOf("en" to "Direct Bypass", "fa" to "مستقیم (بدون پروکسی)"),
        "mode_bypass_lan" to mapOf("en" to "Bypass Iran/LAN", "fa" to "دور زدن سایت‌های داخلی"),
        "receipt_title" to mapOf("en" to "Velocity VIP Activation", "fa" to "فعال‌سازی اشتراک VIP ولوسیتی"),
        "receipt_desc" to mapOf("en" to "Upload transaction slip or buy directly via Telegram Support.", "fa" to "تصویر فیش واریزی را بارگذاری کنید یا مستقیما از پشتیبانی تلگرام خرید فرمایید."),
        "import_config" to mapOf("en" to "Import Config", "fa" to "وارد کردن کانفیگ"),
        "import_prompt" to mapOf("en" to "Paste vless://, vmess://, trojan://, ss://, or hysteria2:// link", "fa" to "لینک کانفیگ (vless, vmess, trojan, ss, hysteria2) را وارد کنید"),
        "import_btn" to mapOf("en" to "Import & Test", "fa" to "وارد کردن و تست"),
        "cancel" to mapOf("en" to "Cancel", "fa" to "انصراف"),
        "tx_id" to mapOf("en" to "Transaction Hash / Receipt ID", "fa" to "کد پیگیری یا هش تراکنش"),
        "tx_placeholder" to mapOf("en" to "e.g. 0x9f2a... or Ref #847291", "fa" to "مثال: کد رهگیری یا هش تراکنش"),
        "plan_select" to mapOf("en" to "Select Velocity Plan", "fa" to "انتخاب پلن اشتراک ولوسیتی"),
        "upload_image_btn" to mapOf("en" to "Attach Receipt Proof", "fa" to "پیوست تصویر فیش واریزی"),
        "receipt_attached" to mapOf("en" to "Receipt Proof Attached", "fa" to "تصویر فیش ضمیمه شد"),
        "submit_receipt" to mapOf("en" to "Submit Activation Proof", "fa" to "ثبت و ارسال فیش"),
        "receipt_success" to mapOf("en" to "Activation proof received! Velocity Core will activate your account within 5 mins.", "fa" to "اطلاعات با موفقیت ارسال شد! اشتراک شما ظرف ۵ دقیقه توسط پشتیبانی ولوسیتی فعال می‌گردد."),
        "telegram_support_msg" to mapOf("en" to "Contact @VelocityVPN_Support for instant purchase or setup help.", "fa" to "برای خرید فوری اشتراک به آیدی تلگرام @VelocityVPN_Support پیام دهید."),
        "open_telegram" to mapOf("en" to "Open Telegram", "fa" to "ورود به تلگرام"),
        "close" to mapOf("en" to "Close", "fa" to "بستن"),
        "connected_time" to mapOf("en" to "Duration", "fa" to "مدت زمان اتصال")
    )

    fun t(key: String): String {
        val langCode = if (currentLang == AppLanguage.FA) "fa" else "en"
        return strings[key]?.get(langCode) ?: key
    }
}
