import SwiftUI
import SwiftData

struct NoteListView: View {
    @Query(
        filter: #Predicate<Note> { $0.statusRaw == "pending" },
        sort: \Note.createdAt,
        order: .reverse
    ) private var notes: [Note]

    @Environment(\.modelContext) private var context
    @State private var showCapture = false

    private var repo: NoteRepository { NoteRepository(context: context) }

    private var tasks: [Note] { notes.filter { $0.category == .task } }
    private var ideas: [Note] { notes.filter { $0.category == .idea } }

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    emptyState
                } else {
                    noteList
                }
            }
            .navigationTitle("QuickNotes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCapture = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCapture) {
                NavigationStack {
                    CaptureView(viewModel: CaptureViewModel(repo: repo))
                        .navigationTitle("New Note")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { showCapture = false }
                            }
                        }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var noteList: some View {
        List {
            if !tasks.isEmpty {
                Section("Tasks") {
                    ForEach(tasks) { note in
                        NoteRowView(
                            note: note,
                            onDone: { markDone(note) },
                            onDelete: { delete(note) }
                        )
                    }
                }
            }
            if !ideas.isEmpty {
                Section("Ideas") {
                    ForEach(ideas) { note in
                        NoteRowView(
                            note: note,
                            onDone: { markDone(note) },
                            onDelete: { delete(note) }
                        )
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "note.text")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No notes yet")
                .font(.headline)
            Text("Tap + to capture something quickly")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Add a note") { showCapture = true }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func markDone(_ note: Note) {
        try? repo.markDone(note)
        rescheduleNudges()
    }

    private func delete(_ note: Note) {
        try? repo.delete(note)
        rescheduleNudges()
    }

    private func rescheduleNudges() {
        Task {
            let pending = (try? repo.fetchPending()) ?? []
            await NotificationManager.shared.scheduleNudge(for: pending)
        }
    }
}
