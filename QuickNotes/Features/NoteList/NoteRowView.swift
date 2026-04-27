import SwiftUI

struct NoteRowView: View {
    let note: Note
    let onDone: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.content)
                .font(.body)
                .lineLimit(3)
                .strikethrough(note.status == .done)
                .foregroundStyle(note.status == .done ? .secondary : .primary)

            HStack(spacing: 6) {
                Image(systemName: note.category.systemImage)
                    .font(.caption)
                Text(note.category.displayName.dropLast()) // "Task" / "Idea"
                    .font(.caption)
                Spacer()
                Text(note.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: onDone) {
                Label("Done", systemImage: "checkmark")
            }
            .tint(.green)
        }
    }
}
