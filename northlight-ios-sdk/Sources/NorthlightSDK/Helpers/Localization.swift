import Foundation

extension String {
    static func northlightLocalized(_ key: String) -> String {
        return NSLocalizedString(key, bundle: .module, comment: "")
    }
}