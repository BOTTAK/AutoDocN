import Foundation

enum NetworkDataFetcherError: Error {
    case noData
    case imageAlreadyLoading
    case decodingError(Error)
    case badStatusCode(statusCode: Int)
}
