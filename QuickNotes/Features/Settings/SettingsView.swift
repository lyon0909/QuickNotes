import SwiftUI

struct SettingsView: View {
    @AppStorage("useClaudeAPI") private var useClaudeAPI = false
    @AppStorage("claudeAPIKey") private var claudeAPIKey = ""
    @State private var notificationStatus: String = "Checking..."

    var body: some View {
        Form {
            Section("Notifications") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(notificationStatus)
                        .foregroundStyle(.secondary)
                }
                Button("Open Settings") {
                    openAppSettings()
                }
            }

            Section {
                Toggle("Use Claude AI for categorization", isOn: $useClaudeAPI)
                if useClaudeAPI {
                    SecureField("API Key", text: $claudeAPIKey)
                        .textContentType(.password)
                }
            } header: {
                Text("AI Categorization")
            } footer: {
                Text("Without an API key, notes are categorized using built-in rules. Claude AI improves accuracy but requires an Anthropic API key.")
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .task { await checkNotificationStatus() }
    }

    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized: notificationStatus = "Enabled"
        case .denied: notificationStatus = "Disabled"
        case .notDetermined: notificationStatus = "Not requested"
        case .provisional: notificationStatus = "Provisional"
        default: notificationStatus = "Unknown"
        }
    }

    private func openAppSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}
