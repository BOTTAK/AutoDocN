import Foundation

public enum NetworkServiceError: Error, LocalizedError {
    case invalidURL
    case invalidNetworkResponse
    case missingParameters

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL Error."
        case .invalidNetworkResponse:
            return "The server returned an invalid NetworkResponse. Please try again later."
        case .missingParameters:
            return "Some required parameters are missing."
        }
    }
}
