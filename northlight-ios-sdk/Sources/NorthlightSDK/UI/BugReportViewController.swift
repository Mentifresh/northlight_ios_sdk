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
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "Report Bug"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        titleTextField.placeholder = "Bug title (required)"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.text = "Description (required)"
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descriptionLabel.textColor = .label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        severityLabel.text = "Severity"
        severityLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        severityLabel.textColor = .label
        severityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        severitySegmentedControl.selectedSegmentIndex = 1
        severitySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        stepsLabel.text = "Steps to Reproduce (optional)"
        stepsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        stepsLabel.textColor = .label
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stepsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        stepsTextView.layer.borderWidth = 1
        stepsTextView.layer.cornerRadius = 8
        stepsTextView.font = UIFont.systemFont(ofSize: 16)
        stepsTextView.translatesAutoresizingMaskIntoConstraints = false
        
        emailTextField.placeholder = "Email (optional)"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        submitButton.setTitle("Submit Bug Report", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        submitButton.backgroundColor = .systemRed
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(severityLabel)
        contentView.addSubview(severitySegmentedControl)
        contentView.addSubview(stepsLabel)
        contentView.addSubview(stepsTextView)
        contentView.addSubview(emailTextField)
        contentView.addSubview(submitButton)
        contentView.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
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
            
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),
            
            severityLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            severityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            severityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            severitySegmentedControl.topAnchor.constraint(equalTo: severityLabel.bottomAnchor, constant: 8),
            severitySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            severitySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            stepsLabel.topAnchor.constraint(equalTo: severitySegmentedControl.bottomAnchor, constant: 16),
            stepsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stepsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            stepsTextView.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 8),
            stepsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stepsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stepsTextView.heightAnchor.constraint(equalToConstant: 100),
            
            emailTextField.topAnchor.constraint(equalTo: stepsTextView.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            submitButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 32),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
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
        
        guard let description = descriptionTextView.text, !description.isEmpty else {
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

extension Northlight {
    public static func createBugReportViewController() -> UINavigationController {
        let bugReportVC = NorthlightBugReportViewController()
        return UINavigationController(rootViewController: bugReportVC)
    }
}