import UIKit

public protocol NorthlightFeedbackViewControllerDelegate: AnyObject {
    func feedbackViewController(_ controller: NorthlightFeedbackViewController, didSubmitFeedbackWithId feedbackId: String)
    func feedbackViewControllerDidCancel(_ controller: NorthlightFeedbackViewController)
    func feedbackViewController(_ controller: NorthlightFeedbackViewController, didFailWithError error: Error)
}

public class NorthlightFeedbackViewController: UIViewController {
    
    public weak var delegate: NorthlightFeedbackViewControllerDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let categoryTextField = UITextField()
    private let emailTextField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let categories = ["Feature Request", "UI/UX", "Performance", "Other"]
    private var selectedCategory: String?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
        view.backgroundColor = NorthlightTheme.Colors.background
        
        // Configure navigation bar
        navigationItem.title = "Send Feedback"
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
        titleTextField.placeholder = "What's your feedback about?"
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.applyNorthlightStyle()
        
        // Add labels
        let titleLabel = createLabel(text: "Title", isRequired: true)
        let descriptionLabel = createLabel(text: "Description", isRequired: true)
        let categoryLabel = createLabel(text: "Category", isRequired: false)
        let emailLabel = createLabel(text: "Email", isRequired: false)
        
        // Description text view
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.applyNorthlightStyle()
        descriptionTextView.text = "Tell us more about your feedback..."
        descriptionTextView.textColor = NorthlightTheme.Colors.tertiaryLabel
        
        // Category field
        categoryTextField.placeholder = "Select a category"
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryTextField.applyNorthlightStyle()
        
        // Email field
        emailTextField.placeholder = "your@email.com"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.applyNorthlightStyle()
        
        // Submit button
        submitButton.setTitle("Submit Feedback", for: .normal)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.applyNorthlightPrimaryStyle()
        
        // Activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categoryTextField)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(submitButton)
        contentView.addSubview(activityIndicator)
        
        // Set delegate for description text view
        descriptionTextView.delegate = self
        
        setupCategoryPicker()
        updateConstraints(titleLabel: titleLabel, descriptionLabel: descriptionLabel, categoryLabel: categoryLabel, emailLabel: emailLabel)
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
    
    private func setupConstraints() {
        // This method is now empty as constraints are set in updateConstraints
    }
    
    private func updateConstraints(titleLabel: UILabel, descriptionLabel: UILabel, categoryLabel: UILabel, emailLabel: UILabel) {
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
            descriptionTextView.heightAnchor.constraint(equalToConstant: 140),
            
            // Category section
            categoryLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: NorthlightTheme.Spacing.xLarge),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            
            categoryTextField.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: NorthlightTheme.Spacing.xSmall),
            categoryTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            categoryTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            categoryTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Email section
            emailLabel.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: NorthlightTheme.Spacing.xLarge),
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
    
    private func setupCategoryPicker() {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        categoryTextField.inputView = picker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(categoryPickerDone))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: false)
        categoryTextField.inputAccessoryView = toolbar
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
    
    @objc private func categoryPickerDone() {
        categoryTextField.resignFirstResponder()
    }
    
    @objc private func cancelTapped() {
        delegate?.feedbackViewControllerDidCancel(self)
    }
    
    @objc private func submitTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter a title for your feedback.")
            return
        }
        
        guard let description = descriptionTextView.text, 
              !description.isEmpty, 
              description != "Tell us more about your feedback..." else {
            showAlert(title: "Missing Description", message: "Please enter a description for your feedback.")
            return
        }
        
        if let email = emailTextField.text, !email.isEmpty {
            Northlight.shared.setUserEmail(email)
        }
        
        setLoadingState(true)
        
        Task {
            do {
                let feedbackId = try await Northlight.submitFeedback(
                    title: title,
                    description: description,
                    category: selectedCategory
                )
                
                await MainActor.run {
                    setLoadingState(false)
                    delegate?.feedbackViewController(self, didSubmitFeedbackWithId: feedbackId)
                }
            } catch {
                await MainActor.run {
                    setLoadingState(false)
                    showError(error)
                    delegate?.feedbackViewController(self, didFailWithError: error)
                }
            }
        }
    }
    
    private func setLoadingState(_ loading: Bool) {
        submitButton.isEnabled = !loading
        submitButton.setTitle(loading ? "" : "Submit Feedback", for: .normal)
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        
        titleTextField.isEnabled = !loading
        descriptionTextView.isEditable = !loading
        categoryTextField.isEnabled = !loading
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
                message = "You've reached the feedback limit for the free tier."
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

extension NorthlightFeedbackViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
        categoryTextField.text = categories[row]
    }
}

// MARK: - UITextViewDelegate

extension NorthlightFeedbackViewController: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == NorthlightTheme.Colors.tertiaryLabel {
            textView.text = ""
            textView.textColor = NorthlightTheme.Colors.label
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us more about your feedback..."
            textView.textColor = NorthlightTheme.Colors.tertiaryLabel
        }
    }
}

extension Northlight {
    public static func createFeedbackViewController() -> UINavigationController {
        let feedbackVC = NorthlightFeedbackViewController()
        return UINavigationController(rootViewController: feedbackVC)
    }
}