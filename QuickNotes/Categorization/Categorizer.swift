import Foundation

protocol Categorizer {
    func categorize(_ content: String) async -> NoteCategory
}
