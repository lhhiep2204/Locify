# Locify iOS App

Locify is a location-based application designed for iOS, iPadOS, macOS, and visionOS, enabling users to manage and share favorite places, organize them into categories, and synchronize data seamlessly between offline and online modes. Built with **Clean Architecture**, Locify ensures a modular, testable, and maintainable codebase, leveraging **SwiftUI**, **Firebase**, **Apple Maps (MapKit)**, and **SwiftData** for a robust user experience across all supported platforms.

---

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Project Structure](#project-structure)

---

## Features
- **Location Management**: Create, edit, and delete favorite locations with details like name, address, coordinates, and images.
- **Category Management**: Organize locations into custom categories for easy access.
- **Main Map**: Interactive map powered by Apple Maps (MapKit) for searching, navigating, and visualizing locations.
- **Authentication**: Secure user authentication via Firebase Authentication, supporting email/password login and registration.
- **Offline/Online Sync**: Store and manage locations and categories offline using SwiftData, with automatic synchronization when online.
- **Settings**: Manage user account, preferences (language, theme), and previews.
- **Multi-platform Support**: Optimized for iOS, iPadOS, macOS, and visionOS with a consistent UI.

---

## Requirements
- **Minimum Deployment Targets**:
  - iOS 26
  - iPadOS 26
  - macOS 26
  - visionOS 26
- **Development Environment**:
  - Xcode 26
  - Swift 6
- **Dependencies**:
  - Firebase (Authentication, Storage) via Swift Package Manager (SPM)

---

## Project Structure
Locify follows **Clean Architecture**, dividing the codebase into **Presentation**, **Domain**, **Data**, and **Shared** layers for separation of concerns. Below is the directory structure, followed by a diagram illustrating the relationships between layers.

### Directory Structure

```
Locify
├── App
├── Data
│   ├── Mappers
│   │   ├── Local
│   │   └── Remote
│   ├── Network
│   │   ├── Base
│   │   ├── Models
│   │   ├── Requests
│   │   └── Services
│   ├── Repositories
│   ├── Storage
│   │   ├── Keychain
│   │   ├── LocalData
│   │   │   ├── SwiftData
│   │   │   └── SyncManager
│   │   ├── Models
│   │   └── UserDefaults
│   └── ThirdParty
│       └── Firebase
│           ├── Authentication
│           └── Storage
├── Domain
│   ├── Entities
│   ├── Repositories
│   └── UseCases
│       ├── Authentication
│       ├── Category
│       ├── Location
│       └── Sync
├── Presentation
│   ├── DesignSystem
│   │   ├── Components
│   │   │   ├── Button
│   │   │   ├── Dialog
│   │   │   ├── Drawer
│   │   │   ├── Image
│   │   │   ├── Map
│   │   │   ├── Text
│   │   │   └── TextField
│   │   └── Styles
│   ├── Features
│   │   ├── Authentication
│   │   │   ├── Views
│   │   │   └── ViewModels
│   │   ├── CategoryManagement
│   │   │   ├── Views
│   │   │   └── ViewModels
│   │   ├── LocationManagement
│   │   │   ├── Views
│   │   │   └── ViewModels
│   │   ├── MainMap
│   │   │   ├── Views
│   │   │   └── ViewModels
│   │   ├── Settings
│   │   │   ├── Views
│   │   │   └── ViewModels
│   │   └── Shared
│   │       ├── Views
│   │       └── ViewModels
│   └── Routing
├── Resources
│   ├── Assets
│   │   ├── Colors
│   │   ├── Icons
│   │   └── Images
│   ├── Fonts
│   ├── Localization
│   │   └── Localized
│   │       └── Keys
│   ├── MockData
│   │   ├── Categories
│   │   ├── Locations
│   │   └── Users
│   └── PreviewContent
├── Shared
│   ├── Configuration
│   ├── DI
│   │   ├── Assemblies
│   │   └── Protocols
│   ├── Errors
│   │   ├── NetworkErrors
│   │   ├── StorageErrors
│   │   └── SyncErrors
│   ├── Extensions
│   │   ├── Foundation
│   │   └── SwiftUI
│   └── Utilities
└── Tests
    ├── UnitTests
    │   ├── Data
    │   ├── Domain
    │   └── Presentation
    ├── UITests
    └── Mocks
```

### Key Components
- **Dependency Injection**: Uses **Assemblies** in `Shared/DI/Assemblies` to register dependencies (UseCases, ViewModels, Repositories) into a custom `DependencyContainer`.
- **Navigation**: Managed directly in SwiftUI Views and ViewModels using `NavigationStack` and `NavigationPath`, with centralized routing in `RouterManager`.
- **Offline Support**: SwiftData handles local storage, with `SyncManager` managing offline/online synchronization (sync_status: synced, pendingCreate, pendingUpdate, pendingDelete).
- **Design System**: Reusable UI components (Button, Map, TextField) in `Presentation/DesignSystem` ensure consistent styling.

### Architecture Diagram
The following diagram illustrates the relationships between directories in Locify's Clean Architecture, highlighting the level-2 directories and how dependencies flow through the `DependencyContainer`.

```mermaid
graph LR
    A[App] -->|Initializes| B[Shared]
    B -->|DependencyContainer| C[Domain]
    B -->|DependencyContainer| D[Data]
    B -->|DependencyContainer| E[Presentation]
    D -->|Implements Repositories| C
    E -->|Calls UseCases| C
    E -->|Uses| F[Resources]
    G[Tests] -->|Tests| C
    G -->|Tests| D
    G -->|Tests| E
    subgraph Shared
        B1[Configuration]
        B2[DI]
        B3[Errors]
        B4[Extensions]
        B5[Utilities]
    end
    subgraph Data
        D1[Mappers]
        D2[Network]
        D3[Repositories]
        D4[Storage]
        D5[ThirdParty]
    end
    subgraph Domain
        C1[Entities]
        C2[Repositories]
        C3[UseCases]
    end
    subgraph Presentation
        E1[DesignSystem]
        E2[Features]
        E3[Routing]
    end
    subgraph Resources
        F1[Assets]
        F2[Fonts]
        F3[Localization]
        F4[MockData]
        F5[PreviewContent]
    end
    subgraph Tests
        G1[UnitTests]
        G2[UITests]
        G3[Mocks]
    end
```

---

[Back to Project Overview](../README.md)
