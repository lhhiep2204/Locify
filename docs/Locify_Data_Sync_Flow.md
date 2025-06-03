# Locify Data Synchronization Flow

This document describes the data flow and synchronization mechanisms for the Locify application, supporting online and offline functionality for saving and managing locations for planned visits or memorable places without requiring login.

---

## Table of Contents
- [Overview](#overview)
- [Online Data Flow](#online-data-flow)
  - [Get Data](#get-data-online)
  - [Create Data](#create-data-online)
  - [Update Data](#update-data-online)
  - [Delete Data](#delete-data-online)
- [Offline Data Flow](#offline-data-flow)
  - [Get Data](#get-data-offline)
  - [Create Data](#create-data-offline)
  - [Update Data](#update-data-offline)
  - [Delete Data](#delete-data-offline)
- [Synchronization Process](#synchronization-process)
  - [When Synchronization Occurs](#when-synchronization-occurs)
  - [User Deletion](#user-deletion)
  - [Conflict Resolution](#conflict-resolution)

---

## Overview
Locify allows users to manage locations and categories in both online and offline modes without requiring login. The client uses local storage to cache data and supports offline operations. When not logged in, even if online, the app retrieves category and location data from local storage, but other online features (e.g., search, share, feedback) function normally. Data synchronization occurs after login to ensure consistency between local storage and the backend server under the logged-in user's account. The `sync_status` field (`synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`) in the `categories` and `locations` tables tracks changes for synchronization.

- **Online Mode (No Login)**: The client performs operations on local storage for adding, editing, or deleting categories/locations, retrieving data locally even when online. Other online features (e.g., search, share, feedback) operate normally without requiring login, using Google Maps SDK for search/navigation on both iOS and Android. No server interaction occurs for category/location data until login.  
- **Online Mode (Logged In)**: The client interacts directly with the backend API to fetch, create, update, or delete category/location data. Successful API calls update local storage to maintain consistency. Other online features continue to function normally.  
- **Offline Mode**: The client performs operations on local storage, marking changes with appropriate `sync_status` values for later synchronization. Online-only features (e.g., search, share, feedback) are unavailable.  
- **Synchronization**: After login, the client sends all pending local changes to the server, which processes them under the logged-in user's account and updates `sync_status` to `synced`. After logout or user deletion, local data is managed as specified below.

---

## Online Data Flow
### Get Data (Online)
- **Description**: Fetch all categories or locations for the authenticated user (after login). If not logged in, even when online, retrieve data from local storage.  
- **Process**:
  1. If the user is logged in:
     - Client checks the validity of the Firebase ID token. If expired, the Firebase SDK attempts to refresh the token. If refresh fails, prompt the user to log in again.
     - Client sends a GET request to the appropriate endpoint with the Firebase `Authorization` token for category/location data, including pagination parameters (`page`, `size`, default `size=20`).
     - Server validates the token and returns a response containing:
       - `data`: Array of categories or locations (up to 20 records per page by default).
       - `meta`: Object with `total_count` (total records), `total_pages` (total pages), `page` (current page), and `size` (records per page).
     - Client updates local storage with the received `data`, overwriting existing records based on `id` and setting `sync_status` to `synced`. The `meta` information is used to manage pagination in the UI (e.g., display "Showing 1-20 of 400 items").
  2. If the user is not logged in (online or offline):
     - Client queries local storage for categories or locations (not tied to a user ID).  
     - Client displays all records, including those with `sync_status` of `pendingCreate`, `pendingUpdate`, or `pendingDelete`.  
     - No API calls are made.  
  3. Other online features (e.g., search, share, feedback) operate normally when online, regardless of login status, using Google Maps SDK for search/navigation on both iOS and Android and system sharing mechanisms for sharing.

### Create Data (Online)
- **Description**: Create a new category or location (after login). If not logged in, store locally even when online.  
- **Process**:
  1. If the user is logged in:
     - Client generates a UUID for the new record and sends a POST request with `sync_status: pendingCreate`.  
     - For categories, includes basic info (name, icon) and sync status.
     - For locations, includes all location details (name, address, coordinates, etc.).
     - Server validates the request (e.g., checks `name` length, valid `icon` URL, `latitude` range) and creates the record under the logged-in user's account.  
     - Server returns the created resource with `sync_status: synced` and server-generated timestamps.  
     - Client updates local storage with the server response.  
  2. If the user is not logged in (online or offline):
     - Client generates a UUID for the new record and stores it in local storage with `sync_status: pendingCreate`.  
     - For categories, stores name, icon (local or remote URL), and sync status locally.
     - For locations, stores all location details, including local image URLs (e.g., `file://`) if images are added.
     - Record is immediately available for viewing/editing in the app.  
     - When the user logs in and goes online, the client synchronizes the record with the server under the logged-in user's account.  

### Update Data (Online)
- **Description**: Update an existing category or location (after login). If not logged in, store locally even when online.  
- **Process**:
  1. If the user is logged in:
     - Client sends a PUT request with updated fields and `sync_status: pendingUpdate`.  
     - For categories, can update name and icon (valid URL or new upload).
     - For locations, can update any location details, including new image URLs (up to 10).
     - Server validates the request (e.g., checks `name` length, valid `latitude`/`longitude`) and updates the record, setting `sync_status: synced` and updating `updated_at`.  
     - Server returns the updated resource.  
     - Client updates local storage with the server response.  
  2. If the user is not logged in (online or offline):
     - Client updates the record in local storage and sets `sync_status: pendingUpdate`.  
     - Updated record is reflected in the app immediately.  
     - When the user logs in and goes online, the client synchronizes the record with the server under the logged-in user's account.  

### Delete Data (Online)
- **Description**: Delete a category or location (after login). If not logged in, mark for deletion locally even when online.  
- **Process**:
  1. If the user is logged in:
     - Client sends a DELETE request. For categories with locations, include `reassign_category_id` in the request body.  
     - Server validates the request and deletes the record (or reassigns locations for categories).  
     - Server responds with a success status.  
     - Client removes the record from local storage.  
  2. If the user is not logged in (online or offline):
     - Client marks the record in local storage with `sync_status: pendingDelete`.  
     - The app hides the record from the UI but retains it in local storage for synchronization.  
     - When the user logs in and goes online, the client synchronizes the deletion with the server under the logged-in user's account.  

---

## Offline Data Flow
### Get Data (Offline)
- **Description**: Fetch categories or locations from local storage when offline or not logged in.  
- **Process**:
  1. Client queries local storage for categories or locations (not tied to a user ID if not logged in).  
  2. Client displays all records, including those with `sync_status` of `pendingCreate`, `pendingUpdate`, or `pendingDelete`.  
  3. For locations with images, the client displays locally stored images (using local URLs like `file://`) or a placeholder image if no local copy exists.  
  4. No API calls are made.  

### Create Data (Offline)
- **Description**: Create a new category or location while offline or not logged in.  
- **Process**:
  1. Client generates a UUID for the new record and stores it in local storage with `sync_status: pendingCreate`.  
  2. For categories, stores name and icon (local URL if uploaded offline, e.g., `file://category_icon.jpg`).  
  3. For locations, stores all location details, including local image URLs (e.g., `file://image1.jpg`) for images selected offline. Images are stored in the device's temporary storage (e.g., app sandbox).  
  4. Record is immediately available for viewing/editing in the app, with local images displayed if available.  
  5. When the user logs in and goes online, the client synchronizes the record with the server under the logged-in user's account.  

### Update Data (Offline)
- **Description**: Update an existing category or location while offline or not logged in.  
- **Process**:
  1. Client updates the record in local storage and sets `sync_status: pendingUpdate`.  
  2. For locations, new images selected offline are stored in the device's temporary storage with local URLs (e.g., `file://new_image.jpg`) and added to `image_urls`.  
  3. Updated record is reflected in the app immediately, with local images displayed if available.  
  4. When the user logs in and goes online, the client synchronizes the record with the server under the logged-in user's account.  

### Delete Data (Offline)
- **Description**: Delete a category or location while offline or not logged in.  
- **Process**:
  1. Client marks the record in local storage with `sync_status: pendingDelete`.  
  2. The app hides the record from the UI but retains it in local storage for synchronization.  
  3. Local images associated with the record are retained in temporary storage until synchronization.  
  4. When the user logs in and goes online, the client synchronizes the deletion with the server under the logged-in user's account.  

---

## Synchronization Process
### When Synchronization Occurs
- **Trigger**: Synchronization occurs automatically when the client detects internet connectivity and the user logs in.  
- **Process**:
  1. **After Login**:
     - If the user logs in with a new account (different from the previous session):
       - **Online**: The client clears the previous Firebase Authentication session by calling `FirebaseAuth.signOut()` before logging in, then displays a dialog: “Do you want to sync local data to the new account or discard it? (X categories, Y locations will be affected).” The dialog shows the count of records with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete`.
       - **Offline**: The client allows login using cached credentials, but disables sync until online. The dialog is shown when the app reconnects.
     - If the user chooses to sync, the client assigns the logged-in user’s Firebase UID to all local records without a `user_id`.  
     - If the user chooses to discard, the client deletes all local records with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete` from local storage, including local image/icon files (e.g., `file://`).  
     - If syncing is confirmed, the client collects all records from local storage with `sync_status` of `pendingCreate`, `pendingUpdate`, or `pendingDelete`.  
     - Client fetches server data using pagination (e.g., `GET /locations?page=1&size=50`) to merge with local data.  
     - Client sends these records to the server in batches (up to 50 records per request) in sequence:  
       - **Create**: 
         - For locations with images: First upload images to Firebase Storage, replacing local URLs (e.g., `file://`) with remote URLs, then send POST request with the logged-in user’s `user_id` and image URLs.
         - For categories with icons: Upload icon to Firebase Storage, then send POST request with the logged-in user’s `user_id` and icon URL.
         - For records without images/icons: Send POST request with the logged-in user’s `user_id`.
       - **Update**: 
         - For locations with new images: Upload new images to Firebase Storage, replacing local URLs, then send PUT request with the logged-in user’s `user_id` and updated image URLs.
         - For categories with new icons: Upload new icon to Firebase Storage, then send PUT request with the logged-in user’s `user_id` and updated icon URL.
         - For records without image changes: Send PUT request with the logged-in user’s `user_id`.
       - **Delete**: 
         - For locations with images: Send DELETE request with the logged-in user’s `user_id`. The client deletes images from Firebase Storage for individual location deletions. Local image files (e.g., `file://`) are deleted immediately when marked `pendingDelete` offline.
         - For categories: Send DELETE request with the logged-in user’s `user_id`. If the category contains locations, the client displays a confirmation dialog: “Deleting this category will also delete all locations within it. Are you sure you want to proceed?” If confirmed, the backend deletes the category icon and images of all associated locations from Firebase Storage. Local icon/image files (e.g., `file://`) are deleted immediately when marked `pendingDelete` offline. During user account deletion, the backend handles icon/image deletion from Firebase Storage.
         - For records without images/icons: Send DELETE request with the logged-in user’s `user_id`.
     - Server processes each request, validates the `user_id` against the Firebase token, and updates `sync_status` to `synced`.  
     - Server returns updated records (or success status for deletions).  
     - Client updates local storage with server responses, associating records with the logged-in user’s `user_id`.  
  2. **After Logout**:
     - **Online**: The client calls `FirebaseAuth.signOut()` to clear the Firebase Authentication session, removes the Firebase token from local storage, and retains all local data (with `sync_status: synced`, `pendingCreate`, `pendingUpdate`, or `pendingDelete`). The app displays a warning: “You have unsynced data (X categories, Y locations). Please sync before logging out to avoid data loss.”  
     - **Offline**: The client does not call `FirebaseAuth.signOut()` when offline. Instead, it sets a local flag `isLoggedOut: true`, retains all local data, and displays a dialog: “You are offline. Logout will be completed when you reconnect. Data will remain saved locally and sync when you log in again.” When the app detects internet connectivity, it calls `FirebaseAuth.signOut()`, removes the Firebase token, updates `isLoggedOut: false`, and shows a notification: “Reconnected. Logout completed.”
     - Local data is not associated with any `user_id` until the next login.  
  3. **Multi-Device Sync**:
     - If the user logs in on a different device with the same account, the client syncs local unsynced data with the server, which merges it with existing server data based on `updated_at`.  
     - For images and icons, the server compares the URLs to avoid duplicate uploads.  
  4. **Error Handling**:
     - If a sync request fails, the client retains the record’s `sync_status` and retries during the next sync attempt using exponential backoff (initial delay: 1s, max delay: 60s).  
     - If image upload fails:
       - The client keeps the local image URLs in the record.
       - The record’s data remains in local storage with the original `sync_status`.
       - During the next sync attempt, the client will:
         1. Check if any image URLs are local URLs (e.g., starting with `file://` or `content://`).
         2. If local URLs are found, attempt to upload these images first.
         3. After successful upload, update the record with the new remote URLs.
         4. Proceed with the API request using the updated URLs.
     - If a conflict occurs (e.g., older `updated_at`), the server returns an `E008` error, and the client updates local storage with the server’s version.
     - For category deletion, if the backend fails to delete images/icons (e.g., Firebase Storage error), the server returns an `S002` error, and the client displays a notification: “Failed to delete category. Please try again.” with a “Retry” button.

### User Deletion
- **Trigger**: Occurs when the user initiates account deletion via `DELETE /users/me` (online only).
- **Process**:
  1. **Client**:
     - Sends a `DELETE /users/me` request with the Firebase `Authorization` token.
     - Upon receiving a 204 No Content response, clears all local storage (categories, locations, and images) and calls `FirebaseAuth.signOut()` to clear the authentication session.
     - Displays a confirmation: “Your account and all associated data have been deleted.”
  2. **Server**:
     - Validates the Firebase token to ensure the request is from the authenticated user.
     - Queries the `categories` table for all `icon` URLs and the `locations` table for all `image_urls` associated with the `user_id`.
     - Deletes all identified images from Firebase Storage using the Firebase Admin SDK.
     - Deletes all records in `categories` and `locations` tables for the `user_id`.
     - Deletes the user record from the `users` table and removes the user from Firebase Authentication.
     - Returns a 204 No Content response.
  3. **Error Handling**:
     - If the token is invalid, the server returns an `E005` error.
     - If the user is not authorized, the server returns an `E006` error.
     - If image deletion or database operations fail, the server returns an `S002` error, and the client displays a message: “Account deletion failed. Please try again.”
     - If the request fails due to network issues, the client retries with exponential backoff (initial delay: 1s, max delay: 60s).
  4. **Offline**:
     - Account deletion is not supported offline. The client displays a message: “Account deletion requires an internet connection. Please try again when online.”

### Conflict Resolution
- **Mechanism**: The server uses the `updated_at` timestamp to resolve conflicts. The record with the latest `updated_at` takes precedence.  
- **Process**:
  1. If a client submits a record with an older `updated_at` than the server’s version, the server rejects the update with an `E008` error and returns the server’s version.  
  2. Client updates local storage with the server’s version, including image URLs.  
  3. If the user logs in with a different account and syncs local data, the server treats local records as new if no matching `id` exists, or resolves conflicts using `updated_at` if there are overlaps.
  4. For image conflicts:
     - If both versions have different images, the server keeps the images from the version with the latest `updated_at`.
     - If one version has images and the other doesn’t, the server keeps the images if the version with images has the latest `updated_at`.

---

[Back to Project Overview](../README.md)
