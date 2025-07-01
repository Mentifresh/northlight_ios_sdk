import UIKit
import SwiftUI

extension Northlight {
    /// Creates a feedback view controller wrapped in a navigation controller
    /// This method returns a UIKit navigation controller containing the SwiftUI feedback view
    public static func createFeedbackViewController() -> UINavigationController {
        let swiftUIView = NorthlightFeedbackView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        return UINavigationController(rootViewController: hostingController)
    }
    
    /// Creates a bug report view controller wrapped in a navigation controller
    /// This method returns a UIKit navigation controller containing the SwiftUI bug report view
    public static func createBugReportViewController() -> UINavigationController {
        let swiftUIView = NorthlightBugReportView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        return UINavigationController(rootViewController: hostingController)
    }
}