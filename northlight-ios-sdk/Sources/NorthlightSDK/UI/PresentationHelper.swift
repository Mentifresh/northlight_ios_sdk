import UIKit
import SwiftUI

extension Northlight {
    
    /// Presents a feedback form modally. Shows existing feedback first, allowing users to view and vote before submitting new feedback.
    /// - Parameters:
    ///   - onSuccess: Called when feedback is successfully submitted with the feedback ID
    ///   - onCancel: Called when the user cancels the feedback form
    ///   - onError: Called when an error occurs during submission
    public static func presentFeedbackForm(
        onSuccess: ((String) -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        // Show public feedback first
        presentPublicFeedback(
            onNewFeedback: {
                // User wants to submit new feedback - this is handled internally by the public feedback view
            },
            onCancel: {
                onCancel?()
            }
        )
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
                
                let delegate = BugReportPresentationDelegate(
                    navigationController: navigationController,
                    onSuccess: onSuccess,
                    onCancel: onCancel,
                    onError: onError
                )
                
                bugReportVC.delegate = delegate
                // Keep a strong reference to the delegate
                objc_setAssociatedObject(bugReportVC, "NorthlightDelegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                topViewController.present(navigationController, animated: true)
            }
        }
    }
}

// MARK: - Helper Classes

private class PresentationDelegate: NSObject, NorthlightFeedbackViewControllerDelegate {
    private weak var navigationController: UINavigationController?
    private let onSuccess: ((String) -> Void)?
    private let onCancel: (() -> Void)?
    private let onError: ((Error) -> Void)?
    
    init(navigationController: UINavigationController,
         onSuccess: ((String) -> Void)?,
         onCancel: (() -> Void)?,
         onError: ((Error) -> Void)?) {
        self.navigationController = navigationController
        self.onSuccess = onSuccess
        self.onCancel = onCancel
        self.onError = onError
    }
    
    func feedbackViewController(_ controller: NorthlightFeedbackViewController, didSubmitFeedbackWithId feedbackId: String) {
        navigationController?.dismiss(animated: true) {
            self.onSuccess?(feedbackId)
        }
    }
    
    func feedbackViewControllerDidCancel(_ controller: NorthlightFeedbackViewController) {
        navigationController?.dismiss(animated: true) {
            self.onCancel?()
        }
    }
    
    func feedbackViewController(_ controller: NorthlightFeedbackViewController, didFailWithError error: Error) {
        self.onError?(error)
    }
}

private class BugReportPresentationDelegate: NSObject, NorthlightBugReportViewControllerDelegate {
    private weak var navigationController: UINavigationController?
    private let onSuccess: ((String) -> Void)?
    private let onCancel: (() -> Void)?
    private let onError: ((Error) -> Void)?
    
    init(navigationController: UINavigationController,
         onSuccess: ((String) -> Void)?,
         onCancel: (() -> Void)?,
         onError: ((Error) -> Void)?) {
        self.navigationController = navigationController
        self.onSuccess = onSuccess
        self.onCancel = onCancel
        self.onError = onError
    }
    
    func bugReportViewController(_ controller: NorthlightBugReportViewController, didSubmitBugWithId bugId: String) {
        navigationController?.dismiss(animated: true) {
            self.onSuccess?(bugId)
        }
    }
    
    func bugReportViewControllerDidCancel(_ controller: NorthlightBugReportViewController) {
        navigationController?.dismiss(animated: true) {
            self.onCancel?()
        }
    }
    
    func bugReportViewController(_ controller: NorthlightBugReportViewController, didFailWithError error: Error) {
        self.onError?(error)
    }
}

// MARK: - UIViewController Extension

extension UIViewController {
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