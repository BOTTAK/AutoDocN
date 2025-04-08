import Foundation

final class NetworkDataFetcher<Service: NetworkServiceProtocol>: NetworkDataFetcherProtocol
where Service.EndPoint == AutoDocAPI {

    private let networkService: Service
    private let taskManager: TaskManagerProtocol

    init(networkService: Service, taskManager: TaskManagerProtocol) {
        self.networkService = networkService
        self.taskManager = taskManager
    }

    func getNews(currentPage: Int, pageSize: Int) async throws -> NewsResponse {
        let response = try await networkService.request(.getNews(currentPage: currentPage, pageSize: pageSize))

        guard (200...299).contains(response.statusCode) else {
            throw NetworkDataFetcherError.badStatusCode(statusCode: response.statusCode)
        }

        guard let data = response.data else {
            throw NetworkDataFetcherError.noData
        }

        do {
            return try JSONDecoder().decode(NewsResponse.self, from: data)
        } catch {
            throw NetworkDataFetcherError.decodingError(error)
        }
    }

    func fetchImageData(urlString: String) async throws -> Data {
        return try await taskManager.addOrGet(urlString: urlString) { [weak self] in
            let response = try await self?.networkService.simpleRequest(from: urlString)

            guard let response else {
                throw NetworkDataFetcherError.noData
            }

            guard (200...299).contains(response.statusCode) else {
                throw NetworkDataFetcherError.badStatusCode(statusCode: response.statusCode)
            }

            guard let data = response.data else {
                throw NetworkDataFetcherError.noData
            }

            return data
        }
    }

    func cancelLoadingImageData(urlString: String) {
        taskManager.cancel(urlString: urlString)
    }

    func cancelLoadingQueryData() {
        taskManager.cancelAllTasks()
    }
}
