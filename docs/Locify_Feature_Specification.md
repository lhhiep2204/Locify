# Detailed Feature Specification for the "Locify" Application

**Objective**: Develop and release the "Locify" application on the App Store (iOS) and Google Play Store (Android), enabling users to save and manage locations for planned visits or memorable places, supporting both online and offline use without requiring login.

---

## Table of Contents
- [Screens and Main Features](#screens-and-main-features)
  - [1. Main Screen (Map)](#1-main-screen-map)
  - [2. Saved Locations List (Collections)](#2-saved-locations-list-collections)
  - [3. Saved Locations List (Locations)](#3-saved-locations-list-locations)
  - [4. Add Location Screen](#4-add-location-screen)
  - [5. Settings Screen](#5-settings-screen)
  - [6. Login/Registration Screen](#6-loginregistration-screen)
- [Main Functional Workflows](#main-functional-workflows)
  - [1. App Startup](#1-app-startup)
  - [2. Explore and Save Locations](#2-explore-and-save-locations)
  - [3. Add New Location](#3-add-new-location)
  - [4. Manage Collections and Locations](#4-manage-collections-and-locations)
  - [5. Navigation](#5-navigation)
  - [6. Login/Registration and Data Sync](#6-loginregistration-and-data-sync)
  - [7. Send Feedback](#7-send-feedback)
- [Potential Additional Features (For Future Consideration)](#potential-additional-features-for-future-consideration)

---

## Screens and Main Features

### 1. Main Screen (Map)
**Purpose**: Default screen displayed on app startup, allowing users to explore, search, save, and share locations.
**Features**:
- **Display user location** (Online/Offline): The app determines and displays the current location (requires location permission). Uses Google Maps SDK on both iOS and Android. In offline mode, displays the last known GPS location (if available).
- **Search for locations** (Online): Users enter a name or address to search for locations, available whether logged in or not. Uses Google Maps SDK search functionality on both iOS and Android. Not available offline.
- **Location Information Display** (Online/Offline): Shows official name (resolved from Google Maps), custom name (displayName), address, and coordinates of a location. Details are stored locally after being fetched to support offline viewing. Images are displayed if available locally; otherwise, a placeholder image ("Image unavailable offline") is shown.
- **Save location** (Online/Offline): Users save a location to the list, required to select a collection (from default collections like Restaurant, Cafe, Tourist Attraction, Favorites, or user-created collections). Data is stored locally for offline access and synced with the server after login if not logged in.
- **Share location** (Online): Users share location details (custom name, official name, address, coordinates) via the system sharing mechanism (iOS or Android), available whether logged in or not. Not available offline.
- **Navigate** (Online): Provides in-app navigation to the selected location using Google Maps SDK on both iOS and Android, available whether logged in or not. In offline mode, displays a message: "Navigation unavailable offline."

### 2. Saved Locations List (Collections)
**Purpose**: Display a list of location collections, allowing users to manage collections and select a collection to view its location list.
**Features**:
- **Display collection list** (Online/Offline): Shows all collections (default ones like Restaurant, Cafe, Tourist Attraction, Favorites, and user-created collections) with their respective icons and the number of locations in each. Data is stored locally to support offline access. Icons are displayed if available locally; otherwise, a placeholder icon is shown.
- **Create collection** (Online/Offline): Users create a new collection by entering a name and selecting or uploading an icon. The new collection is stored locally and synced with the server after login if not logged in. Offline icons are stored in temporary storage (e.g., `file://collection_icon.jpg`).
- **Edit collection** (Online/Offline): Users edit the name and icon of an existing collection. Changes are stored locally and synced with the server after login if not logged in. New offline icons are stored in temporary storage.
- **Delete collection** (Online/Offline): Users delete a collection. If the collection contains locations, the collection and all its locations (including their images) are deleted. Changes are stored locally, with the collection and locations marked as `pendingDelete`, and local image/icon files (e.g., `file://`) are removed immediately to free device storage. The changes are synced with the server after login if not logged in, with the backend handling deletion of Firebase Storage images/icons.
- **Go to location list** (Online/Offline): Select a collection to view its locations.

### 3. Saved Locations List (Locations)
**Purpose**: Display all locations within a selected collection, allowing users to view, edit, delete, or share locations.
**Features**:
- **Display location list** (Online/Offline): Shows locations with their custom name (displayName), official name, address, and favorite status. Data is stored locally to support offline access. Images are displayed if available locally; otherwise, a placeholder is shown.
- **Edit location** (Online/Offline): Users edit location details (custom name (displayName), official name, address, coordinates, description, notes, tags, favorite status, collection). Changes are stored locally and synced with the server after login if not logged in. Image selection is only available when logged in; otherwise, a message is displayed: "Please log in to add or remove images."
- **Delete location** (Online/Offline): Users delete a location, with changes stored locally as `pendingDelete`. Local images (e.g., `file://`) are deleted immediately to free device storage. The changes are synced with the server after login if not logged in.
- **Mark/unmark favorite** (Online/Offline): Users toggle the favorite status, stored locally and synced after login if not logged in.
- **Share location** (Online): Users share location details (custom name, official name, address, coordinates) via the system sharing mechanism (iOS or Android), available whether logged in or not. Not available offline.
- **View on map** (Online/Offline): Users view the location on the map (online: dynamic map; offline: displays a message "Map unavailable offline" with only location details shown; Google Maps SDK).

### 4. Add Location Screen
**Purpose**: Allow users to add a new location to a collection.
**Features**:
- **Search or manual entry** (Online): Users search for a location by name/address or manually enter coordinates (Google Maps SDK). In offline mode, users can only manually enter details, and a message is displayed: "Search unavailable offline."
- **Select collection** (Online/Offline): Users select a collection (default or user-created) or create a new one.
- **Enter details** (Online/Offline): Users enter custom name (displayName), official name (required), address, description, notes, tags, and favorite status. Image selection is only available when logged in; otherwise, a message is displayed: "Please log in to add or remove images."
- **Save location** (Online/Offline): The location is saved to local storage with `sync_status: pendingCreate` and synced with the server after login if not logged in. Offline images, when logged in, are stored in temporary storage (e.g., `file://`).

### 5. Settings Screen
**Purpose**: Allow users to manage their account and app settings.
**Features**:
- **Login/Registration**: Navigate to the Login/Registration screen to log in, create an account, or log out.
- **Delete account** (Online): Users delete their account, removing all associated data (online only). A confirmation dialog is shown: "This will delete all your data. Continue?" If offline, a message is displayed: "Account deletion requires an internet connection."
- **Send Feedback** (Online): Opens an in-app email composer to send feedback, report bugs, or suggest features, available whether logged in or not.
- **Manage offline data** (Online/Offline): Users view the number of unsynced collections/locations and trigger manual synchronization (online only). If offline, a message is displayed: "Synchronization requires an internet connection."

### 6. Login/Registration Screen
**Purpose**: Allow users to log in or create an account.
**Features**:
- **Login** (Online/Offline): Users log in with email/password or OAuth (Google, Apple, etc.) when online. Offline login uses cached credentials (after first login). If login fails offline, a message is displayed: "Login failed. Please try again when online."
- **Registration** (Online): Users create an account with email/password or OAuth. Offline registration is not supported, and a message is displayed: "Registration requires an internet connection."
- **Data sync** (Online): After login, local data is synced with the server. If logging in with a different account, a dialog is shown: "Do you want to sync local data (X collections, Y locations) to the new account or discard it?" with "Sync" and "Discard" options.
- **Logout** (Online/Offline): Users log out. Online logout syncs unsynced data first; if sync fails, a warning is shown: "You have unsynced data (X collections, Y locations). Please sync before logging out to avoid data loss." Offline logout sets `isLoggedOut: true`, retaining local data until the next login.

---

## Main Functional Workflows

### 1. App Startup
- The app checks for an existing Firebase Authentication session or cached credentials.
- If logged in and online, the app fetches user data, collections, and locations from the server and updates local storage.
- If not logged in or offline, the app loads data from local storage (not tied to a user ID if not logged in).
- The Main Screen (Map) is displayed, showing the user’s location (if permission is granted) or the last known location (offline).

### 2. Explore and Save Locations
- Users search for locations (online only, Google Maps SDK) or select a point on the map.
- Users view location details (custom name (displayName), official name, address, coordinates; images if available locally).
- Users save the location to a collection (online/offline), stored locally and synced after login if not logged in.

### 3. Add New Location
- Users access the Add Location Screen from the Main Screen or Saved Locations List.
- Users search for a location (online) or manually enter details (online/offline).
- Users select a collection or create a new one.
- Users enter details (custom name (displayName), official name (required), address, description, notes, tags, favorite status). Image selection is only available when logged in.
- The location is saved, stored locally for offline access and synced with the server after login if not logged in.

### 4. Manage Collections and Locations
- Users view the collection list with the number of locations per collection, retrieved from local storage (online/offline when not logged in; online synced data when logged in).
- Users create, edit, or delete collections (online/offline). When deleting a collection with locations, the app prompts to select a replacement collection. Changes are stored locally and synced with the server after login if not logged in. Offline icons are stored in temporary storage.
- Select a collection to view its location list, retrieved from local storage (online/offline when not logged in; online synced data when logged in).
- In the location list, users view, edit (including changing custom name (displayName), official name, address, coordinates, description, notes, tags, favorite status, collection; image selection only available when logged in), delete, mark/unmark as favorite, or share locations via the system sharing mechanism (iOS or Android; sharing online only, available whether logged in or not). When not logged in, the image selection option is disabled, and a message is displayed: "Please log in to add or remove images." Changes to collections or locations are stored locally and synced after login if not logged in. Offline images, when logged in, are stored in temporary storage.
- Select a location to view on the map (online: dynamic map, available whether logged in or not; offline: displays a message "Map unavailable offline" and shows only location details; Google Maps SDK on both iOS and Android). Images are displayed if available locally; otherwise, a placeholder is shown.

### 5. Navigation
- Users select a location from the map or list.
- The app provides in-app navigation to the location using Google Maps SDK on both iOS and Android (online only, available whether logged in or not). In offline mode, displays a message: "Navigation unavailable offline."

### 6. Login/Registration and Data Sync
- Users access the Login/Registration screen from the Settings screen.
- Users log in (online/offline after first login) or create an account (online).
- After login, all locally stored collections and locations (with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete`) are synced with the server using the authenticated user's account.
  - If logging in with a different account from the previous session, the app clears the previous Firebase Authentication session (if online) and shows a dialog: "Do you want to sync local data (X collections, Y locations) to the new account or discard it?" with "Sync" and "Discard" options.
  - If offline, login uses cached credentials, but sync is disabled until online.
- If sync fails (e.g., network issues, image upload failure, conflict), the app displays a notification: "Sync failed (X collections, Y locations). Please try again." with a "Retry" button to trigger manual synchronization.
- After logout:
  - **Online**: The app attempts to sync unsynced data before logging out. If sync fails, the app displays a warning: "You have unsynced data (X collections, Y locations). Please sync before logging out to avoid data loss." with options "Sync and Logout" or "Cancel".
  - **Offline**: The app displays a dialog: "You are offline. Logout will be completed when you reconnect. Data will remain saved locally and sync when you log in again. Proceed with logout?" with options "Proceed" or "Cancel". A flag `isLoggedOut: true` is stored locally, and data remains in local storage. When the app detects a network connection, it completes the logout by clearing the Firebase Authentication session and updates `isLoggedOut: false`.
  - Local data (including unsynced data with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete`) is retained in local storage and not associated with any `user_id` until the next login.
- Credentials are stored locally for offline access after the first login.

### 7. Send Feedback
- Users access the settings screen and tap "Send Feedback" to open an in-app email composer to send feedback, report bugs, or suggest features (online only, available whether logged in or not).

---

## Potential Additional Features (For Future Consideration)
- Search within the saved location list.
- Filter location list by criteria (e.g., distance, name).
- Manage offline data (pre-download maps).
- Rate and comment on locations (online).
- Location suggestions (online).
- Login with Google, Apple, or Facebook accounts.

---

[Back to Project Overview](../README.md)
