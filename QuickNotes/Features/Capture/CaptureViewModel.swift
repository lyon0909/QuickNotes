import SwiftData
import Foundation

@MainActor
final class CaptureViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let repo: NoteRepository
    private let categorizer: Categorizer

    init(repo: NoteRepository, categorizer: Categorizer = HeuristicCategorizer()) {
        self.repo = repo
        self.categorizer = categorizer
    }

    var canSave: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func save() async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSaving = true
        defer { isSaving = false }

        let category = await categorizer.categorize(trimmed)
        do {
            _ = try repo.create(content: trimmed, category: category)
            text = ""
            errorMessage = nil

            let pending = (try? repo.fetchPending()) ?? []
            await NotificationManager.shared.scheduleNudge(for: pending)
        } catch {
            errorMessage = "Failed to save note. Please try again."
        }
    }
}
