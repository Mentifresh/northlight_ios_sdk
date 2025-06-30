import Foundation

public struct VoteRequest: Codable {
    let userIdentifier: String
    
    enum CodingKeys: String, CodingKey {
        case userIdentifier = "user_identifier"
    }
}

public struct VoteResponse: Codable {
    public let success: Bool
    public let voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case success
        case voteCount = "vote_count"
    }
}