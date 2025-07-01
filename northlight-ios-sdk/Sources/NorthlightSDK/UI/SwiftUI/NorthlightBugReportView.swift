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
                        NorthlightLabel(text: String(localized: "feedback.form.title.label"), isRequired: true)
                        
                        TextField(String(localized: "bug.form.title.placeholder"), text: $title)
                            .textFieldStyle(NorthlightTextFieldStyle())
                            .disabled(isLoading)
                    }
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        NorthlightLabel(text: String(localized: "feedback.form.description.label"), isRequired: true)
                        
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
                                Text(String(localized: "bug.form.description.placeholder"))
                                    .foregroundColor(Color(NorthlightTheme.Colors.tertiaryLabel))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    
                    // Severity Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        Text(String(localized: "bug.form.severity.label"))
                            .font(NorthlightTheme.Typography.captionSwiftUI)
                            .foregroundColor(Color(NorthlightTheme.Colors.secondaryLabel))
                        
                        Picker("Severity", selection: $severity) {
                            Text(String(localized: "bug.form.severity.low")).tag(BugSeverity.low)
                            Text(String(localized: "bug.form.severity.medium")).tag(BugSeverity.medium)
                            Text(String(localized: "bug.form.severity.high")).tag(BugSeverity.high)
                            Text(String(localized: "bug.form.severity.critical")).tag(BugSeverity.critical)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .disabled(isLoading)
                    }
                    
                    // Steps to Reproduce Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        NorthlightLabel(text: String(localized: "bug.form.steps.label"), isRequired: false)
                        
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
                                Text(String(localized: "bug.form.steps.placeholder"))
                                    .foregroundColor(Color(NorthlightTheme.Colors.tertiaryLabel))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    
                    // Email Section
                    VStack(alignment: .leading, spacing: NorthlightTheme.Spacing.xSmall) {
                        NorthlightLabel(text: String(localized: "feedback.form.email.label"), isRequired: false)
                        
                        TextField(String(localized: "feedback.form.email.placeholder"), text: $email)
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
                            Text(String(localized: "bug.form.submit.button"))
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
            .navigationTitle(String(localized: "bug.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.cancel")) {
                        onCancel?()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button(String(localized: "common.submit")) {
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
                    dismissButton: .default(Text(String(localized: "common.ok")))
                )
            }
        }
    }
    
    private func submitBugReport() {
        guard !title.isEmpty, !description.isEmpty else {
            alertTitle = String(localized: "error.missing_info.title")
            alertMessage = String(localized: "error.missing_info.message")
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
                            alertTitle = String(localized: "error.configuration.title")
                            alertMessage = String(localized: "error.configuration.message")
                        case .rateLimitExceeded:
                            alertTitle = String(localized: "error.rate_limit.title")
                            alertMessage = String(localized: "error.rate_limit.message")
                        case .feedbackLimitReached:
                            alertTitle = String(localized: "error.limit_reached.title")
                            alertMessage = String(localized: "error.limit_reached.message")
                        case .networkError:
                            alertTitle = String(localized: "error.network.title")
                            alertMessage = String(localized: "error.network.message")
                        default:
                            alertTitle = String(localized: "error.generic.title")
                            alertMessage = northlightError.errorDescription ?? "An unexpected error occurred."
                        }
                    } else {
                        alertTitle = String(localized: "error.generic.title")
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