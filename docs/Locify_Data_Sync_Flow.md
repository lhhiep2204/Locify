# Locify Data Synchronization Flow

This document describes the data flow and synchronization mechanisms for the Locify application, supporting online and offline functionality for managing user locations and categories. It details how the client (iOS/Android) interacts with the backend API and local storage, how data is synchronized, and how conflicts are resolved.

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
- [Data Flow Diagram](#data-flow-diagram)

---

## Overview
Locify allows users to manage locations and categories in both online and offline modes. The client uses local storage to cache data and supports offline operations. Data synchronization ensures consistency between local storage and the backend server when the client reconnects to the internet. The `sync_status` field (`synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`) in the `categories` and `locations` tables tracks changes for synchronization.

- **Online Mode**: The client interacts directly with the backend API to fetch, create, update, or delete data. Successful API calls update local storage to maintain consistency.
- **Offline Mode**: The client performs operations on local storage, marking changes with appropriate `sync_status` values for later synchronization.
- **Synchronization**: When the client regains internet connectivity, it sends pending changes to the server, which processes them and updates `sync_status` to `synced`.

---

## Online Data Flow

### Get Data (Online)
- **Description**: Fetch all categories or locations for the authenticated user.
- **Process**:
  1. Client sends a GET request to the appropriate endpoint with the Firebase `Authorization` token.
  2. Server validates the token and returns the requested data.
  3. Client updates local storage with the received data, overwriting existing records based on `id` and setting `sync_status` to `synced`.
  4. If the request fails, the client falls back to local storage.

### Create Data (Online)
- **Description**: Create a new category or location.
- **Process**:
  1. Client generates a UUID for the new record and sends a POST request with `sync_status: pendingCreate`.
  2. Server validates the request and creates the record.
  3. Server returns the created resource with `sync_status: synced` and server-generated timestamps.
  4. Client updates local storage with the server response.
  5. If the request fails, the client retains the record in local storage with `sync_status: pendingCreate` for later synchronization.

### Update Data (Online)
- **Description**: Update an existing category or location.
- **Process**:
  1. Client sends a PUT request with updated fields and `sync_status: pendingUpdate`.
  2. Server validates the request and updates the record, setting `sync_status: synced` and updating `updated_at`.
  3. Server returns the updated resource.
  4. Client updates local storage with the server response.
  5. If the request fails, the client retains the updated record in local storage with `sync_status: pendingUpdate` for later synchronization.

### Delete Data (Online)
- **Description**: Delete a category or location.
- **Process**:
  1. Client sends a DELETE request. For categories with locations, include `reassign_category_id` in the request body.
  2. Server validates the request and deletes the record (or reassigns locations for categories).
  3. Server responds with a success status.
  4. Client removes the record from local storage.
  5. If the request fails, the client marks the record in local storage with `sync_status: pendingDelete` for later synchronization.

---

## Offline Data Flow

### Get Data (Offline)
- **Description**: Fetch categories or locations from local storage when offline.
- **Process**:
  1. Client queries local storage for categories or locations associated with the authenticated user.
  2. Client displays all records, including those with `sync_status` of `pendingCreate`, `pendingUpdate`, or `pendingDelete`.
  3. No API calls are made.

### Create Data (Offline)
- **Description**: Create a new category or location while offline.
- **Process**:
  1. Client generates a UUID for the new record and stores it in local storage with `sync_status: pendingCreate`.
  2. Record is immediately available for viewing/editing in the app.
  3. When online, the client synchronizes the record.

### Update Data (Offline)
- **Description**: Update an existing category or location while offline.
- **Process**:
  1. Client updates the record in local storage and sets `sync_status: pendingUpdate`.
  2. Updated record is reflected in the app immediately.
  3. When online, the client synchronizes the record.

### Delete Data (Offline)
- **Description**: Delete a category or location while offline.
- **Process**:
  1. Client marks the record in local storage with `sync_status: pendingDelete`.
  2. The app hides the record from the UI but retains it in local storage for synchronization.
  3. When online, the client synchronizes the deletion.

---

## Synchronization Process

### When Synchronization Occurs
- **Trigger**: Synchronization occurs automatically when the client detects internet connectivity.
- **Process**:
  1. Client collects all records from local storage with `sync_status` of `pendingCreate`, `pendingUpdate`, or `pendingDelete`.
  2. Client sends these records to the server in sequence:
     - **Create**: POST requests.
     - **Update**: PUT requests.
     - **Delete**: DELETE requests.
  3. Server processes each request, validates the `user_id` against the Firebase token, and updates `sync_status` to `synced`.
  4. Server returns updated records (or success status for deletions).
  5. Client updates local storage with server responses.
- **Error Handling**:
  - If a sync request fails, the client retains the record’s `sync_status` and retries during the next sync attempt.
  - Clients implement exponential backoff for retries.

### Conflict Resolution
- **Mechanism**: The server uses the `updated_at` timestamp to resolve conflicts. The record with the latest `updated_at` takes precedence.
- **Process**:
  1. If a client submits a record with an older `updated_at` than the server’s version, the server rejects the update with a conflict error.
  2. Client updates local storage with the server’s version.

---

## Data Flow Diagram
The following diagram illustrates the online and offline data flows:

- **Online**: Client sends API requests to Server, which updates Database; response updates Local Storage with `sync_status: synced`.
```text
   +--------+    API Request     +--------+             +----------+
   | Client | -----------------> | Server | ----------> | Database |
   +--------+                    +--------+             +----------+
        |        API Response        |
        +----------------------------+
        |
        v
+---------------+
| Local Storage | (sync_status: synced)
+---------------+
```

- **Offline**: Client stores changes in Local Storage with `sync_status: pendingCreate/pendingUpdate/pendingDelete`. When online, pending changes are synced with Server, updating Local Storage.
```text
+--------+    Local Changes Stored in     +---------------+
| Client | -----------------------------> | Local Storage |
+--------+                                +---------------+
                        (sync_status: pendingCreate / pendingUpdate / pendingDelete)

When Online:
+---------------+    Sync Pending Changes     +--------+      Update
| Local Storage | --------------------------> | Server | ----------------+
+---------------+                             +--------+                 |
                                                                         v
                                                                 +---------------+
                                                                 | Local Storage |
                                                                 +---------------+
```

---

[Back to Project Overview](../README.md)
