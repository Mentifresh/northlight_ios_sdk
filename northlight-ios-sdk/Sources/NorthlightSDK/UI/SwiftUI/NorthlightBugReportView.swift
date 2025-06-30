import SwiftUI

@available(iOS 14.0, *)
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
            Form {
                Section(header: Text("Bug Details")) {
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
                    
                    Picker("Severity", selection: $severity) {
                        Text("Low").tag(BugSeverity.low)
                        Text("Medium").tag(BugSeverity.medium)
                        Text("High").tag(BugSeverity.high)
                        Text("Critical").tag(BugSeverity.critical)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(isLoading)
                }
                
                Section(header: Text("Additional Information")) {
                    TextEditor(text: $stepsToReproduce)
                        .frame(minHeight: 80)
                        .overlay(
                            Group {
                                if stepsToReproduce.isEmpty {
                                    Text("Steps to reproduce (optional)")
                                        .foregroundColor(Color(.placeholderText))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                        .disabled(isLoading)
                    
                    TextField("Email (optional)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(isLoading)
                }
            }
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
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}