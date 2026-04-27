import UserNotifications

enum NotificationActionID {
    static let done = "DONE"
    static let skip = "SKIP"
    static let later = "LATER"
    static let categoryID = "NUDGE_CATEGORY"
}

enum NotificationUserInfoKey {
    static let noteID = "noteID"
}

enum NotificationCategories {
    static func register() {
        let done = UNNotificationAction(
            identifier: NotificationActionID.done,
            title: "Done",
            options: []
        )
        let skip = UNNotificationAction(
            identifier: NotificationActionID.skip,
            title: "Skip",
            options: [.destructive]
        )
        let later = UNNotificationAction(
            identifier: NotificationActionID.later,
            title: "Later",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: NotificationActionID.categoryID,
            actions: [done, skip, later],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
