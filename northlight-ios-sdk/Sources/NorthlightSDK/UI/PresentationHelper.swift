import UIKit
import SwiftUI

extension Northlight {
    
    /// Presents a feedback form modally. Automatically detects whether to use UIKit or SwiftUI presentation.
    /// - Parameters:
    ///   - onSuccess: Called when feedback is successfully submitted with the feedback ID
    ///   - onCancel: Called when the user cancels the feedback form
    ///   - onError: Called when an error occurs during submission
    public static func presentFeedbackForm(
        onSuccess: ((String) -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController?.topMostViewController() {
                
                let feedbackVC = NorthlightFeedbackViewController()
                let navigationController = UINavigationController(rootViewController: feedbackVC)
                
                feedbackVC.delegate = PresentationDelegate(
                    onSuccess: { feedbackId in
                        navigationController.dismiss(animated: true) {
                            onSuccess?(feedbackId)
                        }
                    },
                    onCancel: {
                        navigationController.dismiss(animated: true) {
                            onCancel?()
                        }
                    },
                    onError: { error in
                        navigationController.dismiss(animated: true) {
                            onError?(error)
                        }
                    }
                )
                
                topViewController.present(navigationController, animated: true)
            }
        }
    }
    
    /// Presents a bug report form modally. Automatically detects whether to use UIKit or SwiftUI presentation.
    /// - Parameters:
    ///   - onSuccess: Called when bug report is successfully submitted with the bug ID
    ///   - onCancel: Called when the user cancels the bug report form
    ///   - onError: Called when an error occurs during submission
    public static func presentBugReportForm(
        onSuccess: ((String) -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController?.topMostViewController() {
                
                let bugReportVC = NorthlightBugReportViewController()
                let navigationController = UINavigationController(rootViewController: bugReportVC)
                
                bugReportVC.delegate = BugReportPresentationDelegate(
                    onSuccess: { bugId in
                        navigationController.dismiss(animated: true) {
                            onSuccess?(bugId)
                        }
                    },
                    onCancel: {
                        navigationController.dismiss(animated: true) {
                            onCancel?()
                        }
                    },
                    onError: { error in
                        navigationController.dismiss(animated: true) {
                            onError?(error)
                        }
                    }
                )
                
                topViewController.present(navigationController, animated: true)
            }
        }
    }
}

// MARK: - Helper Classes

private class PresentationDelegate: NSObject, NorthlightFeedbackViewControllerDelegate {
    private let onSuccess: (String) -> Void
    private let onCancel: () -> Void
    private let onError: (Error) -> Void
    
    init(onSuccess: @escaping (String) -> Void,
         onCancel: @escaping () -> Void,
         onError: @escaping (Error) -> Void) {
        self.onSuccess = onSuccess
        self.onCancel = onCancel
        self.onError = onError
    }
    
    func feedbackViewController(_ controller: NorthlightFeedbackViewController, didSubmitFeedbackWithId feedbackId: String) {
        onSuccess(feedbackId)
    }
    
    func feedbackViewControllerDidCancel(_ controller: NorthlightFeedbackViewController) {
        onCancel()
    }
    
    func feedbackViewController(_ controller: NorthlightFeedbackViewController, didFailWithError error: Error) {
        onError(error)
    }
}

private class BugReportPresentationDelegate: NSObject, NorthlightBugReportViewControllerDelegate {
    private let onSuccess: (String) -> Void
    private let onCancel: () -> Void
    private let onError: (Error) -> Void
    
    init(onSuccess: @escaping (String) -> Void,
         onCancel: @escaping () -> Void,
         onError: @escaping (Error) -> Void) {
        self.onSuccess = onSuccess
        self.onCancel = onCancel
        self.onError = onError
    }
    
    func bugReportViewController(_ controller: NorthlightBugReportViewController, didSubmitBugWithId bugId: String) {
        onSuccess(bugId)
    }
    
    func bugReportViewControllerDidCancel(_ controller: NorthlightBugReportViewController) {
        onCancel()
    }
    
    func bugReportViewController(_ controller: NorthlightBugReportViewController, didFailWithError error: Error) {
        onError(error)
    }
}

// MARK: - UIViewController Extension

private extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}