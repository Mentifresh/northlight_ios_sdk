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
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "Send Feedback"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        titleTextField.placeholder = "Title (required)"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        categoryTextField.placeholder = "Category (optional)"
        categoryTextField.borderStyle = .roundedRect
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        
        emailTextField.placeholder = "Email (optional)"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        submitButton.setTitle("Submit Feedback", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(categoryTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(submitButton)
        contentView.addSubview(activityIndicator)
        
        setupCategoryPicker()
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
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 150),
            
            categoryTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            categoryTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryTextField.heightAnchor.constraint(equalToConstant: 44),
            
            emailTextField.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 16),
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
        
        guard let description = descriptionTextView.text, !description.isEmpty else {
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

extension Northlight {
    public static func createFeedbackViewController() -> UINavigationController {
        let feedbackVC = NorthlightFeedbackViewController()
        return UINavigationController(rootViewController: feedbackVC)
    }
}