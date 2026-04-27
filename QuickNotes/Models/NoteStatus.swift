import Foundation

enum NoteStatus: String, Codable, CaseIterable {
    case pending
    case done
    case skipped
}
