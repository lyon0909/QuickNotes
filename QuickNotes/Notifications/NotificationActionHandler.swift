import UserNotifications
import SwiftData
import Foundation

final class NotificationActionHandler: NSObject, UNUserNotificationCenterDelegate {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let idString = userInfo[NotificationUserInfoKey.noteID] as? String,
              let id = UUID(uuidString: idString) else {
            completionHandler()
            return
        }

        Task { @MainActor in
            let repo = NoteRepository(context: container.mainContext)
            guard let note = try? repo.find(id: id) else {
                completionHandler()
                return
            }

            switch response.actionIdentifier {
            case NotificationActionID.done:
                try? repo.markDone(note)

            case NotificationActionID.skip:
                try? repo.markSkipped(note)

            case NotificationActionID.later:
                try? repo.updateLastNudged(note)
                let pending = (try? repo.fetchPending()) ?? []
                await NotificationManager.shared.scheduleNudge(for: pending)

            default:
                break
            }

            completionHandler()
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
