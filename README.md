# ⚡ VELOCITY VPN - High-Performance Anti-Censorship Client

<div align="center">

```
  ██    ██ ███████ ██       ██████   ██████ ██ ████████ ██    ██
  ██    ██ ██      ██      ██    ██ ██      ██    ██     ██  ██ 
  ██    ██ █████   ██      ██    ██ ██      ██    ██      ████  
   ██  ██  ██      ██      ██    ██ ██      ██    ██       ██   
    ████   ███████ ███████  ██████   ██████ ██    ██       ██   
```

**Next-Gen Cyberpunk Midnight VPN Terminal & Multi-Protocol Tunneling Suite**  
*Powered by Sing-box & Hiddify Core Routing • Tun2Socks Engine • Role-Based Access Control*

[![Build & Release APK](https://github.com/velocity-vpn/velocity/actions/workflows/build-apk.yml/badge.svg)](https://github.com/velocity-vpn/velocity/actions/workflows/build-apk.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-8.0%2B%20(API%2026%2B)-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![Protocol](https://img.shields.io/badge/Protocols-VLESS%20%7C%20Hysteria%202%20%7C%20Trojan-00E5FF?style=for-the-badge)](https://github.com/XTLS/Xray-core)
[![License](https://img.shields.io/badge/License-MIT-FFD600?style=for-the-badge)](LICENSE)

[English](#-english-documentation) • [فارسی (Persian)](#-مستندات-فارسی)

---

</div>

## 🌐 English Documentation

### 🚀 Overview
**VELOCITY** is an advanced, production-grade anti-censorship VPN client engineered with a cyberpunk midnight aesthetic and high-performance routing inspired by **Sing-box**, **Hiddify**, and **v2rayNG**. Designed specifically to conquer strict firewalls and DPI (Deep Packet Inspection), Velocity integrates advanced protocol obfuscation, dynamic subscriptions, multi-method user authentication, and real-time network telemetry.

### ✨ Key Features

- 🛡️ **Next-Gen Protocol Support:**
  - **VLESS Reality**: Camouflages traffic using legitimate TLS 1.3 handshakes and TLS fingerprint mimicry (`chrome`, `safari`, `firefox`).
  - **Hysteria 2**: UDP-based protocol with aggressive BBR-like congestion control and port-hopping for filtered or throttled connections.
  - **Trojan gRPC & VMess WebSocket**: Obfuscated multi-transport fallbacks with CDN reverse-proxy compatibility.
  - **Shadowsocks 2022**: Modern AEAD cipher suites (BLAKE3, 2022-blake3-aes-128-gcm).

- 🧠 **Intelligent Core Routing & Tun2Socks:**
  - **Split Tunneling (Iran Bypass)**: Automatic routing rules bypass `.ir` domains, Iranian banking IP ranges, and local government subnets, ensuring high speed without disconnecting.
  - **Anti-DPI Packet Fragmentation**: Splits initial TLS ClientHello packets to evade stateful DPI inspection.
  - **Custom DNS Resolvers**: Encrypted DNS-over-HTTPS (DoH) via Cloudflare (`1.1.1.1`), Google (`8.8.8.8`), and NextDNS to defeat DNS poisoning and hijacking.

- 🔐 **Multi-Method User Authentication:**
  - **Telegram Account Sync**: Instant 1-tap link with Telegram usernames or IDs to restore active subscriptions and node pools.
  - **Gmail OTP Terminal**: Email authentication with real-time countdown timer and 6-digit verification code generator.
  - **Admin RBAC Terminal**: Secure role-based administrative control with credential validation (`admin@velocity.vpn`).

- 💼 **Dynamic Plan & Subscription Management:**
  - **Store Management**: Full administrative CRUD (Create, Read, Update, Delete) for subscription packages.
  - **Dual Currency Pricing**: Automated pricing display in Iranian Tomans and USDT.
  - **Payment Integration**: One-click copy for TRC-20 USDT and TON wallet payment addresses.
  - **Instant Store Visibility**: Live toggle to show or hide plans in the public store without redeploying.

- 📊 **Cyberpunk Telemetry & Live Diagnostics:**
  - Real-time RTT latency oscilloscope and round-trip ping chart.
  - Connection Jitter meter and packet-loss rate monitor.
  - Real-time upload and download throughput meters.
  - GeoIP country resolver with direct node flag indicators (Germany, Finland, Netherlands, USA, Japan, etc.).

- 🎨 **Visual Identity & Design System:**
  - Electric Cyan (`#00E5FF`), Neon Green (`#00FF88`), Neon Pink (`#FFFF1744`), and Neon Yellow (`#FFD600`).
  - Deep Midnight OLED black canvas (`#000000`, `#060910`) for minimal battery consumption.
  - Dual-language engine (English / Persian) with automatic RTL and LTR layout switching.

---

### 📱 Architecture & Project Layout

```
velocity/
├── .github/
│   └── workflows/
│       └── build-apk.yml       # Automated CI/CD workflow for Android APK builds
├── app/                        # Native Android Gradle configuration & wrapper
│   ├── build.gradle.kts
│   └── src/main/
│       └── AndroidManifest.xml
├── lib/
│   └── main.dart               # Complete Flutter application with state management,
│                               # telemetry engine, auth, and admin plan dashboard
├── pubspec.yaml                # Flutter project specification & dependencies
├── .gitignore                  # Production-grade Git ignore filters
├── metadata.json               # Google AI Studio platform metadata
└── README.md                   # Dual-language repository documentation
```

---

### 🛠️ Prerequisites & Local Setup

#### Prerequisites
1. **Flutter SDK**: Version `3.19.0` or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
2. **Java Development Kit**: JDK 17 ([Temurin 17](https://adoptium.net/))
3. **Android SDK**: API Level 34 with Android Build Tools 34.0.0+

#### 1. Clone the Repository
```bash
git clone https://github.com/velocity-vpn/velocity.git
cd velocity
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Run on Connected Device / Emulator
```bash
flutter run
```

---

### 📦 Building Release APK

To build a standalone production release APK ready to install on Android phones:

```bash
flutter build apk --release
```

The compiled release APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

To build split APKs per ABI (for smaller file sizes):
```bash
flutter build apk --release --split-per-abi
```

---

### 🔑 Default Admin Demo Credentials

For testing the **Admin Dashboard** and **Dynamic Plan Management**:
- **Email:** `admin@velocity.vpn`
- **Password:** `AdminSecurePassword123!`
*(Quick autofill shortcut is available directly inside the Authentication dialog)*

---

<br/>

## 🇮🇷 مستندات فارسی

### 🚀 معرفی پروژه
**ولوسیتی (VELOCITY)** یک کلاینت ضد فیلترینگ و تونلینگ نسل جدید با طراحی سایبرپانک و موتور مسیریابی مبتنی بر اصول **سینگ‌باکس (Sing-box)**، **هیدیفای (Hiddify)** و **v2rayNG** است. این نرم‌افزار به صورت ویژه برای عبور پایدار از دیوارهای آتش پیشرفته و سیستم‌های فیلترینگ عمیق بسته‌ها (DPI) طراحی و بهینه‌سازی شده است.

### ✨ قابلیت‌های کلیدی

- 🛡️ **پشتیبانی جامع از پروتکل‌های نوین:**
  - **VLESS Reality**: پنهان‌سازی ترافیک پشت اتصالات واقعی TLS 1.3 با شبیه‌سازی دقیق اثر انگشت مرورگرها (`chrome`, `safari`, `firefox`).
  - **Hysteria 2**: پروتکل پرسرعت مبتنی بر UDP با کنترل ازدحام اختصاصی و قابلیت تعویض پورت (Port Hopping) مناسب شرایط اختلال شدید اینترنت.
  - **Trojan gRPC & VMess WebSocket**: امکان عبور از CDNها و دامنه‌های واسط با ترافیک وب معتبر.
  - **Shadowsocks 2022**: جدیدترین استانداردهای رمزنگاری ایمن AEAD.

- 🧠 **مسیریابی هوشمند و تفکیک ترافیک ایران (Bypass Iran):**
  - **تونل‌زنی هوشمند (Split Tunneling)**: عبور مستقیم ترافیک سایت‌های بانکی و دامنه‌های `.ir` بدون نیاز به قطع اتصال فیلترشکن.
  - **تکه‌تکه‌سازی بسته‌های اولیه (Fragmentation)**: دور زدن شناسایی پکت‌های ClientHello توسط فیلترینگ هوشمند.
  - **DNS رمزنگاری‌شده (DoH)**: استفاده از سرورهای امن Cloudflare و Google برای مقابله با مسمومیت و مسدودسازی DNS.

- 🔐 **ترمینال احراز هویت چندگانه:**
  - **اتصال با تلگرام**: همگام‌سازی فوری از طریق آیدی یا یوزرنیم تلگرام (`@username`) جهت بازیابی اشتراک VIP.
  - **ورود با کد یکبار مصرف جیمیل (Gmail OTP)**: ارسال کد تایید ۶ رقمی به همراه شمارش معکوس ۶۰ ثانیه‌ای.
  - **پنل مدیریت ادمین (RBAC)**: دسترسی کنترل‌شده برای ادمین‌ها با تایید رمزعبور امنیتی.

- 💼 **مدیریت پویا و بلادرنگ پلن‌های اشتراک:**
  - ایجاد، ویرایش، مخفی‌سازی و حذف پلن‌های اشتراک توسط ادمین.
  - قیمت‌گذاری دوگانه به **تومان** و **تتر (USDT)**.
  - درگاه‌های پرداخت کریپتو با قابلیت کپی سریع آدرس کیف‌پول‌های USDT TRC-20 و TON.

- 📊 **مانیتورینگ و تله‌متری زنده:**
  - نمودار نوسان‌نمای تاخیر پینگ (RTT) و شاخص پایداری ارتباط (Jitter).
  - سنجش لحظه‌ای سرعت دانلود و آپلود بر حسب کیلوبایت و مگابایت بر ثانیه.
  - تشخیص موقعیت جغرافیایی سرورها به همراه پرچم کشورهای متصل (آلمان، هلند، فنلاند، آمریکا و...).

- 🎨 **طراحی نئونی و رابط کاربری دو زبانه:**
  - رنگ‌بندی سایبرپانک فیروزه‌ای الکتریک (`#00E5FF`) و پس‌زمینه تمام مشکی بهینه‌شده برای نمایشگرهای AMOLED.
  - پشتیبانی کامل و اصولی از زبان‌های فارسی (راست‌چین RTL) و انگلیسی (چپ‌چین LTR).

---

### 💻 راهنمای نصب و اجرای محلی

#### پیش‌نیازها
1. نصب **Flutter SDK** نسخه ۳.۱۹ به بالا
2. نصب **JDK 17**
3. ابزارهای اندروید (Android SDK 34)

#### مراحل اجرا:
```bash
# دریافت مخزن پروژه
git clone https://github.com/velocity-vpn/velocity.git
cd velocity

# دریافت پکیج‌های فلاتر
flutter pub get

# اجرای برنامه روی شبیه‌ساز یا دستگاه متصل
flutter run
```

#### خروجی فایل نصبی (APK):
```bash
flutter build apk --release
```
فایل نصبی نهایی در مسیر زیر ایجاد خواهد شد:
`build/app/outputs/flutter-apk/app-release.apk`

---

### 🤖 بیلد خودکار در گیت‌هاب (CI/CD)
در پوشه `.github/workflows/build-apk.yml` فرآیند کامل بیلد خودکار تنظیم شده است. با هر بار اعمال کامیت در شاخه `main` یا ایجاد تگ انتشار جدید (مثلا `v1.0.0`)، گیت‌هاب اکشنز به طور خودکار محیط جاوا و فلاتر را بارگذاری کرده و نسخه Release APK را کامپایل نموده و در بخش Releases برای دانلود کاربران قرار می‌دهد.

---

### ⚖️ Disclaimer & Terms of Service
This project is developed for educational, network security evaluation, and digital accessibility purposes. Users are solely responsible for compliance with their local telecommunications regulations.

---

<div align="center">

**VELOCITY TUNNEL CORE • POWERED BY OPEN-SOURCE FREEDOM**  
*Crafted with ⚡ and precision for resilient global connectivity.*

</div>
