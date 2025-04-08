import Foundation

public protocol NetworkServiceProtocol {
    associatedtype EndPoint: EndPointType
    func request(_ rout: EndPoint) async throws -> NetworkResponse
    func simpleRequest(from urlString: String) async throws -> NetworkResponse
}
