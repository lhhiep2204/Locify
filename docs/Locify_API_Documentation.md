# Locify API Documentation

This document outlines the RESTful API endpoints for the Locify backend, built with Java/Spring Boot and integrated with Firebase Authentication for user management. The API supports user-based location and category management and synchronization for offline use. All endpoints use JSON for requests and responses and are secured with Firebase Authentication tokens.

## Table of Contents
- [Base URL](#base-url)
- [Authentication](#authentication)
- [Error Responses and Validation](#error-responses-and-validation)
- [Endpoints](#endpoints)
  - [Users](#users)
    - [Get User Profile](#get-user-profile)
    - [Update User Profile](#update-user-profile)
  - [Categories](#categories)
    - [Get All Categories](#get-all-categories)
    - [Create Category](#create-category)
    - [Update Category](#update-category)
    - [Delete Category](#delete-category)
  - [Locations](#locations)
    - [Get All Locations](#get-all-locations)
    - [Get Locations by Category](#get-locations-by-category)
    - [Create Location](#create-location)
    - [Update Location](#update-location)
    - [Delete Location](#delete-location)
- [Synchronization](#synchronization)

---

## Base URL
```
https://api.locify.com/v1
```

---

## Authentication
All endpoints require a valid Firebase Authentication token passed in the `Authorization` header as a Bearer token. The token is validated against Firebase to authenticate the user and retrieve the `user_id` (Firebase UID).

**Header Example**:
```
Authorization: Bearer <firebase_id_token>
```

---

## Error Responses and Validation
Errors are returned with appropriate HTTP status codes and a JSON body containing error details. Validation rules for API request inputs are defined below. Basic database constraints (e.g., `NOT NULL`, maximum length, foreign keys) are enforced at the database level and documented in the [Database Schema](../docs/Locify_Database_Schema.md).

### Error Response Format
```json
{
  "error": {
    "code": 400,
    "message": "Invalid request: Missing required field 'name'"
  }
}
```

**Example Error Responses**:
```json
// Invalid email format
{
  "error": {
    "code": 400,
    "message": "Invalid request: Email must be a valid format (e.g., user@example.com)"
  }
}
// Special characters in name
{
  "error": {
    "code": 400,
    "message": "Invalid request: Name cannot contain special characters (allowed: letters, numbers, spaces, hyphens, underscores)"
  }
}
// Resource not found
{
  "error": {
    "code": 404,
    "message": "Category with ID uuid not found"
  }
}
// Rate limit exceeded
{
  "error": {
    "code": 429,
    "message": "Too many requests: Rate limit of 100 requests per minute exceeded"
  }
}
```

### Validation Rules
- **Email** (e.g., `users.email`):
  - Must be a valid email format (e.g., `user@example.com`).
  - Example invalid cases:
    - Missing `@` symbol: `user.example.com` → 400 Bad Request.
    - Already exists: `user@example.com` (already registered) → 409 Conflict.
- **Name** (e.g., `users.name`, `categories.name`, `locations.name`):
  - No special characters (allowed: letters, numbers, spaces, hyphens, underscores; regex: `^[a-zA-Z0-9 _-]+$`).
  - Cannot be empty or whitespace-only.
  - Example invalid cases:
    - Contains special characters: `Cafe@123` → 400 Bad Request.
    - Empty: `""` → 400 Bad Request.
    - Whitespace-only: `"   "` → 400 Bad Request.
- **Description** (e.g., `locations.description`):
  - Optional, can be empty or null.
  - Example invalid case:
    - Exceeds database limit: `[1000+ characters]` → 400 Bad Request.
- **Latitude** (e.g., `locations.latitude`):
  - Must be a valid number between -90 and 90.
  - Example invalid cases:
    - Out of range: `91` → 400 Bad Request.
    - Non-numeric: `abc` → 400 Bad Request.
- **Longitude** (e.g., `locations.longitude`):
  - Must be a valid number between -180 and 180.
  - Example invalid cases:
    - Out of range: `181` → 400 Bad Request.
    - Non-numeric: `abc` → 400 Bad Request.
- **Category ID** (e.g., `locations.category_id`, `reassign_category_id`):
  - Must be a valid UUID.
  - Must exist in the `categories` table and belong to the authenticated user.
  - Example invalid cases:
    - Invalid UUID: `invalid-uuid` → 400 Bad Request.
    - Non-existent or unauthorized: `uuid` (not found or belongs to another user) → 404 Not Found or 403 Forbidden.
- **Sync Status** (e.g., `categories.sync_status`, `locations.sync_status`):
  - Must be one of: `synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`.
  - Example invalid case:
    - Invalid value: `invalidStatus` → 400 Bad Request.

### Common Status Codes
- **4xx Client Errors**:
  - `400 Bad Request`: Invalid request data, such as:
    - Missing required fields (e.g., `name`, `email`, `latitude`, `longitude`, `category_id`).
    - Invalid field formats (e.g., email, UUID, latitude/longitude out of range, special characters in `name` or `subject`).
    - Invalid or unsupported `sync_status` values.
  - `401 Unauthorized`: Missing or invalid Firebase Authentication token.
  - `403 Forbidden`: User lacks permission to access the resource (e.g., attempting to access another user's category or location).
  - `404 Not Found`: Resource not found (e.g., category or location ID does not exist).
  - `409 Conflict`: Resource already exists (e.g., email already registered, duplicate category name for a user).
  - `429 Too Many Requests`: Rate limit exceeded for the user or endpoint (e.g., exceeding 100 requests per minute per user).
- **5xx Server Errors**:
  - `500 Internal Server Error`: Unexpected server error (e.g., database failure, unhandled exception).
  - `502 Bad Gateway`: Issue with upstream services (e.g., Firebase Authentication service unavailable).
  - `503 Service Unavailable`: Server temporarily down (e.g., during maintenance).
  - `504 Gateway Timeout`: Upstream service (e.g., Firebase) timed out.

### Rate Limiting
To ensure fair usage, the API enforces a rate limit of 100 requests per minute per user for all endpoints. Exceeding this limit returns a `429 Too Many Requests` error. Clients should implement exponential backoff for retries.

---

## Endpoints

### Users

#### Get User Profile
Retrieve the authenticated user's profile information.

- **Method**: GET
- **Endpoint**: `/users/me`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**: None
- **Response**:
  - **Status**: 200 OK
  - **Body**:
    ```json
    {
      "id": "firebase_uid",
      "email": "user@example.com",
      "name": "John Doe",
      "created_at": "2025-05-29T14:30:00Z",
      "updated_at": "2025-05-29T15:00:00Z"
    }
    ```

#### Update User Profile
Update the authenticated user's profile information (e.g., name).

- **Method**: PUT
- **Endpoint**: `/users/me`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**:
  ```json
  {
    "name": "John Doe"
  }
  ```
- **Response**:
  - **Status**: 200 OK
  - **Body**:
    ```json
    {
      "id": "firebase_uid",
      "email": "user@example.com",
      "name": "John Doe",
      "created_at": "2025-05-29T14:30:00Z",
      "updated_at": "2025-05-29T15:00:00Z"
    }
    ```

### Categories

#### Get All Categories
Retrieve all categories for the authenticated user.

- **Method**: GET
- **Endpoint**: `/categories`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**: None
- **Response**:
  - **Status**: 200 OK
  - **Body**:
    ```json
    [
      {
        "id": "uuid",
        "user_id": "firebase_uid",
        "name": "Restaurant",
        "sync_status": "synced",
        "created_at": "2025-05-29T14:30:00Z",
        "updated_at": "2025-05-29T14:30:00Z"
      },
      {
        "id": "uuid",
        "user_id": "firebase_uid",
        "name": "Favorites",
        "sync_status": "pendingUpdate",
        "created_at": "2025-05-29T14:35:00Z",
        "updated_at": "2025-05-29T15:00:00Z"
      }
    ]
    ```

#### Create Category
Create a new category for the authenticated user.

- **Method**: POST
- **Endpoint**: `/categories`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**:
  ```json
  {
    "id": "client-generated-uuid",
    "name": "Cafe",
    "sync_status": "pendingCreate"
  }
  ```
- **Response**:
  - **Status**: 201 Created
  - **Body**:
    ```json
    {
      "id": "uuid",
      "user_id": "firebase_uid",
      "name": "Cafe",
      "sync_status": "synced",
      "created_at": "2025-05-29T14:30:00Z",
      "updated_at": "2025-05-29T14:30:00Z"
    }
    ```

#### Update Category
Update an existing category's name.

- **Method**: PUT
- **Endpoint**: `/categories/{category_id}`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**:
  ```json
  {
    "name": "Updated Cafe",
    "sync_status": "pendingUpdate"
  }
  ```
- **Response**:
  - **Status**: 200 OK
  - **Body**:
    ```json
    {
      "id": "uuid",
      "user_id": "firebase_uid",
      "name": "Updated Cafe",
      "sync_status": "synced",
      "created_at": "2025-05-29T14:30:00Z",
      "updated_at": "2025-05-29T15:00:00Z"
    }
    ```

#### Delete Category
Delete a category. If the category contains locations, the client must reassign them to another category.

- **Method**: DELETE
- **Endpoint**: `/categories/{category_id}`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**:
  ```json
  {
    "reassign_category_id": "uuid"
  }
  ```
- **Response**:
  - **Status**: 204 No Content
  - **Body**: None

### Locations

#### Get All Locations
Retrieve all locations for the authenticated user.

- **Method**: GET
- **Endpoint**: `/locations`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**: None
- **Response**:
  - **Status**: 200 OK
  - **Body**:
    ```json
    [
      {
        "id": "uuid",
        "user_id": "firebase_uid",
        "category_id": "uuid",
        "name": "Coffee Shop",
        "address": "123 Main St",
        "description": "Great coffee place",
        "latitude": 37.7749,
        "longitude": -122.4194,
        "is_favorite": true,
        "sync_status": "synced",
        "created_at": "2025-05-29T14:30:00Z",
        "updated_at": "2025-05-29T14:30:00Z"
      }
    ]
    ```

#### Get Locations by Category
Retrieve all locations for a specific category.

- **Method**: GET
- **Endpoint**: `/locations?category_id={category_id}`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**: None
- **Response**:
  - **Status**: 200 OK
  - **Body**:
    ```json
    [
      {
        "id": "uuid",
        "user_id": "firebase_uid",
        "category_id": "uuid",
        "name": "Coffee Shop",
        "address": "123 Main St",
        "description": "Great coffee place",
        "latitude": 37.7749,
        "longitude": -122.4194,
        "is_favorite": true,
        "sync_status": "synced",
        "created_at": "2025-05-29T14:30:00Z",
        "updated_at": "2025-05-29T14:30:00Z"
      }
    ]
    ```

#### Create Location
Create a new location for the authenticated user.

- **Method**: POST
- **Endpoint**: `/locations`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**:
  ```json
  {
    "id": "client-generated-uuid",
    "category_id": "uuid",
    "name": "Coffee Shop",
    "address": "123 Main St",
    "description": "Great coffee place",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "is_favorite": true,
    "sync_status": "pendingCreate"
  }
  ```
- **Response**:
  - **Status**: 201 Created
  - **Body**:
    ```json
    {
      "id": "uuid",
      "user_id": "firebase_uid",
      "category_id": "uuid",
      "name": "Coffee Shop",
      "address": "123 Main St",
      "description": "Great coffee place",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "is_favorite": true,
      "sync_status": "synced",
      "created_at": "2025-05-29T14:30:00Z",
      "updated_at": "2025-05-29T14:30:00Z"
    }
    ```

#### Update Location
Update an existing location's details.

- **Method**: PUT
- **Endpoint**: `/locations/{location_id}`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**:
  ```json
  {
    "category_id": "uuid",
    "name": "Updated Coffee Shop",
    "address": "123 Main St",
    "description": "Updated description",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "is_favorite": false,
    "sync_status": "pendingUpdate"
  }
  ```
- **Response**:
  - **Status**: 200 OK
  - **Body**:
    ```json
    {
      "id": "uuid",
      "user_id": "firebase_uid",
      "category_id": "uuid",
      "name": "Updated Coffee Shop",
      "address": "123 Main St",
      "description": "Updated description",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "is_favorite": false,
      "sync_status": "synced",
      "created_at": "2025-05-29T14:30:00Z",
      "updated_at": "2025-05-29T15:00:00Z"
    }
    ```

#### Delete Location
Delete a location.

- **Method**: DELETE
- **Endpoint**: `/locations/{location_id}`
- **Request Headers**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- **Request Body**: None
- **Response**:
  - **Status**: 204 No Content
  - **Body**: None

---

## Synchronization
The API supports offline synchronization using the `sync_status` field (`synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`) in the `categories` and `locations` tables. Clients send the `sync_status` in requests to indicate local changes, and the server updates the `sync_status` to `synced` upon successful processing. The `updated_at` timestamp ensures the latest data is prioritized during synchronization.

- **Client Behavior**:
  - Create records locally with `pendingCreate` and a client-generated UUID.
  - Update records locally with `pendingUpdate`.
  - Mark records for deletion with `pendingDelete`.
  - When online, send all pending changes to the server for synchronization.
- **Server Behavior**:
  - Validates `user_id` against the Firebase token.
  - Processes pending changes and updates `sync_status` to `synced`.
  - Uses `updated_at` to resolve conflicts (e.g., the record with the latest `updated_at` timestamp takes precedence).
  - Returns the updated resource with server-generated timestamps.

---

[Back to Project Overview](../README.md)
