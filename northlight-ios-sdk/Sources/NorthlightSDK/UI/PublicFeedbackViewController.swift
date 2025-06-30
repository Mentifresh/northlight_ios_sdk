import UIKit

public protocol PublicFeedbackViewControllerDelegate: AnyObject {
    func publicFeedbackViewControllerDidRequestNewFeedback(_ controller: PublicFeedbackViewController)
    func publicFeedbackViewControllerDidCancel(_ controller: PublicFeedbackViewController)
    func publicFeedbackViewController(_ controller: PublicFeedbackViewController, didVoteForFeedback feedbackId: String)
}

public class PublicFeedbackViewController: UIViewController {
    
    public weak var delegate: PublicFeedbackViewControllerDelegate?
    
    private let tableView = UITableView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel = UILabel()
    private let submitButton = UIButton(type: .system)
    private let refreshControl = UIRefreshControl()
    
    private var feedbackItems: [Feedback] = []
    private var filteredFeedbackItems: [Feedback] = []
    private var votedFeedbackIds: Set<String> = []
    private var selectedStatusFilter: StatusFilter = .all
    
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadVotedFeedbackIds()
        loadFeedback()
    }
    
    private func setupUI() {
        view.backgroundColor = NorthlightTheme.Colors.background
        
        // Configure navigation bar
        navigationItem.title = "Feature Requests"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = NorthlightTheme.Colors.background
        appearance.largeTitleTextAttributes = [.font: NorthlightTheme.Typography.largeTitle]
        appearance.titleTextAttributes = [.font: NorthlightTheme.Typography.headline]
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = NorthlightTheme.Colors.primary
        
        // Add filter button
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        filterButton.tintColor = NorthlightTheme.Colors.primary
        navigationItem.rightBarButtonItem = filterButton
        
        // Table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = NorthlightTheme.Colors.background
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedbackCell.self, forCellReuseIdentifier: FeedbackCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        // Refresh control
        refreshControl.addTarget(self, action: #selector(refreshFeedback), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Loading view
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        loadingView.color = NorthlightTheme.Colors.primary
        
        // Empty state
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No feature requests yet.\nBe the first to submit one!"
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = NorthlightTheme.Typography.body
        emptyStateLabel.textColor = NorthlightTheme.Colors.secondaryLabel
        emptyStateLabel.isHidden = true
        
        // Submit button
        submitButton.setTitle("Submit New Feature Request", for: .normal)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.applyNorthlightPrimaryStyle()
        
        // Add shadow container for button
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.backgroundColor = NorthlightTheme.Colors.background
        buttonContainer.layer.shadowColor = UIColor.black.cgColor
        buttonContainer.layer.shadowOpacity = 0.1
        buttonContainer.layer.shadowOffset = CGSize(width: 0, height: -2)
        buttonContainer.layer.shadowRadius = 8
        
        view.addSubview(tableView)
        view.addSubview(buttonContainer)
        buttonContainer.addSubview(submitButton)
        view.addSubview(loadingView)
        view.addSubview(emptyStateLabel)
        
        setupButtonConstraints(buttonContainer: buttonContainer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupButtonConstraints(buttonContainer: UIView) {
        NSLayoutConstraint.activate([
            buttonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: 80),
            
            submitButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            submitButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            submitButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private func loadVotedFeedbackIds() {
        // Load from UserDefaults
        if let savedIds = UserDefaults.standard.array(forKey: "NorthlightVotedFeedbackIds") as? [String] {
            votedFeedbackIds = Set(savedIds)
        }
    }
    
    private func saveVotedFeedbackIds() {
        UserDefaults.standard.set(Array(votedFeedbackIds), forKey: "NorthlightVotedFeedbackIds")
    }
    
    @objc private func closeTapped() {
        delegate?.publicFeedbackViewControllerDidCancel(self)
    }
    
    @objc private func submitTapped() {
        delegate?.publicFeedbackViewControllerDidRequestNewFeedback(self)
    }
    
    @objc private func refreshFeedback() {
        loadFeedback()
    }
    
    private func loadFeedback() {
        loadingView.startAnimating()
        emptyStateLabel.isHidden = true
        
        Task {
            do {
                let feedback = try await Northlight.getPublicFeedback()
                await MainActor.run {
                    self.feedbackItems = self.sortFeedbackByStatus(feedback)
                    self.applyFilter()
                    self.tableView.reloadData()
                    self.loadingView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.emptyStateLabel.isHidden = !self.filteredFeedbackItems.isEmpty
                }
            } catch {
                await MainActor.run {
                    self.loadingView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.showError(error)
                }
            }
        }
    }
    
    func voteFeedback(at indexPath: IndexPath) {
        guard indexPath.row < filteredFeedbackItems.count else { return }
        
        let feedback = filteredFeedbackItems[indexPath.row]
        
        guard !votedFeedbackIds.contains(feedback.id) else {
            showAlert(title: "Already Voted", message: "You have already voted for this feature request.")
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
                    self.votedFeedbackIds.insert(feedback.id)
                    self.saveVotedFeedbackIds()
                    
                    // Update the feedback item in both arrays
                    if let index = self.feedbackItems.firstIndex(where: { $0.id == feedback.id }) {
                        self.feedbackItems[index].voteCount = newVoteCount
                    }
                    if let index = self.filteredFeedbackItems.firstIndex(where: { $0.id == feedback.id }) {
                        self.filteredFeedbackItems[index].voteCount = newVoteCount
                    }
                    
                    // Reload the cell
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    
                    // Notify delegate
                    self.delegate?.publicFeedbackViewController(self, didVoteForFeedback: feedback.id)
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showError(_ error: Error) {
        let title: String
        let message: String
        
        if let northlightError = error as? NorthlightError {
            switch northlightError {
            case .networkError:
                title = "Network Error"
                message = "Please check your internet connection and try again."
            default:
                title = "Error"
                message = northlightError.errorDescription ?? "An unexpected error occurred."
            }
        } else {
            title = "Error"
            message = error.localizedDescription
        }
        
        showAlert(title: title, message: message)
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
    
    @objc private func filterTapped() {
        let actionSheet = UIAlertController(title: "Filter by Status", message: nil, preferredStyle: .actionSheet)
        
        for filter in StatusFilter.allCases {
            let action = UIAlertAction(title: filter.rawValue, style: .default) { [weak self] _ in
                self?.selectedStatusFilter = filter
                self?.applyFilter()
                self?.tableView.reloadData()
                self?.emptyStateLabel.isHidden = !self?.filteredFeedbackItems.isEmpty ?? true
            }
            
            if selectedStatusFilter == filter {
                action.setValue(true, forKey: "checked")
            }
            
            actionSheet.addAction(action)
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = actionSheet.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(actionSheet, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension PublicFeedbackViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFeedbackItems.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedbackCell.identifier, for: indexPath) as! FeedbackCell
        let feedback = filteredFeedbackItems[indexPath.row]
        let hasVoted = votedFeedbackIds.contains(feedback.id)
        cell.configure(with: feedback, hasVoted: hasVoted)
        cell.onVoteTapped = { [weak self] in
            self?.voteFeedback(at: indexPath)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PublicFeedbackViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let feedback = filteredFeedbackItems[indexPath.row]
        let detailVC = FeedbackDetailViewController(feedback: feedback)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Northlight Extension

extension Northlight {
    public static func presentPublicFeedback(
        onNewFeedback: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController?.topMostViewController() {
                
                let publicFeedbackVC = PublicFeedbackViewController()
                let navigationController = UINavigationController(rootViewController: publicFeedbackVC)
                navigationController.modalPresentationStyle = .fullScreen
                
                let delegate = PublicFeedbackDelegate(
                    navigationController: navigationController,
                    onNewFeedback: onNewFeedback,
                    onCancel: onCancel
                )
                
                publicFeedbackVC.delegate = delegate
                objc_setAssociatedObject(publicFeedbackVC, "NorthlightDelegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                topViewController.present(navigationController, animated: true)
            }
        }
    }
}

// MARK: - Delegate Helper

private class PublicFeedbackDelegate: NSObject, PublicFeedbackViewControllerDelegate {
    private weak var navigationController: UINavigationController?
    private let onNewFeedback: (() -> Void)?
    private let onCancel: (() -> Void)?
    
    init(navigationController: UINavigationController,
         onNewFeedback: (() -> Void)?,
         onCancel: (() -> Void)?) {
        self.navigationController = navigationController
        self.onNewFeedback = onNewFeedback
        self.onCancel = onCancel
    }
    
    func publicFeedbackViewControllerDidRequestNewFeedback(_ controller: PublicFeedbackViewController) {
        // Present feedback form
        let feedbackVC = NorthlightFeedbackViewController()
        let feedbackNav = UINavigationController(rootViewController: feedbackVC)
        
        let feedbackDelegate = FeedbackFromPublicDelegate(
            feedbackNavController: feedbackNav,
            publicNavController: navigationController
        )
        
        feedbackVC.delegate = feedbackDelegate
        objc_setAssociatedObject(feedbackVC, "NorthlightDelegate", feedbackDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        controller.present(feedbackNav, animated: true) {
            self.onNewFeedback?()
        }
    }
    
    func publicFeedbackViewControllerDidCancel(_ controller: PublicFeedbackViewController) {
        navigationController?.dismiss(animated: true) {
            self.onCancel?()
        }
    }
    
    func publicFeedbackViewController(_ controller: PublicFeedbackViewController, didVoteForFeedback feedbackId: String) {
        // Optional: Handle vote event
    }
}

// MARK: - Feedback from Public Delegate

private class FeedbackFromPublicDelegate: NSObject, NorthlightFeedbackViewControllerDelegate {
    private weak var feedbackNavController: UINavigationController?
    private weak var publicNavController: UINavigationController?
    
    init(feedbackNavController: UINavigationController,
         publicNavController: UINavigationController?) {
        self.feedbackNavController = feedbackNavController
        self.publicNavController = publicNavController
    }
    
    func feedbackViewController(_ controller: NorthlightFeedbackViewController, didSubmitFeedbackWithId feedbackId: String) {
        feedbackNavController?.dismiss(animated: true) {
            // Dismiss the public feedback view too
            self.publicNavController?.dismiss(animated: true)
        }
    }
    
    func feedbackViewControllerDidCancel(_ controller: NorthlightFeedbackViewController) {
        feedbackNavController?.dismiss(animated: true)
    }
    
    func feedbackViewController(_ controller: NorthlightFeedbackViewController, didFailWithError error: Error) {
        // Error is already shown by the feedback controller
    }
}