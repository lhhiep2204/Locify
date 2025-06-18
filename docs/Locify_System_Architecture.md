# System Architecture for the "Locify" Application

**Objective**: Outline the high-level system architecture for the Locify application, detailing the components, their interactions, and data flow to support online and offline functionality for saving and managing locations.

---

## Table of Contents
- [System Overview](#system-overview)
- [Components](#components)
- [Data Flow](#data-flow)
  - [1. Authentication Flow](#1-authentication-flow)
  - [2. Data Synchronization Flow](#2-data-synchronization-flow)
  - [3. Offline Support Flow](#3-offline-support-flow)
  - [4. Image Handling Flow](#4-image-handling-flow)
- [Diagrams](#diagrams)

---

## System Overview
Locify is a cross-platform application (iOS, Android, and backend) designed to allow users to save and manage locations, supporting both online and offline modes. The system uses a client-server architecture with Firebase for authentication and storage, a PostgreSQL database for structured data, and local storage for offline support. The backend is built with Java/Spring Boot, while both the iOS and Android apps use Swift and Kotlin, respectively, with Google Maps SDK for map functionalities.

Key features:
- **Online/Offline Support**: Users can save, edit, and delete locations and categories offline, with data syncing when online.
- **Authentication**: Firebase Authentication manages user sessions, with offline login support using cached credentials.
- **Data Synchronization**: Local data syncs with the server upon login or network availability, handling conflicts and batch processing.
- **Image Handling**: Images are stored in Firebase Storage by the client, with temporary local storage for offline use. The backend deletes images during user account deletion to clean up storage.

---

## Components
1. **Client Applications**:
   - **iOS App**: Built with Swift, using Google Maps SDK for maps and Firebase SDK for authentication/storage.
   - **Android App**: Built with Kotlin, using Google Maps SDK and Firebase SDK.
   - **Local Storage**: SwiftData (iOS) and Room (Android) for caching data and supporting offline operations.
2. **Backend Service**:
   - **Java/Spring Boot**: Handles API requests, business logic, database interactions, and image deletion in Firebase Storage during user deletion.
   - **PostgreSQL**: Stores structured data (users, locations, categories).
   - **Firebase Authentication**: Manages user authentication and token verification.
   - **Firebase Storage**: Stores images and category icons, managed by clients for uploads and by the backend for deletions.
3. **External Services**:
   - **Google Maps SDK**: Provides map rendering, search, and navigation for both iOS and Android.

---

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
    Note over Client,LocalDB: Store token for offline use
    Client->>LocalDB: Store auth token
    Note over Client: Check token validity
    Client->>Auth: Refresh token if expired
    Auth-->>Client: Return new token or error
    alt Token refresh fails
        Client->>Client: Prompt user to re-login
    end
    Note over Client: User logs out
    alt Online
        Client->>Auth: Call FirebaseAuth.signOut()
        Auth-->>Client: Confirm session cleared
        Client->>LocalDB: Remove token, set isLoggedOut: false
    else Offline
        Client->>LocalDB: Set isLoggedOut: true, retain token
        Note over Client: When network available
        Client->>Auth: Call FirebaseAuth.signOut()
        Auth-->>Client: Confirm session cleared
        Client->>LocalDB: Remove token, set isLoggedOut: false
    end
    Note over Client,API: Include token in API requests
    Client->>API: Include token in requests
    API->>Auth: Verify token
    Auth-->>API: Token valid
    API->>DB: Process request
    DB-->>API: Return data
    API-->>Client: Return response
    Note over Client,LocalDB: Cache data for offline use
    Client->>LocalDB: Cache response data
```

**Key Points**:
- Firebase ID Token is stored locally for offline use and refreshed automatically when online.
- Offline logout sets `isLoggedOut: true` and defers `FirebaseAuth.signOut()` until network is available.
- API responses are cached locally for offline access.

**Additional Details**:
- See [Locify_Data_Sync_Flow.md](./Locify_Data_Sync_Flow.md) for token refresh failure handling and offline session management.

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
    Note over Client,LocalDB: Store data locally before sync
    Client->>Storage: Upload images directly
    Storage-->>Client: Return download URLs
    Note over Client,LocalDB: Update with image URLs
    Client->>LocalDB: Update with image URLs
    Note over Client,API: Sync in batches when online
    Client->>API: Send batch of location data (up to 50 records)
    API->>DB: Store location data
    DB-->>API: Confirm storage
    API-->>Client: Return updated locations
    Note over Client,LocalDB: Update with server data
    Client->>LocalDB: Update with server data
```

**Key Points**:
- Data is stored locally before syncing with the server.
- Images are uploaded directly to Firebase Storage by the client, and URLs are stored locally.
- Synchronization uses batch requests (up to 50 records) with pagination.

**Additional Details**:
- See [Locify_Data_Sync_Flow.md](./Locify_Data_Sync_Flow.md) for batch processing and conflict resolution details.

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
    Note over Client,LocalDB: Store images in temporary storage
    Client->>LocalDB: Store local image URLs (e.g., file://)
    Note over Client: When internet connection is available
    Client->>LocalDB: Get pending changes
    Note over Client: Check isLoggedOut flag
    alt isLoggedOut: true
        Client->>Auth: Call FirebaseAuth.signOut()
        Auth-->>Client: Confirm session cleared
        Client->>LocalDB: Remove token, set isLoggedOut: false
    end
    Note over Client,Storage: Upload pending images
    Client->>Storage: Upload pending images
    Storage-->>Client: Return download URLs
    Note over Client,API: Sync pending changes
    Client->>API: Sync pending changes (up to 50 records)
    API->>DB: Update server data
    DB-->>API: Confirm updates
    API-->>Client: Return synced data
    Note over Client,LocalDB: Update with synced data
    Client->>LocalDB: Update with synced data
```

**Key Points**:
- Offline operations are stored locally, with images saved in temporary storage (e.g., `file://`).
- When online, the app checks `isLoggedOut: true` and completes logout.
- Pending changes are synced in batches, with server data updating local storage.

**Additional Details**:
- See [Locify_Data_Sync_Flow.md](./Locify_Data_Sync_Flow.md) for offline image handling and sync retry logic.

### 4. Image Handling Flow
```mermaid
sequenceDiagram
    participant Client
    participant LocalDB
    participant Storage
    participant API
    participant DB

    Note over Client: User selects image (only when logged in)
    alt Not logged in
        Client->>Client: Display message: "Please log in to add or remove images"
    else Logged in
        Client->>LocalDB: Store image metadata (local URL if offline)
        alt Online
            Client->>Storage: Upload image
            Storage-->>Client: Return download URL
        else Offline
            Note over Client,LocalDB: Store in temporary storage
            Client->>LocalDB: Store image in temporary storage (file://)
        end
        Note over Client,LocalDB: Update location with URL
        Client->>LocalDB: Update location with image URL
        Note over Client,API: Sync with server
        Client->>API: Update location with image URL
        API->>DB: Update location data
        DB-->>API: Confirm update
        API-->>Client: Return updated location
        Note over Client: User deletes individual image
        Client->>LocalDB: Remove image URL from location/category
        alt Online
            Client->>Storage: Delete image
            Storage-->>Client: Confirm deletion
        else Offline
            Client->>LocalDB: Delete local image file (file://)
        end
        Client->>API: Update location/category with new URLs
        API->>DB: Update location/category data
        DB-->>API: Confirm update
        API-->>Client: Return updated record
    end
    Note over Client: User deletes location
    Client->>LocalDB: Mark location as pendingDelete
    alt Online
        Client->>Storage: Delete all location images
        Storage-->>Client: Confirm deletion
        Client->>API: DELETE /locations/{location_id}
        API->>DB: Delete location
        DB-->>API: Confirm deletion
        API-->>Client: Return 204 No Content
    else Offline
        Client->>LocalDB: Delete local image files (file://)
    end
    Note over Client,API: Category deletion
    Client->>LocalDB: Mark category and locations as pendingDelete
    Client->>API: DELETE /categories/{category_id}
    API->>DB: Query icon URL and location image URLs
    DB-->>API: Return icon/image URLs
    API->>Storage: Delete icon and location images
    Storage-->>API: Confirm deletion
    API->>DB: Delete category and locations
    DB-->>API: Confirm deletion
    API-->>Client: Return 204 No Content
    Note over API: User deletion
    API->>DB: Query image URLs for user
    DB-->>API: Return image URLs
    API->>Storage: Delete images
    Storage-->>API: Confirm deletion
    API->>DB: Delete user data
    DB-->>API: Confirm deletion
```

**Key Points**:
- Image selection is only available when the user is logged in; otherwise, a message is displayed: "Please log in to add or remove images."
- When logged in, images are uploaded to Firebase Storage by the client when online or stored locally (e.g., `file://`) when offline.
- Image URLs are updated in local storage and synced with the server.
- Offline images are marked as pending upload and processed when online.
- For individual image deletions (e.g., editing location/category) or location deletions, the client deletes images from Firebase Storage using the Firebase SDK. Offline, local image files (e.g., `file://`) are deleted immediately to free device storage.
- For category deletions, the backend queries the database for the category’s icon URL and all image URLs of associated locations, then deletes them from Firebase Storage before removing database records.
- During user deletion, the backend queries the database for all image URLs associated with the user and deletes them from Firebase Storage before removing database records.

**Additional Details**:
- See [Locify_API_Documentation.md](./Locify_API_Documentation.md) for image constraints (e.g., 5MB max size, 10 images per location) and user deletion endpoint.

---

## Diagrams
### System Architecture Diagram
```mermaid
%% System Architecture Diagram for Locify: Client-Backend interactions for managing categories and locations with offline support and image storage %%

graph LR
    subgraph Client
        A[iOS Client]
        B[Android Client]
        C[Local Storage]
    end

    subgraph Backend
        D[API Server]
        E[PostgreSQL]
        F[Firebase Auth]
        G[Firebase Storage]
    end

    A -->|API Requests| D
    B -->|API Requests| D
    A -->|Auth| F
    B -->|Auth| F
    A -->|Image Upload/Delete| G
    B -->|Image Upload/Delete| G
    D -->|Query| E
    D -->|Verify Token| F
    D -->|"Delete Images (Category/User)"| G
    A -->|Cache| C
    B -->|Cache| C
```

**Key Points**:
- **Client Interaction**:
  - iOS and Android clients send HTTP requests to the **API Server** for CRUD operations on categories and locations.
  - Clients authenticate using **Firebase Authentication**, obtaining tokens for secure API requests.
  - Clients upload and delete images/icons directly to/from **Firebase Storage** using the Firebase Storage SDK for individual location updates, location deletions, or category icon updates (excluding category deletions), but only when logged in.
  - Offline data is cached in **Local Storage** (SwiftData for iOS, Room for Android), with local image/icon files (e.g., `file://`) deleted immediately upon marking `pendingDelete` or `pendingUpdate` to free device storage.
- **Backend Interaction**:
  - The **API Server** processes requests, queries the **PostgreSQL** database, and verifies tokens via **Firebase Authentication**.
  - For category deletions (including associated locations) or user account deletions, the **API Server** deletes images/icons from **Firebase Storage** using the Firebase Admin SDK in batches, ensuring data integrity with database transactions.
- **Data Flow**:
  - Data is synchronized between client and server when online, with offline changes marked as `pendingCreate`, `pendingUpdate`, or `pendingDelete` in **Local Storage**.
  - Images/icons are stored in **Firebase Storage** with paths organized by `user_id` (e.g., `/locations/{user_id}/{location_id}/{image_id}`, `/categories/{user_id}/{category_id}/icon`).

---

[Back to Project Overview](../README.md)
