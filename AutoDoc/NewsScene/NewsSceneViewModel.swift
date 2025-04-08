import Foundation
import Combine
import UIKit

final class NewsSceneViewModel: NewsSceneViewModelProtocol {

    private(set) var newsSceneUIModels = CurrentValueSubject<[NewsSceneUIModel], Never>([])
    private(set) var isLoading = CurrentValueSubject<Bool, Never>(false)

    private var dataManger: NewsSceneDataManagerProtocol
    private var router: NewsSceneRouterProtocol
    private var cancellables = Set<AnyCancellable>()

    init(dataManger: NewsSceneDataManagerProtocol, router: NewsSceneRouterProtocol) {
        self.dataManger = dataManger
        self.router = router
        bindDataManager()
    }

    func fetchNews() {
        dataManger.loadNews()
    }

    func fetchImage(urlString: String) -> AnyPublisher<UIImage?, Never> {
        dataManger.fetchImage(urlString: urlString)
            .map { data -> UIImage? in
                if let data = data {
                    return UIImage(data: data)
                }
                return nil
            }
            .eraseToAnyPublisher()
    }

    func openNewsDetail(for news: NewsSceneUIModel, image: UIImage) {

        let (publishedDate, description) = dataManger.getPublishedDateAndDescription(by: news.id) ?? (nil, "")
        let fomatedDate = formatDate(publishedDate)
        let detailNews = DetailNewsSceneUIModel(title: news.title,
                                                publishedDate: fomatedDate,
                                                description: description,
                                                image: image)
        router.openNewsDetail(for: detailNews)
    }

    func cancelImageLoad(urlString: String) {
        dataManger.cancelLoadingImageData(urlString: urlString)
    }

    private func showError(messageError: String) {
        router.showAlert(title: "Error", message: messageError)
    }

    private func toDomainModel(_ news: [NewsDTO]) -> [News] {
        news.map { News(newsDTO: $0) }
    }
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }

    private func bindDataManager() {
        dataManger.news
            .map { news in
                news.map { NewsSceneUIModel(news: $0) }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] news in
                self?.newsSceneUIModels.send(news)
            }
            .store(in: &cancellables)

        dataManger.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool in
                self?.isLoading.send(bool)
            }
            .store(in: &cancellables)

        dataManger.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let message = message else { return }
                self?.showError(messageError: message)
            }
            .store(in: &cancellables)
    }
}
