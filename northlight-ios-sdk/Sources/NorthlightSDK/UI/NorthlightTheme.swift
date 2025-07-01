import UIKit
import SwiftUI

struct NorthlightTheme {
    
    // MARK: - Colors
    struct Colors {
        static var primary: UIColor {
            return Northlight.shared.getBrandColor()
        }
        static var primarySwiftUI: Color {
            return Color(primary)
        }
        
        static let accent = UIColor.systemGray
        static let accentSwiftUI = Color.gray
        
        static let background = UIColor.systemBackground
        static let secondaryBackground = UIColor.secondarySystemBackground
        
        static let label = UIColor.label
        static let secondaryLabel = UIColor.secondaryLabel
        static let tertiaryLabel = UIColor.tertiaryLabel
        
        static let separator = UIColor.separator
        static let border = UIColor.systemGray5
        
        static let success = UIColor.systemGreen
        static let error = UIColor.systemRed
        static let warning = UIColor.systemOrange
        
        // Button colors
        static var buttonBackground: UIColor { primary }
        static let buttonText = UIColor.white
        static var buttonBackgroundSwiftUI: Color { primarySwiftUI }
        static let buttonTextSwiftUI = Color.white
        
        // Status colors (pastel versions)
        static let statusPending = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) // Soft gray
        static let statusSuggested = UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0) // Soft orange
        static let statusApproved = UIColor(red: 0.6, green: 0.85, blue: 0.6, alpha: 1.0) // Soft green
        static let statusInProgress = UIColor(red: 0.6, green: 0.7, blue: 0.9, alpha: 1.0) // Soft blue
        static let statusCompleted = UIColor(red: 0.8, green: 0.7, blue: 0.9, alpha: 1.0) // Soft purple
        static let statusRejected = UIColor(red: 0.95, green: 0.7, blue: 0.7, alpha: 1.0) // Soft red
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = UIFont.systemFont(ofSize: 28, weight: .semibold)
        static let title = UIFont.systemFont(ofSize: 20, weight: .medium)
        static let headline = UIFont.systemFont(ofSize: 17, weight: .medium)
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let caption = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let small = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        // SwiftUI
        static let largeTitleSwiftUI = Font.system(size: 28, weight: .semibold)
        static let titleSwiftUI = Font.system(size: 20, weight: .medium)
        static let headlineSwiftUI = Font.system(size: 17, weight: .medium)
        static let bodySwiftUI = Font.system(size: 16, weight: .regular)
        static let captionSwiftUI = Font.system(size: 14, weight: .regular)
        static let smallSwiftUI = Font.system(size: 12, weight: .regular)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let button: CGFloat = 8
        static let input: CGFloat = 8
    }
}

// MARK: - UIKit Extensions

extension UITextField {
    func applyNorthlightStyle() {
        font = NorthlightTheme.Typography.body
        backgroundColor = NorthlightTheme.Colors.secondaryBackground
        layer.cornerRadius = NorthlightTheme.CornerRadius.input
        layer.borderWidth = 1
        layer.borderColor = NorthlightTheme.Colors.border.cgColor
        
        // Remove default border style
        borderStyle = .none
        
        // Add padding with fixed size
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 48))
        leftView = paddingView
        leftViewMode = .always
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 48))
        rightView = rightPaddingView
        rightViewMode = .always
    }
}

extension UITextView {
    func applyNorthlightStyle() {
        font = NorthlightTheme.Typography.body
        backgroundColor = NorthlightTheme.Colors.secondaryBackground
        layer.cornerRadius = NorthlightTheme.CornerRadius.input
        layer.borderWidth = 1
        layer.borderColor = NorthlightTheme.Colors.border.cgColor
        textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
}

extension UIButton {
    func applyNorthlightPrimaryStyle() {
        backgroundColor = NorthlightTheme.Colors.buttonBackground
        setTitleColor(NorthlightTheme.Colors.buttonText, for: .normal)
        titleLabel?.font = NorthlightTheme.Typography.headline
        layer.cornerRadius = NorthlightTheme.CornerRadius.button
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
    
    func applyNorthlightSecondaryStyle() {
        backgroundColor = .clear
        setTitleColor(NorthlightTheme.Colors.primary, for: .normal)
        titleLabel?.font = NorthlightTheme.Typography.body
        layer.borderWidth = 1
        layer.borderColor = NorthlightTheme.Colors.border.cgColor
        layer.cornerRadius = NorthlightTheme.CornerRadius.button
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }
}