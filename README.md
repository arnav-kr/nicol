<picture>
	<source srcset="chrome/assets/logo_dark.svg" media="(prefers-color-scheme: dark)">
	<source srcset="chrome/assets/logo_light.svg" media="(prefers-color-scheme: light)">
	<img src="chrome/assets/logo_light.svg" alt="Nicol Browser Logo" width="256" height="256" />
</picture>

# Nicol Browser

A minimal web browser based on Qt.

<!-- ![Build Status](https://github.com/arnav-kr/nicol/actions/workflows/build.yaml/badge.svg) -->

| <!-- | [Download Nicol Browser](https://github.com/arnav-kr/nicol/releases/latest) |
| ---- | --------------------------------------------------------------------------- |>


## Features
* Tabbed browsing with multiple window support
* Incognito mode with isolated session data
* Smart address bar with DuckDuckGo search fallback
* Full keyboard navigation (Ctrl+T, Ctrl+W, Ctrl+L, F11, etc.)
* Page zoom with visual indicator
* Background tab freezing for reduced resource usage
* Built-in PDF viewer

## Requirements
* Qt 6.8 or later
* CMake 3.16 or later
* C++17 compatible compiler

### Arch Linux
```bash
sudo pacman -S base-devel cmake qt6-webengine qt6-declarative
```

### Debian/Ubuntu
> **Note:** Ubuntu's official repositories only provide Qt 6.4, which is below the required 6.8. You'll need to install Qt 6.8 manually using the [Qt Online Installer](https://www.qt.io/download-qt-installer) or [aqtinstall](https://github.com/miurahr/aqtinstall).

```bash
sudo apt install build-essential cmake
# Then install Qt 6.8+ via Qt Online Installer or aqtinstall
```

### Fedora
```bash
sudo dnf install cmake qt6-qtwebengine-devel qt6-qtdeclarative-devel
```

### macOS
```bash
brew install qt@6 cmake
```

### Windows
Install Qt 6.8 with MSVC 2022 components via the Qt Online Installer. Ensure CMake and MSVC build tools are available.

## Building
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

The executable will be at `build/appnicol` (Linux/macOS) or `build/Release/appnicol.exe` (Windows).

## Running
```bash
./build/appnicol
```

## Project Structure
```bash
nicol/
├── main.cpp              # application entry point
├── Main.qml              # root QML component
├── config.ini            # browser configuration
├── ui/                   # UI components
│   ├── BrowserWindow.qml
│   ├── ToolbarButton.qml
│   ├── AppMenuItem.qml
│   ├── ZoomOverlay.qml
│   └── FullScreenNotification.qml
├── chrome/               # internal pages (new tab, incognito, error)
└── assets/               # icons and resources
```

## License
This project is licensed under the [AGPL-3.0 License](LICENSE).