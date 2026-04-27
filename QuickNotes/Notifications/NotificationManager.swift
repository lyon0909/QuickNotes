import UserNotifications
import Foundation

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    private let scheduler = NudgeScheduler()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleNudge(for notes: [Note]) async {
        guard let plan = scheduler.nextNudge(from: notes) else { return }

        // Cancel any existing nudge before scheduling a new one
        center.removePendingNotificationRequests(withIdentifiers: ["nudge"])

        let content = UNMutableNotificationContent()
        content.title = plan.note.category == .task ? "Pending task" : "Saved idea"
        content.body = plan.note.content
        content.categoryIdentifier = NotificationActionID.categoryID
        content.userInfo = [NotificationUserInfoKey.noteID: plan.note.id.uuidString]
        content.sound = .default

        let interval = max(plan.fireDate.timeIntervalSinceNow, 60)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: "nudge", content: content, trigger: trigger)

        try? await center.add(request)
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
