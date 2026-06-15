import SwiftUI

/// Shared tab selection so views (e.g. a "Coping skills" prompt on Home)
/// can switch the active tab in RootTabView.
@Observable
final class TabSelection {
    var selection: RootTabView.Tab = .home
}
