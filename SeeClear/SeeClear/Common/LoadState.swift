import Foundation

/// The state of an initial (non-refresh) load. Refresh-in-flight and refresh-failure are modeled
/// separately (see `TeamsViewModel`/`SquadViewModel`) so a failed refresh never regresses `.loaded`
/// back to an error state and blank the screen.
enum LoadState<Value> {
    case loading
    case loaded(Value)
    case failed(Error)
}
