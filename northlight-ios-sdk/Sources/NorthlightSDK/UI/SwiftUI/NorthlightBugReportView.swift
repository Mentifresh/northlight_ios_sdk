import SwiftUI

public struct NorthlightBugReportView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var stepsToReproduce = ""
    @State private var severity: BugSeverity = .medium
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    public var onSuccess: ((String) -> Void)?
    public var onCancel: (() -> Void)?
    public var onError: ((Error) -> Void)?
    
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
                        NorthlightLabel(text: "Title", isRequired: true)
                        
                        TextField("Brief summary of the issue", text: $title)
                            .textFieldStyle(NorthlightTextFieldStyle())
                            .disabled(isLoading)
                    }
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        NorthlightLabel(text: "Description", isRequired: true)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)
                                .frame(minHeight: 120)
                                .padding(4)
                                .background(Color(NorthlightTheme.Colors.secondaryBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.input)
                                        .stroke(Color(NorthlightTheme.Colors.border), lineWidth: 1)
                                )
                                .disabled(isLoading)
                            
                            if description.isEmpty {
                                Text("Describe what happened...")
                                    .foregroundColor(Color(NorthlightTheme.Colors.tertiaryLabel))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    
                    // Severity Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        Text("Severity")
                            .font(NorthlightTheme.Typography.captionSwiftUI)
                            .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
                        
                        Picker("Severity", selection: $severity) {
                            Text("Low").tag(BugSeverity.low)
                            Text("Medium").tag(BugSeverity.medium)
                            Text("High").tag(BugSeverity.high)
                            Text("Critical").tag(BugSeverity.critical)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .disabled(isLoading)
                    }
                    
                    // Steps to Reproduce Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        NorthlightLabel(text: "Steps to Reproduce", isRequired: false)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $stepsToReproduce)
                                .frame(minHeight: 100)
                                .padding(4)
                                .background(Color(NorthlightTheme.Colors.secondaryBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: NorthlightTheme.CornerRadius.input)
                                        .stroke(Color(NorthlightTheme.Colors.border), lineWidth: 1)
                                )
                                .disabled(isLoading)
                            
                            if stepsToReproduce.isEmpty {
                                Text("1.\n2.\n3.")
                                    .foregroundColor(Color(NorthlightTheme.Colors.tertiaryLabel))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    
                    // Email Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        NorthlightLabel(text: "Email", isRequired: false)
                        
                        TextField("your@email.com", text: $email)
                            .textFieldStyle(NorthlightTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disabled(isLoading)
                    }
                    
                    // Submit Button
                    Button(action: submitBugReport) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Submit Bug Report")
                                .font(NorthlightTheme.Typography.headlineSwiftUI)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(NorthlightTheme.Colors.error))
                    .foregroundColor(.white)
                    .cornerRadius(NorthlightTheme.CornerRadius.button)
                    .disabled(isLoading || title.isEmpty || description.isEmpty)
                    .padding(.top, NorthlightTheme.Spacing.small)
                }
                .padding(NorthlightTheme.Spacing.large)
            }
            .background(Color(NorthlightTheme.Colors.background))
            .navigationTitle("Report Bug")
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
                            submitBugReport()
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
    
    private func submitBugReport() {
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
                let bugId = try await Northlight.reportBug(
                    title: title,
                    description: description,
                    severity: severity,
                    stepsToReproduce: stepsToReproduce.isEmpty ? nil : stepsToReproduce
                )
                
                await MainActor.run {
                    isLoading = false
                    onSuccess?(bugId)
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
                            alertMessage = "You've reached the limit for the free tier."
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

#Preview {
    NorthlightBugReportView()
}