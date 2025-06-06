# Locify - Location Saving App

**Locify** is a monorepo project that provides a cross-platform solution for saving and managing locations, supporting both online and offline use for users to plan visits or keep memorable places.

---

## Table of Contents
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [Setup Instructions](#setup-instructions)
- [Branch Naming Rules](#branch-naming-rules)
- [Commit Message Convention](#commit-message-convention)
- [Git Workflow](#git-workflow)

---

## Project Structure
- **`/locify-ios`**: iOS app written in Swift.
- **`/locify-android`**: Android app written in Kotlin.
- **`/locify-backend`**: Backend service using Java/Spring Boot.

---

## Documentation
- **API Documentation**: [Locify_API_Documentation.md](./docs/Locify_API_Documentation.md)
- **Database Schema**: [Locify_Database_Schema.md](./docs/Locify_Database_Schema.md)
- **Data Sync Flow**: [Locify_Data_Sync_Flow.md](./docs/Locify_Data_Sync_Flow.md)
- **Feature Specification**: [Locify_Feature_Specification.md](./docs/Locify_Feature_Specification.md)
- **System Architecture**: [Locify_System_Architecture.md](./docs/Locify_System_Architecture.md)

---

## Setup Instructions
Setup guides for each platform are located in their respective subdirectories:

- **iOS App**: [locify-ios/README.md](./locify-ios/README.md)
- **Android App**: [locify-android/README.md](./locify-android/README.md)
- **Backend Service**: [locify-backend/README.md](./locify-backend/README.md)

---

## Branch Naming Rules
To keep the repository organized, we follow a consistent naming convention:

### Format
```bash
<type>/<platform>/<description>
```

- **`<type>`**: feature, bugfix, hotfix, release.
- **`<platform>`**: ios, android, backend.
- **`<description>`**: Short, kebab-case description.

### Main Branches
- **`main`**: Stable production-ready code.
- **`develop`**: The single development branch for all platforms (iOS, Android, backend).

### Examples
- `feature/ios/add-map`
- `feature/android/save-location-ui`
- `feature/backend/new-endpoint`
- `bugfix/ios/fix-crash-on-search`
- `hotfix/backend/fix-env-vars`
- `release/v1.0.0`

---

## Commit Message Convention
Commits should be clear, concise, and consistently formatted for better readability and tracking.

### Format
```bash
[<Platform>] <Verb> <Short Description>
```

- **`<Platform>`**: 
  - [iOS], [Android], [Backend] — optional for platform-specific changes.
  - Omit this tag if the change affects all platforms (e.g., update README or scripts).
- **`<Verb>`**: Start with a present-tense action verb (e.g., Add, Fix, Update).
- **`<Short Description>`**: Describe the change concisely.

### Examples
- [iOS] Add map view to home screen
- [Android] Fix crash on navigation button click
- [Backend] Implement save location endpoint
- Update README with new rules

---

## Git Workflow
To ensure a clean and maintainable Git history, follow the workflow below when contributing to the repository:

### 1. Create a Branch
- Branch off from the `develop` branch.
```bash
git checkout develop
git checkout -b feature/ios/add-search-bar
```

### 2. Work and Commit
- Commit frequently with clear messages following the Commit Message Convention.

### 3. Rebase Before Merging
- Always rebase your feature branch onto the latest `develop` to keep history clean and resolve conflicts early.
```bash
git fetch origin
git rebase origin/develop
```

### 4. Pull Request (PR)
- Open a PR targeting the `develop` branch.
- Include a clear description of changes.
- Request at least 1 code review before merging.

### 5. Merge Strategy
- Prefer Squash and Merge to keep commit history concise.
- Ensure the final commit message is clean and informative.
