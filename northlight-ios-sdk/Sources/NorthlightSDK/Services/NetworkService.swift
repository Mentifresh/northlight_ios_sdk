import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
    }
    
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE
    }
    
    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod = .GET,
                               body: Data? = nil,
                               responseType: T.Type) async throws -> T {
        
        let apiKey = try Northlight.shared.getAPIKey()
        let baseURL = Northlight.shared.getBaseURL()
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw NorthlightError.invalidInput("Invalid URL")
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("ios", forHTTPHeaderField: "X-Platform")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NorthlightError.networkError(NSError(domain: "Invalid response", code: 0))
            }
            
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw NorthlightError.decodingError(error)
                }
            case 401, 403:
                // Try to parse error message from response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NorthlightError.invalidInput(errorResponse.error)
                } else {
                    throw NorthlightError.invalidAPIKey
                }
            case 429:
                throw NorthlightError.rateLimitExceeded
            case 402:
                throw NorthlightError.feedbackLimitReached
            case 400:
                // Try to parse error message from response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NorthlightError.invalidInput(errorResponse.error)
                } else {
                    throw NorthlightError.invalidInput("Invalid request")
                }
            default:
                // Try to parse error message from response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NorthlightError.serverError(statusCode: httpResponse.statusCode, message: errorResponse.error)
                } else {
                    throw NorthlightError.serverError(statusCode: httpResponse.statusCode, message: nil)
                }
            }
        } catch let error as NorthlightError {
            throw error
        } catch {
            throw NorthlightError.networkError(error)
        }
    }
    
    func request(_ endpoint: String,
                method: HTTPMethod = .GET,
                body: Data? = nil) async throws {
        
        let apiKey = try Northlight.shared.getAPIKey()
        let baseURL = Northlight.shared.getBaseURL()
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw NorthlightError.invalidInput("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("ios", forHTTPHeaderField: "X-Platform")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NorthlightError.networkError(NSError(domain: "Invalid response", code: 0))
            }
            
            
            switch httpResponse.statusCode {
            case 200...299:
                return
            case 401, 403:
                // Try to parse error message from response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NorthlightError.invalidInput(errorResponse.error)
                } else {
                    throw NorthlightError.invalidAPIKey
                }
            case 429:
                throw NorthlightError.rateLimitExceeded
            case 402:
                throw NorthlightError.feedbackLimitReached
            case 400:
                // Try to parse error message from response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NorthlightError.invalidInput(errorResponse.error)
                } else {
                    throw NorthlightError.invalidInput("Invalid request")
                }
            default:
                // Try to parse error message from response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NorthlightError.serverError(statusCode: httpResponse.statusCode, message: errorResponse.error)
                } else {
                    throw NorthlightError.serverError(statusCode: httpResponse.statusCode, message: nil)
                }
            }
        } catch let error as NorthlightError {
            throw error
        } catch {
            throw NorthlightError.networkError(error)
        }
    }
}