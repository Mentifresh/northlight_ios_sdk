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
    
    /// Presents the public feedback view showing existing feedback with voting
    /// - Parameters:
    ///   - onNewFeedback: Called when user wants to submit new feedback
    ///   - onCancel: Called when the user cancels
    public static func presentPublicFeedback(
        onNewFeedback: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController?.topMostViewController() {
                
                let swiftUIView = PublicFeedbackView(
                    onNewFeedbackSubmitted: { feedbackId in
                        onNewFeedback?()
                    },
                    onCancel: onCancel
                )
                
                let hostingController = UIHostingController(rootView: swiftUIView)
                hostingController.modalPresentationStyle = .fullScreen
                
                topViewController.present(hostingController, animated: true)
            }
        }
    }
    
    /// Presents a bug report form modally
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
                
                let swiftUIView = NorthlightBugReportView(
                    onSuccess: { bugId in
                        onSuccess?(bugId)
                    },
                    onCancel: onCancel,
                    onError: onError
                )
                
                let hostingController = UIHostingController(rootView: swiftUIView)
                hostingController.modalPresentationStyle = .fullScreen
                
                topViewController.present(hostingController, animated: true)
            }
        }
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