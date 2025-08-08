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

- **Online Mode (No Login)**: The client performs operations on local storage for adding, editing, or deleting categories/locations, retrieving data locally even when online. Image selection for locations is disabled, and a message is displayed: "Please log in to add or remove images." Other online features (e.g., search, share, feedback) operate normally without requiring login, using Google Maps SDK for search/navigation on both iOS and Android. No server interaction occurs for category/location data until login.
- **Online Mode (Logged In)**: The client interacts directly with the backend API to fetch, create, update, or delete category/location data, including image selection for locations. Successful API calls update local storage to maintain consistency. Other online features continue to function normally.
- **Offline Mode**: The client performs operations on local storage, marking changes with appropriate `sync_status` values for later synchronization. Image selection for locations is only available when logged in; if not logged in, the option is disabled with a message: "Please log in to add or remove images." Online-only features (e.g., search, share, feedback) are unavailable.
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

### Create Data (Online)
- **Description**: Create a new category or location for the authenticated user (after login). If not logged in, store locally.
- **Process**:
  1. If the user is logged in:
     - Client generates a UUID for the new record and sends a POST request (e.g., `POST /categories` or `POST /categories/:categoryId/locations`) with the Firebase `Authorization` token.
     - For locations, image selection is enabled, and images are uploaded to Firebase Storage, with URLs included in the request.
     - Server validates the token, processes the request, and stores the record in the database with `sync_status: synced`.
     - Server returns the created record with server-generated timestamps.
     - Client updates local storage with the returned record.
  2. If the user is not logged in:
     - Client generates a UUID and stores the record in local storage with `sync_status: pendingCreate`.
     - Image selection is disabled, and a message is displayed: "Please log in to add or remove images."

### Update Data (Online)
- **Description**: Update an existing category or location for the authenticated user (after login). If not logged in, store locally.
- **Process**:
  1. If the user is logged in:
     - Client sends a PATCH request (e.g., `PATCH /categories/:id` or `PATCH /locations/:id`) with the Firebase `Authorization` token, including updated fields and `sync_status: pendingUpdate`.
     - For locations, image selection is enabled, and new images are uploaded to Firebase Storage, with updated URLs included in the request.
     - Server validates the token, checks `updated_at` for conflicts, and updates the record with `sync_status: synced`.
     - Server returns the updated record.
     - Client updates local storage with the returned record.
  2. If the user is not logged in:
     - Client updates the record in local storage with `sync_status: pendingUpdate`.
     - Image selection is disabled, and a message is displayed: "Please log in to add or remove images."

### Delete Data (Online)
- **Description**: Delete a category or location for the authenticated user (after login). If not logged in, mark for deletion locally.
- **Process**:
  1. If the user is logged in:
     - Client sends a DELETE request (e.g., `DELETE /categories/:id` or `DELETE /locations/:id`) with the Firebase `Authorization` token.
     - Server validates the token, queries the database for image/icon URLs, deletes them from Firebase Storage, and removes the record from the database.
     - Server returns a 204 No Content response.
     - Client removes the record from local storage.
  2. If the user is not logged in:
     - Client marks the record in local storage with `sync_status: pendingDelete`.
     - Local image/icon files (e.g., `file://`) are deleted immediately to free device storage.
     - Image selection is disabled, and a message is displayed: "Please log in to add or remove images."

---

## Offline Data Flow

### Get Data (Offline)
- **Description**: Retrieve categories or locations from local storage.
- **Process**:
  - Client queries local storage for categories or locations (not tied to a user ID if not logged in).
  - Client displays all records, including those with `sync_status` of `pendingCreate`, `pendingUpdate`, or `pendingDelete`.
  - Images/icons are displayed if available locally; otherwise, a placeholder is shown.
  - Online-only features (e.g., search, share, feedback) are unavailable, and a message is displayed: "Feature unavailable offline."

### Create Data (Offline)
- **Description**: Create a new category or location in local storage.
- **Process**:
  - Client generates a UUID and stores the record in local storage with `sync_status: pendingCreate`.
  - If logged in, image selection is enabled, and images/icons are stored locally (e.g., `file://`) for later upload.
  - If not logged in, image selection is disabled, and a message is displayed: "Please log in to add or remove images."

### Update Data (Offline)
- **Description**: Update an existing category or location in local storage.
- **Process**:
  - Client updates the record in local storage with `sync_status: pendingUpdate`.
  - If logged in, image selection is enabled, and new images/icons are stored locally (e.g., `file://`) for later upload.
  - If not logged in, image selection is disabled, and a message is displayed: "Please log in to add or remove images."

### Delete Data (Offline)
- **Description**: Mark a category or location for deletion in local storage.
- **Process**:
  - Client marks the record in local storage with `sync_status: pendingDelete`.
  - Local image/icon files (e.g., `file://`) are deleted immediately to free device storage.
  - If not logged in, image selection is disabled, and a message is displayed: "Please log in to add or remove images."

---

## Synchronization Process

### When Synchronization Occurs
- **Trigger**: Synchronization occurs when:
  1. The user logs in (online).
  2. The app detects network connectivity after being offline.
  3. The user manually triggers synchronization via the Settings screen (online).
- **Process**:
  1. **Login**:
     - After login, the client sends all local records with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete` to the server using batch requests (up to 50 records per request).
     - If logged in with a different account from the previous session, the client shows a dialog: “Do you want to sync local data (X categories, Y locations) to the new account or discard it?” with “Sync” and “Discard” options.
     - If “Sync” is selected, local data is sent to the server with the new `user_id`. If “Discard” is selected, local data is cleared, and the client fetches server data for the new `user_id`.
     - For images/icons, the client uploads local files (e.g., `file://`) to Firebase Storage and updates records with the new URLs before sending to the server.
     - Server processes the requests, updates `sync_status` to `synced`, and returns updated records.
     - Client updates local storage with the returned records.
  2. **Network Available**:
     - When the app detects network connectivity, it sends all pending changes to the server using batch requests.
     - If the user is logged out (`isLoggedOut: true`), the app completes the logout by calling `FirebaseAuth.signOut()`, clearing the Firebase token, and updating `isLoggedOut: false`.
     - For images/icons, the client uploads local files and updates records with Firebase Storage URLs.
  3. **Manual Sync**:
     - Users trigger synchronization via the Settings screen, sending all pending changes to the server.
     - If sync fails, the app displays a notification: “Sync failed (X categories, Y locations). Please try again.” with a “Retry” button.
  4. **Logout**:
     - **Online**: The client attempts to sync unsynced data before logging out. If sync fails, the app displays: “You have unsynced data (X categories, Y locations). Please sync before logging out to avoid data loss.” with options “Sync and Logout” or “Cancel”.
     - **Offline**: The app displays: “You are offline. Logout will be completed when you reconnect. Data will remain saved locally and sync when you log in again.” When the app detects internet connectivity, it calls `FirebaseAuth.signOut()`, removes the Firebase token, updates `isLoggedOut: false`, and shows a notification: “Reconnected. Logout completed.”
     - Local data is not associated with any `user_id` until the next login.
  5. **Multi-Device Sync**:
     - If the user logs in on a different device with the same account, the client syncs local unsynced data with the server, which merges it with existing server data based on `updated_at`.
     - For images and icons, the server compares the URLs to avoid duplicate uploads.
  6. **Error Handling**:
     - If a sync request fails, the client retains the record’s `sync_status` and retries during the next sync attempt using exponential backoff (initial delay: 1s, max delay: 60s).
     - If image upload fails (only when logged in):
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
