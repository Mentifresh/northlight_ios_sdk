import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
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
            case 429:
                throw NorthlightError.rateLimitExceeded
            case 402:
                throw NorthlightError.feedbackLimitReached
            default:
                throw NorthlightError.serverError(statusCode: httpResponse.statusCode)
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
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NorthlightError.networkError(NSError(domain: "Invalid response", code: 0))
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return
            case 429:
                throw NorthlightError.rateLimitExceeded
            case 402:
                throw NorthlightError.feedbackLimitReached
            default:
                throw NorthlightError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let error as NorthlightError {
            throw error
        } catch {
            throw NorthlightError.networkError(error)
        }
    }
}