<div align="center">

<img src="release_assets/exports/google-play/feature-graphic/01-google-play-feature-en-1024x500.png" alt="Ruflet Explorer — Ruby anywhere" width="100%" />

# Ruflet Explorer

### The Expo Go of Ruby.

**Write a Ruby app. Run `ruflet run`. Scan the QR code. It's on your phone.**

No Xcode, no Android Studio, no rebuild, no redeploy — the same loop React Native
developers get from Expo Go, for Ruby.

[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-6750A4)](#-build)
[![Pure Ruby](https://img.shields.io/badge/100%25-pure%20Ruby-CC342D)](#-project-layout)
[![Version](https://img.shields.io/badge/version-1.0.1%2B6-6750A4)](services.yaml)
[![Extensions](https://img.shields.io/badge/extensions-17-6750A4)](ruflet.yaml)
[![Studio apps](https://img.shields.io/badge/studio%20apps-68-6750A4)](studio/)

</div>

---

## 📱 See it

<div align="center">

<img src="release_assets/exports/apple/iphone-6.9/01-home-en-1320x2868.png" alt="Connect to Ruflet" width="24%" />
<img src="release_assets/exports/apple/iphone-6.9/02-gallery-en-1320x2868.png" alt="Built-in gallery" width="24%" />
<img src="release_assets/exports/apple/iphone-6.9/03-spinkit-en-1320x2868.png" alt="Live components" width="24%" />
<img src="release_assets/exports/apple/iphone-6.9/04-charts-en-1320x2868.png" alt="Charts" width="24%" />

<sub>Connect · Browse the gallery · Run live components · Render charts</sub>

</div>

---

## ✨ What it does

Ruflet Explorer is written **entirely in Ruby** — every screen, every control, every
route. There is no hand-written Dart, Kotlin, or Swift in this project. It is Ruflet
dogfooding itself: the app that runs your Ruflet apps is a Ruflet app.

| | |
|---|---|
| 🔗 **Connect by URL** | Type `http://192.168.1.20:8550` — scheme, port, and localhost rewriting are handled for you |
| 📷 **Scan to connect** | Camera scanner with torch and camera-switch, reading the QR printed by `ruflet run` |
| 🧭 **Live rendering** | The remote app loads through Ruflet's `ruflet_app` control with auto-reconnect |
| 🎨 **Studio on board** | A launcher FAB opens a bundled Ruflet Studio — 68 runnable example apps with source |
| ♻️ **One VM** | Explorer and Studio share a single embedded Ruby VM; Studio's hub FAB returns home |

URL normalization is deliberately forgiving: it accepts bare hosts, upgrades `ws`/`wss`
to `http`/`https`, picks `http` for IPs and localhost, and rewrites loopback addresses to
`10.0.2.2` on Android emulators.

---

## 🚀 Run

```bash
ruflet run main.rb
```

Skip the launcher and connect straight to a server:

```bash
RUFLET_URL=http://192.168.1.20:8550 ruflet run main.rb
```

---

## 🧪 Tests

```bash
ruby test/url_test.rb
```

```bash
ruby test/app_test.rb
```

```bash
ruby test/standalone_apps_test.rb
```

- `url_test.rb` — scheme inference, port handling, IPv6, Android loopback rewriting
- `app_test.rb` — launcher, scanner, and connection view construction
- `standalone_apps_test.rb` — every bundled Studio example still loads

---

## 📦 Build

Always use **self-contained mode** so the Ruby launcher is embedded in the native app:

```bash
ruflet build apk --self
```

```bash
ruflet build aab --self
```

```bash
ruflet build ios --self
```

---

## 🎨 Icon and splash

[`ruflet.yaml`](ruflet.yaml) is the single source of truth — the build pipeline copies the
assets and generates the native resources for every platform.

```yaml
assets:
  dir: assets
  splash_screen: assets/splash.png
  icon_launcher: assets/icon.png

build:
  splash_color: "#FFFFFF"
  splash_dark_color: "#0B0B0B"
  icon_background: "#FFFFFF"
  theme_color: "#6750A4"
```

Each platform has its own section using the same key names, overriding the shared values:

```yaml
android:
  splash_color: "#FFFFFF"
  splash_dark_color: "#0B0B0B"
  splash_fullscreen: true
  splash_android_12_icon_background_color: "#FFFFFF"
  splash_android_12_icon_background_color_dark: "#0B0B0B"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: assets/icon.png
  min_sdk: 21

ios:
  splash_screen: assets/splash.png
  splash_color: "#FFFFFF"
  splash_dark_color: "#0B0B0B"
  icon_launcher: assets/icon.png
  remove_alpha: true
```

`macos:` and `windows:` take `icon_launcher` (Windows also `icon_size`), and `web:` takes
`splash_screen`, `icon_launcher`, `icon_background`, and `theme_color`.

---

## 🗂️ Project layout

```
main.rb                  entry point → RufletExplorer::App
ruflet.yaml              extensions, assets, per-platform icon/splash config
services.yaml            app identity + permission rationale
lib/ruflet_explorer/
  app.rb                 launcher, scanner, and connection views
  url.rb                 URL parsing and normalization
  qr_scanner_control.rb  QR scanner control wrapper
  studio.rb              embeds Studio into the shared page
studio/                  vendored Ruflet Studio (do not edit)
test/                    minitest suites
release_assets/          store screenshots and their generator
```

---

## 🖼️ Store assets

Production screenshots and the Google Play feature graphic live in
[`release_assets/`](release_assets/README.md), alongside the editable generator used to
produce them.
