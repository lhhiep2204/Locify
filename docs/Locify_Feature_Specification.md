# Detailed Feature Specification for the "Locify" Application

**Objective**: Develop and release the "Locify" application on the App Store (iOS) and Google Play Store (Android), enabling users to save and manage locations for planned visits or memorable places, supporting both online and offline use without requiring login.

## Table of Contents
- [Screens and Main Features](#screens-and-main-features)
  - [1. Main Screen (Map)](#1-main-screen-map)
  - [2. Saved Locations List (Categories)](#2-saved-locations-list-categories)
  - [3. Saved Locations List (Locations)](#3-saved-locations-list-locations)
  - [4. Add Location Screen](#4-add-location-screen)
  - [5. Settings Screen](#5-settings-screen)
  - [6. Login/Registration Screen](#6-loginregistration-screen)
- [Main Functional Workflows](#main-functional-workflows)
  - [1. App Startup](#1-app-startup)
  - [2. Explore and Save Locations](#2-explore-and-save-locations)
  - [3. Add New Location](#3-add-new-location)
  - [4. Manage Categories and Locations](#4-manage-categories-and-locations)
  - [5. Navigation](#5-navigation)
  - [6. Login/Registration and Data Sync](#6-loginregistration-and-data-sync)
  - [7. Send Feedback](#7-send-feedback)
- [Potential Additional Features (For Future Consideration)](#potential-additional-features-for-future-consideration)

---

## Screens and Main Features
### 1. Main Screen (Map)
**Purpose**: Default screen displayed on app startup, allowing users to explore, search, save, and share locations.  
**Features**:
- **Display user location** (Online/Offline): The app determines and displays the current location (requires location permission). On iOS, uses MapKit; on Android, uses Google Maps. In offline mode, displays the last known GPS location (if available).  
- **Search for locations** (Online): Users enter a name or address to search for locations, available whether logged in or not. On iOS, uses MapKit's search functionality; on Android, uses Google Maps. Not available offline.  
- **Location Information Display** (Online/Offline): Shows name, address, and coordinates of a location. Details are stored locally after being fetched to support offline viewing.  
- **Save location** (Online/Offline): Users save a location to the list, required to select a category (from default categories like Restaurant, Cafe, Tourist Attraction, Favorites, or user-created categories). Data is stored locally for offline access and synced with the server after login if not logged in.  
- **Share location** (Online): Users share location details (name, address, coordinates) via the system sharing mechanism (iOS or Android), available whether logged in or not. Not available offline.  
- **Navigate** (Online): Provides in-app navigation to the selected location using MapKit (iOS) or Google Maps (Android), available whether logged in or not. In offline mode, displays a message that navigation is unavailable.  

### 2. Saved Locations List (Categories)
**Purpose**: Display a list of location categories, allowing users to manage categories and select a category to view its location list.  
**Features**:
- **Display category list** (Online/Offline): Shows all categories (default ones like Restaurant, Cafe, Tourist Attraction, Favorites, and user-created categories) with their respective icons and the number of locations in each. Data is stored locally to support offline access.  
- **Create category** (Online/Offline): Users create a new category by entering a name and selecting or uploading an icon. The new category is stored locally and synced with the server after login if not logged in.  
- **Edit category** (Online/Offline): Users edit the name and icon of an existing category. Changes are stored locally and synced with the server after login if not logged in.  
- **Delete category** (Online/Offline): Users delete a category. If the category contains locations, the app prompts the user to select another category (or a default like "Other") to reassign the locations before deletion. Changes are stored locally and synced with the server after login if not logged in.  
- **Go to location list** (Online/Offline): Select a category to navigate to the location list for that category.  

### 3. Saved Locations List (Locations)
**Purpose**: Allow users to view and manage the list of saved locations within a specific category.  
**Features**:
- **Display location list** (Online/Offline): Shows all saved locations in the selected category, stored locally for offline access.  
- **View location on map** (Online/Offline): When a location is selected, the app:  
  - Navigates to the map screen.  
  - Displays detailed information about the selected location.
  - Shows location images if available.
  - Shows markers for other locations in the same category on the map (MapKit on iOS, Google Maps on Android).  
  - In offline mode, displays a message that the map is unavailable and shows only the location details.  
- **Edit location details** (Online/Offline): Edit name, description, category (select from default or user-created categories), or add/remove location images, stored locally for offline support and synced with the server after login if not logged in.  
- **Mark/Unmark as Favorite** (Online/Offline): Mark or unmark a location as a favorite, stored locally. Favorite locations appear in the "Favorites" category and are synced after login if not logged in.  
- **Delete location** (Online/Offline): Delete a location from the list, updated locally and synced with the server after login if not logged in.  
- **Share location** (Online): Users share location details (name, address, coordinates) and images via the system sharing mechanism (iOS or Android), available whether logged in or not. Not available offline.  
- **Navigate** (Online): Provides in-app navigation to the selected location using MapKit (iOS) or Google Maps (Android), available whether logged in or not. In offline mode, displays a message that navigation is unavailable.  

### 4. Add Location Screen
**Purpose**: Add a new saved location.  
**Features**:
- **Location Search** (Online): Functionality to search for a location, available whether logged in or not. Not available offline.  
- **Location Details** (Online/Offline): Input fields for the location name, category, notes, and option to add images.  
- **Category Selection** (Online/Offline): Ability to select a category for the location (with the option to create a new category with icon).  
- **Map Preview** (Online): Displays a non-interactive map view with a marker indicating the selected location, available whether logged in or not.  

### 5. Settings Screen
**Purpose**: Manage account, access login, send feedback, and customize the application.  
**Features**:
- **Login/Registration** (Online): Option to navigate to the Login/Registration screen for users to log in or create an account.  
- **Manage account** (Online/Offline): Change password and personal information (stored locally, synced when online; available only after login).  
- **Log out** (Online/Offline): Log out of the account (available only after login). Displays a warning about unsynced local data, encouraging users to sync before logging out.  
- **View app information** (Online/Offline): Display app version and developer information, available offline.  
- **Send feedback** (Online): Opens an in-app email composer to send feedback, report bugs, or suggest features, available whether logged in or not. Not available offline.  

### 6. Login/Registration Screen
**Purpose**: Allow users to create an account or log in to sync local data with the server.  
**Features**:
- **Login** (Online/Offline): Users log in with email and password. After the first login, credentials are stored locally to allow offline access (only for features not requiring internet). After login, local data (categories and locations) syncs with the server.  
- **Registration** (Online): Users create a new account with email and password. After registration, local data syncs with the server.  

---

## Main Functional Workflows
### 1. App Startup
- The app opens directly to the Main Screen (Map), allowing immediate use without login.  
- All operations (e.g., saving locations, managing categories) are stored locally and function offline or when online but not logged in.  

### 2. Explore and Save Locations
- The app determines the user's location (online or last GPS if offline; MapKit on iOS, Google Maps on Android).  
- Users search for locations (online only; MapKit on iOS, Google Maps on Android), available whether logged in or not.  
- Display location details, stored locally for offline viewing.  
- Users save a location, required to select a category (default or user-created), stored locally and synced with the server after login if not logged in.  
- If not logged in (online or offline), category and location data is retrieved from local storage only.  
- Users share a location via the system sharing mechanism (iOS or Android; online only), available whether logged in or not.  

### 3. Add New Location
- Users access the Add Location Screen.  
- Users search for a location (online only; MapKit on iOS, Google Maps on Android), available whether logged in or not.  
- Users enter location details (name, category, notes) and select a category (default, user-created, or create a new one; online/offline).  
- A non-interactive map preview displays the selected location (online only; available whether logged in or not).  
- The location is saved, stored locally for offline access and synced with the server after login if not logged in.  

### 4. Manage Categories and Locations
- Users view the category list with the number of locations per category, retrieved from local storage (online/offline when not logged in; online synced data when logged in).  
- Users create, edit, or delete categories (online/offline). When deleting a category with locations, the app prompts to select a replacement category. Changes are stored locally and synced with the server after login if not logged in.  
- Select a category to view its location list, retrieved from local storage (online/offline when not logged in; online synced data when logged in).  
- In the location list, users view, edit (including changing category), delete, mark/unmark as favorite, or share locations via the system sharing mechanism (iOS or Android; sharing online only, available whether logged in or not). Changes to categories or locations are stored locally and synced after login if not logged in.  
- Select a location to view on the map (online: dynamic map, available whether logged in or not; offline: displays a message that the map is unavailable and shows only location details; MapKit on iOS, Google Maps on Android).  

### 5. Navigation
- Users select a location from the map or list.  
- The app provides in-app navigation to the location using MapKit (iOS) or Google Maps (Android; online only, available whether logged in or not). In offline mode, displays a message that navigation is unavailable.  

### 6. Login/Registration and Data Sync
- Users access the Login/Registration screen from the Settings screen.  
- Users log in (online/offline after first login) or create an account (online).  
- After login, all locally stored categories and locations (with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete`) are synced with the server using the authenticated user's account. If logging in with a different account from the previous session, the app prompts the user to confirm syncing local data to the new account or discard it.  
- After logout, local data (including unsynced data with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete`) is retained in local storage and not associated with any `user_id` until the next login. The app displays a warning about unsynced data when the user logs out, encouraging them to sync before logging out.  
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
