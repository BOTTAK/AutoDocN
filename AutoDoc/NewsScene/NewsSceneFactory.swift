import UIKit

final class NewsSceneFactory: NewsSceneFactoryProtocol {
    func makeNewsScene() -> UIViewController {

        let networkService = NetworkService<AutoDocAPI>()
        let taskManager = TaskManager()
        let networkDataFetcher = NetworkDataFetcher(networkService: networkService, taskManager: taskManager)
        let cacheService = CacheService()
        let dataManager = NewsSceneDataManager(networkDataFetcher: networkDataFetcher, cacheService: cacheService)
        let router = NewsSceneRouter(newsDetailSceneFactory: NewsDetailSceneFactory(), alertFactory: AlertFactory())
        let viewModel = NewsSceneViewModel(dataManger: dataManager, router: router)
        let viewController = NewsViewController(viewModel: viewModel)
        router.setRootViewController(root: viewController)

        return viewController
    }
}
