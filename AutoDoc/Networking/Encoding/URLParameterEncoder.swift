import Foundation

public struct URLParameterEncoder: ParameterEncoder {
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else {
            throw ParameterEncodingError.invalidURL
        }

        guard !parameters.isEmpty else { return }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw ParameterEncodingError.urlEncodingFailed
        }

        urlComponents.queryItems = parameters.map { key, value in
            URLQueryItem(
                name: key,
                value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            )
        }

        guard let encodedURL = urlComponents.url else {
            throw ParameterEncodingError.urlEncodingFailed
        }
        urlRequest.url = encodedURL

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}
