# SeeClear — FPL Team Viewer

A native Swift/UIKit app that browses Premier League teams and squads using the Fantasy Premier
League API (`https://fantasy.premierleague.com/api/bootstrap-static/`).

## Build & run

The Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
`project.yml` rather than committed directly, so the `.pbxproj` diff never needs to be reviewed by
hand.

```bash
brew install xcodegen   # if you don't have it
xcodegen generate
open SeeClear.xcodeproj
```

Then build & run the `SeeClear` scheme on an iOS 17+ simulator (⌘R), or run the tests with ⌘U.
From the command line:

```bash
xcodebuild test -project SeeClear.xcodeproj -scheme SeeClear \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

MVVM, no coordinator. There are only two screens with a single push navigation, so a coordinator
layer would add indirection without earning it. MVVM keeps the loading/refresh/error state machine
and the search/grouping logic fully unit-testable without touching UIKit.

- **Models** — `Team`/`Player` domain structs, decoupled from the FPL wire format
  (`BootstrapResponse`/`TeamDTO`/`ElementDTO`). `BootstrapMapper` is a pure function that turns one
  into the other, computing each team's player count and each player's `Position`.
- **Networking** — `FPLAPIClientProtocol` + `URLSessionFPLAPIClient`, a single
  `fetchBootstrap() async throws` call.
- **Persistence** — `BootstrapCacheProtocol` + `FileBootstrapCache`, writing the raw bootstrap JSON
  to the Caches directory.
- **Repository** — `FPLRepositoryProtocol` with `loadInitial()` (network, falling back to the cache
  on failure — this is what makes an offline launch show the last known data) and `refresh()`
  (network only; the caller keeps whatever was already on screen if it throws).
- **ViewModels** — `TeamsViewModel` (a `LoadState<FPLSnapshot>` plus separate `isRefreshing` /
  `refreshErrorMessage` so a failed pull-to-refresh never blanks the list) and `SquadViewModel`
  (grouping/sorting/filtering the already-fetched players for one team; no extra network call
  needed for the squad screen).
- **Views** — programmatic UIKit throughout (no storyboards/XIBs): `UITableView` + `UIRefreshControl`
  for teams, `UITableView` + `UISearchController` for the squad, and a shared `StatusOverlayView` for
  the loading/error/empty states both screens can be in.
- **Concurrency** — `async/await` end to end; view models are `@MainActor`, view controllers wrap
  calls in `Task { }` and cancel on `deinit` where relevant.

## Assumptions & decisions

- **Team crests and player photos** are fetched from the Premier League's own asset CDN
  (`resources.premierleague.com`, keyed by each team/player's Opta `code` field — not their FPL
  `id`). This isn't in the brief's requirements, and it's a second host beyond the bootstrap-static
  endpoint, but it's the Premier League's own asset host (not a third-party proxy for FPL *data*),
  and the brief explicitly allows "additional visual elements". Images are cached in memory only
  (`NSCache`, one per app run) — a missing/failed image falls back to an SF Symbol placeholder
  rather than a blank space or a crash.
- **Squad ordering**: within each position, players are sorted by total FPL points, descending.
- **Search**: case-insensitive substring match on the player's `web_name` (the short display name
  FPL itself uses, e.g. "Saka" rather than "Bukayo Saka").
- **Offline vs. error semantics**: launching with no network but a cache from a previous successful
  load is treated as a *successful* load of (possibly stale) data — not an error state. The
  "initial request failure" / retry state only appears when the network fails *and* there's no
  cache at all.
- Deployment target iOS 17, Swift 6 with strict concurrency checking enabled.

## Testing

26 unit tests, all against fixtures/fakes — none touch the live API:

- `BootstrapMapperTests` — DTO decoding and DTO→domain transformation, including that an unmapped
  FPL position id (e.g. a future "Manager" slot) is excluded rather than mis-categorized.
- `PlayerSearchFilterTests` — grouping, sort order, and search filtering on `SquadViewModel`.
- `FPLRepositoryTests` — the cache-fallback-on-initial-failure and keep-existing-data-on-refresh-failure
  behavior described above.
- `FileBootstrapCacheTests` — round-trip, missing cache, and corrupted-cache-on-disk.
- `TeamsViewModelTests` — the full loading/loaded/failed/refreshing/refresh-failed state machine.
- `TeamCrestURLTests` — the crest/photo URL builders.

## What I'd improve with more time

- Persist the crest/player-photo cache to disk (currently in-memory only, so it re-fetches every
  launch).
- Replace the refresh-failure `UIAlertController` with a proper non-blocking banner/toast.
- `UITableViewDiffableDataSource` instead of `reloadData()` for smoother updates on refresh.
- A Coordinator if a third screen were ever added.
- Snapshot/UI tests for the view controllers themselves (current tests deliberately stop at the
  view model boundary per the brief's "non-UI behaviour" scope).

## Known limitations

- No pagination/virtualization concerns since bootstrap-static returns everything in one payload.
- No retry/backoff policy on the network call itself (a single attempt; the user retries manually).
- Crest/photo loading has no on-disk cache, so it depends on network on every launch (falls back to
  a placeholder icon when unavailable, but doesn't block or degrade anything else).
