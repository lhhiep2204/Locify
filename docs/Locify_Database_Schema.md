# Locify Database Schema

This document defines the relational database schema used in the Locify backend, built with PostgreSQL. It supports user-based location management and category grouping for saving planned or memorable locations, with offline synchronization and cross-device consistency using `sync_status` and `updated_at`.

## Table of Contents
- [Validation Notes](#validation-notes)
- [Users Table](#users-table)
- [Categories Table](#categories-table)
- [Locations Table](#locations-table)
- [Sync Status Values](#sync-status-values)
- [Relationship Diagram](#relationship-diagram)
- [Related Documentation](#related-documentation)

---

## Validation Notes
This schema defines basic database constraints such as data types, `NOT NULL`, `UNIQUE`, maximum lengths, and foreign key relationships. Additional validation rules (e.g., email format, special characters in `name`, valid `sync_status` values) are enforced at the API layer and documented in the [API Documentation](../docs/Locify_API_Documentation.md).

---

## Users Table
Stores information about registered users, synchronized with Firebase Authentication.

| Column Name  | Data Type           | Constraints                       | Description                         |
|--------------|---------------------|-----------------------------------|-------------------------------------|
| `id`         | VARCHAR(128)        | PRIMARY KEY                       | Unique user ID (Firebase UID)       |
| `email`      | VARCHAR(255)        | UNIQUE, NOT NULL                  | Unique email address                |
| `name`       | VARCHAR(255)        | NOT NULL                          | Full name of the user               |
| `created_at` | TIMESTAMP           |                                   | Time of account creation            |
| `updated_at` | TIMESTAMP           |                                   | Last time the user info was updated |

---

## Categories Table
Stores user-defined or default categories for organizing locations.

| Column Name   | Data Type           | Constraints                                     | Description                                     |
|---------------|---------------------|-------------------------------------------------|-------------------------------------------------|
| `id`          | UUID                | PRIMARY KEY                                     | Unique category ID                              |
| `user_id`     | VARCHAR(128)        | FOREIGN KEY (users.id), NOT NULL                | References `users(id)`                          |
| `name`        | VARCHAR(255)        | NOT NULL                                        | Name of the category                            |
| `icon`        | VARCHAR(255)        |                                                 | URL of the category icon          |
| `sync_status` | ENUM('synced', 'pendingCreate', 'pendingUpdate', 'pendingDelete') | NOT NULL                    | Synchronization status                           |
| `created_at`  | TIMESTAMP           |                                                 | Time of category creation                       |
| `updated_at`  | TIMESTAMP           |                                                 | Last time the category was updated              |

**Indexes**:
- `idx_categories_user_id`

**Relations**:
- Belongs to one `user`
- Has many `locations`

---

## Locations Table
Stores all location information saved by the user.

| Column Name   | Data Type           | Constraints                                     | Description                                      |
|---------------|---------------------|-------------------------------------------------|--------------------------------------------------|
| `id`          | UUID                | PRIMARY KEY                                     | Unique location ID                               |
| `user_id`     | VARCHAR(128)        | FOREIGN KEY (users.id), NOT NULL                | References `users(id)`                           |
| `category_id` | UUID                | FOREIGN KEY (categories.id), NOT NULL           | References `categories(id)`                      |
| `name`        | VARCHAR(255)        | NOT NULL                                        | Name of the location                             |
| `address`     | TEXT                |                                                 | Address of the location (e.g., "123 Main St")     |
| `description` | TEXT                |                                                 | Optional description of the location             |
| `latitude`    | DOUBLE PRECISION    | NOT NULL                                        | Latitude coordinate (between -90 and 90)         |
| `longitude`   | DOUBLE PRECISION    | NOT NULL                                        | Longitude coordinate (between -180 and 180)      |
| `is_favorite` | BOOLEAN             | DEFAULT FALSE                                   | Whether the location is marked as a favorite      |
| `image_urls`  | TEXT[]              |                                                 | Array of URLs for location images                |
| `sync_status` | ENUM('synced', 'pendingCreate', 'pendingUpdate', 'pendingDelete') | NOT NULL                    | Synchronization status                           |
| `created_at`  | TIMESTAMP           |                                                 | Time of location creation                        |
| `updated_at`  | TIMESTAMP           |                                                 | Last time the location was updated                            |

**Indexes**:
- `idx_locations_category_id`
- `idx_locations_user_id`

**Relations**:
- Belongs to one `user`
- Belongs to one `category`

---

## Sync Status Values
Values for `sync_status` used in `categories` and `locations`:
- `synced`: Synced with the server
- `pendingCreate`: Created locally, not yet sent to server
- `pendingUpdate`: Updated locally, not yet synced
- `pendingDelete`: Deleted locally, pending sync

---

## Relationship Diagram
The diagram below illustrates the relationships between the `users`, `categories`, and `locations` tables:
- Each `user` **owns multiple** `categories`, indicated by the `user_id` foreign key in the `categories` table.
- Each `user` **also owns multiple** `locations`, indicated by the `user_id` foreign key in the `locations` table.
- Each `category` **can include multiple** `locations`, indicated by the `category_id` foreign key in the `locations` table.
- Each `location` **belongs to one** `category` and **one** `user`.

```text
+---------+                             +-------------+
|  Users  |                             |  Categories |
|  (id)   |<--------- user_id ----------|  (user_id)  |
+---------+             ^               +-------------+
    ^                   |                      |
    |                   |     category_id      |
    |                   +----------------------+
    |                                          |
    |            +---------------+             |
    +----------> |   Locations   | <-----------+
                 |   (user_id)   |
                 | (category_id) |
                 +---------------+
```

---

[Back to Project Overview](../README.md)
