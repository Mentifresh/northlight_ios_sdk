import Foundation

public enum BugSeverity: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

public struct BugSubmission: Codable {
    let title: String
    let description: String
    let severity: BugSeverity
    let stepsToReproduce: String?
    let userEmail: String?
    let deviceInfo: DeviceInfo
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case severity
        case stepsToReproduce = "steps_to_reproduce"
        case userEmail = "user_email"
        case deviceInfo = "device_info"
    }
}

public struct BugResponse: Codable {
    public let success: Bool
    public let bugId: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case bugId = "bug_id"
    }
}