import Foundation

public struct Feedback: Codable {
    public let id: String
    public let projectId: String
    public let title: String
    public let description: String
    public let status: String
    public let category: String?
    public let platform: String?
    public let userEmail: String?
    public let deviceInfo: DeviceInfo?
    public var voteCount: Int
    public let createdAt: String
    public let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case title
        case description
        case status
        case category
        case platform
        case userEmail = "user_email"
        case deviceInfo = "device_info"
        case voteCount = "vote_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Handle missing vote_count in API response
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        projectId = try container.decode(String.self, forKey: .projectId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        status = try container.decode(String.self, forKey: .status)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        platform = try container.decodeIfPresent(String.self, forKey: .platform)
        userEmail = try container.decodeIfPresent(String.self, forKey: .userEmail)
        deviceInfo = try container.decodeIfPresent(DeviceInfo.self, forKey: .deviceInfo)
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? 0
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

public struct FeedbackSubmission: Codable {
    let title: String
    let description: String
    let category: String?
    let userEmail: String?
    let deviceInfo: DeviceInfo
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case category
        case userEmail = "user_email"
        case deviceInfo = "device_info"
    }
}

public struct FeedbackResponse: Codable {
    public let success: Bool
    public let feedbackId: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case feedbackId = "feedback_id"
    }
}

public struct FeedbackListResponse: Codable {
    public let success: Bool
    public let feedback: [Feedback]
}