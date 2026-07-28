<div align="center">

<img src="release_assets/exports/google-play/feature-graphic/01-google-play-feature-en-1024x500.png" alt="Ruflet Explorer — Ruby anywhere" width="100%" />

# Ruflet Explorer

### Your Ruby app, on a real device, in seconds.

**Edit `main.rb` → `ruflet run` → scan → it's live in your hand.**

Install Explorer once and every Ruby app you write runs on the device immediately —
nothing to compile, nothing to sign, nothing to install again. If you've used Expo Go
for React Native, this is that loop, for Ruby.

[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-6750A4)](#-build)
[![Pure Ruby](https://img.shields.io/badge/100%25-pure%20Ruby-CC342D)](#-project-layout)
[![Version](https://img.shields.io/badge/version-1.0.1%2B6-6750A4)](services.yaml)
[![Extensions](https://img.shields.io/badge/extensions-17-6750A4)](ruflet.yaml)
[![Studio apps](https://img.shields.io/badge/studio%20apps-68-6750A4)](studio/)

</div>

---

## ✨ What it does

**Two ways in.** Paste a server URL, or point the camera at the QR code `ruflet run`
prints. Either way your app is on screen a second later, and Explorer holds the
connection open across reloads and reconnects.

**A gallery in your pocket.** Tap the launcher button and 68 runnable examples open
up — buttons, charts, maps, sensors, games — each with its Ruby source there to read.
Nothing is fetched, so it all works offline.

**Forgiving addresses.** Typing a URL on a phone is miserable, so `192.168.1.20:8550`
is enough. Explorer fills in the scheme, converts `ws://` and `wss://` to HTTP, and
swaps `localhost` for `10.0.2.2` when you're on an Android emulator.

**Built with Ruflet.** The launcher, the scanner, the embedded Studio — all Ruby.
Explorer is a Ruflet app that runs Ruflet apps, which makes it the hardest test the
framework gets.

---

## 🚀 Run

This repository is the Explorer client itself. To run it on a device or in a desktop
preview:

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
