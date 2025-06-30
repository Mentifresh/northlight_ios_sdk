import UIKit

public protocol NorthlightBugReportViewControllerDelegate: AnyObject {
    func bugReportViewController(_ controller: NorthlightBugReportViewController, didSubmitBugWithId bugId: String)
    func bugReportViewControllerDidCancel(_ controller: NorthlightBugReportViewController)
    func bugReportViewController(_ controller: NorthlightBugReportViewController, didFailWithError error: Error)
}

public class NorthlightBugReportViewController: UIViewController {
    
    public weak var delegate: NorthlightBugReportViewControllerDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let stepsTextView = UITextView()
    private let severitySegmentedControl = UISegmentedControl(items: ["Low", "Medium", "High", "Critical"])
    private let emailTextField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let severityLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let stepsLabel = UILabel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
        view.backgroundColor = NorthlightTheme.Colors.background
        
        // Configure navigation bar
        navigationItem.title = "Report Bug"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = NorthlightTheme.Colors.background
        appearance.titleTextAttributes = [.font: NorthlightTheme.Typography.headline]
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = NorthlightTheme.Colors.primary
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title field
        titleTextField.placeholder = "Brief summary of the issue"
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.applyNorthlightStyle()
        
        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        updateDescriptionLabel()
        
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.applyNorthlightStyle()
        descriptionTextView.text = "Describe what happened..."
        descriptionTextView.textColor = NorthlightTheme.Colors.tertiaryLabel
        descriptionTextView.delegate = self
        
        // Severity
        severityLabel.text = "Severity"
        severityLabel.font = NorthlightTheme.Typography.caption
        severityLabel.textColor = NorthlightTheme.Colors.secondaryLabel
        severityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure segmented control with modern styling
        severitySegmentedControl.selectedSegmentIndex = 1
        severitySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        severitySegmentedControl.backgroundColor = NorthlightTheme.Colors.secondaryBackground
        severitySegmentedControl.selectedSegmentTintColor = NorthlightTheme.Colors.primary
        
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: NorthlightTheme.Colors.label]
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        severitySegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        severitySegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        // Steps to reproduce
        stepsLabel.text = "Steps to Reproduce (optional)"
        stepsLabel.font = NorthlightTheme.Typography.caption
        stepsLabel.textColor = NorthlightTheme.Colors.secondaryLabel
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stepsTextView.translatesAutoresizingMaskIntoConstraints = false
        stepsTextView.applyNorthlightStyle()
        stepsTextView.text = "1. \n2. \n3. "
        stepsTextView.textColor = NorthlightTheme.Colors.tertiaryLabel
        stepsTextView.delegate = self
        
        // Email field
        let emailLabel = createLabel(text: "Email", isRequired: false)
        emailTextField.placeholder = "your@email.com"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.applyNorthlightStyle()
        
        // Submit button
        submitButton.setTitle("Submit Bug Report", for: .normal)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.applyNorthlightPrimaryStyle()
        submitButton.backgroundColor = NorthlightTheme.Colors.error
        
        // Activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let titleLabel = createLabel(text: "Title", isRequired: true)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(severityLabel)
        contentView.addSubview(severitySegmentedControl)
        contentView.addSubview(stepsLabel)
        contentView.addSubview(stepsTextView)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(submitButton)
        contentView.addSubview(activityIndicator)
        
        updateConstraints(titleLabel: titleLabel, emailLabel: emailLabel)
    }
    
    private func createLabel(text: String, isRequired: Bool) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NorthlightTheme.Typography.caption
        label.textColor = NorthlightTheme.Colors.secondaryLabel
        
        if isRequired {
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.append(NSAttributedString(string: " *", attributes: [.foregroundColor: NorthlightTheme.Colors.error]))
            label.attributedText = attributedText
        } else {
            label.text = text
        }
        
        return label
    }
    
    private func updateDescriptionLabel() {
        let attributedText = NSMutableAttributedString(string: "Description")
        attributedText.append(NSAttributedString(string: " *", attributes: [.foregroundColor: NorthlightTheme.Colors.error]))
        descriptionLabel.attributedText = attributedText
        descriptionLabel.font = NorthlightTheme.Typography.caption
        descriptionLabel.textColor = NorthlightTheme.Colors.secondaryLabel
    }
    
    private func setupConstraints() {
        // This method is now empty as constraints are set in updateConstraints
    }
    
    private func updateConstraints(titleLabel: UILabel, emailLabel: UILabel) {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title section
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: NorthlightTheme.Spacing.large),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: NorthlightTheme.Spacing.xSmall),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            titleTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Description section
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: NorthlightTheme.Spacing.xLarge),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: NorthlightTheme.Spacing.xSmall),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),
            
            // Severity section
            severityLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: NorthlightTheme.Spacing.xLarge),
            severityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            severityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            
            severitySegmentedControl.topAnchor.constraint(equalTo: severityLabel.bottomAnchor, constant: NorthlightTheme.Spacing.xSmall),
            severitySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            severitySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            severitySegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            // Steps section
            stepsLabel.topAnchor.constraint(equalTo: severitySegmentedControl.bottomAnchor, constant: NorthlightTheme.Spacing.xLarge),
            stepsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            stepsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            
            stepsTextView.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: NorthlightTheme.Spacing.xSmall),
            stepsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            stepsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            stepsTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // Email section
            emailLabel.topAnchor.constraint(equalTo: stepsTextView.bottomAnchor, constant: NorthlightTheme.Spacing.xLarge),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: NorthlightTheme.Spacing.xSmall),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            emailTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Submit button
            submitButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: NorthlightTheme.Spacing.xxLarge),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            submitButton.heightAnchor.constraint(equalToConstant: 52),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -NorthlightTheme.Spacing.xxLarge),
            
            activityIndicator.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor)
        ])
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = keyboardSize.height
        scrollView.scrollIndicatorInsets.bottom = keyboardSize.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc private func cancelTapped() {
        delegate?.bugReportViewControllerDidCancel(self)
    }
    
    @objc private func submitTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter a title for the bug.")
            return
        }
        
        guard let description = descriptionTextView.text, 
              !description.isEmpty,
              description != "Describe what happened..." else {
            showAlert(title: "Missing Description", message: "Please enter a description of the bug.")
            return
        }
        
        if let email = emailTextField.text, !email.isEmpty {
            Northlight.shared.setUserEmail(email)
        }
        
        let severityMapping: [Int: BugSeverity] = [0: .low, 1: .medium, 2: .high, 3: .critical]
        let severity = severityMapping[severitySegmentedControl.selectedSegmentIndex] ?? .medium
        
        setLoadingState(true)
        
        Task {
            do {
                let bugId = try await Northlight.reportBug(
                    title: title,
                    description: description,
                    severity: severity,
                    stepsToReproduce: stepsTextView.text.isEmpty ? nil : stepsTextView.text
                )
                
                await MainActor.run {
                    setLoadingState(false)
                    delegate?.bugReportViewController(self, didSubmitBugWithId: bugId)
                }
            } catch {
                await MainActor.run {
                    setLoadingState(false)
                    showError(error)
                    delegate?.bugReportViewController(self, didFailWithError: error)
                }
            }
        }
    }
    
    private func setLoadingState(_ loading: Bool) {
        submitButton.isEnabled = !loading
        submitButton.setTitle(loading ? "" : "Submit Bug Report", for: .normal)
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        
        titleTextField.isEnabled = !loading
        descriptionTextView.isEditable = !loading
        stepsTextView.isEditable = !loading
        severitySegmentedControl.isEnabled = !loading
        emailTextField.isEnabled = !loading
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
            case .invalidAPIKey:
                title = "Configuration Error"
                message = "Invalid API key. Please check your Northlight configuration."
            case .rateLimitExceeded:
                title = "Rate Limit"
                message = "Too many requests. Please try again later."
            case .feedbackLimitReached:
                title = "Limit Reached"
                message = "You've reached the limit for the free tier."
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
}

// MARK: - UITextViewDelegate

extension NorthlightBugReportViewController: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == descriptionTextView && textView.textColor == NorthlightTheme.Colors.tertiaryLabel {
            textView.text = ""
            textView.textColor = NorthlightTheme.Colors.label
        } else if textView == stepsTextView && textView.text == "1. \n2. \n3. " {
            textView.text = ""
            textView.textColor = NorthlightTheme.Colors.label
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descriptionTextView && textView.text.isEmpty {
            textView.text = "Describe what happened..."
            textView.textColor = NorthlightTheme.Colors.tertiaryLabel
        } else if textView == stepsTextView && textView.text.isEmpty {
            textView.text = "1. \n2. \n3. "
            textView.textColor = NorthlightTheme.Colors.tertiaryLabel
        }
    }
}

extension Northlight {
    public static func createBugReportViewController() -> UINavigationController {
        let bugReportVC = NorthlightBugReportViewController()
        return UINavigationController(rootViewController: bugReportVC)
    }
}