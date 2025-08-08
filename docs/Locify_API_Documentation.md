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

## Base URL
The base URL for all API endpoints is:

```
https://api.locify.com/v1
```

All endpoints require authentication via Firebase Authentication, and requests must include a valid Firebase ID token in the `Authorization` header as a Bearer token.

## Authentication
Locify uses **Firebase Authentication** for user authentication. Clients must include a valid Firebase ID token in every request.

- **Header Format**:
  ```
  Authorization: Bearer <firebase_id_token>
  ```

- **Token Acquisition**:
  - Clients obtain the Firebase ID token using Firebase Authentication SDKs on iOS (Swift), Android (Kotlin), or web (JavaScript).
  - The token is refreshed automatically by the Firebase SDK when it expires (typically after 1 hour).

- **Server-Side Validation**:
  - The backend verifies the Firebase ID token using the Firebase Admin SDK to authenticate the user and extract the `user_id` (Firebase UID).
  - If the token is invalid or expired, the server returns an `E006` error (Unauthorized access).

- **Example Client Code**:
  **iOS (Swift)**:
  ```swift
  import FirebaseAuth

  Auth.auth().currentUser?.getIDToken { token, error in
      if let error = error {
          print("Failed to get token: \(error)")
          return
      }
      guard let token = token else { return }
      let headers = ["Authorization": "Bearer \(token)"]
      // Use headers in API requests
  }
  ```

  **Android (Kotlin)**:
  ```kotlin
  import com.google.firebase.auth.FirebaseAuth

  FirebaseAuth.getInstance().currentUser?.getIdToken(true)?.addOnCompleteListener { task ->
      if (task.isSuccessful) {
          val token = task.result?.token
          // Use token in API requests
          val headers = mapOf("Authorization" to "Bearer $token")
      } else {
          // Handle error
      }
  }
  ```

  **Web (JavaScript)**:
  ```javascript
  import { getAuth } from "firebase/auth";

  const auth = getAuth();
  auth.currentUser.getIdToken(/* forceRefresh */ true)
      .then(token => {
          const headers = { Authorization: `Bearer ${token}` };
          // Use headers in API requests
      })
      .catch(error => {
          console.error("Error fetching token:", error);
      });
  ```

## Endpoints

### Users
- **GET /users/{user_id}**
  - Description: Retrieve a user’s profile by their ID (Firebase UID).
  - **Path Parameters**:
    - `user_id` (required): The Firebase UID of the user to retrieve.
  - **Constraints**:
    - Requires a valid Firebase ID token.
    - The `user_id` must exist in the `users` table.
  - Response:
    ```json
    {
      "id": "firebase_uid_1",
      "email": "userABC@gmail.com",
      "name": "User ABC",
      "avatar_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_1%2Fprofile.jpg",
      "created_at": "2025-05-31T23:15:00Z",
      "updated_at": "2025-05-31T23:15:00Z"
    }
    ```
  - **Error Cases**:
    - Returns `E005` (Invalid or missing Firebase token) if the token is invalid or missing.
    - Returns `E006` (Unauthorized access) if the user is not authenticated.
    - Returns `E007` (Resource not found) if the `user_id` does not exist.

- **GET /users/search**
  - Description: Search for users by name, email, or ID, returning a list of matching users.
  - **Query Parameters**:
    - `query` (required): Search term for partial matching on `name` or `email`, or exact matching on `id` (Firebase UID). Minimum 3 characters.
    - `page` (optional, default: 1): Page number for pagination.
    - `size` (optional, default: 20, max: 100): Number of records per page.
  - **Constraints**:
    - `query`: Must be at least 3 characters, case-insensitive for `name` and `email`.
    - Requires a valid Firebase ID token.
  - Response:
    ```json
    {
      "data": [
        {
          "id": "firebase_uid_1",
          "email": "userABC@gmail.com",
          "name": "User ABC",
          "avatar_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_1%2Fprofile.jpg",
          "created_at": "2025-05-31T23:15:00Z",
          "updated_at": "2025-05-31T23:15:00Z"
        },
        {
          "id": "firebase_uid_2",
          "email": "userAB@gmail.com",
          "name": "User AB",
          "avatar_url": null,
          "created_at": "2025-05-31T23:16:00Z",
          "updated_at": "2025-05-31T23:16:00Z"
        }
      ],
      "meta": {
        "total_count": 2,
        "total_pages": 1,
        "page": 1,
        "size": 20
      }
    }
    ```
  - **Error Cases**:
    - Returns `E001` (Invalid input data) if `query` is less than 3 characters.
    - Returns `E005` (Invalid or missing Firebase token) if the token is invalid or missing.
    - Returns `E006` (Unauthorized access) if the user is not authenticated.

- **GET /users/me**
  - Description: Retrieve the authenticated user's profile.
  - Response: 
    ```json
    {
      "id": "firebase_uid",
      "email": "user@example.com",
      "name": "John Doe",
      "avatar_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid%2Fprofile.jpg",
      "created_at": "2025-05-31T23:15:00Z",
      "updated_at": "2025-05-31T23:15:00Z"
    }
    ```
  - **Error Cases**:
    - Returns `E005` (Invalid or missing Firebase token) if the token is invalid or missing.
    - Returns `E006` (Unauthorized access) if the user is not authenticated.

- **PUT /users/me**
  - Description: Update the authenticated user's profile.
  - **Constraints**:
    - `name`: Maximum 255 characters, must not be empty or null.
    - `avatar_url`: Must be a valid URL (if provided).
  - Request Body:
    ```json
    {
      "name": "John Doe",
      "avatar_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid%2Fprofile.jpg"
    }
    ```
  - Response: Updated user object (same as GET /users/me response).

- **DELETE /users/me**
  - Description: Delete the authenticated user's account, including all associated categories, locations, category shares, location shares, and images in Firebase Storage.
  - **Process**:
    - Validates the Firebase token to ensure the request is from the authenticated user.
    - Queries the `categories` table for all `icon` URLs and the `locations` table for all `image_urls` associated with the `user_id`.
    - Deletes all identified images from Firebase Storage using the Firebase Admin SDK, processing deletions in batches for efficiency.
    - Uses database transactions to delete all records in `categories`, `locations`, `category_shares`, and `location_shares` tables for the `user_id`, ensuring data integrity.
    - Deletes the user record from the `users` table and removes the user from Firebase Authentication.
  - Response: 204 No Content.
  - **Error Cases**:
    - Returns `E006` (Unauthorized access) if the token does not match the user ID.
    - Returns `S002` (Server error) if image deletion or database operations fail.

### Categories
- **GET /categories**
  - Description: List all categories for the authenticated user, including shared categories.
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
          "icon": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/categories%2Ffirebase_uid%2Fuuid%2Ficon.png",
          "visibility": "private",
          "is_default": false,
          "sync_status": "synced",
          "created_at": "2025-05-31T23:15:00Z",
          "updated_at": "2025-05-31T23:15:00Z",
          "share": {
            "role": "owner",
            "permissions": [
              {
                "user_id": "firebase_uid_456",
                "role": "read",
                "name": "Jane Smith",
                "email": "jane@example.com",
                "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_456%2Fprofile.jpg"
              },
              {
                "user_id": "firebase_uid_789",
                "role": "edit",
                "name": "Bob Wilson",
                "email": "bob@example.com",
                "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_789%2Fprofile.jpg"
              }
            ]
          }
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
  - **Error Cases**:
    - Returns `E002` (Invalid UUID format) for `id` or any `share.permissions[].user_id`.
    - Returns `E004` (Missing required field) if `name` or `id` is missing.
    - Returns `E007` (Resource not found) if any `share.permissions[].user_id` does not exist.
    - Returns `E003` (Duplicate ID) if a category with the same UUID already exists.

- **POST /categories**
  - Description: Create a new category, optionally specifying sharing permissions.
  - **Constraints**:
    - `id`: Must be a valid UUID.
    - `name`: Maximum 255 characters, must not be empty or null.
    - `icon`: Must be a valid URL (if provided).
    - `visibility`: Must be one of `private`, `shared`, `public`. Defaults to `private`. If `shared`, the `share.permissions` array must include at least one user.
    - `is_default`: Boolean, defaults to `false`.
    - `sync_status`: Must be one of `synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`.
    - `share.permissions`: Optional array of objects, each containing:
      - `user_id`: Valid Firebase UID, must exist in `users`.
      - `role`: Must be one of `read`, `edit` (cannot be `owner` as the creator is the owner).
  - Request Body:
    ```json
    {
      "id": "client-generated-uuid",
      "name": "Cafe",
      "icon": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/categories%2Ffirebase_uid%2Fuuid%2Ficon.png",
      "visibility": "shared",
      "is_default": false,
      "sync_status": "pendingCreate",
      "share": {
        "permissions": [
          {
            "user_id": "firebase_uid_456",
            "role": "read"
          },
          {
            "user_id": "firebase_uid_789",
            "role": "edit"
          }
        ]
      }
    }
    ```
  - Response:
    ```json
    {
      "id": "uuid",
      "user_id": "firebase_uid",
      "name": "Cafe",
      "icon": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/categories%2Ffirebase_uid%2Fuuid%2Ficon.png",
      "visibility": "shared",
      "is_default": false,
      "sync_status": "synced",
      "created_at": "2025-05-31T23:15:00Z",
      "updated_at": "2025-05-31T23:15:00Z",
      "share": {
        "role": "owner",
        "permissions": [
          {
            "user_id": "firebase_uid_456",
            "role": "read",
            "name": "Jane Smith",
            "email": "jane@example.com",
            "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_456%2Fprofile.jpg"
          },
          {
            "user_id": "firebase_uid_789",
            "role": "edit",
            "name": "Bob Wilson",
            "email": "bob@example.com",
            "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_789%2Fprofile.jpg"
          }
        ]
      }
    }
    ```
  - **Notes**:
    - The authenticated user is automatically assigned the `owner` role in the `share.role` field of the response.
    - If `visibility` is `shared`, the `share.permissions` array must include at least one user; otherwise, the server returns an `E001` error (Invalid input data).
    - Sharing permissions are stored in the `category_shares` table, with `owner_id` set to the authenticated user’s `user_id`.
    - To remove sharing, set `visibility` to `private` or provide an empty `share.permissions` array, which deletes all associated `category_shares` records.
  - **Error Cases**:
    - Returns `E002` (Invalid UUID format) for `id` or `share.permissions[].user_id`.
    - Returns `E004` (Missing required field) if `id` is missing.
    - Returns `E007` (Resource not found) if the category does not exist.
    - Returns `E006` (Unauthorized access) if the user is not the owner or does not have `edit` role.
    - Returns `E003` (Conflict during synchronization) if the request has an older `updated_at`.

- **PUT /categories**
  - Description: Update an existing category, including its sharing permissions.
  - **Constraints**: Same as POST /categories.
    - `share.permissions`: Optional. If provided, updates the sharing permissions by replacing existing ones (creates new `category_shares` records and deletes outdated ones).
  - Request Body:
    ```json
    {
      "id": "uuid",
      "name": "Coffee Shop",
      "icon": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/categories%2Ffirebase_uid%2Fuuid%2Ficon.png",
      "visibility": "shared",
      "is_default": false,
      "sync_status": "pendingUpdate",
      "share": {
        "permissions": [
          {
            "user_id": "firebase_uid_456",
            "role": "edit"
          },
          {
            "user_id": "firebase_uid_789",
            "role": "read"
          }
        ]
      }
    }
    ```
  - Response:
    ```json
    {
      "id": "uuid",
      "user_id": "firebase_uid",
      "name": "Coffee Shop",
      "icon": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/categories%2Ffirebase_uid%2Fuuid%2Ficon.png",
      "visibility": "shared",
      "is_default": false,
      "sync_status": "synced",
      "created_at": "2025-05-31T23:15:00Z",
      "updated_at": "2025-05-31T23:16:00Z",
      "share": {
        "role": "owner",
        "permissions": [
          {
            "user_id": "firebase_uid_456",
            "role": "edit",
            "name": "Jane Smith",
            "email": "jane@example.com",
            "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_456%2Fprofile.jpg"
          },
          {
            "user_id": "firebase_uid_789",
            "role": "read",
            "name": "Bob Wilson",
            "email": "bob@example.com",
            "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_789%2Fprofile.jpg"
          }
        ]
      }
    }
    ```
  - **Notes**:
    - Only the owner or users with `edit` role can update the category.
    - If `share.permissions` is provided, it replaces existing permissions in the `category_shares` table for the given `category_id`.
    - If `visibility` is changed to `private` or `share.permissions` is empty, existing `category_shares` records are deleted.
  - **Error Cases**:
    - Returns `E002` (Invalid UUID format) for `category_id` or `reassign_category_id`.
    - Returns `E004` (Missing required field) if the category contains locations and no `reassign_category_id` provided.
    - Returns `E007` (Resource not found) if the category does not exist.
    - Returns `E006` (Unauthorized access) if the user is not the owner or does not have `edit` role.
    - Returns `E007` (Resource not found) if `reassign_category_id` does not exist or user has no access.
    - Returns `E002` (Invalid UUID format) for `category_id` if provided.
    - Returns `E007` (Resource not found) if `category_id` does not exist or user has no access.


- **DELETE /categories/{category_id}**
  - Description: Delete a category by ID, including all associated locations, their images, and category shares.
  - **Constraints**:
    - `category_id`: Must be a valid UUID.
    - If the category contains locations, a `reassign_category_id` (valid UUID) must be provided in the request body to reassign the locations.
  - Request Body (if reassigning locations):
    ```json
    {
      "reassign_category_id": "uuid"
    }
    ```
  - Response: 204 No Content.
  - **Error Cases**:
    - Returns `E002` (Invalid UUID format) for `id` or `category_id`.
    - Returns `E004` (Missing required field) if `id`, `category_id`, `name`, or `displayName` is missing.
    - Returns `E007` (Resource not found) if the category does not exist or user has no edit rights.

### Locations
- **GET /locations**
  - Description: List all locations for the authenticated user, optionally filtered by category, including shared locations.
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
          "displayName": "My Favorite Coffee Shop",
          "address": "123 Main St",
          "description": "Great coffee",
          "latitude": 37.7749,
          "longitude": -122.4194,
          "is_favorite": true,
          "image_urls": [
            "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_1.jpg",
            "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_2.jpg"
          ],
          "notes": "Try their signature latte",
          "tags": ["coffee", "outdoor"],
          "visibility": "shared",
          "sync_status": "synced",
          "created_at": "2025-08-05T21:00:00Z",
          "updated_at": "2025-08-05T21:00:00Z",
          "share": {
            "role": "edit",
            "permissions": [
              {
                "user_id": "firebase_uid_789",
                "role": "owner",
                "name": "Bob Wilson",
                "email": "bob@example.com",
                "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_789%2Fprofile.jpg"
              },
              {
                "user_id": "firebase_uid_456",
                "role": "read",
                "name": "Jane Smith",
                "email": "jane@example.com",
                "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_456%2Fprofile.jpg"
              }
            ]
          }
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
  - Description: Create a new location, optionally specifying sharing permissions.
  - **Constraints**:
    - `id`: Must be a valid UUID.
    - `category_id`: Must be a valid UUID and exist in `categories`.
    - `name`: Maximum 255 characters, must not be empty or null.
    - `displayName`: Maximum 255 characters, must not be empty or null.
    - `address`: Maximum 1000 characters (optional).
    - `description`: Maximum 1000 characters (optional).
    - `latitude`: Must be between -90 and 90.
    - `longitude`: Must be between -180 and 180.
    - `is_favorite`: Boolean, defaults to `false`.
    - `image_urls`: Array of valid URLs, maximum 10 URLs.
    - `notes`: Maximum 1000 characters (optional).
    - `tags`: Array of strings, each maximum 50 characters (optional).
    - `visibility`: Must be one of `private`, `shared`, `public`. Defaults to `private`. If `shared`, the `share.permissions` array must include at least one user.
    - `sync_status`: Must be one of `synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`.
    - `share.permissions`: Optional array of objects, each containing:
      - `user_id`: Valid Firebase UID, must exist in `users`.
      - `role`: Must be one of `read`, `edit` (cannot be `owner` as the creator is the owner).
  - Request Body:
    ```json
    {
      "id": "client-generated-uuid",
      "category_id": "uuid",
      "name": "Coffee Shop",
      "displayName": "My Favorite Coffee Shop",
      "address": "123 Main St",
      "description": "Great coffee",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "is_favorite": true,
      "image_urls": [
        "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_1.jpg",
        "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_2.jpg"
      ],
      "notes": "Try their signature latte",
      "tags": ["coffee", "outdoor"],
      "visibility": "shared",
      "sync_status": "pendingCreate",
      "share": {
        "permissions": [
          {
            "user_id": "firebase_uid_456",
            "role": "read"
          },
          {
            "user_id": "firebase_uid_789",
            "role": "edit"
          }
        ]
      }
    }
    ```
  - Response:
    ```json
    {
      "id": "uuid",
      "user_id": "firebase_uid",
      "category_id": "uuid",
      "name": "Coffee Shop",
      "displayName": "My Favorite Coffee Shop",
      "address": "123 Main St",
      "description": "Great coffee",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "is_favorite": true,
      "image_urls": [
        "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_1.jpg",
        "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_2.jpg"
      ],
      "notes": "Try their signature latte",
      "tags": ["coffee", "outdoor"],
      "visibility": "shared",
      "sync_status": "synced",
      "created_at": "2025-08-05T21:00:00Z",
      "updated_at": "2025-08-05T21:00:00Z",
      "share": {
        "role": "owner",
        "permissions": [
          {
            "user_id": "firebase_uid_456",
            "role": "read",
            "name": "Jane Smith",
            "email": "jane@example.com",
            "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_456%2Fprofile.jpg"
          },
          {
            "user_id": "firebase_uid_789",
            "role": "edit",
            "name": "Bob Wilson",
            "email": "bob@example.com",
            "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_789%2Fprofile.jpg"
          }
        ]
      }
    }
    ```
  - **Notes**:
    - The authenticated user is automatically assigned the `owner` role in the `share.role` field of the response.
    - If `visibility` is `shared`, the `share.permissions` array must include at least one user; otherwise, the server returns an `E001` error (Invalid input data).
    - Sharing permissions are stored in the `location_shares` table, with `owner_id` set to the authenticated user’s `user_id`.
    - To remove sharing, set `visibility` to `private` or provide an empty `share.permissions` array, which deletes all associated `location_shares` records.
  - **Error Cases**:
    - Returns `E002` (Invalid UUID format) for `id` or `category_id`.
    - Returns `E004` (Missing required field) if `id` is missing.
    - Returns `E007` (Resource not found) if the location or category does not exist.
    - Returns `E006` (Unauthorized access) if the user is not the owner or does not have `edit` role.
    - Returns `E003` (Conflict during synchronization) if the request has an older `updated_at`.
    - Returns `E001` (Invalid input data) if `latitude`/`longitude` out of range or other validation fails.

- **PUT /locations**
  - Description: Update an existing location, including its sharing permissions.
  - **Constraints**: Same as POST /locations.
    - `share.permissions`: Optional. If provided, updates the sharing permissions by replacing existing ones (creates new `location_shares` records and deletes outdated ones).
  - Request Body:
    ```json
    {
      "id": "uuid",
      "category_id": "uuid",
      "name": "Coffee Shop",
      "displayName": "My Favorite Coffee Shop",
      "address": "123 Main St",
      "description": "Great coffee",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "is_favorite": true,
      "image_urls": [
        "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_1.jpg",
        "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_2.jpg"
      ],
      "notes": "Try their signature latte",
      "tags": ["coffee", "outdoor"],
      "visibility": "shared",
      "sync_status": "pendingUpdate",
      "share": {
        "permissions": [
          {
            "user_id": "firebase_uid_456",
            "role": "edit"
          },
          {
            "user_id": "firebase_uid_789",
            "role": "read"
          }
        ]
      }
    }
    ```
  - Response:
    ```json
    {
      "id": "uuid",
      "user_id": "firebase_uid",
      "category_id": "uuid",
      "name": "Coffee Shop",
      "displayName": "My Favorite Coffee Shop",
      "address": "123 Main St",
      "description": "Great coffee",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "is_favorite": true,
      "image_urls": [
        "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_1.jpg",
        "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/locations%2Ffirebase_uid%2Fuuid%2Fimage_2.jpg"
      ],
      "notes": "Try their signature latte",
      "tags": ["coffee", "outdoor"],
      "visibility": "shared",
      "sync_status": "synced",
      "created_at": "2025-08-05T21:00:00Z",
      "updated_at": "2025-08-05T21:01:00Z",
      "share": {
        "role": "owner",
        "permissions": [
          {
            "user_id": "firebase_uid_456",
            "role": "edit",
            "name": "Jane Smith",
            "email": "jane@example.com",
            "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_456%2Fprofile.jpg"
          },
          {
            "user_id": "firebase_uid_789",
            "role": "read",
            "name": "Bob Wilson",
            "email": "bob@example.com",
            "user_image_url": "https://firebasestorage.googleapis.com/v0/b/locify-123.appspot.com/o/users%2Ffirebase_uid_789%2Fprofile.jpg"
          }
        ]
      }
    }
    ```
  - **Notes**:
    - Only the owner or users with `edit` role can update the location.
    - If `share.permissions` is provided, it replaces existing permissions in the `location_shares` table for the given `location_id`.
    - If `visibility` is changed to `private` or `share.permissions` is empty, existing `location_shares` records are deleted.

- **DELETE /locations/{location_id}**
  - Description: Delete a location by ID, including associated images and location shares.
  - **Constraints**:
    - `location_id`: Must be a valid UUID.
  - Response: 204 No Content.
  - **Error Cases**:
    - Returns `E002` (Invalid UUID format) for `id` or `category_id`.
    - Returns `E004` (Missing required field) if `id` is missing.
    - Returns `E007` (Resource not found) if the location or category does not exist.
    - Returns `E006` (Unauthorized access) if the user is not the owner or does not have `edit` role.
    - Returns `E003` (Conflict during synchronization) if the request has an older `updated_at`.
    - Returns `E001` (Invalid input data) if `latitude`/`longitude` out of range or other validation fails.

### Images
- **Firebase Storage Integration**:
  - **Client Operations**: Clients use the Firebase Storage SDK directly for image upload and deletion operations.
  - **Backend Operations**: The backend deletes images from Firebase Storage during user account deletion (via `DELETE /users/me`), category deletion (via `DELETE /categories/{category_id}`), or location deletion (via `DELETE /locations/{location_id}`) using the Firebase Admin SDK.
  - Storage path structure: `/locations/{user_id}/{location_id}/{image_name}` for location images, `/categories/{user_id}/{category_id}/{icon_name}` for category icons, and `/users/{user_id}/{image_name}` for user avatars.
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
          match /users/{userId}/{imageName} {
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
  - Backend handles bulk image deletion during user, category, or location deletion to clean up Firebase Storage, using batch processing for efficiency and database transactions to ensure data integrity.
  - Provides upload/download progress monitoring, retries, and error handling for client operations.
  - Firebase Storage security rules enforce user-specific access control.
  - Download URLs are generated automatically for client uploads and stored in the database.
  - Backend ensures atomicity by performing image deletions before database record deletions within a transaction, preventing orphaned data.

## Synchronization
Locify supports offline functionality, allowing clients to create, update, and delete resources offline, with changes synchronized when connectivity is restored.

- **Client-Side**:
  - Clients assign a client-generated UUID to the `id` field for `categories` and `locations` when creating resources offline.
  - Clients set the `sync_status` field to `pendingCreate`, `pendingUpdate`, or `pendingDelete` to track pending operations.
  - The Firebase SDKs (for Authentication and Storage) support offline persistence, queuing operations until connectivity is restored.
  - Clients maintain a local queue of API requests (POST, PUT, DELETE) with their respective `sync_status` values.

- **Server-Side**:
  - The server processes requests with `sync_status` values:
    - `pendingCreate`: Creates a new record, sets `sync_status` to `synced` in the response.
    - `pendingUpdate`: Updates the existing record, sets `sync_status` to `synced`.
    - `pendingDelete`: Deletes the record (no response body).
  - The server uses database transactions to ensure atomicity for create, update, and delete operations, including associated `category_shares` and `location_shares` records.
  - For offline-created resources, the server validates the client-generated UUID and ensures no conflicts with existing records.

- **Conflict Resolution**:
  - If two clients create resources with the same UUID offline, the server rejects the second request with an `E003` error (Duplicate ID).
  - For updates, the server uses the `updated_at` timestamp to resolve conflicts, applying the most recent change based on client-provided `sync_status` and timestamps.
  - Clients should fetch the latest data (via `GET /categories` or `GET /locations`) after syncing to resolve any conflicts and update their local state.

- **Example Flow**:
  1. Client creates a category offline:
     ```json
     {
       "id": "client-generated-uuid",
       "name": "Cafe",
       "visibility": "private",
       "is_default": false,
       "sync_status": "pendingCreate"
     }
     ```
  2. Client queues a `POST /categories` request.
  3. When online, the client sends the queued request.
  4. Server creates the category, sets `sync_status` to `synced`, and returns:
     ```json
     {
       "id": "client-generated-uuid",
       "user_id": "firebase_uid",
       "name": "Cafe",
       "icon": null,
       "visibility": "private",
       "is_default": false,
       "sync_status": "synced",
       "created_at": "2025-08-05T21:00:00Z",
       "updated_at": "2025-08-05T21:00:00Z",
       "share": {
         "role": "owner",
         "permissions": []
       }
     }
     ```
  5. Client updates local state with the server’s response.

## Error Handling
The Locify API returns error responses with a custom `error` object containing a `code` and `message`. iOS and Android clients should map the `code` to user-friendly messages, while the `message` is for debugging.

### Error Response Format
The API uses standard HTTP status codes and includes an error code and message in the response body for error cases.

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
