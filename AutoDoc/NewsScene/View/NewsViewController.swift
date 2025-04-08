import UIKit
import Combine

final class NewsViewController: UIViewController {

    // MARK: - Properties

    private(set) var viewModel: NewsSceneViewModelProtocol?
    private(set) var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var customView = NewsView()

    // MARK: - Initialization

    init(viewModel: NewsSceneViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = customView
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        customView.viewModel = viewModel
        viewModel?.fetchNews()
    }
}

// MARK: - Private Methods

private extension NewsViewController {
    func setup() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "News"
        bindViewModel()
    }

    func bindViewModel() {
        viewModel?.newsSceneUIModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newsSceneUIModels in
                guard let self = self else { return }
                self.customView.applySnapshot(with: newsSceneUIModels)
            }
            .store(in: &cancellables)

        viewModel?.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                self.customView.updateFooterVisibility(isLoading: isLoading)
            }
            .store(in: &cancellables)
    }
}
