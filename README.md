<p align="center">
  <img src="screenshots/status.png" width="500" alt="RAMCacheManager Status Panel">
</p>

<h1 align="center">RAMCacheManager</h1>

<p align="center">
  A native macOS app to manage RAM disk caches for faster builds and automatic cleanup.
</p>

<p align="center">
  <a href="https://github.com/talkcozy/RAMCacheManager/releases"><img src="https://img.shields.io/github/v/release/talkcozy/RAMCacheManager?style=flat-square" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/talkcozy/RAMCacheManager?style=flat-square" alt="License"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/arch-Apple%20Silicon-orange?style=flat-square" alt="Architecture">
</p>

<p align="center">
  <a href="README_CN.md">中文文档</a>
</p>

---

## Why RAMCacheManager?

Development tools like npm, Cargo, CocoaPods, and Go generate gigabytes of cache files on your SSD. These caches slow down over time, waste disk space, and shorten SSD lifespan.

RAMCacheManager moves these caches to a RAM disk — a virtual drive stored entirely in memory. This gives you:

- **10-100x faster** cache I/O compared to SSD
- **Automatic cleanup** on every restart — no stale caches
- **SSD space saved** — reclaim gigabytes of disk space
- **Longer SSD life** — fewer unnecessary writes

## Screenshots

| Status | Settings | Caches |
|--------|----------|--------|
| ![Status](screenshots/status.png) | ![Settings](screenshots/settings.png) | ![Caches](screenshots/caches.png) |

## Features

- **Adjustable RAM Disk** — Create a RAM disk from 1 GB to 16 GB
- **One-Click Cache Linking** — Symlink cache directories to RAM disk with a toggle
- **Preset Cache Support** — npm, pip, Cargo, CocoaPods, Go, pnpm, and more
- **Launch at Login** — Automatically create RAM disk when you log in
- **Menu Bar App** — Quick access from the menu bar
- **Real-time Monitoring** — Track RAM disk usage and linked cache count
- **Native macOS** — Built with Swift and SwiftUI, lightweight and fast

## Supported Caches

| Cache | Path | Description |
|-------|------|-------------|
| npm | `~/.npm` | Node.js package cache |
| General Cache | `~/.cache` | XDG cache directory |
| uv | `~/.cache/uv` | Python uv package manager |
| Puppeteer | `~/.cache/puppeteer` | Chromium browser cache |
| Cargo | `~/.cargo/registry` | Rust crate registry |
| CocoaPods | `~/.cocoapods/repos` | iOS dependency specs |
| Go Build | `~/Library/Caches/go-build` | Go compilation cache |
| pnpm | `~/.pnpm-store` | pnpm content-addressable store |
| Dart Pub | `~/.pub-cache` | Dart/Flutter package cache |

## Installation

### Download DMG

Download the latest `.dmg` from the [Releases](https://github.com/talkcozy/RAMCacheManager/releases) page.

### Build from Source

```bash
# Clone the repository
git clone https://github.com/talkcozy/RAMCacheManager.git
cd RAMCacheManager

# Install XcodeGen (if not installed)
brew install xcodegen

# Generate Xcode project and build
xcodegen generate
xcodebuild -project RAMCacheManager.xcodeproj -scheme RAMCacheManager -configuration Release build
```

## Usage

1. Launch RAMCacheManager
2. Click **Create RAM Disk** on the Status tab
3. Go to **Caches** tab and toggle the caches you want to link
4. (Optional) Enable **Launch at Login** in Settings

## How It Works

```
┌──────────────────────────────────────────┐
│         /Volumes/RAMCache (RAM Disk)     │
│  ├── npm/                                │
│  ├── cache/                              │
│  ├── cargo-registry/                     │
│  └── go-build/                           │
└──────────────────────────────────────────┘
                    ▲
                    │  symlink
                    │
┌──────────────────────────────────────────┐
│  ~/.npm        → /Volumes/RAMCache/npm   │
│  ~/.cache      → /Volumes/RAMCache/cache │
│  ~/.cargo/registry → .../cargo-registry  │
└──────────────────────────────────────────┘
```

When you restart your Mac, the RAM disk is automatically cleared. If "Launch at Login" is enabled, a fresh RAM disk is created on next login.

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon (arm64)

## License

[MIT License](LICENSE)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
