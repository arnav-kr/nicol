<picture>
	<source srcset="chrome/assets/logo_dark.svg" media="(prefers-color-scheme: dark)">
	<source srcset="chrome/assets/logo_light.svg" media="(prefers-color-scheme: light)">
	<img src="chrome/assets/logo_light.svg" alt="Nicol Browser Logo" width="256" height="256" />
</picture>

# Nicol Browser

A minimal web browser based on Qt.

![Build Status](https://github.com/arnav-kr/nicol/actions/workflows/build.yaml/badge.svg)

| [Download Nicol Browser](https://github.com/arnav-kr/nicol/releases/latest) |
|---|


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

### Linux
```bash
sudo apt install build-essential cmake qt6-webengine-dev qt6-declarative-dev
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