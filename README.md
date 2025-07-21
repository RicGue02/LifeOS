# Life OS

A personal productivity iOS app built with SwiftUI and native Apple technologies.

## Architecture

The project follows MVVM architecture pattern with a clean folder structure:

```
Life OS/
├── App/                    # App entry point and main views
├── Core/                   # Core functionality
│   ├── Models/            # Data models
│   ├── Services/          # Business logic and data persistence
│   └── Extensions/        # Swift extensions
└── Features/              # Feature modules
    └── Tasks/             # Task management feature
        ├── Views/         # SwiftUI views
        └── ViewModels/    # ViewModels for MVVM
```

## Features

- ✅ Task Management with priorities and due dates
- ✅ Local persistence using UserDefaults
- ✅ Search functionality
- ✅ Swipe actions for task deletion
- ✅ Clean MVVM architecture

## Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## Tech Stack

- **UI**: SwiftUI
- **Architecture**: MVVM
- **Persistence**: UserDefaults
- **Dependencies**: None (100% native Apple technologies)

## Getting Started

1. Clone the repository
2. Open `Life OS.xcodeproj` in Xcode
3. Build and run (⌘R)

## Development Philosophy

This project is built exclusively with native Apple technologies, ensuring:
- Maximum performance
- Minimal app size
- No third-party dependency risks
- Full compatibility with Apple platforms