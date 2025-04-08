import UIKit

final class NewsDetailSceneViewController: UIViewController {

    // MARK: - Properties

    private let deatilNews: DetailNewsSceneUIModel
    private let detailView = NewsDetailSceneView()

    // MARK: - Initialization

    init(deatilNews: DetailNewsSceneUIModel) {
        self.deatilNews = deatilNews
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        detailView.updateUI(with: deatilNews)
    }
}
