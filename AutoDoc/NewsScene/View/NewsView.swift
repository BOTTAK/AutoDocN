import UIKit
import Combine

final class NewsView: UIView {

    // MARK: - Properties

    var viewModel: NewsSceneViewModelProtocol?

    private(set) var cancellables = Set<AnyCancellable>()
    private(set) var dataSource: NewsCollectionDataSource?

    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.reuseIdentifier)
        collectionView.register(LoadingFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: LoadingFooterView.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        return collectionView
    }()

    // MARK: - Lifecycle

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    func updateFooterVisibility(isLoading: Bool) {
        let footerIndexPath = IndexPath(item: 0, section: 0)
        guard let footer = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionFooter,
            at: footerIndexPath
        ) as? LoadingFooterView else { return }

        if isLoading {
            footer.startAnimating()
        } else {
            footer.stopAnimating()
        }
    }

    func applySnapshot(with items: [NewsSceneUIModel]) {
        var snapshot = NewsCollectionSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot)
    }
}

// MARK: - UICollectionViewDelegate

extension NewsView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let news = viewModel?.newsSceneUIModels.value[indexPath.row] else { return }

        let cell = collectionView.cellForItem(at: indexPath) as? NewsCell
        let image = cell?.getImage()

        viewModel?.openNewsDetail(for: news, image: image ?? UIImage())
    }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.frame.size.height

            if offsetY > contentHeight - scrollViewHeight {
                viewModel?.fetchNews()
            }
        }
}

// MARK: - Private Methods

private extension NewsView {

    func commonInit() {
        backgroundColor = .systemBackground
        setupSubviews()
        setupConstraints()
        configureDataSource()
    }

    func setupSubviews() {
        addSubview(collectionView)

    }

    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - createLayout

    func createLayout() -> UICollectionViewCompositionalLayout {
            return UICollectionViewCompositionalLayout { (_, environment) -> NSCollectionLayoutSection? in
                let spacing: CGFloat = 16
                let columns = self.calculateNumberOfColumns(
                    for: environment.container.effectiveContentSize.width,
                    height: environment.container.effectiveContentSize.height
                )
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(300)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(300)
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitem: item,
                    count: columns
                )
                group.interItemSpacing = .fixed(spacing)
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = spacing
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: spacing,
                    leading: spacing,
                    bottom: spacing,
                    trailing: spacing
                )
                let footerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)
                )
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: footerSize,
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
                section.boundarySupplementaryItems = [footer]
                return section
            }
    }

    // MARK: - Calculate

    func calculateNumberOfColumns(for width: CGFloat, height: CGFloat) -> Int {
             let isLandscape = width > height

             switch width {
             case 1100...:
                 return isLandscape ? 3 : 2
             case 700...:
                 return 2
             default:
                 return isLandscape ? 2 : 1
             }
        }

    // MARK: - configureDataSource

    func configureDataSource() {
        dataSource = NewsCollectionDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, _ in
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NewsCell.reuseIdentifier, for: indexPath
                ) as? NewsCell,

                let self = self,
                let cellModel = self.viewModel?.newsSceneUIModels.value[indexPath.row]
            else {
                return UICollectionViewCell()
            }

            let imagePublisher = cellModel.imageURL.flatMap { self.viewModel?.fetchImage(urlString: $0) }

            cell.configure(
                with: cellModel.title,
                imageURL: cellModel.imageURL,
                imagePublisher: imagePublisher,
                cancelLoad: { [weak self] url in
                    self?.viewModel?.cancelImageLoad(urlString: url)
                }
            )

            return cell
        }
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: LoadingFooterView.reuseIdentifier,
                    for: indexPath) as? LoadingFooterView
                return footer
            }
            return nil
        }
    }
}
