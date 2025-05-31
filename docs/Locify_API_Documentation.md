# Locify API Documentation

This document outlines the RESTful API endpoints for the Locify backend, built with Java/Spring Boot and integrated with Firebase Authentication for user management. The API supports user-based location and category management for saving planned or memorable locations, with synchronization for offline use.

---

## Table of Contents
- [Base URL](#base-url)
- [Authentication](#authentication)
- [Endpoints](#endpoints)
  - [Users](#users)
  - [Categories](#categories)
  - [Locations](#locations)
  - [Images](#images)
- [Synchronization](#synchronization)
- [Error Handling](#error-handling)
  - [Error Response Format](#error-response-format)
  - [Error Codes](#error-codes)
  - [Notes](#notes)

---

## Base URL
`https://api.locify.com/v1`

---

## Authentication
- All endpoints require a Firebase ID token in the `Authorization` header:
  ```
  Authorization: Bearer <firebase_id_token>
  ```
- Tokens are validated server-side using Firebase Authentication.

---

## Endpoints

### Users
- **GET /users/me**
  - Description: Retrieve the authenticated user's profile.
  - Response: 
    ```json
    {
      "id": "firebase_uid",
      "email": "user@example.com",
      "name": "John Doe",
      "created_at": "2025-05-31T23:15:00Z",
      "updated_at": "2025-05-31T23:15:00Z"
    }
    ```
- **PUT /users/me**
  - Description: Update the authenticated user's profile.
  - Request Body:
    ```json
    {
      "name": "John Doe"
    }
    ```
  - Response: Updated user object.

### Categories
- **GET /categories**
  - Description: List all categories for the authenticated user.
  - Query Parameters: None
  - Response:
    ```json
    [
      {
        "id": "uuid",
        "user_id": "firebase_uid",
        "name": "Restaurant",
        "icon": "https://example.com/icons/restaurant.png",
        "sync_status": "synced",
        "created_at": "2025-05-31T23:15:00Z",
        "updated_at": "2025-05-31T23:15:00Z"
      }
    ]
    ```
- **POST /categories**
  - Description: Create a new category.
  - Request Body:
    ```json
    {
      "id": "client-generated-uuid",
      "name": "Cafe",
      "icon": "https://example.com/icons/cafe.png",
      "sync_status": "pendingCreate"
    }
    ```
  - Response: Created category object.
- **PUT /categories**
  - Description: Update an existing category.
  - Request Body:
    ```json
    {
      "id": "uuid",
      "name": "Coffee Shop",
      "icon": "https://example.com/icons/coffee.png",
      "sync_status": "pendingUpdate"
    }
    ```
  - Response: Updated category object.
- **DELETE /categories/{category_id}**
  - Description: Delete a category by ID.
  - Response: 204 No Content.

### Locations
- **GET /locations**
  - Description: List all locations for the authenticated user, optionally filtered by category.
  - Query Parameters: `category_id` (optional)
  - Response:
    ```json
    [
      {
        "id": "uuid",
        "user_id": "firebase_uid",
        "category_id": "uuid",
        "name": "Coffee Shop",
        "address": "123 Main St",
        "description": "Great coffee",
        "latitude": 37.7749,
        "longitude": -122.4194,
        "is_favorite": true,
        "image_urls": [
          "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Fuser_123%2Flocation_456%2Fimage_1.jpg",
          "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Fuser_123%2Flocation_456%2Fimage_2.jpg"
        ],
        "sync_status": "synced",
        "created_at": "2025-05-31T23:15:00Z",
        "updated_at": "2025-05-31T23:15:00Z"
      }
    ]
    ```
- **POST /locations**
  - Description: Create a new location.
  - Request Body:
    ```json
    {
      "id": "client-generated-uuid",
      "category_id": "uuid",
      "name": "Coffee Shop",
      "address": "123 Main St",
      "description": "Great coffee",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "is_favorite": true,
      "image_urls": [
        "https://example.com/images/coffee-shop-1.jpg",
        "https://example.com/images/coffee-shop-2.jpg"
      ],
      "sync_status": "pendingCreate"
    }
    ```
  - Response: Created location object.
- **PUT /locations**
  - Description: Update an existing location.
  - Request Body:
    ```json
    {
      "id": "uuid",
      "category_id": "uuid",
      "name": "Coffee Shop",
      "address": "123 Main St",
      "description": "Great coffee",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "is_favorite": true,
      "image_urls": [
        "https://example.com/images/coffee-shop-1.jpg",
        "https://example.com/images/coffee-shop-2.jpg"
      ],
      "sync_status": "pendingUpdate"
    }
    ```
  - Response: Updated location object.
- **DELETE /locations/{location_id}**
  - Description: Delete a location by ID.
  - Response: 204 No Content.

### Images
- **Firebase Storage Integration**:
  - Use Firebase Storage SDK directly for image operations
  - Storage path structure: `/locations/{user_id}/{location_id}/{image_name}`
  - Security rules ensure users can only access their own images

  **iOS (SwiftUI)**:
  ```swift
  // Upload image
  let storageRef = Storage.storage().reference()
  let imageRef = storageRef.child("locations/\(userId)/\(locationId)/\(imageName)")
  
  // Upload from UIImage
  if let imageData = image.jpegData(compressionQuality: 0.8) {
      let metadata = StorageMetadata()
      metadata.contentType = "image/jpeg"
      
      imageRef.putData(imageData, metadata: metadata) { metadata, error in
          if let error = error {
              print("Upload failed: \(error)")
              return
          }
          // Get download URL
          imageRef.downloadURL { url, error in
              if let downloadURL = url {
                  // Use downloadURL in your location data
              }
          }
      }
  }
  
  // Delete image
  imageRef.delete { error in
      if let error = error {
          print("Delete failed: \(error)")
      }
  }
  ```

  **Android (Kotlin)**:
  ```kotlin
  // Upload image
  val storageRef = FirebaseStorage.getInstance().reference
  val imageRef = storageRef.child("locations/$userId/$locationId/$imageName")
  
  // Upload from File
  val uploadTask = imageRef.putFile(imageUri)
      .addOnSuccessListener {
          // Get download URL
          imageRef.downloadUrl.addOnSuccessListener { uri ->
              // Use uri in your location data
          }
      }
      .addOnFailureListener { e ->
          // Handle failure
      }
  
  // Delete image
  imageRef.delete()
      .addOnSuccessListener {
          // Deletion successful
      }
      .addOnFailureListener { e ->
          // Handle failure
      }
  ```

  **Notes**:
  - Firebase Storage SDK handles authentication automatically.
  - Supports offline persistence.
  - Provides upload/download progress monitoring.
  - Handles retries and error cases.
  - Manages security rules and access control.
  - Generates download URLs automatically.

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

## Error Handling
The Locify API returns error responses with a custom `error` object containing a `code` and `message`. Clients (iOS/Android) should map the `code` to user-friendly messages for display, while the `message` is designed for debugging.

### Error Response Format
```json
{
  "error": {
    "code": "E001",
    "message": "Field 'name' is empty or null"
  }
}
```
- **code**: Custom error code (e.g., `E001`, `S001`). Prefix `E` for client-side errors (input, auth, not found), `S` for server-side errors (rate limit, server error).
- **message**: Technical message for debugging (not for user display).

### Error Codes
| Error Code | HTTP Status | Description | Example Error Message |
|------------|-------------|-------------|-----------------------|
| E001       | 400         | Invalid input data | Field 'name' is empty or null |
| E002       | 400         | Invalid UUID format | 'category_id' is not a valid UUID |
| E003       | 400         | Invalid coordinates | 'latitude' must be between -90 and 90 |
| E004       | 400         | Missing required field | 'user_id' is required |
| E005       | 401         | Invalid or missing Firebase token | Authentication token is invalid |
| E006       | 403         | Unauthorized access | User not authorized for this resource |
| E007       | 404         | Resource not found | Location with ID 'uuid' not found |
| S001       | 429         | Rate limit exceeded | Too many requests, try again later |
| S002       | 500         | Server error | Unexpected server error, check logs |

### Notes
- Clients should map `error.code` (HTTP status) to user-friendly messages using the `Error Code` (e.g., `E001` -> "Please enter a location name").
- `error.message` is for debugging only and should not be shown to users.
- All responses include HTTP status codes for compatibility with standard REST practices.

---

[Back to Project Overview](../README.md)
