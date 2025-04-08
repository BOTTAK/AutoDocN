import UIKit
import Combine

protocol NewsSceneViewModelProtocol {
    var newsSceneUIModels: CurrentValueSubject<[NewsSceneUIModel], Never> { get }
    var isLoading: CurrentValueSubject<Bool, Never> { get }

    func fetchNews()
    func fetchImage(urlString: String) -> AnyPublisher<UIImage?, Never>
    func openNewsDetail(for news: NewsSceneUIModel, image: UIImage)
    func cancelImageLoad(urlString: String)
}

protocol NewsSceneDataManagerProtocol {
    var news: CurrentValueSubject<[News], Never> { get }
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    var errorMessage: CurrentValueSubject<String?, Never> { get }

    func loadNews()
    func fetchImage(urlString: String) -> AnyPublisher<Data?, Never>
    func cancelLoadingImageData(urlString: String)
    func getPublishedDateAndDescription(by id: Int) -> (Date?, String)?
}

protocol NewsSceneRouterProtocol {
    func openNewsDetail(for detailNews: DetailNewsSceneUIModel)
    func showAlert(title: String, message: String)
}

protocol NewsSceneFactoryProtocol {
    func makeNewsScene() -> UIViewController
}
