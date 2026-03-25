import SwiftUI
import FirebaseCore

// MARK: - Firebase App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - App Entry Point
@main
struct AnchorBloomApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authManager = AuthManager()
    @StateObject private var firestoreService = FirestoreService()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(firestoreService)
                .environmentObject(subscriptionManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - Root View (Auth Router)
struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
    }
}

// MARK: - Main Tab View
/// Creates the shared AppViewModel here (not in App.init) so Firebase is configured
struct MainTabView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @State private var selectedTab = 0

    var body: some View {
        MainTabContent(firestoreService: firestoreService, selectedTab: $selectedTab)
    }
}

/// Inner view that owns the @StateObject for AppViewModel
struct MainTabContent: View {
    @StateObject var viewModel: AppViewModel
    @Binding var selectedTab: Int

    init(firestoreService: FirestoreService, selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: AppViewModel(firestoreService: firestoreService))
        _selectedTab = selectedTab
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "tree.fill")
                }
                .tag(0)

            JourneyListView()
                .tabItem {
                    Label("Journeys", systemImage: "map.fill")
                }
                .tag(1)

            DriftLogView()
                .tabItem {
                    Label("Drift Log", systemImage: "water.waves")
                }
                .tag(2)

            CirclesListView()
                .tabItem {
                    Label("Circles", systemImage: "heart.circle.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(ABTheme.sageGreen)
        .environmentObject(viewModel)
        .task {
            await viewModel.loadUserData()
        }
    }
}
