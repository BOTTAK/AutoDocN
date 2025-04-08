import UIKit

final class NewsSceneRouter: NewsSceneRouterProtocol {
    private weak var root: UIViewController?
    private let newsDetailSceneFactory: NewsDetailSceneFactoryProtocol
    private let alertFactory: AlertFactoryProtocol

    init(newsDetailSceneFactory: NewsDetailSceneFactoryProtocol, alertFactory: AlertFactoryProtocol) {
        self.newsDetailSceneFactory = newsDetailSceneFactory
        self.alertFactory = alertFactory
    }

    func openNewsDetail(for deatilNews: DetailNewsSceneUIModel) {
        let detailViewController = newsDetailSceneFactory.makeDetailNewsScene(with: deatilNews)
        root?.navigationController?.pushViewController(detailViewController, animated: true)
    }

    func showAlert(title: String, message: String) {
        let alertController = alertFactory.makeAlert(title: title, message: message)
        root?.navigationController?.topViewController?.present(alertController, animated: true, completion: nil)
    }

    func setRootViewController(root: UIViewController) {
        self.root = root
    }
}
