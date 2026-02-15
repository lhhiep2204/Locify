# Locify iOS — Instructions (Local-only Phase)

---
applyTo: "locify-ios/**"
---

## 1) Current phase constraints (MUST FOLLOW)
- Current phase is **Local-only**.
- There is no API, no login, and no sync engine yet.
- Therefore Copilot MUST NOT:
  - Add a new networking layer (API clients, remote DTOs, remote services).
  - Implement auth/login flows or token handling.
  - Add sync_status / batching / conflict-resolution stubs.
- Copilot MUST implement only: full local CRUD (SwiftData) + necessary UI/UX.

## 2) Tech baseline
- Toolchain: Xcode 26, Swift 6; iOS 26+ deployment target.
- UI: SwiftUI.
- Persistence: SwiftData (reuse existing local infrastructure).
- Maps: MapKit only (do not add Google Maps in new work).

## 3) Identity & IDs (CRITICAL)
- Domain entities use `id: UUID` (e.g., `Location.id` is `UUID`, and `Location.collectionId` is also `UUID`).
- SwiftData local models use `@Attribute(.unique) var id: UUID`.
- All CRUD repository contracts MUST use `UUID` (never `String` IDs).

## 4) Clean Architecture (MANDATORY)
Use the existing layers: Presentation / Domain / Data / Shared, with dependencies flowing inward only.

### Presentation
- SwiftUI Views + ViewModels.
- Views/ViewModels MUST NOT access SwiftData directly; they call Domain UseCases only.
- ViewModels update UI state on the main thread (`@MainActor` when appropriate).

### Domain
- Entities + Repository protocols + UseCases (full CRUD).
- Do not import SwiftUI / SwiftData / MapKit in Domain.
- Repository methods should be `async throws` to match Swift Concurrency.

### Data (local-only)
- Implement repositories using LocalDataSources + existing SwiftData managers/containers.
- Mapping Domain <-> Local models belongs in Data (prefer reusing existing mappers).

### Shared
- DI, configuration, utilities, errors.
- Do not introduce a new DI framework/pattern.

## 5) Dependency Injection (follow the repo)
- Composition root is `AppContainer.shared`.
- `AppContainer` wires feature containers (e.g., collection/location containers) and core services.
- ViewModels must be created via `AppContainer` / feature container builders (do not instantiate ViewModels directly in Views).
- When adding a new dependency: wire it into the relevant feature container and expose a builder via `AppContainer` (keep the current synchronous factory style).

## 6) Swift Concurrency (MANDATORY)
- Use `async/await` end-to-end (UseCase -> Repository -> LocalDataSource).
- Never block the main thread; avoid sync-wait.
- From Views: call ViewModel work using `Task { await ... }`; keep state mutations on MainActor.

## 7) CRUD baseline (Domain contracts)
When adding a new CRUD feature, provide at least these UseCases:
- Fetch (list; optionally detail if needed)
- Create
- Update
- Delete

Recommended repository signatures (adjust names to match existing repo conventions, but keep UUID IDs):
- CollectionRepositoryProtocol:
  - `func fetchCollections() async throws -> [Collection]`
  - `func createCollection(_ collection: Collection) async throws -> Collection`
  - `func updateCollection(_ collection: Collection) async throws -> Collection`
  - `func deleteCollection(id: UUID) async throws`
- LocationRepositoryProtocol:
  - `func fetchLocations(collectionId: UUID) async throws -> [Location]`
  - `func createLocation(_ location: Location) async throws -> Location`
  - `func updateLocation(_ location: Location) async throws -> Location`
  - `func deleteLocation(id: UUID) async throws`

Notes:
- Local-only phase: no user scoping; IDs are local UUIDs.
- On create, ensure `id`, `createdAt`, `updatedAt` are valid and consistent with the existing entity initializers.

## 8) Local persistence (reuse existing code)
- Prefer existing LocalDataSources rather than writing SwiftData queries directly inside repositories.
- Prefer existing SwiftData managers/containers; do not create a second persistence mechanism in parallel.
- Keep SwiftData model updates consistent with `@Attribute(.unique) id` behavior.

## 9) SwiftLint (MUST PASS)
SwiftLint config is `locify-ios/.swiftlint.yml` and it only includes the `Locify/` path.

Hard rules to keep Copilot output lint-friendly:
- line_length <= 120
- Avoid `!`, `as!`, `try!` (force_unwrapping / force_cast / force_try)
- Identifier length >= 3 (except `id`)
- Avoid overly long files/types (file_length/type_body_length)
- No unused imports/declarations

## 10) What NOT to do
- Do not add network/auth/sync stubs in this phase.
- Do not bypass UseCases to access SwiftData in Views/ViewModels.
- Do not invent endpoints/DTOs/remote fields.
