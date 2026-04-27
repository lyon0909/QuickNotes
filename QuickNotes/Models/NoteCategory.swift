import Foundation

enum NoteCategory: String, Codable, CaseIterable {
    case task
    case idea

    var displayName: String {
        switch self {
        case .task: return "Tasks"
        case .idea: return "Ideas"
        }
    }

    var systemImage: String {
        switch self {
        case .task: return "checkmark.circle"
        case .idea: return "lightbulb"
        }
    }
}
