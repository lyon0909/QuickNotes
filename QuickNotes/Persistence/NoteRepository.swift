import SwiftData
import Foundation

@MainActor
final class NoteRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func create(content: String, category: NoteCategory) throws -> Note {
        let note = Note(content: content, category: category)
        context.insert(note)
        try context.save()
        return note
    }

    func fetchAll() throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func fetchPending() throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.statusRaw == "pending" },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return try context.fetch(descriptor)
    }

    func markDone(_ note: Note) throws {
        note.status = .done
        try context.save()
    }

    func markSkipped(_ note: Note) throws {
        note.status = .skipped
        try context.save()
    }

    func updateLastNudged(_ note: Note, date: Date = Date()) throws {
        note.lastNudgedAt = date
        try context.save()
    }

    func find(id: UUID) throws -> Note? {
        let idString = id.uuidString
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    func delete(_ note: Note) throws {
        context.delete(note)
        try context.save()
    }
}
