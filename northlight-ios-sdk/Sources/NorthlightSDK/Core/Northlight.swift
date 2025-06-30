import Foundation

public final class Northlight {
    
    public static let shared = Northlight()
    
    private var apiKey: String?
    private var userEmail: String?
    private var userIdentifier: String?
    private var customBaseURL: String?
    
    private let defaultBaseURL = "https://northlight.app/api/v1"
    private let version = "1.0.0"
    
    private init() {}
    
    public static func configure(apiKey: String, baseURL: String? = nil) {
        guard !apiKey.isEmpty else {
            print("[Northlight] Warning: Empty API key provided")
            return
        }
        shared.apiKey = apiKey
        shared.customBaseURL = baseURL
        
        if let baseURL = baseURL {
            print("[Northlight] SDK configured with API key: \(String(apiKey.prefix(8)))... and custom base URL: \(baseURL)")
        } else {
            print("[Northlight] SDK configured with API key: \(String(apiKey.prefix(8)))...")
        }
    }
    
    public func setUserEmail(_ email: String?) {
        userEmail = email
    }
    
    public func setUserIdentifier(_ identifier: String?) {
        userIdentifier = identifier
    }
    
    var isConfigured: Bool {
        return apiKey != nil
    }
    
    func getAPIKey() throws -> String {
        guard let key = apiKey else {
            throw NorthlightError.invalidAPIKey
        }
        return key
    }
    
    func getUserEmail() -> String? {
        return userEmail
    }
    
    func getUserIdentifier() -> String? {
        return userIdentifier
    }
    
    func getBaseURL() -> String {
        if let customBaseURL = customBaseURL {
            // Ensure the URL ends with /api/v1 if it doesn't already
            if customBaseURL.hasSuffix("/api/v1") {
                return customBaseURL
            } else if customBaseURL.hasSuffix("/") {
                return customBaseURL + "api/v1"
            } else {
                return customBaseURL + "/api/v1"
            }
        }
        return defaultBaseURL
    }
    
    func getSDKVersion() -> String {
        return version
    }
}

// MARK: - Public API Methods

extension Northlight {
    
    public static func submitFeedback(title: String,
                                    description: String,
                                    category: String? = nil,
                                    completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let feedbackId = try await submitFeedback(title: title,
                                                         description: description,
                                                         category: category)
                completion(.success(feedbackId))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public static func submitFeedback(title: String,
                                    description: String,
                                    category: String? = nil) async throws -> String {
        guard !title.isEmpty, title.count <= 255 else {
            throw NorthlightError.invalidInput("Title must be between 1 and 255 characters")
        }
        
        guard !description.isEmpty else {
            throw NorthlightError.invalidInput("Description cannot be empty")
        }
        
        let submission = FeedbackSubmission(
            title: title,
            description: description,
            category: category,
            userEmail: shared.getUserEmail(),
            deviceInfo: DeviceInfo.current()
        )
        
        let encoder = JSONEncoder()
        let body = try encoder.encode(submission)
        
        print("[Northlight] Submitting feedback with title: \(title)")
        
        let response = try await NetworkService.shared.request(
            "/feedback",
            method: .POST,
            body: body,
            responseType: FeedbackResponse.self
        )
        
        return response.feedbackId
    }
    
    public static func reportBug(title: String,
                               description: String,
                               severity: BugSeverity = .medium,
                               stepsToReproduce: String? = nil,
                               completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let bugId = try await reportBug(title: title,
                                               description: description,
                                               severity: severity,
                                               stepsToReproduce: stepsToReproduce)
                completion(.success(bugId))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public static func reportBug(title: String,
                               description: String,
                               severity: BugSeverity = .medium,
                               stepsToReproduce: String? = nil) async throws -> String {
        guard !title.isEmpty, title.count <= 255 else {
            throw NorthlightError.invalidInput("Title must be between 1 and 255 characters")
        }
        
        guard !description.isEmpty else {
            throw NorthlightError.invalidInput("Description cannot be empty")
        }
        
        let submission = BugSubmission(
            title: title,
            description: description,
            severity: severity,
            stepsToReproduce: stepsToReproduce,
            userEmail: shared.getUserEmail(),
            deviceInfo: DeviceInfo.current(includeBugReportInfo: true)
        )
        
        let encoder = JSONEncoder()
        let body = try encoder.encode(submission)
        
        let response = try await NetworkService.shared.request(
            "/bugs",
            method: .POST,
            body: body,
            responseType: BugResponse.self
        )
        
        return response.bugId
    }
    
    public static func vote(feedbackId: String,
                          completion: @escaping (Result<Int, Error>) -> Void) {
        Task {
            do {
                let voteCount = try await vote(feedbackId: feedbackId)
                completion(.success(voteCount))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public static func vote(feedbackId: String) async throws -> Int {
        guard let userIdentifier = shared.getUserIdentifier() else {
            throw NorthlightError.missingUserIdentifier
        }
        
        let voteRequest = VoteRequest(userIdentifier: userIdentifier)
        
        let encoder = JSONEncoder()
        let body = try encoder.encode(voteRequest)
        
        let response = try await NetworkService.shared.request(
            "/feedback/\(feedbackId)/vote",
            method: .POST,
            body: body,
            responseType: VoteResponse.self
        )
        
        return response.voteCount
    }
    
    public static func getPublicFeedback(completion: @escaping (Result<[Feedback], Error>) -> Void) {
        Task {
            do {
                let feedback = try await getPublicFeedback()
                completion(.success(feedback))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public static func getPublicFeedback() async throws -> [Feedback] {
        let response = try await NetworkService.shared.request(
            "/feedback",
            responseType: FeedbackListResponse.self
        )
        
        return response.feedback
    }
    
    public static func getRoadmap(completion: @escaping (Result<[RoadmapItem], Error>) -> Void) {
        Task {
            do {
                let roadmap = try await getRoadmap()
                completion(.success(roadmap))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public static func getRoadmap() async throws -> [RoadmapItem] {
        let response = try await NetworkService.shared.request(
            "/roadmap",
            responseType: RoadmapResponse.self
        )
        
        return response.roadmapItems
    }
}