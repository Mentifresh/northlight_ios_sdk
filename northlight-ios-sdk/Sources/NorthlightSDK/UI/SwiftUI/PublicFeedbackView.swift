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
    @State private var selectedFeedback: Feedback?
    @State private var showingFeedbackDetail = false
    
    enum StatusFilter: CaseIterable {
        case all
        case pending
        case suggested
        case approved
        case inProgress
        case completed
        case rejected
        
        var displayName: String {
            switch self {
            case .all:
                return String(localized: "feedback.filter.all")
            case .pending:
                return String(localized: "feedback.filter.pending")
            case .suggested:
                return String(localized: "feedback.filter.suggested")
            case .approved:
                return String(localized: "feedback.filter.approved")
            case .inProgress:
                return String(localized: "feedback.filter.in_progress")
            case .completed:
                return String(localized: "feedback.filter.completed")
            case .rejected:
                return String(localized: "feedback.filter.rejected")
            }
        }
        
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
                Color(NorthlightTheme.Colors.background)
                    .ignoresSafeArea()
                
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
                    VStack(spacing: 0) {
                        submitButton
                            .padding(.horizontal, NorthlightTheme.Spacing.large)
                            .padding(.top, NorthlightTheme.Spacing.medium)
                            .padding(.bottom, NorthlightTheme.Spacing.xLarge)
                    }
                    .background(
                        Color(NorthlightTheme.Colors.background)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                    )
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle(String(localized: "feedback.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.close")) {
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
                                HStack {
                                    if selectedStatusFilter == filter {
                                        Image(systemName: "checkmark")
                                    }
                                    Text(filter.displayName)
                                }
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
                    dismissButton: .default(Text(String(localized: "common.ok")))
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
        .sheet(isPresented: $showingFeedbackDetail) {
            if let feedback = selectedFeedback {
                NavigationView {
                    FeedbackDetailView(
                        feedback: feedback,
                        hasVoted: .constant(votedFeedbackIds.contains(feedback.id)),
                        onVote: {
                            showingFeedbackDetail = false
                            voteFeedback(feedback)
                        }
                    )
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: NorthlightTheme.Spacing.medium) {
            Text(String(localized: "feedback.empty.title"))
                .font(NorthlightTheme.Typography.headlineSwiftUI)
                .foregroundColor(Color(NorthlightTheme.Colors.label))
            
            Text(String(localized: "feedback.empty.subtitle"))
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
                        },
                        onTap: {
                            selectedFeedback = feedback
                            showingFeedbackDetail = true
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
            Text(String(localized: "feedback.submit.button"))
                .font(NorthlightTheme.Typography.headlineSwiftUI)
                .foregroundColor(Color(NorthlightTheme.Colors.buttonText))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(NorthlightTheme.Colors.buttonBackground))
                .cornerRadius(NorthlightTheme.CornerRadius.button)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                .padding(.bottom, 8)
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
            alertTitle = String(localized: "error.already_voted.title")
            alertMessage = String(localized: "error.already_voted.message")
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
                alertTitle = String(localized: "error.network.title")
                alertMessage = String(localized: "error.network.message")
            default:
                alertTitle = String(localized: "error.generic.title")
                alertMessage = northlightError.errorDescription ?? String(localized: "error.generic.message")
            }
        } else {
            alertTitle = String(localized: "error.generic.title")
            alertMessage = error.localizedDescription
        }
        showingAlert = true
    }
    
    private func sortFeedbackByStatus(_ feedback: [Feedback]) -> [Feedback] {
        // Status priority for tiebreakers (lower number = higher priority)
        let statusPriority: [String: Int] = [
            "in_progress": 1,
            "approved": 2,
            "suggested": 3,
            "pending": 4,
            "rejected": 5,
            "completed": 6  // Always at bottom
        ]
        
        return feedback.sorted { first, second in
            // Completed items always go to bottom
            if first.status.lowercased() == "completed" && second.status.lowercased() != "completed" {
                return false
            }
            if first.status.lowercased() != "completed" && second.status.lowercased() == "completed" {
                return true
            }
            
            // Sort by vote count first (higher votes first)
            if first.voteCount != second.voteCount {
                return first.voteCount > second.voteCount
            }
            
            // If vote counts are equal, sort by status priority
            let firstPriority = statusPriority[first.status.lowercased()] ?? Int.max
            let secondPriority = statusPriority[second.status.lowercased()] ?? Int.max
            return firstPriority < secondPriority
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
    let onTap: () -> Void
    
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
            
            VStack(spacing: NorthlightTheme.Spacing.xSmall) {
                Button(action: onVote) {
                    Image(systemName: hasVoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(hasVoted ? Color(NorthlightTheme.Colors.primary) : Color(NorthlightTheme.Colors.secondaryLabel))
                        .frame(width: 44, height: 44)
                        .background(Color(NorthlightTheme.Colors.background))
                        .overlay(
                            RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.small)
                                .stroke(hasVoted ? Color(NorthlightTheme.Colors.primary) : Color(NorthlightTheme.Colors.border), lineWidth: hasVoted ? 2 : 1)
                        )
                        .cornerRadius(NorthlightTheme.CornerRadius.small)
                }
                .disabled(hasVoted)
                
                Text("\(feedback.voteCount)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(hasVoted ? Color(NorthlightTheme.Colors.primary) : Color(NorthlightTheme.Colors.label))
            }
        }
        .padding(NorthlightTheme.Spacing.medium)
        .background(Color(NorthlightTheme.Colors.secondaryBackground))
        .cornerRadius(NorthlightTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.large)
                .stroke(Color(NorthlightTheme.Colors.border), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct StatusBadge: View {
    let status: String
    
    var backgroundColor: Color {
        switch status.lowercased() {
        case "pending":
            return Color(NorthlightTheme.Colors.statusPending)
        case "suggested":
            return Color(NorthlightTheme.Colors.statusSuggested)
        case "approved":
            return Color(NorthlightTheme.Colors.statusApproved)
        case "in_progress":
            return Color(NorthlightTheme.Colors.statusInProgress)
        case "completed":
            return Color(NorthlightTheme.Colors.statusCompleted)
        case "rejected":
            return Color(NorthlightTheme.Colors.statusRejected)
        default:
            return Color(NorthlightTheme.Colors.statusPending)
        }
    }
    
    var displayText: String {
        switch status.lowercased() {
        case "pending":
            return String(localized: "status.pending")
        case "suggested":
            return String(localized: "status.suggested")
        case "approved":
            return String(localized: "status.approved")
        case "in_progress":
            return String(localized: "status.in_progress")
        case "completed":
            return String(localized: "status.completed")
        case "rejected":
            return String(localized: "status.rejected")
        default:
            return status.capitalized
        }
    }
    
    var body: some View {
        Text(displayText)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Color(NorthlightTheme.Colors.label))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(backgroundColor, lineWidth: 0.5)
            )
            .cornerRadius(6)
    }
}

#Preview {
    StatusBadge(status: "in_progress")
}
