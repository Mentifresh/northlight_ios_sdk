# Northlight iOS SDK Specification

## Overview
The Northlight SDK enables iOS developers to integrate user feedback collection, bug reporting, and feature voting capabilities into their mobile applications. This document provides the complete specification for implementing the iOS SDK.

## SDK Requirements

### Minimum Requirements
- iOS 13.0+
- Swift 5.5+
- Xcode 13.0+

### Dependencies
- URLSession for network requests
- UIKit for UI components (optional feedback UI)
- SwiftUI support (optional)

## Core Features

### 1. Feedback Collection
Allow users to submit feedback directly from your app with optional email collection.

### 2. Bug Reporting
Enable users to report bugs with severity levels, steps to reproduce, and automatic device information collection.

### 3. Feature Voting
Let users vote on existing feedback items to help prioritize development.

### 4. Public Board Access
Provide access to public feedback, roadmap, and bug tracking boards.

## API Endpoints

### Base URL
```
https://northlight.app/api/v1
```

### Authentication
All requests must include the API key in the header:
```
X-API-Key: your_project_api_key
X-Platform: ios
```

### 1. Submit Feedback
```
POST /feedback
Content-Type: application/json

{
  "title": "string (required, max 255 chars)",
  "description": "string (required)",
  "category": "string (optional)",
  "user_email": "string (optional, valid email)",
  "device_info": {
    "model": "iPhone 14 Pro",
    "os_version": "17.2",
    "app_version": "1.0.0",
    "screen_resolution": "1170x2532",
    "locale": "en_US"
  }
}

Response:
{
  "success": true,
  "feedback_id": "uuid"
}
```

### 2. Submit Bug Report
```
POST /bugs
Content-Type: application/json

{
  "title": "string (required, max 255 chars)",
  "description": "string (required)",
  "severity": "low|medium|high|critical (optional, default: medium)",
  "steps_to_reproduce": "string (optional)",
  "user_email": "string (optional, valid email)",
  "device_info": {
    "model": "iPhone 14 Pro",
    "os_version": "17.2",
    "app_version": "1.0.0",
    "screen_resolution": "1170x2532",
    "locale": "en_US",
    "free_memory": "2GB",
    "battery_level": 0.75,
    "network_type": "wifi"
  }
}

Response:
{
  "success": true,
  "bug_id": "uuid"
}
```

### 3. Vote on Feedback
```
POST /feedback/{feedback_id}/vote
Content-Type: application/json

{
  "user_identifier": "string (required, unique user ID or hashed identifier)"
}

Response:
{
  "success": true,
  "vote_count": 42
}
```

### 4. Get Public Feedback
```
GET /feedback?status=approved,suggested

Response:
{
  "feedback": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string",
      "status": "approved|suggested",
      "category": "string",
      "vote_count": 42,
      "created_at": "ISO 8601 timestamp"
    }
  ]
}
```

### 5. Get Public Roadmap
```
GET /roadmap

Response:
{
  "roadmap_items": [
    {
      "id": "uuid",
      "feature": {
        "title": "string",
        "description": "string"
      },
      "position": 1,
      "estimated_date": "2024-Q2"
    }
  ]
}
```

## SDK Implementation Guide

### 1. Installation

#### Swift Package Manager (Recommended)
```swift
dependencies: [
    .package(url: "https://github.com/northlight/northlight-ios-sdk", from: "1.0.0")
]
```

#### CocoaPods
```ruby
pod 'NorthlightSDK', '~> 1.0'
```

### 2. Basic Integration

#### Initialize SDK
```swift
import NorthlightSDK

// In AppDelegate or App struct
Northlight.configure(apiKey: "your_api_key_here")
```

#### Set User Information (Optional)
```swift
Northlight.shared.setUserEmail("user@example.com")
Northlight.shared.setUserIdentifier("unique_user_id")
```

### 3. Core SDK Methods

#### Submit Feedback
```swift
Northlight.submitFeedback(
    title: "Add dark mode support",
    description: "It would be great to have a dark mode option...",
    category: "UI/UX", // optional
    completion: { result in
        switch result {
        case .success(let feedbackId):
            print("Feedback submitted: \(feedbackId)")
        case .failure(let error):
            print("Error: \(error)")
        }
    }
)
```

#### Report Bug
```swift
Northlight.reportBug(
    title: "App crashes on login",
    description: "When I tap the login button, the app crashes",
    severity: .high,
    stepsToReproduce: "1. Open app\n2. Tap login\n3. App crashes",
    completion: { result in
        // Handle result
    }
)
```

#### Vote on Feedback
```swift
Northlight.vote(
    feedbackId: "feedback_uuid",
    completion: { result in
        switch result {
        case .success(let voteCount):
            print("New vote count: \(voteCount)")
        case .failure(let error):
            print("Vote failed: \(error)")
        }
    }
)
```

### 4. UI Components (Optional)

#### Present Feedback Form
```swift
let feedbackVC = Northlight.createFeedbackViewController()
feedbackVC.delegate = self
present(feedbackVC, animated: true)
```

#### Present Bug Report Form
```swift
let bugReportVC = Northlight.createBugReportViewController()
present(bugReportVC, animated: true)
```

### 5. Device Information Collection

The SDK should automatically collect:
- Device model
- iOS version
- App version (from Info.plist)
- Screen resolution
- Locale/Language
- Available memory (for bug reports)
- Battery level (for bug reports)
- Network type (WiFi/Cellular)

### 6. Error Handling

```swift
enum NorthlightError: Error {
    case invalidAPIKey
    case networkError(Error)
    case rateLimitExceeded
    case feedbackLimitReached // Free tier: 5 items max
    case invalidInput(String)
    case serverError(statusCode: Int)
}
```

### 7. Rate Limiting

The API implements rate limiting based on subscription tier:
- Free: 100 requests/minute
- Starter: 1,000 requests/minute
- Growth: 5,000 requests/minute
- Enterprise: Unlimited

Handle 429 (Too Many Requests) responses appropriately.

### 8. Privacy & Security

#### Data Collection
- User email is always optional
- Device information should be anonymized
- No PII should be collected without explicit consent
- Support App Tracking Transparency (ATT) framework

#### Network Security
- All API calls must use HTTPS
- Implement certificate pinning (optional but recommended)
- API keys should be stored securely in the app

### 9. SwiftUI Support

```swift
import SwiftUI
import NorthlightSDK

struct ContentView: View {
    @State private var showingFeedback = false
    
    var body: some View {
        Button("Send Feedback") {
            showingFeedback = true
        }
        .sheet(isPresented: $showingFeedback) {
            NorthlightFeedbackView()
        }
    }
}
```

### 10. Best Practices

1. **Initialization**: Initialize the SDK as early as possible in the app lifecycle
2. **Error Handling**: Always handle network errors gracefully
3. **User Experience**: Show loading states during API calls
4. **Caching**: Consider caching public feedback/roadmap data
5. **Analytics**: Track SDK usage events for debugging
6. **Testing**: Provide a sandbox/test mode for development

## Example App Structure

```
NorthlightExample/
├── AppDelegate.swift
├── Models/
│   ├── Feedback.swift
│   ├── Bug.swift
│   └── RoadmapItem.swift
├── Services/
│   └── NorthlightService.swift
├── ViewControllers/
│   ├── FeedbackViewController.swift
│   ├── BugReportViewController.swift
│   └── PublicBoardViewController.swift
└── Resources/
    └── Info.plist
```

## Testing

### Unit Tests
- Test all API endpoint integrations
- Test error handling scenarios
- Test data validation
- Test device info collection

### Integration Tests
- Test actual API calls with test API key
- Test rate limiting behavior
- Test network error scenarios

### UI Tests
- Test feedback form submission
- Test bug report form
- Test voting functionality

## SDK Distribution

1. **GitHub Repository**: Public repo with source code
2. **Documentation**: Comprehensive docs with examples
3. **Sample App**: Full example implementation
4. **Changelog**: Version history and migration guides
5. **Support**: GitHub Issues for bug reports

## Versioning

Follow Semantic Versioning (SemVer):
- MAJOR: Breaking API changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes

## License

MIT License (or your preferred open-source license)

## Support

- GitHub Issues: https://github.com/northlight/northlight-ios-sdk/issues
- Documentation: https://docs.northlight.app/ios
- Email: sdk-support@northlight.app