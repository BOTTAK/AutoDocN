import UIKit

protocol NewsDetailSceneFactoryProtocol {
    func makeDetailNewsScene(with detailNews: DetailNewsSceneUIModel) -> UIViewController
}

final class NewsDetailSceneFactory: NewsDetailSceneFactoryProtocol {
    func makeDetailNewsScene(with detailNews: DetailNewsSceneUIModel) -> UIViewController {
        let viewController = NewsDetailSceneViewController(deatilNews: detailNews)
        return viewController
    }
}
