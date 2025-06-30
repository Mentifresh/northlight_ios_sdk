import SwiftUI

public struct PublicFeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var feedbackItems: [Feedback] = []
    @State private var filteredFeedbackItems: [Feedback] = []
    @State private var selectedStatusFilter: StatusFilter = .all
    @State private var isLoading = true
    @State private var showingNewFeedback = false
    @State private var votedFeedbackIds: Set<String> = []
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    enum StatusFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case suggested = "Suggested"
        case approved = "Approved"
        case inProgress = "In Progress"
        case completed = "Completed"
        case rejected = "Rejected"
        
        var statusValue: String? {
            switch self {
            case .all: return nil
            case .pending: return "pending"
            case .suggested: return "suggested"
            case .approved: return "approved"
            case .inProgress: return "in_progress"
            case .completed: return "completed"
            case .rejected: return "rejected"
            }
        }
    }
    
    public var onNewFeedbackSubmitted: ((String) -> Void)?
    public var onCancel: (() -> Void)?
    
    public init(onNewFeedbackSubmitted: ((String) -> Void)? = nil,
                onCancel: (() -> Void)? = nil) {
        self.onNewFeedbackSubmitted = onNewFeedbackSubmitted
        self.onCancel = onCancel
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if filteredFeedbackItems.isEmpty {
                    emptyStateView
                } else {
                    feedbackListView
                }
                
                VStack {
                    Spacer()
                    submitButton
                        .padding(.horizontal, NorthlightTheme.Spacing.large)
                        .padding(.bottom, NorthlightTheme.Spacing.large)
                }
            }
            .background(Color(NorthlightTheme.Colors.background))
            .navigationTitle("Feature Requests")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        onCancel?()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(NorthlightTheme.Colors.primary))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(StatusFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                selectedStatusFilter = filter
                                applyFilter()
                            }) {
                                Label(filter.rawValue, systemImage: selectedStatusFilter == filter ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .foregroundColor(Color(NorthlightTheme.Colors.primary))
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            loadVotedIds()
            loadFeedback()
        }
        .sheet(isPresented: $showingNewFeedback) {
            NorthlightFeedbackView(
                onSuccess: { feedbackId in
                    onNewFeedbackSubmitted?(feedbackId)
                    // Refresh the feedback list to show the new pending item
                    loadFeedback()
                }
            )
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: NorthlightTheme.Spacing.medium) {
            Text("No feature requests yet")
                .font(NorthlightTheme.Typography.headlineSwiftUI)
                .foregroundColor(Color(NorthlightTheme.Colors.label))
            
            Text("Be the first to submit one!")
                .font(NorthlightTheme.Typography.bodySwiftUI)
                .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
        }
    }
    
    private var feedbackListView: some View {
        ScrollView {
            LazyVStack(spacing: NorthlightTheme.Spacing.small) {
                ForEach(filteredFeedbackItems, id: \.id) { feedback in
                    FeedbackRow(
                        feedback: feedback,
                        hasVoted: votedFeedbackIds.contains(feedback.id),
                        onVote: {
                            voteFeedback(feedback)
                        }
                    )
                    .padding(.horizontal, NorthlightTheme.Spacing.medium)
                }
            }
            .padding(.top, NorthlightTheme.Spacing.medium)
            .padding(.bottom, 100) // Space for button
        }
        .refreshable {
            await loadFeedbackAsync()
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            showingNewFeedback = true
        }) {
            Text("Submit New Feature Request")
                .font(NorthlightTheme.Typography.headlineSwiftUI)
                .foregroundColor(Color(NorthlightTheme.Colors.buttonText))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(NorthlightTheme.Colors.buttonBackground))
                .cornerRadius(NorthlightTheme.CornerRadius.button)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
    }
    
    private func loadVotedIds() {
        if let savedIds = UserDefaults.standard.array(forKey: "NorthlightVotedFeedbackIds") as? [String] {
            votedFeedbackIds = Set(savedIds)
        }
    }
    
    private func saveVotedIds() {
        UserDefaults.standard.set(Array(votedFeedbackIds), forKey: "NorthlightVotedFeedbackIds")
    }
    
    private func loadFeedback() {
        Task {
            await loadFeedbackAsync()
        }
    }
    
    @MainActor
    private func loadFeedbackAsync() async {
        isLoading = true
        
        do {
            let feedback = try await Northlight.getPublicFeedback()
            feedbackItems = sortFeedbackByStatus(feedback)
            applyFilter()
            isLoading = false
        } catch {
            isLoading = false
            handleError(error)
        }
    }
    
    private func voteFeedback(_ feedback: Feedback) {
        guard !votedFeedbackIds.contains(feedback.id) else {
            alertTitle = "Already Voted"
            alertMessage = "You have already voted for this feature request."
            showingAlert = true
            return
        }
        
        // Set user identifier if not already set
        if Northlight.shared.getUserIdentifier() == nil {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            Northlight.shared.setUserIdentifier(deviceId)
        }
        
        Task {
            do {
                let newVoteCount = try await Northlight.vote(feedbackId: feedback.id)
                
                await MainActor.run {
                    // Update local state
                    votedFeedbackIds.insert(feedback.id)
                    saveVotedIds()
                    
                    // Update the feedback item in both arrays
                    if let index = feedbackItems.firstIndex(where: { $0.id == feedback.id }) {
                        feedbackItems[index].voteCount = newVoteCount
                    }
                    if let index = filteredFeedbackItems.firstIndex(where: { $0.id == feedback.id }) {
                        filteredFeedbackItems[index].voteCount = newVoteCount
                    }
                }
            } catch {
                await MainActor.run {
                    handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        if let northlightError = error as? NorthlightError {
            switch northlightError {
            case .networkError:
                alertTitle = "Network Error"
                alertMessage = "Please check your internet connection and try again."
            default:
                alertTitle = "Error"
                alertMessage = northlightError.errorDescription ?? "An unexpected error occurred."
            }
        } else {
            alertTitle = "Error"
            alertMessage = error.localizedDescription
        }
        showingAlert = true
    }
    
    private func sortFeedbackByStatus(_ feedback: [Feedback]) -> [Feedback] {
        let statusOrder: [String] = ["pending", "suggested", "approved", "in_progress", "completed", "rejected"]
        
        return feedback.sorted { first, second in
            let firstIndex = statusOrder.firstIndex(of: first.status.lowercased()) ?? Int.max
            let secondIndex = statusOrder.firstIndex(of: second.status.lowercased()) ?? Int.max
            
            if firstIndex != secondIndex {
                return firstIndex < secondIndex
            } else {
                // If same status, sort by vote count
                return first.voteCount > second.voteCount
            }
        }
    }
    
    private func applyFilter() {
        if let statusValue = selectedStatusFilter.statusValue {
            filteredFeedbackItems = feedbackItems.filter { $0.status.lowercased() == statusValue }
        } else {
            filteredFeedbackItems = feedbackItems
        }
    }
}

struct FeedbackRow: View {
    let feedback: Feedback
    let hasVoted: Bool
    let onVote: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: NorthlightTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                Text(feedback.title)
                    .font(NorthlightTheme.Typography.headlineSwiftUI)
                    .foregroundColor(Color(NorthlightTheme.Colors.label))
                    .lineLimit(2)
                
                Text(feedback.description)
                    .font(NorthlightTheme.Typography.bodySwiftUI)
                    .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
                    .lineLimit(3)
                
                HStack {
                    StatusBadge(status: feedback.status)
                    
                    if let category = feedback.category, !category.isEmpty {
                        Text(category)
                            .font(NorthlightTheme.Typography.captionSwiftUI)
                            .foregroundColor(Color(NorthlightTheme.Colors.accent))
                    }
                    
                    Spacer()
                    
                    if let date = ISO8601DateFormatter().date(from: feedback.createdAt) {
                        Text(date, style: .relative)
                            .font(NorthlightTheme.Typography.smallSwiftUI)
                            .foregroundColor(Color(NorthlightTheme.Colors.tertiaryLabel))
                    }
                }
            }
            
            VStack(spacing: NorthlightTheme.Spacing.xxSmall) {
                Button(action: onVote) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(hasVoted ? .white : Color(NorthlightTheme.Colors.primary))
                        .frame(width: 44, height: 44)
                        .background(hasVoted ? Color(NorthlightTheme.Colors.primary) : Color(NorthlightTheme.Colors.background))
                        .overlay(
                            RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.small)
                                .stroke(Color(NorthlightTheme.Colors.border), lineWidth: 1)
                        )
                        .cornerRadius(NorthlightTheme.CornerRadius.small)
                }
                .disabled(hasVoted)
                
                Text("\(feedback.voteCount)")
                    .font(NorthlightTheme.Typography.captionSwiftUI)
                    .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
            }
        }
        .padding(NorthlightTheme.Spacing.medium)
        .background(Color(NorthlightTheme.Colors.secondaryBackground))
        .cornerRadius(NorthlightTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.large)
                .stroke(Color(NorthlightTheme.Colors.border), lineWidth: 1)
        )
    }
}

struct StatusBadge: View {
    let status: String
    
    var backgroundColor: Color {
        switch status.lowercased() {
        case "pending":
            return Color.gray
        case "suggested":
            return Color.orange
        case "approved":
            return Color.green
        case "in_progress":
            return Color.blue
        case "completed":
            return Color.purple
        case "rejected":
            return Color.red
        default:
            return Color.gray
        }
    }
    
    var displayText: String {
        status.split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    var body: some View {
        Text(displayText)
            .font(NorthlightTheme.Typography.smallSwiftUI)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(4)
    }
}