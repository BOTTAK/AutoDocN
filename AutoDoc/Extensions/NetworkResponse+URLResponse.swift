import Foundation

public extension NetworkResponse {
    init?(response: URLResponse, data: Data?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }
        self.statusCode = httpResponse.statusCode
        self.data = data
    }
}
