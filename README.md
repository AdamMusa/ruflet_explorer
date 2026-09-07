<div align="center">

<img src="release_assets/exports/google-play/feature-graphic/01-google-play-feature-en-1024x500.png" alt="Ruflet Explorer — Ruby anywhere" width="100%" />

# Ruflet Explorer

### The app preview for Ruflet — written entirely in Ruflet, 100% pure Ruby.

Install it once and every Ruby app you write runs immediately on Android, iOS,
macOS, Windows, Linux, and the web. Nothing to compile, nothing to sign, nothing
to install again.

If you've used Expo Go for React Native, this is that loop, for Ruby.

[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-6750A4)](#-build)
[![Pure Ruby](https://img.shields.io/badge/100%25-pure%20Ruby-CC342D)](#-project-layout)
[![Version](https://img.shields.io/badge/version-1.0.1%2B10-6750A4)](services.yaml)
[![Extensions](https://img.shields.io/badge/extensions-17-6750A4)](ruflet.yaml)
[![Studio apps](https://img.shields.io/badge/studio%20apps-68-6750A4)](studio/)

</div>

---

## ✨ What it does

**Two ways in.** On mobile, paste a server URL or point the camera at the QR code
`ruflet run` prints. On desktop and web there is nothing to type — `ruflet run
--desktop` and `--web` hand the client the address themselves. Either way your app
is on screen a second later, and the connection survives reloads and reconnects.

**A gallery in your pocket.** The mobile app carries 68 runnable examples — buttons,
charts, maps, sensors, games — each with its Ruby source there to read. Nothing is
fetched, so it all works offline.

**Forgiving addresses.** Typing a URL on a phone is miserable, so `192.168.1.20:8550`
is enough. Explorer fills in the scheme, converts `ws://` and `wss://` to HTTP, and
swaps `localhost` for `10.0.2.2` when you're on an Android emulator.

**Built with Ruflet.** The launcher, the scanner, the embedded Studio — all Ruby.
Explorer is a Ruflet app that runs Ruflet apps, which makes it the hardest test the
framework gets.

> On mobile Explorer ships self-contained, so its Ruby launcher, scanner and Studio
> come with it. Desktop and web clients are server-driven and render whatever app
> `ruflet run` points them at.

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

On mobile, build **self-contained** so the Ruby launcher and scanner are embedded
in the app:

```bash
ruflet build apk --self
```

```bash
ruflet build aab --self
```

```bash
ruflet build ios --self
```

Desktop and web are **server-driven**: those clients are told which server to open
at launch, so nothing is baked in and one build works against any port.

```bash
ruflet build macos
```

```bash
ruflet build windows
```

```bash
ruflet build linux
```

```bash
ruflet build web
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
