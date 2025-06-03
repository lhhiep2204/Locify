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
- **Token Refresh Handling**:
  - If the token is expired, the server returns an `E005` error (Invalid or missing Firebase token).
  - Clients should use the Firebase SDK to automatically refresh tokens when online. If offline for an extended period, clients must prompt the user to log in again upon reconnection to obtain a new token.

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
  - **Constraints**:
    - `name`: Maximum 255 characters, must not be empty or null.
  - Request Body:
    ```json
    {
      "name": "John Doe"
    }
    ```
  - Response: Updated user object.
- **DELETE /users/me**
  - Description: Delete the authenticated user's account, including all associated categories, locations, and images in Firebase Storage.
  - **Process**:
    - Validates the Firebase token to ensure the request is from the authenticated user.
    - Queries the `categories` table for all `icon` URLs and the `locations` table for all `image_urls` associated with the `user_id`.
    - Deletes all identified images from Firebase Storage using the Firebase Admin SDK, processing deletions in batches for efficiency.
    - Uses database transactions to delete all records in `categories` and `locations` tables for the `user_id`, ensuring data integrity.
    - Deletes the user record from the `users` table and removes the user from Firebase Authentication.
  - Response: 204 No Content.
  - **Error Cases**:
    - Returns `E006` (Unauthorized access) if the token does not match the user ID.
    - Returns `S002` (Server error) if image deletion or database operations fail.

### Categories
- **GET /categories**
  - Description: List all categories for the authenticated user.
  - **Query Parameters**:
    - `page` (optional, default: 1): Page number for pagination.
    - `size` (optional, default: 20, max: 100): Number of records per page.
  - Response:
    ```json
    {
      "data": [
        {
          "id": "uuid",
          "user_id": "firebase_uid",
          "name": "Restaurant",
          "icon": "https://example.com/icons/restaurant.png",
          "sync_status": "synced",
          "created_at": "2025-05-31T23:15:00Z",
          "updated_at": "2025-05-31T23:15:00Z"
        }
      ],
      "meta": {
        "total_count": 20,
        "total_pages": 1,
        "page": 1,
        "size": 20
      }
    }
    ```
- **POST /categories**
  - Description: Create a new category.
  - **Constraints**:
    - `id`: Must be a valid UUID.
    - `name`: Maximum 255 characters, must not be empty or null.
    - `icon`: Must be a valid URL (if provided).
    - `sync_status`: Must be one of `synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`.
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
  - **Constraints**: Same as POST /categories.
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
  - Description: Delete a category by ID, including all associated locations and their images.
  - **Constraints**:
    - `category_id`: Must be a valid UUID.
    - If the category contains locations, a `reassign_category_id` (valid UUID) must be provided in the request body.
  - Response: 204 No Content.

### Locations
- **GET /locations**
  - Description: List all locations for the authenticated user, optionally filtered by category.
  - **Query Parameters**:
    - `category_id` (optional): Filter by category UUID.
    - `page` (optional, default: 1): Page number for pagination.
    - `size` (optional, default: 20, max: 100): Number of records per page.
  - Response:
    ```json
    {
      "data": [
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
      ],
      "meta": {
        "total_count": 400,
        "total_pages": 20,
        "page": 1,
        "size": 20
      }
    }
    ```
- **POST /locations**
  - Description: Create a new location.
  - **Constraints**:
    - `id`: Must be a valid UUID.
    - `category_id`: Must be a valid UUID and exist in `categories`.
    - `name`: Maximum 255 characters, must not be empty or null.
    - `address`: Maximum 1000 characters (optional).
    - `description`: Maximum 1000 characters (optional).
    - `latitude`: Must be between -90 and 90.
    - `longitude`: Must be between -180 and 180.
    - `image_urls`: Array of valid URLs, maximum 10 URLs.
    - `sync_status`: Must be one of `synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`.
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
  - **Constraints**: Same as POST /locations.
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
  - **Constraints**:
    - `location_id`: Must be a valid UUID.
  - Response: 204 No Content.

### Images
- **Firebase Storage Integration**:
  - **Client Operations**: Clients use the Firebase Storage SDK directly for image upload and deletion operations.
  - **Backend Operations**: The backend deletes images from Firebase Storage during user account deletion (via `DELETE /users/me`) using the Firebase Admin SDK.
  - Storage path structure: `/locations/{user_id}/{location_id}/{image_name}` for location images and `/categories/{user_id}/{category_id}/{icon_name}` for category icons.
  - **Constraints**:
    - Maximum image size: 5MB per image.
    - Maximum 10 images per location.
    - Supported formats: JPEG, PNG.
  - **Security Rules**:
    - Users can only access their own images (enforced by Firebase Security Rules).
    - Example rule:
      ```json
      rules_version = '2';
      service firebase.storage {
        match /b/{bucket}/o {
          match /locations/{userId}/{locationId}/{imageName} {
            allow read, write: if request.auth != null && request.auth.uid == userId;
          }
          match /categories/{userId}/{categoryId}/{iconName} {
            allow read, write: if request.auth != null && request.auth.uid == userId;
          }
        }
      }
      ```

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

  **Backend (Java/Spring Boot with Firebase Admin SDK)**:
  ```java
  // Example: Delete images during user deletion
  import com.google.cloud.storage.BlobId;
  import com.google.cloud.storage.Storage;
  import com.google.firebase.cloud.StorageClient;

  public void deleteUserImages(String userId) {
      Storage storage = StorageClient.getInstance().bucket().getStorage();
      
      // Query database for image URLs
      List<String> imageUrls = getImageUrlsForUser(userId); // Custom method to fetch URLs from DB
      
      // Batch delete images for efficiency
      List<BlobId> blobIds = imageUrls.stream()
          .map(url -> {
              String path = extractPathFromUrl(url); // Custom method to parse URL
              return BlobId.of("locify-123.appspot.com", path);
          })
          .collect(Collectors.toList());
      
      storage.delete(blobIds);
  }
  ```

  **Notes**:
  - Clients handle image uploads and individual deletions using Firebase Storage SDK, which supports offline persistence and automatic authentication.
  - Backend handles bulk image deletion during user account deletion to clean up Firebase Storage, using batch processing for efficiency and database transactions to ensure data integrity.
  - Provides upload/download progress monitoring, retries, and error handling for client operations.
  - Firebase Storage security rules enforce user-specific access control.
  - Download URLs are generated automatically for client uploads and stored in the database.
  - Backend ensures atomicity by performing image deletions before database record deletions within a transaction, preventing orphaned data.

---

## Synchronization
The API supports offline synchronization using the `sync_status` field (`synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`) in the `categories` and `locations` tables. Clients send the `sync_status` in requests to indicate local changes, and the server updates the `sync_status` to `synced` upon successful processing. The `updated_at` timestamp ensures the latest data is prioritized during synchronization.

- **Client Behavior**:
  - Create records locally with `pendingCreate` and a client-generated UUID.
  - Update records locally with `pendingUpdate`.
  - Mark records for deletion with `pendingDelete`.
  - When online, send all pending changes to the server for synchronization using batch requests (up to 50 records per request).
- **Server Behavior**:
  - Validates `user_id` against the Firebase token.
  - Processes pending changes in batch and updates `sync_status` to `synced`.
  - Uses `updated_at` to resolve conflicts (e.g., the record with the latest `updated_at` timestamp takes precedence).
  - Returns the updated resource with server-generated timestamps.
- **Error Handling During Synchronization**:
  - If a sync request fails (e.g., due to network issues or server error), the client retains the `sync_status` and retries with exponential backoff (initial delay: 1s, max delay: 60s).
  - If an image upload fails during sync, the client keeps the local image URLs (e.g., `file://`) and retries uploading during the next sync attempt.
  - If a conflict occurs (e.g., older `updated_at`), the server returns an `E008` error with the server's version of the record.

---

## Error Handling
The Locify API returns error responses with a custom `error` object containing a `code` and `message`. iOS and Android clients should map the `code` to user-friendly messages, while the `message` is for debugging.

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
| E005       | 401         | Invalid or missing Firebase token | Authentication token is invalid or expired |
| E006       | 403         | Unauthorized access | User not authorized for this resource |
| E007       | 404         | Resource not found | Location with ID 'uuid' not found |
| E008       | 409         | Conflict during synchronization | Record with older 'updated_at' rejected |
| S001       | 429         | Rate limit exceeded | Too many requests, try again later |
| S002       | 500         | Server error | Unexpected server error, check logs |

### Notes
- Clients should map `error.code` (HTTP status) to user-friendly messages using the `Error Code` (e.g., `E001` -> "Please enter a location name").
- `error.message` is for debugging only and should not be shown to users.
- All responses include HTTP status codes for compatibility with standard REST practices.

---

[Back to Project Overview](../README.md)
