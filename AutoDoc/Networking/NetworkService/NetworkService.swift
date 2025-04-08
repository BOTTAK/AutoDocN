import Foundation

public final class NetworkService<EndPoint: EndPointType>: NetworkServiceProtocol {
    let session = URLSession.shared

    public func request(_ rout: EndPoint) async throws -> NetworkResponse {

        do {

            let request = try self.buildRequest(from: rout)
            let (data, response) = try await session.data(for: request)

            guard let networkResponse = NetworkResponse(response: response, data: data) else {
                throw NetworkServiceError.invalidNetworkResponse
            }
            return networkResponse

        } catch {
            throw error
        }
    }

    public func simpleRequest(from urlString: String) async throws -> NetworkResponse {
        guard let requestURL = URL(string: urlString) else {
            throw NetworkServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: requestURL)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkServiceError.invalidNetworkResponse
        }
        return NetworkResponse(statusCode: httpResponse.statusCode, data: data)
    }

// MARK: - Private Methods

    private func buildRequest(from rout: EndPoint) throws -> URLRequest {

        guard let baseURL = URL(string: rout.baseURL) else {
            throw NetworkServiceError.invalidURL
        }

        var request = URLRequest(url: baseURL.appendingPathComponent(rout.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)

        request.httpMethod = rout.httpMethod.rawValue

        do {

            switch rout.task {
            case .request: break
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):

                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)

            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):

                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request

        } catch {
            throw error
        }
    }

    private func configureParameters(bodyParameters: Parameters?,
                                     bodyEncoding: ParameterEncoding,
                                     urlParameters: Parameters?,
                                     request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters,
                                    urlParameters: urlParameters)
        } catch {
            throw error
        }
    }

    private func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
