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
            Form {
                Section(header: Text("Feedback Details")) {
                    TextField("Title (required)", text: $title)
                        .disabled(isLoading)
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Description (required)")
                                        .foregroundColor(Color(.placeholderText))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                        .disabled(isLoading)
                }
                
                Section(header: Text("Optional Information")) {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .disabled(isLoading)
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(isLoading)
                }
            }
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