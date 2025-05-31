# Locify System Architecture

This document outlines the system architecture of the Locify application, detailing the components, their interactions, and data flows.

## Table of Contents
- [System Architecture](#system-architecture)
  - [Component Details](#component-details)
    - [Client Apps](#1-client-apps)
    - [Firebase Services](#2-firebase-services)
    - [Backend Services](#3-backend-services)
- [Data Flow](#data-flow)
  - [Authentication Flow](#1-authentication-flow)
  - [Data Synchronization Flow](#2-data-synchronization-flow)
  - [Offline Support Flow](#3-offline-support-flow)
  - [Image Handling Flow](#4-image-handling-flow)

---

## System Architecture
```mermaid
graph TB
    subgraph "Client Apps"
        subgraph "iOS App"
            iOS_UI[SwiftUI UI]
            SwiftData[(SwiftData DB)]
        end
        subgraph "Android App"
            Android_UI[Jetpack Compose UI]
            Room[(Room DB)]
        end
    end

    subgraph "Firebase Services"
        Auth[Firebase Auth]
        Storage[Firebase Storage]
    end

    subgraph "Backend Services"
        API[Spring Boot API]
        DB[(PostgreSQL Database)]
    end

    iOS_UI --> SwiftData
    Android_UI --> Room
    iOS_UI --> Auth
    Android_UI --> Auth
    iOS_UI --> Storage
    Android_UI --> Storage
    iOS_UI --> API
    Android_UI --> API
    API --> DB
    Auth --> API

    style iOS_UI fill:#f9f,stroke:#333,stroke-width:2px
    style Android_UI fill:#f9f,stroke:#333,stroke-width:2px
    style SwiftData fill:#f9f,stroke:#333,stroke-width:2px
    style Room fill:#f9f,stroke:#333,stroke-width:2px
    style Auth fill:#bbf,stroke:#333,stroke-width:2px
    style Storage fill:#bbf,stroke:#333,stroke-width:2px
    style API fill:#bfb,stroke:#333,stroke-width:2px
    style DB fill:#bfb,stroke:#333,stroke-width:2px
```

## Component Details
### 1. Client Apps
- **iOS App**
  - SwiftUI-based UI
  - SwiftData for local persistence
    - Automatic schema generation
    - CRUD operations
    - Relationship management
    - Offline data sync
  - Firebase SDK integration
  - Direct Firebase Storage access
  - MapKit integration

- **Android App**
  - Jetpack Compose UI
  - Room Database for local persistence
    - Type-safe queries
    - LiveData integration
    - Offline data sync
    - Migration support
  - Firebase SDK integration
  - Direct Firebase Storage access
  - Google Maps integration

### 2. Firebase Services
- **Firebase Auth**
  - User authentication
  - Token generation
  - Session management

- **Firebase Storage**
  - Image storage
  - Direct upload/download
  - Security rules
  - Offline persistence

### 3. Backend Services
- **Spring Boot API**
  - RESTful endpoints
  - Data validation
  - Business logic
  - Firebase token verification
  - Database operations

- **PostgreSQL Database**
  - User data
  - Location data
  - Category data
  - Sync status tracking

## Data Flow
### 1. Authentication Flow
```mermaid
sequenceDiagram
    participant Client
    participant LocalDB
    participant Auth
    participant API
    participant DB

    Note over Client: App starts or user logs in
    Client->>Auth: Sign in with Firebase
    Auth-->>Client: Return Firebase ID Token
    Note over Client: Store token for offline access
    Client->>LocalDB: Store auth token
    Note over Client: Include token in all API requests
    Client->>API: Include token in requests
    API->>Auth: Verify token
    Auth-->>API: Token valid
    API->>DB: Process request
    DB-->>API: Return data
    API-->>Client: Return response
    Note over Client: Cache data for offline use
    Client->>LocalDB: Cache response data
```

**Notes**:
- Firebase ID Token is stored in local database for offline use
- Token is automatically refreshed when expired
- API response data is cached in local database for offline use
- When offline, app uses cached token and data

### 2. Data Synchronization Flow
```mermaid
sequenceDiagram
    participant Client
    participant LocalDB
    participant Storage
    participant API
    participant DB

    Note over Client: User adds/updates location
    Client->>LocalDB: Store location data
    Note over Client: Upload images directly to Firebase Storage
    Client->>Storage: Upload images directly
    Storage-->>Client: Return download URLs
    Note over Client: Update local data with URLs
    Client->>LocalDB: Update with image URLs
    Note over Client: Send data to server
    Client->>API: Send location data with image URLs
    API->>DB: Store location data
    DB-->>API: Confirm storage
    API-->>Client: Return updated location
    Note over Client: Update local data with server data
    Client->>LocalDB: Update with server data
```

**Notes**:
- Data is stored locally before sync
- Images are uploaded directly to Firebase Storage
- Download URLs are stored in local database
- Server data is used to update local data
- If offline, data is marked as pending sync

### 3. Offline Support Flow
```mermaid
sequenceDiagram
    participant Client
    participant LocalDB
    participant Storage
    participant API
    participant DB

    Note over Client: Offline operation
    Client->>LocalDB: Store data locally
    LocalDB-->>Client: Confirm storage
    Note over Client: When internet connection is available
    Client->>LocalDB: Get pending changes
    Note over Client: Upload images selected offline
    Client->>Storage: Upload pending images
    Storage-->>Client: Return download URLs
    Note over Client: Sync data with server
    Client->>API: Sync pending changes
    API->>DB: Update server data
    DB-->>API: Confirm updates
    API-->>Client: Return synced data
    Note over Client: Update local data
    Client->>LocalDB: Update with synced data
```

**Notes**:
- All offline operations are stored in local database
- When online, app checks and syncs pending changes
- Images are uploaded before data sync
- Server data is used to update local data
- In case of conflicts, server data takes precedence

### 4. Image Handling Flow
```mermaid
sequenceDiagram
    participant Client
    participant LocalDB
    participant Storage
    participant API
    participant DB

    Note over Client: User selects image
    Client->>LocalDB: Store image metadata
    Note over Client: Upload image directly
    Client->>Storage: Upload image
    Storage-->>Client: Return download URL
    Note over Client: Update location with URL
    Client->>LocalDB: Update location with image URL
    Note over Client: Sync with server
    Client->>API: Update location with image URL
    API->>DB: Update location data
    DB-->>API: Confirm update
    API-->>Client: Return updated location
    Client->>LocalDB: Update with server data
```

**Notes**:
- Images are uploaded directly to Firebase Storage
- Metadata is stored in local database
- Download URL is stored in location data
- If offline, image is marked as pending upload
- When online, pending images are uploaded and synced

---

[Back to Project Overview](../README.md)
