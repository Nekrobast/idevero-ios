import SwiftUI
import UIKit

/// Screen-level feedback stays visible independently of result scroll position.
struct OperationFeedbackView: View {
    @ObservedObject var model: CreateViewModel
    private var spanish: Bool { DisplayLanguage.detect(in: model.analysis?.input ?? model.idea) == .spanish }
    private var message: String? {
        if model.isGenerating && model.analysis != nil { return spanish ? "Actualizando prompt…" : "Updating prompt…" }
        return model.errorMessage ?? model.completionMessage
    }

    var body: some View {
        Group {
            if let message {
                HStack(spacing: 8) {
                    if model.isGenerating { ProgressView().accessibilityHidden(true) }
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(model.errorMessage == nil ? Color.secondary : Color.red)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(message)
                        .accessibilityIdentifier(model.isGenerating ? "generationProgress" : model.errorMessage == nil ? "generationStatus" : "generationError")
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.regularMaterial)
            }
        }
        .onChange(of: model.updateFeedbackRevision) { _, _ in
            if let message { UIAccessibility.post(notification: .announcement, argument: message) }
        }
    }
}
