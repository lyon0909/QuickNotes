import UIKit
import UserNotifications
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
    var notificationHandler: NotificationActionHandler?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        NotificationCategories.register()
        return true
    }
}
