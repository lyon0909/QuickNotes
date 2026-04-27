import SwiftUI
import SwiftData

@main
struct QuickNotesApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    private let container: ModelContainer
    private let notificationHandler: NotificationActionHandler

    init() {
        let c = ModelContainerFactory.makeContainer()
        container = c
        notificationHandler = NotificationActionHandler(container: c)
        UNUserNotificationCenter.current().delegate = notificationHandler

        NotificationCategories.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .task { await requestNotificationsIfNeeded() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { rescheduleNudges() }
                }
        }
    }

    @Environment(\.scenePhase) private var scenePhase

    private func requestNotificationsIfNeeded() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = await NotificationManager.shared.requestAuthorization()
        }
    }

    private func rescheduleNudges() {
        Task { @MainActor in
            let repo = NoteRepository(context: container.mainContext)
            let pending = (try? repo.fetchPending()) ?? []
            await NotificationManager.shared.scheduleNudge(for: pending)
        }
    }
}

struct ContentView: View {
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            NoteListView()
        } detail: {
            Text("Select a note")
                .foregroundStyle(.secondary)
        }
        #else
        TabView {
            NoteListView()
                .tabItem { Label("Notes", systemImage: "note.text") }
            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gear") }
        }
        #endif
    }
}
