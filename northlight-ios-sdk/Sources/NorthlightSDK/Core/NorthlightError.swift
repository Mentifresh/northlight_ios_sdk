import Foundation

public enum NorthlightError: LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case rateLimitExceeded
    case feedbackLimitReached
    case invalidInput(String)
    case serverError(statusCode: Int, message: String?)
    case decodingError(Error)
    case missingUserIdentifier
    
    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid or missing API key. Please configure Northlight with a valid API key."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .feedbackLimitReached:
            return "Feedback limit reached for free tier (maximum 5 items)."
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .serverError(let statusCode, let message):
            if let message = message {
                return message
            } else {
                return "Server error with status code: \(statusCode)"
            }
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .missingUserIdentifier:
            return "User identifier is required for this operation."
        }
    }
}