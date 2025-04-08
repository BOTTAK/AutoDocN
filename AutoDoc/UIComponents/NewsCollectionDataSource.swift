import UIKit

enum NewsSection {
    case main
}

typealias NewsCollectionDataSource = UICollectionViewDiffableDataSource<NewsSection, NewsSceneUIModel>
typealias NewsCollectionSnapshot = NSDiffableDataSourceSnapshot<NewsSection, NewsSceneUIModel>
