# Northlight iOS SDK

The Northlight iOS SDK enables iOS developers to integrate user feedback collection, bug reporting, and feature voting capabilities into their mobile applications.

## Features

- **Feedback Collection**: Allow users to submit feedback directly from your app
- **Bug Reporting**: Enable users to report bugs with severity levels and device information
- **Feature Voting**: Let users vote on existing feedback items
- **Public Board Access**: Access public feedback and roadmap data
- **SwiftUI & UIKit Support**: Native UI components for both frameworks
- **Automatic Device Info**: Collects relevant device information for debugging

## Requirements

- iOS 13.0+
- Swift 5.5+
- Xcode 13.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Mentifresh/northlight_ios_sdk", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Packages...
2. Enter: `https://github.com/Mentifresh/northlight_ios_sdk`
3. Click "Add Package"

## Quick Start

### 1. Configure the SDK

```swift
import NorthlightSDK

// In your AppDelegate or App struct
Northlight.configure(apiKey: "your_api_key_here")
```

### 2. Set User Information (Optional)

```swift
Northlight.shared.setUserEmail("user@example.com")
Northlight.shared.setUserIdentifier("unique_user_id")
```

### 3. Submit Feedback

```swift
// Using async/await
Task {
    do {
        let feedbackId = try await Northlight.submitFeedback(
            title: "Add dark mode support",
            description: "It would be great to have a dark mode option...",
            category: "UI/UX"
        )
        print("Feedback submitted: \(feedbackId)")
    } catch {
        print("Error: \(error)")
    }
}

// Using completion handler
Northlight.submitFeedback(
    title: "Add dark mode support",
    description: "It would be great to have a dark mode option...",
    category: "UI/UX"
) { result in
    switch result {
    case .success(let feedbackId):
        print("Feedback submitted: \(feedbackId)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### 4. Report Bugs

```swift
try await Northlight.reportBug(
    title: "App crashes on login",
    description: "When I tap the login button, the app crashes",
    severity: .high,
    stepsToReproduce: "1. Open app\n2. Tap login\n3. App crashes"
)
```

### 5. Vote on Feedback

```swift
// User identifier must be set before voting
Northlight.shared.setUserIdentifier("user123")

try await Northlight.vote(feedbackId: "feedback_uuid")
```

## UI Components

### UIKit

```swift
// Present feedback form
let feedbackVC = Northlight.createFeedbackViewController()
feedbackVC.delegate = self
present(feedbackVC, animated: true)

// Present bug report form
let bugReportVC = Northlight.createBugReportViewController()
present(bugReportVC, animated: true)
```

### SwiftUI

```swift
import SwiftUI
import NorthlightSDK

struct ContentView: View {
    @State private var showingFeedback = false
    @State private var showingBugReport = false
    
    var body: some View {
        VStack {
            Button("Send Feedback") {
                showingFeedback = true
            }
            
            Button("Report Bug") {
                showingBugReport = true
            }
        }
        .sheet(isPresented: $showingFeedback) {
            NorthlightFeedbackView(
                onSuccess: { feedbackId in
                    print("Feedback submitted: \(feedbackId)")
                }
            )
        }
        .sheet(isPresented: $showingBugReport) {
            NorthlightBugReportView(
                onSuccess: { bugId in
                    print("Bug reported: \(bugId)")
                }
            )
        }
    }
}
```

## Public Data Access

```swift
// Get public feedback
let feedback = try await Northlight.getPublicFeedback()

// Get roadmap
let roadmapItems = try await Northlight.getRoadmap()
```

## Error Handling

The SDK provides detailed error types:

```swift
do {
    let feedbackId = try await Northlight.submitFeedback(...)
} catch NorthlightError.invalidAPIKey {
    // Handle invalid API key
} catch NorthlightError.rateLimitExceeded {
    // Handle rate limit
} catch NorthlightError.networkError(let error) {
    // Handle network error
} catch {
    // Handle other errors
}
```

## Privacy & Security

- User email is always optional
- Device information is anonymized
- All API calls use HTTPS
- No PII is collected without explicit consent

## Support

- Issues: [GitHub Issues](https://github.com/Mentifresh/northlight_ios_sdk/issues)
- Documentation: [https://docs.northlight.app/ios](https://docs.northlight.app/ios)
- Email: sdk-support@northlight.app

## License

This SDK is available under the MIT license. See the LICENSE file for more info.