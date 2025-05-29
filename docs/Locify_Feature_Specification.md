# Detailed Feature Specification for the "Locify" Application

**Objective**: Develop and release the "Locify" application on the App Store (iOS) and Google Play Store (Android), enabling users to save, manage, share, and navigate to important locations, supporting both online and offline use. On iOS, the app uses MapKit; on Android, it uses Google Maps.

## Table of Contents
- [Screens and Main Features](#screens-and-main-features)
  - [1. Login/Registration Screen](#1-loginregistration-screen)
  - [2. Main Screen (Map)](#2-main-screen-map)
  - [3. Saved Locations List (Categories)](#3-saved-locations-list-categories)
  - [4. Saved Locations List (Locations)](#4-saved-locations-list-locations)
  - [5. Add Location Screen](#5-add-location-screen)
  - [6. Settings Screen](#6-settings-screen)
- [Main Functional Workflows](#main-functional-workflows)
  - [1. Login/Registration](#1-loginregistration)
  - [2. Explore and Save Locations](#2-explore-and-save-locations)
  - [3. Add New Location](#3-add-new-location)
  - [4. Manage Categories and Locations](#4-manage-categories-and-locations)
  - [5. Navigation](#5-navigation)
  - [6. Send Feedback](#6-send-feedback)
- [Potential Additional Features (For Future Consideration)](#potential-additional-features-for-future-consideration)

---

## Screens and Main Features

### 1. Login/Registration Screen
**Purpose**: Allow users to create an account or log in to use the application.  
**Features**:
- **Login** (Online/Offline): Users log in with email and password. After the first login, credentials are stored locally to allow offline access (only for features not requiring internet).  
- **Registration** (Online): Users create a new account with email and password.  

### 2. Main Screen (Map)
**Purpose**: Display a map and allow users to explore, search, save, and share locations.  
**Features**:
- **Display user location** (Online/Offline): The app determines and displays the current location (requires location permission). On iOS, uses MapKit; on Android, uses Google Maps. In offline mode, displays the last known GPS location (if available).  
- **Search for locations** (Online): Users enter a name or address to search for locations. On iOS, uses MapKit’s search functionality; on Android, uses Google Maps. Not available offline.  
- **Location Information Display** (Online/Offline): Shows name, address, and coordinates of a location. Details are stored locally after being fetched to support offline viewing.  
- **Save location** (Online/Offline): Users save a location to the list, required to select a category (from default categories like Restaurant, Cafe, Tourist Attraction, Favorites, or user-created categories). Data is stored locally for offline access.  
- **Share location** (Online): Users share location details (name, address, coordinates) via the system sharing mechanism (iOS or Android). Not available offline.  
- **Navigate** (Online): Provides in-app navigation to the selected location using MapKit (iOS) or Google Maps (Android). In offline mode, displays a message that navigation is unavailable.  

### 3. Saved Locations List (Categories)
**Purpose**: Display a list of location categories, allowing users to manage categories and select a category to view its location list.  
**Features**:
- **Display category list** (Online/Offline): Shows all categories (default ones like Restaurant, Cafe, Tourist Attraction, Favorites, and user-created categories), along with the number of locations in each. Data is stored locally to support offline access.  
- **Create category** (Online/Offline): Users create a new category by entering a name. The new category is stored locally and synced when online.  
- **Edit category** (Online/Offline): Users edit the name of an existing category. Changes are stored locally and synced when online.  
- **Delete category** (Online/Offline): Users delete a category. If the category contains locations, the app prompts the user to select another category (or a default like "Other") to reassign the locations before deletion. Changes are stored locally and synced when online.  
- **Go to location list** (Online/Offline): Select a category to navigate to the location list for that category.  

### 4. Saved Locations List (Locations)
**Purpose**: Allow users to view and manage the list of saved locations within a specific category.  
**Features**:
- **Display location list** (Online/Offline): Shows all saved locations in the selected category, stored locally for offline access.  
- **View location on map** (Online/Offline): When a location is selected, the app:  
  - Navigates to the map screen.  
  - Displays detailed information about the selected location.  
  - Shows markers for other locations in the same category on the map (MapKit on iOS, Google Maps on Android).  
  - In offline mode, displays a message that the map is unavailable and shows only the location details.  
- **Edit location details** (Online/Offline): Edit name, description, or category (select from default or user-created categories), stored locally for offline support.  
- **Mark/Unmark as Favorite** (Online/Offline): Mark or unmark a location as a favorite, stored locally. Favorite locations appear in the "Favorites" category.  
- **Delete location** (Online/Offline): Delete a location from the list, updated locally and synced when online.  
- **Share location** (Online): Users share location details (name, address, coordinates) via the system sharing mechanism (iOS or Android). Not available offline.  
- **Navigate** (Online): Provides in-app navigation to the selected location using MapKit (iOS) or Google Maps (Android). In offline mode, displays a message that navigation is unavailable.  

### 5. Add Location Screen
**Purpose**: Add a new saved location.  
**Features**:
- **Location Search** (Online): Functionality to search for a location. Not available offline.  
- **Location Details** (Online/Offline): Input fields for the location name, category, and notes.  
- **Category Selection** (Online/Offline): Ability to select a category for the location (with the option to create a new category).  
- **Map Preview** (Online): Displays a non-interactive map view with a marker indicating the selected location.  

### 6. Settings Screen
**Purpose**: Manage account, send feedback, and customize the application.  
**Features**:
- **Manage account** (Online/Offline): Change password and personal information (stored locally, synced when online).  
- **Log out** (Online/Offline): Log out of the account.  
- **View app information** (Online/Offline): Display app version and developer information, available offline.  
- **Send feedback** (Online): Send feedback, report bugs, or suggest features via email. Not available offline.  

---

## Main Functional Workflows

### 1. Login/Registration
- Users open the app, log in (online/offline after first login) or create an account (online).  
- Credentials are stored locally for offline access.  

### 2. Explore and Save Locations
- The app determines the user’s location (online or last GPS if offline; MapKit on iOS, Google Maps on Android).  
- Users search for locations (online only; MapKit on iOS, Google Maps on Android).  
- Display location details, stored locally for offline viewing.  
- Users save a location, required to select a category (default or user-created), stored locally.  
- Users share a location via the system sharing mechanism (iOS or Android; online only).  

### 3. Add New Location
- Users access the Add Location Screen.  
- Users search for a location (online only; MapKit on iOS, Google Maps on Android).  
- Users enter location details (name, category, notes) and select a category (default, user-created, or create a new one; online/offline).  
- A non-interactive map preview displays the selected location (online/offline).  
- The location is saved, stored locally for offline access.  

### 4. Manage Categories and Locations
- Users view the category list with the number of locations per category (online/offline).  
- Users create, edit, or delete categories (online/offline). When deleting a category with locations, the app prompts to select a replacement category.  
- Select a category to view its location list (online/offline).  
- In the location list, users view, edit (including changing category), delete, mark/unmark as favorite, or share locations via the system sharing mechanism (iOS or Android; sharing online only).  
- Select a location to view on the map (online: dynamic map; offline: displays a message that the map is unavailable and shows only location details; MapKit on iOS, Google Maps on Android).  

### 5. Navigation
- Users select a location from the map or list.  
- The app provides in-app navigation to the location using MapKit (iOS) or Google Maps (Android; online only). In offline mode, displays a message that navigation is unavailable.  

### 6. Send Feedback
- Users access the settings screen and send feedback via email (online only).  

---

## Potential Additional Features (For Future Consideration)
- Search within the saved location list.  
- Filter location list by criteria (e.g., distance, name).  
- Manage offline data (pre-download maps).  
- Adding images to locations.  
- Rate and comment on locations (online).  
- Location suggestions (online).  
- Login with Google, Apple, or Facebook accounts.

---

[Back to Project Overview](../README.md)
