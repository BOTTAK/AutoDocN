import Foundation
import Combine

final class NewsSceneDataManager: NewsSceneDataManagerProtocol {

    private var currentPage: Int = 1
    private var totalCount: Int = 0

    private(set) var news = CurrentValueSubject<[News], Never>([])
    private(set) var isLoading = CurrentValueSubject<Bool, Never>(false)
    private(set) var errorMessage = CurrentValueSubject<String?, Never>(nil)

    private let pageSize = 15
    private let networkDataFetcher: NetworkDataFetcherProtocol
    private let cacheService: CacheServiceProtocol

    init(networkDataFetcher: NetworkDataFetcherProtocol, cacheService: CacheServiceProtocol) {
        self.networkDataFetcher = networkDataFetcher
        self.cacheService = cacheService
    }

    func loadNews() {

        guard isLoading.value == false,
              news.value.count < totalCount || totalCount == 0 else { return }

        isLoading.send(true)

        Task {
            do {
                let newsResponse = try await networkDataFetcher.getNews(currentPage: currentPage, pageSize: pageSize)
                let newsDTO = toDomainModel(newsResponse.news)

                totalCount = newsResponse.totalCount
                news.send(news.value + newsDTO)
                isLoading.send(false)
                currentPage += 1

            } catch {
                isLoading.send(false)
                errorMessage.send(error.localizedDescription)
            }
        }
    }

    func fetchImage(urlString: String) -> AnyPublisher<Data?, Never> {
        if let cachedImage = cacheService.load(key: urlString) {
            return Just(cachedImage)
                .eraseToAnyPublisher()
        }

        return Future { [weak self] promise in
            Task {
                do {
                    let data = try await self?.networkDataFetcher.fetchImageData(urlString: urlString)
                    if let data = data {
                        self?.cacheService.save(key: urlString, value: data)
                    }
                    DispatchQueue.main.async {
                        promise(.success(data))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.success(nil))
                        print("Ошибка при загрузке изображения: \(error)")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func cancelLoadingImageData(urlString: String) {
        networkDataFetcher.cancelLoadingImageData(urlString: urlString)
    }

    func getPublishedDateAndDescription(by id: Int) -> (Date?, String)? {
        guard let news = news.value.first(where: { $0.id == id }) else {
            return nil
        }
        return (news.publishedDate, news.description)
    }

    private func toDomainModel(_ news: [NewsDTO]) -> [News] {
        news.map { News(newsDTO: $0) }
    }
}
