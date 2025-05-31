# Locify Data Synchronization Flow

This document describes the data flow and synchronization mechanisms for the Locify application, supporting online and offline functionality for saving and managing locations for planned visits or memorable places without requiring login.

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
  - [Conflict Resolution](#conflict-resolution)

---

## Overview
Locify allows users to manage locations and categories in both online and offline modes without requiring login. The client uses local storage to cache data and supports offline operations. When not logged in, even if online, the app retrieves category and location data from local storage, but other online features (e.g., search, share, feedback) function normally. Data synchronization occurs after login to ensure consistency between local storage and the backend server under the logged-in user's account. The `sync_status` field (`synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`) in the `categories` and `locations` tables tracks changes for synchronization.

- **Online Mode (No Login)**: The client performs operations on local storage for adding, editing, or deleting categories/locations, retrieving data locally even when online. Other online features (e.g., search, share, feedback) operate normally without requiring login. No server interaction occurs for category/location data until login.  
- **Online Mode (Logged In)**: The client interacts directly with the backend API to fetch, create, update, or delete category/location data. Successful API calls update local storage to maintain consistency. Other online features continue to function normally.  
- **Offline Mode**: The client performs operations on local storage, marking changes with appropriate `sync_status` values for later synchronization. Online-only features (e.g., search, share, feedback) are unavailable.  
- **Synchronization**: After login, the client sends all pending local changes to the server, which processes them under the logged-in user's account and updates `sync_status` to `synced`. After logout, local data (including unsynced data) is retained for future synchronization.

---

## Online Data Flow
### Get Data (Online)
- **Description**: Fetch all categories or locations for the authenticated user (after login). If not logged in, even when online, retrieve data from local storage.  
- **Process**:
  1. If the user is logged in:
     - Client sends a GET request to the appropriate endpoint with the Firebase `Authorization` token for category/location data.  
     - Server validates the token and returns the requested data.  
     - Client updates local storage with the received data, overwriting existing records based on `id` and setting `sync_status` to `synced`.  
  2. If the user is not logged in (online or offline):
     - Client queries local storage for categories or locations (not tied to a user ID).  
     - Client displays all records, including those with `sync_status` of `pendingCreate`, `pendingUpdate`, or `pendingDelete`.  
     - No API calls are made.  
  3. Other online features (e.g., search, share, feedback) operate normally when online, regardless of login status, using MapKit (iOS) or Google Maps (Android) for search/navigation and system sharing mechanisms for sharing.

### Create Data (Online)
- **Description**: Create a new category or location (after login). If not logged in, store locally even when online.  
- **Process**:
  1. If the user is logged in:
     - Client generates a UUID for the new record and sends a POST request with `sync_status: pendingCreate`.  
     - For categories, includes basic info (name, icon) and sync status.
     - For locations, includes all location details (name, address, coordinates, etc.).
     - Server validates the request and creates the record under the logged-in user's account.  
     - Server returns the created resource with `sync_status: synced` and server-generated timestamps.  
     - Client updates local storage with the server response.  
  2. If the user is not logged in (online or offline):
     - Client generates a UUID for the new record and stores it in local storage with `sync_status: pendingCreate`.  
     - For categories, stores name, icon, and sync status locally.
     - For locations, stores all location details locally.
     - Record is immediately available for viewing/editing in the app.  
     - When the user logs in and goes online, the client synchronizes the record with the server under the logged-in user's account.  

### Update Data (Online)
- **Description**: Update an existing category or location (after login). If not logged in, store locally even when online.  
- **Process**:
  1. If the user is logged in:
     - Client sends a PUT request with updated fields and `sync_status: pendingUpdate`.  
     - For categories, can update name and icon.
     - For locations, can update any location details.
     - Server validates the request and updates the record, setting `sync_status: synced` and updating `updated_at`.  
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
  3. No API calls are made.  

### Create Data (Offline)
- **Description**: Create a new category or location while offline or not logged in.  
- **Process**:
  1. Client generates a UUID for the new record and stores it in local storage with `sync_status: pendingCreate`.  
  2. Record is immediately available for viewing/editing in the app.  
  3. When the user logs in and goes online, the client synchronizes the record with the server under the logged-in user's account.  

### Update Data (Offline)
- **Description**: Update an existing category or location while offline or not logged in.  
- **Process**:
  1. Client updates the record in local storage and sets `sync_status: pendingUpdate`.  
  2. Updated record is reflected in the app immediately.  
  3. When the user logs in and goes online, the client synchronizes the record with the server under the logged-in user's account.  

### Delete Data (Offline)
- **Description**: Delete a category or location while offline or not logged in.  
- **Process**:
  1. Client marks the record in local storage with `sync_status: pendingDelete`.  
  2. The app hides the record from the UI but retains it in local storage for synchronization.  
  3. When the user logs in and goes online, the client synchronizes the deletion with the server under the logged-in user's account.  

---

## Synchronization Process
### When Synchronization Occurs
- **Trigger**: Synchronization occurs automatically when the client detects internet connectivity and the user logs in.  
- **Process**:
  1. **After Login**:
     - If the user logs in with a new account (different from the previous session), the app prompts the user to confirm whether to sync local data (with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete`) to the new account or discard it.  
     - If the user chooses to sync, the client assigns the logged-in user's Firebase UID to all local records without a `user_id`.  
     - If the user chooses to discard, the client deletes all local records with `sync_status: pendingCreate`, `pendingUpdate`, or `pendingDelete` from local storage.  
     - If syncing is confirmed, the client collects all records from local storage with `sync_status` of `pendingCreate`, `pendingUpdate`, or `pendingDelete`.  
     - Client sends these records to the server in sequence:  
       - **Create**: 
         - For locations with images: First upload images to storage service, then POST request with the logged-in user's `user_id` and image URLs.
         - For categories with icons: First upload icon to storage service, then POST request with the logged-in user's `user_id` and icon URL.
         - For records without images/icons: POST request with the logged-in user's `user_id`.
       - **Update**: 
         - For locations with new images: First upload new images to storage service, then PUT request with the logged-in user's `user_id` and updated image URLs.
         - For categories with new icons: First upload new icon to storage service, then PUT request with the logged-in user's `user_id` and updated icon URL.
         - For records without image changes: PUT request with the logged-in user's `user_id`.
       - **Delete**: 
         - For locations with images: First DELETE request with the logged-in user's `user_id`, then delete images from storage service.
         - For categories with icons: First DELETE request with the logged-in user's `user_id`, then delete icon from storage service.
         - For records without images/icons: DELETE request with the logged-in user's `user_id`.
     - Server processes each request, validates the `user_id` against the Firebase token, and updates `sync_status` to `synced`.  
     - Server returns updated records (or success status for deletions).  
     - Client updates local storage with server responses, associating records with the logged-in user's `user_id`.  
  2. **After Logout**:
     - When the user logs out, all local data (with `sync_status: synced`, `pendingCreate`, `pendingUpdate`, or `pendingDelete`) remains in local storage.  
     - These records are not associated with any `user_id` until the next login.  
     - The app displays a warning about unsynced data when the user logs out, encouraging them to sync before logging out.  
  3. **Multi-Device Sync**:
     - If the user logs in on a different device with the same account, the client syncs local unsynced data with the server, which merges it with existing server data based on `updated_at`.  
     - For images and icons, the server compares the URLs to avoid duplicate uploads.  
  4. **Error Handling**:
     - If a sync request fails, the client retains the record's `sync_status` and retries during the next sync attempt.  
     - If image upload fails:
       - The client keeps the local image URLs in the record.
       - The record's data remains in local storage with the original `sync_status`.
       - During the next sync attempt, the client will:
         1. Check if any image URLs are local URLs (e.g., starting with "file://" or "content://").
         2. If local URLs are found, attempt to upload these images first.
         3. After successful upload, update the record with the new remote URLs.
         4. Proceed with the API request using the updated URLs.
     - Clients implement exponential backoff for retries.  

### Conflict Resolution
- **Mechanism**: The server uses the `updated_at` timestamp to resolve conflicts. The record with the latest `updated_at` takes precedence.  
- **Process**:
  1. If a client submits a record with an older `updated_at` than the server's version, the server rejects the update with a conflict error.  
  2. Client updates local storage with the server's version, including image URLs.  
  3. If the user logs in with a different account and syncs local data, the server treats local records as new if no matching `id` exists, or resolves conflicts using `updated_at` if there are overlaps.
  4. For image conflicts:
     - If both versions have different images, the server keeps the images from the version with the latest `updated_at`.
     - If one version has images and the other doesn't, the server keeps the images if the version with images has the latest `updated_at`.

---

[Back to Project Overview](../README.md)
