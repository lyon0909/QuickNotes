import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var content: String
    var categoryRaw: String
    var statusRaw: String
    var createdAt: Date
    var lastNudgedAt: Date?

    var category: NoteCategory {
        get { NoteCategory(rawValue: categoryRaw) ?? .idea }
        set { categoryRaw = newValue.rawValue }
    }

    var status: NoteStatus {
        get { NoteStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    var isPending: Bool { status == .pending }

    init(content: String, category: NoteCategory = .idea) {
        self.id = UUID()
        self.content = content
        self.categoryRaw = category.rawValue
        self.statusRaw = NoteStatus.pending.rawValue
        self.createdAt = Date()
        self.lastNudgedAt = nil
    }
}
