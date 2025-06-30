import Foundation

public struct Feedback: Codable {
    public let id: String
    public let title: String
    public let description: String
    public let status: String
    public let category: String?
    public let voteCount: Int
    public let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
        case category
        case voteCount = "vote_count"
        case createdAt = "created_at"
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
    public let feedback: [Feedback]
}