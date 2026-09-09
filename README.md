# 🌐 VELOCITY | Secure VPN Services
> **Next-Generation Multi-Platform Proxy & VPN Client**  
> Built with high-performance Flutter, powered by Sing-box core concepts, featuring an electric cyberpunk UI and intelligent routing mechanics.

---

### 🇬🇧 English Description

#### ⚡ Overview
**VELOCITY** is a modern, enterprise-ready, high-performance VPN and proxy client engineered with **Flutter**. Designed for speed, resilience against heavy network restrictions, and complete user privacy, VELOCITY brings a sleek **Dark Midnight & Electric Cyan** aesthetic paired with powerful telemetry, multi-protocol support, and an automated plan management system.

#### 🚀 Key Features
* **Cyberpunk Visual Interface:** High-contrast neon aesthetics (#00E5FF / #000000), fluid pulse animations, radar telemetry rings, and responsive glassmorphism cards.
* **Modern Protocol Suite:** Architecture ready for **VLESS (Reality), VMess, Trojan, ShadowSocks, and Hysteria 2 (UDP)**.
* **Dynamic Low-Latency Routing:**
  * Real-time multi-node ICMP / TCP ping delay measurement.
  * Instant **Lowest Ping** sorting and country/region smart search.
  * Smart traffic bifurcation (Domestic Iranian IP bypass, ad-blocking, and split tunneling).
* **Bilingual & Native Bi-Directional:** Native, zero-flicker dynamic switching between **English (LTR)** and **Persian (RTL)**.
* **Full-Lifecycle Onboarding:** Step-by-step setup wizard for first-run regional optimization, network preset selection, and Android `VpnService` permission orchestration.
* **Integrated Management & Auth Terminal:**
  * Dual user session linking via Telegram ID or Gmail OTP verification.
  * Role-Based Access Control (RBAC) featuring an **Admin Control Panel**.
  * Real-time plan management (CRUD, quota control, pricing in Tomans & USDT, dynamic public store sync).
  * Direct crypto and card receipt upload integration.

#### 🛠️ Tech Stack
* **Framework:** Flutter 3.x / Dart 3.x
* **State Management:** Reactive ValueNotifiers / In-Memory State Pipeline
* **Core Architecture:** Cross-Platform Native TUN Interface (Android `VpnService` & Desktop TUN abstraction)
* **CI/CD:** Automated GitHub Actions build pipeline targeting Android (`.apk`).

---

<div dir="rtl">

### 🇮🇷 توضیحات فارسی

#### ⚡ معرفی پروژه
**ولاسیتی (VELOCITY)** یک کلاینت وی‌پی‌ان و پراکسی مدرن، سریع و چندمنظوره است که با فریم‌ورک **فلاتر (Flutter)** توسعه یافته است. این برنامه با الهام از معماری هسته‌های قدرتمندی همچون Sing-box و Hiddify و با تمرکز بر عبور از محدودیت‌های شدید شبکه، امنیت داده‌ها و رابط کاربری چشم‌نواز نئونی-سایبرپنک طراحی شده است.

#### 💎 قابلیت‌های برجسته
* **رابط کاربری اختصاصی نئونی (Cyberpunk):** پالت رنگی مشکی عمیق و آبی الکتریکی، دکمه اتصال با انیمیشن راداری تپنده، کارت‌های وضعیت شیشه‌ای و چیدمان استاندارد.
* **پشتیبانی از پروتکل‌های نسل جدید:** ساختار سازگار با پروتکل‌های ضد فیلتر از جمله VLESS Reality ،Hysteria 2 ،Trojan و VMess.
* **مدیریت هوشمند نودها و پینگ واقعی:**
  * تست تاخیر لحظه‌ای با نمایش میلی‌ثانیه (ms).
  * مرتب‌سازی خودکار بر اساس کمترین پینگ (Lowest Ping) و جستجوی پیشرفته بر اساس نام کشور و لوکیشن.
  * روتینگ هوشمند (دور زدن سایت‌های داخلی ایران / LAN و بهینه‌سازی برای اپراتورهای مختلف).
* **سیستم دوزبانه کاملاً بومی:** تغییر لحظه‌ای زبان میان فارسی (RTL) و انگلیسی (LTR) بدون تداخل در چیدمان.
* **ویزارد راه‌اندازی گام‌به‌گام (Onboarding):** راهنمای اولیه کاربر برای انتخاب زبان، بهینه‌سازی ریجن بر اساس اینترنت، و شبیه‌سازی دریافت مجوزهای امنیتی VpnService و نوتیفیکیشن اندروید.
* **سیستم احراز هویت و پنل مدیریت ادمین:**
  * ورود و اتصال حساب از طریق آیدی تلگرام یا دریافت کد تایید ایمیلی (Gmail OTP).
  * تفکیک سطح دسترسی کاربر عادی و ادمین (RBAC).
  * پنل اختصاصی ادمین جهت افزودن، ویرایش و حذف پلن‌ها، تنظیم حجم و قیمت (تومان و تتر) و انتشار لحظه‌ای در فروشگاه.
  * صفحه اختصاصی فعال‌سازی VIP و ارسال تصویر فیش واریزی.

</div>

---
---

## 📥 دانلود و نصب / Installation & Platforms

<div dir="rtl">

کلاینت **VELOCITY** به لطف معماری کراس‌پلتفرم فلاتر و قابلیت خروجی یونیورسال، روی تمام پلتفرم‌ها و دستگاه‌ها قابل اجرا است:

</div>

| پلتفرم / سیستم‌عامل | نسخه و معماری | راهنمای نصب و نکات اختصاصی | وضعیت |
| :--- | :--- | :--- | :--- |
| **Android (سامسونگ، پیکسل و...)** | `Universal APK` (ARM64 / ARMv7) | دانلود مستقیم فایل `.apk` از بخش Releases یا تب Actions گیت‌هاب و فعال‌سازی Allow Unknown Sources. | 🟢 استیبل |
| **Xiaomi (MIUI / HyperOS)** | `APK بهینه‌شده` | نصب فایل APK. در صورت بروز وقفه در پس‌زمینه: خاموش کردن Battery Saver برای برنامه و فعال‌سازی Auto-start. | 🟢 استیبل |
| **Windows** | `Windows x64 (.exe / .zip)` | دانلود سورس یا پکیج ریلیز، اجرای فایل خروجی در ویندوز ۱۰ و ۱۱، بدون نیاز به پیش‌نیاز اضافه. | 🟡 آزمایشی |
| **macOS** | `Apple Silicon (M1/M2/M3) & Intel` | نیازمند کامپایل محلی یا نصب فایل `.dmg` خروجی بیلد مک با دسترسی روت برای رابط TUN. | 🟡 آزمایشی |
| **iOS (iPhone / iPad)** | `IPA / TestFlight` | به دلیل سیاست‌های امنیتی اپل، کلاینت نیازمند ساین با Apple Developer یا نصب از طریق AltStore / TrollStore است. | 🔄 در حال آماده‌سازی |

<div dir="rtl">

### 💡 راهنمای سریع دانلود فایل اندروید و شیائومی (APK):
1. از بالای همین صفحه گیت‌هاب، به تب **Actions** بروید.
2. روی آخرین بیلد سبز رنگ (تیک‌خورده) با عنوان **Build Android Release APK** کلیک کنید.
3. در پایین صفحه و در بخش **Artifacts**، فایل فشرده `Velocity-VPN-Universal-Release` را دانلود کنید.
4. فایل را از زیپ خارج کرده و روی گوشی نصب کنید.

</div>


### 📱 Quick Run / اجرای سریع پروژه

```bash
# Clone the repository
git clone [https://github.com/gamevguysafkhami-lgtm/velocity-vpn.git](https://github.com/gamevguysafkhami-lgtm/velocity-vpn.git)

# Enter project directory
cd velocity-vpn

# Get Flutter dependencies
flutter pub get

# Run on Web / Chrome
flutter run -d chrome --web-port=8080

# Build Android Release APK
flutter build apk --release
