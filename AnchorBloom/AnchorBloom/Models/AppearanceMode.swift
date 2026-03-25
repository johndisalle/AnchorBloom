import SwiftUI
import UIKit

// MARK: - Appearance Mode
/// User preference for light/dark/system appearance
enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var uiStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    /// Apply this appearance mode to all windows immediately
    func apply() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        for window in scene.windows {
            window.overrideUserInterfaceStyle = uiStyle
        }
    }
}
