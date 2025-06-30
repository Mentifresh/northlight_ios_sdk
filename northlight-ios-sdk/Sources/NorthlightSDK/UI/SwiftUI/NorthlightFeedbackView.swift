import SwiftUI

@available(iOS 14.0, *)
public struct NorthlightFeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var category = ""
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    public var onSuccess: ((String) -> Void)?
    public var onCancel: (() -> Void)?
    public var onError: ((Error) -> Void)?
    
    private let categories = ["", "Feature Request", "UI/UX", "Performance", "Other"]
    
    public init(onSuccess: ((String) -> Void)? = nil,
                onCancel: (() -> Void)? = nil,
                onError: ((Error) -> Void)? = nil) {
        self.onSuccess = onSuccess
        self.onCancel = onCancel
        self.onError = onError
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xLarge) {
                    // Title Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        Label("Title", isRequired: true)
                        
                        TextField("What's your feedback about?", text: $title)
                            .textFieldStyle(NorthlightTextFieldStyle())
                            .disabled(isLoading)
                    }
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        Label("Description", isRequired: true)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)
                                .frame(minHeight: 140)
                                .padding(4)
                                .background(Color(NorthlightTheme.Colors.secondaryBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.input)
                                        .stroke(Color(NorthlightTheme.Colors.border), lineWidth: 1)
                                )
                                .disabled(isLoading)
                            
                            if description.isEmpty {
                                Text("Tell us more about your feedback...")
                                    .foregroundColor(Color(NorthlightTheme.Colors.tertiaryLabel))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    
                    // Category Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        Label("Category", isRequired: false)
                        
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { category in
                                Text(category.isEmpty ? "Select a category" : category).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(NorthlightTheme.Colors.secondaryBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.input)
                                .stroke(Color(NorthlightTheme.Colors.border), lineWidth: 1)
                        )
                        .disabled(isLoading)
                    }
                    
                    // Email Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        Label("Email", isRequired: false)
                        
                        TextField("your@email.com", text: $email)
                            .textFieldStyle(NorthlightTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disabled(isLoading)
                    }
                    
                    // Submit Button
                    Button(action: submitFeedback) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Submit Feedback")
                                .font(NorthlightTheme.Typography.headlineSwiftUI)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(NorthlightTheme.Colors.buttonBackground))
                    .foregroundColor(Color(NorthlightTheme.Colors.buttonText))
                    .cornerRadius(NorthlightTheme.CornerRadius.button)
                    .disabled(isLoading || title.isEmpty || description.isEmpty)
                    .padding(.top, NorthlightTheme.Spacing.small)
                }
                .padding(NorthlightTheme.Spacing.large)
            }
            .background(Color(NorthlightTheme.Colors.background))
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel?()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Submit") {
                            submitFeedback()
                        }
                        .disabled(title.isEmpty || description.isEmpty)
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
    }
    
    private func submitFeedback() {
        guard !title.isEmpty, !description.isEmpty else {
            alertTitle = "Missing Information"
            alertMessage = "Please provide both a title and description."
            showingAlert = true
            return
        }
        
        if !email.isEmpty {
            Northlight.shared.setUserEmail(email)
        }
        
        isLoading = true
        
        Task {
            do {
                let feedbackId = try await Northlight.submitFeedback(
                    title: title,
                    description: description,
                    category: category.isEmpty ? nil : category
                )
                
                await MainActor.run {
                    isLoading = false
                    onSuccess?(feedbackId)
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    onError?(error)
                    
                    if let northlightError = error as? NorthlightError {
                        switch northlightError {
                        case .invalidAPIKey:
                            alertTitle = "Configuration Error"
                            alertMessage = "Invalid API key. Please check your Northlight configuration."
                        case .rateLimitExceeded:
                            alertTitle = "Rate Limit"
                            alertMessage = "Too many requests. Please try again later."
                        case .feedbackLimitReached:
                            alertTitle = "Limit Reached"
                            alertMessage = "You've reached the feedback limit for the free tier."
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
            }
        }
    }
}

// MARK: - Helper Views

@available(iOS 14.0, *)
struct Label: View {
    let text: String
    let isRequired: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            Text(text)
                .font(NorthlightTheme.Typography.captionSwiftUI)
                .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
            
            if isRequired {
                Text("*")
                    .font(NorthlightTheme.Typography.captionSwiftUI)
                    .foregroundColor(Color(NorthlightTheme.Colors.error))
            }
        }
    }
}

// MARK: - Custom Styles

@available(iOS 14.0, *)
struct NorthlightTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Color(NorthlightTheme.Colors.secondaryBackground))
            .overlay(
                RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.input)
                    .stroke(Color(NorthlightTheme.Colors.border), lineWidth: 1)
            )
    }
}