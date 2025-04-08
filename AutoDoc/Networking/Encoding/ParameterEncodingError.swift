import Foundation

public enum ParameterEncodingError: Error, LocalizedError {
    case urlEncodingFailed
    case missingParameters
    case invalidURL
    case jsonEncodingFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .urlEncodingFailed:
            return "URL Encoding Error."
        case .missingParameters:
            return "Missing Parameters Error."
        case .invalidURL:
            return "Invalid URL Error."
        case .jsonEncodingFailed(let underlyingError):
            return "JSON Encoding Error: - \(underlyingError.localizedDescription)."
        }
    }
}
