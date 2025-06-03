# Detailed Feature Specification for the "Locify" Application

**Objective**: Develop and release the "Locify" application on the App Store (iOS) and Google Play Store (Android), enabling users to save and manage locations for planned visits or memorable places, supporting both online and offline use without requiring login.

---

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
- **Display user location** (Online/Offline): The app determines and displays the current location (requires location permission). Uses Google Maps SDK on both iOS and Android. In offline mode, displays the last known GPS location (if available).  
- **Search for locations** (Online): Users enter a name or address to search for locations, available whether logged in or not. Uses Google Maps SDK search functionality on both iOS and Android. Not available offline.  
- **Location Information Display** (Online/Offline): Shows name, address, and coordinates of a location. Details are stored locally after being fetched to support offline viewing. Images are displayed if available locally; otherwise, a placeholder image ("Image unavailable offline") is shown.  
- **Save location** (Online/Offline): Users save a location to the list, required to select a category (from default categories like Restaurant, Cafe, Tourist Attraction, Favorites, or user-created categories). Data is stored locally for offline access and synced with the server after login if not logged in.  
- **Share location** (Online): Users share location details (name, address, coordinates) via the system sharing mechanism (iOS or Android), available whether logged in or not. Not available offline.  
- **Navigate** (Online): Provides in-app navigation to the selected location using Google Maps SDK on both iOS and Android, available whether logged in or not. In offline mode, displays a message: "Navigation unavailable offline."  

### 2. Saved Locations List (Categories)
**Purpose**: Display a list of location categories, allowing users to manage categories and select a category to view its location list.
**Features**:
- **Display category list** (Online/Offline): Shows all categories (default ones like Restaurant, Cafe, Tourist Attraction, Favorites, and user-created categories) with their respective icons and the number of locations in each. Data is stored locally to support offline access. Icons are displayed if available locally; otherwise, a placeholder icon is shown.
- **Create category** (Online/Offline): Users create a new category by entering a name and selecting or uploading an icon. The new category is stored locally and synced with the server after login if not logged in. Offline icons are stored in temporary storage (e.g., `file://category_icon.jpg`).  
- **Edit category** (Online/Offline): Users edit the name and icon of an existing category. Changes are stored locally and synced with the server after login if not logged in. New offline icons are stored in temporary storage.  
- **Delete category** (Online/Offline): Users delete a category. If the category contains locations, the category and all its locations (including their images) are deleted. Changes are stored locally, with the category and locations marked as `pendingDelete`, and local image/icon files (e.g., `file://`) are removed immediately to free device storage. The changes are synced with the server after login if not logged in, with the backend handling deletion of Firebase Storage images/icons.
- **Go to location list** (Online/Offline): Select a category to navigate to the location list for that category.

### 3. Saved Locations List (Locations)
**Purpose**: Allow users to view and manage the list of saved locations within a specific category.  
**Features**:
- **Display location list** (Online/Offline): Shows all saved locations in the selected category, stored locally for offline access.  
- **View location on map** (Online/Offline): When a location is selected, the app:  
  - Navigates to the map screen.  
  - Displays detailed information about the selected location.
  - Shows location images if available locally; otherwise, displays a placeholder ("Image unavailable offline").
  - Shows markers for other locations in the same category on the map (Google Maps SDK on both iOS and Android).  
  - In offline mode, displays a message: "Map unavailable offline" and shows only the location details.  
- **Edit location details** (Online/Offline): Edit name, description, category (select from default or user-created categories), or add/remove location images, stored locally for offline support and synced with the server after login if not logged in. Offline images are stored in temporary storage (e.g., `file://image1.jpg`).  
- **Mark/Unmark as Favorite** (Online/Offline): Mark or unmark a location as a favorite, stored locally. Favorite locations appear in the "Favorites" category and are synced after login if not logged in.  
- **Delete location** (Online/Offline): Delete a location from the list, updated locally and synced with the server after login if not logged in.  
- **Share location** (Online): Users share location details (name, address, coordinates) and images (if available) via the system sharing mechanism (iOS or Android), available whether logged in or not. Not available offline.  
- **Navigate** (Online): Provides in-app navigation to the selected location using Google Maps SDK on both iOS and Android, available whether logged in or not. In offline mode, displays a message: "Navigation unavailable offline."  

### 4. Add Location Screen
**Purpose**: Add a new saved location.  
**Features**:
- **Location Search** (Online): Functionality to search for a location, available whether logged in or not. Uses Google Maps SDK on both iOS and Android. Not available offline.  
- **Location Details** (Online/Offline): Input fields for the location name, category, notes, and option to add images. Offline images are stored in temporary storage with local URLs (e.g., `file://image1.jpg`).  
- **Category Selection** (Online/Offline): Ability to select a category for a location (with the option to create a new one).  
- **Map Preview** (Online): Displays a non-interactive map view with a marker indicating the selected location, available whether logged in or not, using Google Maps SDK on both iOS and Android. In offline mode, displays a placeholder: "Map preview unavailable offline."  

### 5. Settings Screen
**Purpose**: Manage account, access login, send feedback, and customize the application.  
**Features**:
- **Login/Registration** (Online): Option to navigate to the Login/Registration screen for users to log in or create a new account.  
- **Manage account** (Online/Offline): Change password and personal information (stored locally, synced with the server when online; available only after login).  
- **Log out** (Online/Offline): Log out of the account (available only after login).  
  - **Online**: Displays a warning: "You have unsynced data (X categories, Y locations). Please confirm sync to proceed." with options "Sync and Logout" or "Cancel".  
  - **Offline**: Displays a dialog: "You are offline. Logout will be completed when you reconnect to the Internet. Data will remain saved locally and sync when you log in again. Proceed with logout?" with options "Proceed" or "Cancel". After logout, a flag `isLoggedOut: true` is stored locally, and data remains in local storage. When the app detects an Internet connection, it completes the logout by clearing the Firebase Authentication session and updates `isLoggedOut: false`.  
- **View app information** (Online/Offline): Display app version and developer information, available offline.  
- **Send feedback** (Online): Opens an in-app email composer to send feedback, report bugs, or suggest features, available whether logged in or not. Not available offline.  

### 6. Login/Registration Screen
**Purpose**: Allow users to create an account or log in to sync local data with the server.  
**Features**:
- **Login** (Online/Offline): Users log in with email and password. After the first login, credentials are stored locally to allow offline access (only for features not requiring internet). After login, local data (categories and locations) syncs with the server. 
  - If `isLoggedOut: true` and unsynced data exists:
    - **Online**: The app clears the previous Firebase Authentication session (if any) before logging in, then shows a dialog: "Do you want to sync local data (X categories, Y locations) to the new account or discard it?"
    - **Offline**: Allows login using cached credentials, but disables sync until online. A notification is shown: "You have unsynced data. Please connect to sync."
- **Registration** (Online): Users create a new account with email and password. After registration, local data syncs with the server.  

---

## Main Functional Workflows
### 1. App Startup
- The app opens directly to the Main Screen (Map), allowing immediate use without login.  
- All operations (e.g., saving locations, managing categories) are stored locally and function offline or when online but not logged in.  
- If `isLoggedOut: true` and unsynced data exists, display a notification: "You have unsynced data. Please log in to sync."

### 2. Explore and Save Locations
- The app determines the user's location (online or last GPS if offline; Google Maps SDK on both iOS and Android).  
- Users search for locations (online only; Google Maps SDK on both iOS and Android), available whether logged in or not.  
- Display location details, stored locally for offline viewing. Images are displayed if available locally; otherwise, a placeholder is shown.  
- Users save a location, required to select a category (default or user-created), stored locally and synced with the server after login if not logged in.  
- If not logged in (online or offline), category and location data is retrieved from local storage only.  
- Users share a location via the system sharing mechanism (iOS or Android; online only), available whether logged in or not.  

### 3. Add New Location
- Users access the Add Location Screen.  
- Users search for a location (online only; Google Maps SDK on both iOS and Android), available whether logged in or not.  
- Users enter location details (name, category, notes) and select a category (default, user-created, or create a new one; online/offline).  
- A non-interactive map preview displays the selected location (online only; available whether logged in or not, using Google Maps SDK). In offline mode, displays a placeholder: "Map preview unavailable offline."  
- The location is saved, stored locally for offline access and synced with the server after login if not logged in. Offline images are stored in temporary storage.  

### 4. Manage Categories and Locations
- Users view the category list with the number of locations per category, retrieved from local storage (online/offline when not logged in; online synced data when logged in).  
- Users create, edit, or delete categories (online/offline). When deleting a category with locations, the app prompts to select a replacement category. Changes are stored locally and synced with the server after login if not logged in. Offline icons are stored in temporary storage.  
- Select a category to view its location list, retrieved from local storage (online/offline when not logged in; online synced data when logged in).  
- In the location list, users view, edit (including changing category), delete, mark/unmark as favorite, or share locations via the system sharing mechanism (iOS or Android; sharing online only, available whether logged in or not). Changes to categories or locations are stored locally and synced after login if not logged in. Offline images are stored in temporary storage.  
- Select a location to view on the map (online: dynamic map, available whether logged in or not; offline: displays a message "Map unavailable offline" and shows only location details; Google Maps SDK on both iOS and Android). Images are displayed if available locally; otherwise, a placeholder is shown.  

### 5. Navigation
- Users select a location from the map or list.  
- The app provides in-app navigation to the location using Google Maps SDK on both iOS and Android (online only, available whether logged in or not). In offline mode, displays a message: "Navigation unavailable offline."  

### 6. Login/Registration and Data Sync
- Users access the Login/Registration screen from the Settings screen.  
- Users log in (online/offline after first login) or create an account (online).  
- After login, all locally stored categories and locations (with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete`) are synced with the server using the authenticated user's account. 
  - If logging in with a different account from the previous session, the app clears the previous Firebase Authentication session (if online) and shows a dialog: "Do you want to sync local data (X categories, Y locations) to the new account or discard it?" with "Sync" and "Discard" options.  
  - If offline, login uses cached credentials, but sync is disabled until online.
- If sync fails (e.g., network issues, image upload failure, conflict), the app displays a notification: "Sync failed (X categories, Y locations). Please try again." with a "Retry" button to trigger manual synchronization.  
- After logout:
  - **Online**: The app attempts to sync unsynced data before logging out. If sync fails, the app displays a warning: "You have unsynced data (X categories, Y locations). Please sync before logging out to avoid data loss." with options "Sync and Logout" or "Cancel".
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
