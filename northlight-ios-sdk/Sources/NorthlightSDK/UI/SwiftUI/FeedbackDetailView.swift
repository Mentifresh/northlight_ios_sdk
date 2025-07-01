import SwiftUI

public struct FeedbackDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let feedback: Feedback
    @Binding var hasVoted: Bool
    let onVote: () -> Void
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.large) {
                // Header
                VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.medium) {
                    Text(feedback.title)
                        .font(NorthlightTheme.Typography.titleSwiftUI)
                        .foregroundColor(Color(NorthlightTheme.Colors.label))
                    
                    HStack {
                        StatusBadge(status: feedback.status)
                        
                        if let category = feedback.category, !category.isEmpty {
                            Text(category)
                                .font(NorthlightTheme.Typography.captionSwiftUI)
                                .foregroundColor(Color(NorthlightTheme.Colors.accent))
                        }
                        
                        Spacer()
                        
                        if let date = ISO8601DateFormatter().date(from: feedback.createdAt) {
                            Text(date, style: .date)
                                .font(NorthlightTheme.Typography.smallSwiftUI)
                                .foregroundColor(Color(NorthlightTheme.Colors.tertiaryLabel))
                        }
                    }
                }
                .padding(.horizontal, NorthlightTheme.Spacing.large)
                .padding(.top, NorthlightTheme.Spacing.medium)
                
                Divider()
                    .padding(.horizontal, NorthlightTheme.Spacing.large)
                
                // Description
                VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.small) {
                    Text(String(localized: "feedback.detail.description"))
                        .font(NorthlightTheme.Typography.captionSwiftUI)
                        .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
                    
                    Text(feedback.description)
                        .font(NorthlightTheme.Typography.bodySwiftUI)
                        .foregroundColor(Color(NorthlightTheme.Colors.label))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, NorthlightTheme.Spacing.large)
                
                // Vote Section
                VStack(spacing: NorthlightTheme.Spacing.medium) {
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                            Text(String(localized: "feedback.detail.votes"))
                                .font(NorthlightTheme.Typography.captionSwiftUI)
                                .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
                            
                            Text("\(feedback.voteCount)")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color(NorthlightTheme.Colors.label))
                        }
                        
                        Spacer()
                        
                        Button(action: onVote) {
                            HStack(spacing: NorthlightTheme.Spacing.small) {
                                Image(systemName: hasVoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .font(.system(size: 18, weight: .medium))
                                
                                Text(hasVoted ? String(localized: "feedback.detail.voted") : String(localized: "feedback.detail.vote"))
                                    .font(NorthlightTheme.Typography.headlineSwiftUI)
                            }
                            .foregroundColor(hasVoted ? Color(NorthlightTheme.Colors.primary) : Color(NorthlightTheme.Colors.buttonText))
                            .padding(.horizontal, NorthlightTheme.Spacing.large)
                            .padding(.vertical, NorthlightTheme.Spacing.medium)
                            .background(hasVoted ? Color(NorthlightTheme.Colors.primary).opacity(0.1) : Color(NorthlightTheme.Colors.buttonBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.button)
                                    .stroke(hasVoted ? Color(NorthlightTheme.Colors.primary) : Color.clear, lineWidth: 2)
                            )
                            .cornerRadius(NorthlightTheme.CornerRadius.button)
                        }
                        .disabled(hasVoted)
                    }
                    .padding(.horizontal, NorthlightTheme.Spacing.large)
                    
                    Divider()
                }
                
                // Metadata
                VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.medium) {
                    if feedback.updatedAt != feedback.createdAt,
                       let updatedDate = ISO8601DateFormatter().date(from: feedback.updatedAt) {
                        VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                            Text(String(localized: "feedback.detail.updated"))
                                .font(NorthlightTheme.Typography.captionSwiftUI)
                                .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
                            
                            Text(updatedDate, style: .relative)
                                .font(NorthlightTheme.Typography.bodySwiftUI)
                                .foregroundColor(Color(NorthlightTheme.Colors.label))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        Text(String(localized: "feedback.detail.id"))
                            .font(NorthlightTheme.Typography.captionSwiftUI)
                            .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
                        
                        Text(feedback.id)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(Color(NorthlightTheme.Colors.tertiaryLabel))
                    }
                }
                .padding(.horizontal, NorthlightTheme.Spacing.large)
                .padding(.bottom, NorthlightTheme.Spacing.xLarge)
            }
        }
        .background(Color(NorthlightTheme.Colors.background))
        .navigationTitle(String(localized: "feedback.detail.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(String(localized: "common.close")) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        FeedbackDetailView(
            feedback: Feedback(
                id: "123",
                projectId: "preview-project",
                title: "Add dark mode support",
                description: "It would be great to have a dark mode option for the app. This would help reduce eye strain when using the app at night.",
                status: "in_progress",
                category: "Feature Request",
                voteCount: 42,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 7)),
                updatedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400))
            ),
            hasVoted: .constant(false),
            onVote: {}
        )
    }
}