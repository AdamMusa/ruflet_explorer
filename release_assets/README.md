# Ruflet Explorer release assets

This folder contains the production App Store and Google Play marketing artwork for Ruflet Explorer.

## Final exports

- `exports/apple/iphone-6.9/`: iPhone screenshots at 1320 × 2868 (6.9")
- `exports/apple/iphone-6.5/`: iPhone screenshots at 1242 × 2688 (6.5")
- `exports/google-play/phone/`: 6 Android screenshots at 1080 × 1920
- `exports/google-play/feature-graphic/`: Google Play feature graphic at 1024 × 500

All final PNG files use the sRGB color space without an alpha channel.

## Story

The screenshots form a six-frame release narrative:

1. Ruby anywhere
2. Connect in seconds
3. Scan and launch
4. Explore real built-in apps
5. Inspect runnable Ruby code
6. Use the Ruflet SDK controls

The visual direction uses the supplied premium store-listing reference: oversized headlines, dark cinematic gradients, subtle stars, strong contrast, and angled device presentations.

## Generator

The editable Next.js generator is in `generator/`.

```sh
cd generator
bun install --ignore-scripts
bun run dev
```

Open `http://localhost:3000`, select a platform, preview the complete set, and use **Export All**.

## Release scope

- Language: English
- Platforms: iPhone and Android phone
- Theme: dark premium technology
- Source imagery: production Ruflet Explorer builds
- Tablet and iPad artwork: not included
