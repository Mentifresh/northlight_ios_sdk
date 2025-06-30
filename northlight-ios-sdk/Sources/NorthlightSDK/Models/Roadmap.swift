import Foundation

public struct RoadmapItem: Codable {
    public let id: String
    public let feature: Feature
    public let position: Int
    public let estimatedDate: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case feature
        case position
        case estimatedDate = "estimated_date"
    }
}

public struct Feature: Codable {
    public let title: String
    public let description: String
}

public struct RoadmapResponse: Codable {
    public let roadmapItems: [RoadmapItem]
    
    enum CodingKeys: String, CodingKey {
        case roadmapItems = "roadmap_items"
    }
}