import SwiftUI

struct CaptureView: View {
    @StateObject private var viewModel: CaptureViewModel
    @FocusState private var isFocused: Bool

    init(viewModel: CaptureViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $viewModel.text)
                .focused($isFocused)
                .font(.body)
                .padding()
                .frame(minHeight: 120)
                .overlay(alignment: .topLeading) {
                    if viewModel.text.isEmpty {
                        Text("What's on your mind?")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                            .allowsHitTesting(false)
                    }
                }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            Divider()

            HStack {
                Spacer()
                Button {
                    Task { await viewModel.save() }
                } label: {
                    if viewModel.isSaving {
                        ProgressView().controlSize(.small)
                    } else {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(!viewModel.canSave || viewModel.isSaving)
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .onAppear { isFocused = true }
    }
}
